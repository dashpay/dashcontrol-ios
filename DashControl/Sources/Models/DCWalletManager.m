//
//  DCWalletManager.m
//  DashControl
//
//  Created by Sam Westrich on 10/23/17.
//  Copyright © 2017 dashfoundation. All rights reserved.
//

#import "DCWalletManager.h"
#import "NSData+Dash.h"
#import "BRBIP32Sequence.h"
#import "NSString+Dash.h"
#import "DCWalletAccountEntity+CoreDataClass.h"
#import "DCWalletAccount.h"
#import "DCWalletEntity+CoreDataClass.h"
#import "DCServerBloomFilter.h"
#import "DCWalletAddressEntity+CoreDataClass.h"
#import "DCWalletAccountEntity+Extensions.h"
#import "NSManagedObject+DCExtensions.h"
#import "DCWalletEntity+Extensions.h"
#import "DCEnvironment.h"
#import "DCPersistenceStack.h"
#import "DCBackendManager.h"

#define SERVER_BLOOM_FILTER_HASH   @"SERVER_BLOOM_FILTER_HASH"

@interface DCWalletManager()

@property(nonatomic,strong) NSMutableSet * wallets;

@end

@implementation DCWalletManager


+ (id)sharedInstance {
    static DCWalletManager *sharedWalletManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedWalletManager = [[self alloc] init];
    });
    return sharedWalletManager;
}

- (id)init {
    if (self = [super init]) {
        
        [self initializeWallets];
        
        
    }
    return self;
}

-(void)initializeWallets {
    self.wallets = [NSMutableSet set];
    [self.stack.persistentContainer performBackgroundTask:^(NSManagedObjectContext *context) {
        NSArray <DCWalletAccountEntity *> * accountEntities = [DCWalletAccountEntity dc_objectsInContext:context];
            for (DCWalletAccountEntity * accountEntity in accountEntities) {
                NSString * locationInKeyValueStore = accountEntity.hash160Key;
                NSError * error = nil;
                NSData * pubkeyData = [[DCEnvironment sharedInstance] getKeychainDataForKey:locationInKeyValueStore error:&error];
                DCWalletAccount * walletAccount = [[DCWalletAccount alloc] initWithAccountPublicKey:pubkeyData hash:locationInKeyValueStore inContext:context];
                [self.wallets addObject:walletAccount];
                [walletAccount startUpWithWalletAccountEntity:accountEntity];
            }
            [self updateBloomFilterInContext:context];
    }];
}

-(void)importWalletMasterAddressFromSource:(NSString*)source withExtended32PublicKey:(NSString*)extended32PublicKey extended44PublicKey:(NSString*)extended44PublicKey {
    BOOL valid = ([extended32PublicKey isValidDashSerializedPublicKey] || [extended44PublicKey isValidDashSerializedPublicKey]);
    
    if (!valid)  {
        return;
    }
    [self.stack.persistentContainer performBackgroundTask:^(NSManagedObjectContext *context) {
        BRBIP32Sequence * sequence = [[BRBIP32Sequence alloc] init];
        NSData * data32 = [sequence deserializedMasterPublicKey:extended32PublicKey];
        NSData * data44 = [sequence deserializedMasterPublicKey:extended44PublicKey];
        NSString * extended32PublicKeyHash = [data32 hash160String];
        NSString * extended44PublicKeyHash = [data44 hash160String];
        
        DCWalletAccountEntity * wallet32Account;
        DCWalletAccountEntity * wallet44Account;
        NSError * error = nil;
        BOOL has32Account = [DCWalletAccountEntity hasWalletAccountForPublicKeyHash:extended32PublicKeyHash inContext:context];
        if (!has32Account) {
            wallet32Account = [NSEntityDescription insertNewObjectForEntityForName:@"DCWalletAccountEntity" inManagedObjectContext:context];
            wallet32Account.hash160Key = extended32PublicKeyHash;
            [[DCEnvironment sharedInstance] setKeychainData:data32 forKey:extended32PublicKeyHash authenticated:NO];
        }
        
        BOOL has44Account = [DCWalletAccountEntity hasWalletAccountForPublicKeyHash:extended44PublicKeyHash inContext:context];
        if (!has44Account) {
            wallet44Account = [NSEntityDescription insertNewObjectForEntityForName:@"DCWalletAccountEntity" inManagedObjectContext:context];
            wallet44Account.hash160Key = extended44PublicKeyHash;
            [[DCEnvironment sharedInstance] setKeychainData:data44 forKey:extended44PublicKeyHash authenticated:NO];
        }
        
        if (has44Account && has32Account) {
            //we already have both accounts
            return;
        }
        
        DCWalletEntity * wallet;
        if (has32Account || has44Account) {
            wallet = [DCWalletEntity walletHavingOneOfAccounts:@[wallet32Account,wallet44Account] withIdentifier:source inContext:context];
            if (![wallet.accounts containsObject:wallet44Account]) {
                [wallet addAccountsObject:wallet44Account];
            }
            if (![wallet.accounts containsObject:wallet32Account]) {
                [wallet addAccountsObject:wallet32Account];
            }
        }
        
        if (!wallet) {
            wallet = [NSEntityDescription insertNewObjectForEntityForName:@"DCWalletEntity" inManagedObjectContext:context];
            [wallet addAccountsObject:wallet32Account];
            [wallet addAccountsObject:wallet44Account];
            wallet.dateAdded = [NSDate date];
            wallet.name = source;
            wallet.identifier = source;
        }
        context.automaticallyMergesChangesFromParent = TRUE;
        context.mergePolicy = NSMergeByPropertyStoreTrumpMergePolicy;
        if (![context save:&error]) {
            NSLog(@"Failure to save context: %@\n%@", [error localizedDescription], [error userInfo]);
            return;
        }

            if (!has32Account) {
                DCWalletAccount * data32Account = [[DCWalletAccount alloc] initWithAccountPublicKey:data32 hash:extended32PublicKeyHash inContext:context];
                [self.wallets addObject:data32Account];
                [data32Account startUpWithWalletAccountEntity:wallet32Account];
                
            }
            if (!has44Account) {
                DCWalletAccount * data44Account = [[DCWalletAccount alloc] initWithAccountPublicKey:data44 hash:extended44PublicKeyHash inContext:context];
                [self.wallets addObject:data44Account];
                [data44Account startUpWithWalletAccountEntity:wallet44Account];
            }
            
            [self updateBloomFilterInContext:context];
    }];
}

-(void)updateBloomFilterInContext:(NSManagedObjectContext*)context {
    NSError * error = nil;
    NSArray * walletAddressEntities = [DCWalletAddressEntity dc_objectsInContext:context];
    if (!error && [walletAddressEntities count]) {
        NSArray * walletAddresses = [walletAddressEntities arrayReferencedByKeyPath:@"address"];
        DCServerBloomFilter * bloomFilter = [self bloomFilterForAddresses:walletAddresses];
        NSData * bloomFilterHashData = [NSData dataWithUInt160:bloomFilter.filterHash];
        NSData * previousBloomFilterHashData = [[DCEnvironment sharedInstance] getKeychainDataForKey:SERVER_BLOOM_FILTER_HASH error:&error];
        if (!previousBloomFilterHashData || ![bloomFilterHashData isEqualToData:previousBloomFilterHashData]) {
            [[DCBackendManager sharedInstance] updateBloomFilter:bloomFilter completion:^(NSError * _Nullable error) {
                if (!error) {
                    [[DCEnvironment sharedInstance] setKeychainData:bloomFilterHashData forKey:SERVER_BLOOM_FILTER_HASH authenticated:NO];
                }
            }];
        }
    }
}

- (DCServerBloomFilter *)bloomFilterForAddresses:(NSArray*)addresses
{
    DCServerBloomFilter *filter = [[DCServerBloomFilter alloc] initWithFalsePositiveRate:BLOOM_REDUCED_FALSEPOSITIVE_RATE
                                                                         forElementCount:addresses.count];
    // double fpRate = [filter falsePositiveRate];
    for (NSString *addr in addresses) {// add addresses to watch for tx receiveing money to the wallet
        NSData *hash = addr.addressToHash160;
        
        if (hash && ! [filter containsData:hash]) [filter insertData:hash];
    }
    return filter;
}

@end
