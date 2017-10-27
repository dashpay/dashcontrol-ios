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
#import "DCWalletMasterAddressEntity+CoreDataClass.h"
#import "DCWalletAccount.h"
#import "DCServerBloomFilter.h"

#define SEC_ATTR_SERVICE      @"org.dashfoundation.dashControl"

@interface DCWalletManager()

@property(nonatomic,strong) NSMutableSet * wallets;

@end

@implementation DCWalletManager

static BOOL setKeychainData(NSData *data, NSString *key, BOOL authenticated)
{
    if (! key) return NO;
    
    id accessible = (authenticated) ? (__bridge id)kSecAttrAccessibleWhenUnlockedThisDeviceOnly
    : (__bridge id)kSecAttrAccessibleAfterFirstUnlockThisDeviceOnly;
    NSDictionary *query = @{(__bridge id)kSecClass:(__bridge id)kSecClassGenericPassword,
                            (__bridge id)kSecAttrService:SEC_ATTR_SERVICE,
                            (__bridge id)kSecAttrAccount:key};
    
    if (SecItemCopyMatching((__bridge CFDictionaryRef)query, NULL) == errSecItemNotFound) {
        if (! data) return YES;
        
        NSDictionary *item = @{(__bridge id)kSecClass: (__bridge id)kSecClassGenericPassword,
                               (__bridge id)kSecAttrService:SEC_ATTR_SERVICE,
                               (__bridge id)kSecAttrAccount:key,
                               (__bridge id)kSecAttrAccessible:accessible,
                               (__bridge id)kSecValueData:data};
        OSStatus status = SecItemAdd((__bridge CFDictionaryRef)item, NULL);
        
        if (status == noErr) return YES;
        NSLog(@"SecItemAdd error: %@",
              [NSError errorWithDomain:NSOSStatusErrorDomain code:status userInfo:nil].localizedDescription);
        return NO;
    }
    
    if (! data) {
        OSStatus status = SecItemDelete((__bridge CFDictionaryRef)query);
        
        if (status == noErr) return YES;
        NSLog(@"SecItemDelete error: %@",
              [NSError errorWithDomain:NSOSStatusErrorDomain code:status userInfo:nil].localizedDescription);
        return NO;
    }
    
    NSDictionary *update = @{(__bridge id)kSecAttrAccessible:accessible,
                             (__bridge id)kSecValueData:data};
    OSStatus status = SecItemUpdate((__bridge CFDictionaryRef)query, (__bridge CFDictionaryRef)update);
    
    if (status == noErr) return YES;
    NSLog(@"SecItemUpdate error: %@",
          [NSError errorWithDomain:NSOSStatusErrorDomain code:status userInfo:nil].localizedDescription);
    return NO;
}


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
        self.wallets = [NSMutableSet set];
    }
    return self;
}

-(void)importWalletMasterAddressFromSource:(NSString*)source withExtended32PublicKey:(NSString*)extended32PublicKey extended44PublicKey:(NSString*)extended44PublicKey completion:(void (^)(BOOL success))completion {
    BOOL valid = [extended32PublicKey isValidDashBIP38Key];
    valid |= [extended44PublicKey isValidDashBIP38Key];
    if (!valid)  {
        if (completion) completion(false);
        return;
    }
    [[(AppDelegate*)[[UIApplication sharedApplication] delegate] persistentContainer] performBackgroundTask:^(NSManagedObjectContext *context) {
        BRBIP32Sequence * sequence = [[BRBIP32Sequence alloc] init];
        NSData * data32 = [sequence deserializedMasterPublicKey:extended32PublicKey];
        NSData * data44 = [sequence deserializedMasterPublicKey:extended44PublicKey];
        NSString * extended32PublicKey = [data32 hash160String];
        NSString * extended44PublicKey = [data44 hash160String];
        
        NSError * error = nil;
        BOOL hasAddress = [[DCCoreDataManager sharedManager] hasWalletMasterAddress:extended32PublicKey inContext:context error:&error];
        if (hasAddress || error) {
            return;
        }
        hasAddress = [[DCCoreDataManager sharedManager] hasWalletMasterAddress:extended44PublicKey inContext:context error:&error];
        if (hasAddress || error) {
            return;
        }
        setKeychainData(data44, extended44PublicKey, NO);
        setKeychainData(data32, extended32PublicKey, NO);
        DCWalletMasterAddressEntity * walletMasterAddress = [NSEntityDescription insertNewObjectForEntityForName:@"WalletMasterAddress" inManagedObjectContext:context];
        walletMasterAddress.masterBIP32NodeKey = extended32PublicKey;
        walletMasterAddress.masterBIP44NodeKey = extended44PublicKey;
        walletMasterAddress.dateAdded = [NSDate date];
        walletMasterAddress.name = source;
        context.automaticallyMergesChangesFromParent = TRUE;
        context.mergePolicy = NSMergeByPropertyStoreTrumpMergePolicy;
        if (![context save:&error]) {
            NSLog(@"Failure to save context: %@\n%@", [error localizedDescription], [error userInfo]);
            setKeychainData(nil, extended44PublicKey, NO);
            setKeychainData(nil, extended32PublicKey, NO);
            if (completion) completion(FALSE);
            return;
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            DCWalletAccount * data32Account = [[DCWalletAccount alloc] initWithAccountPublicKey:data32];
            DCWalletAccount * data44Account = [[DCWalletAccount alloc] initWithAccountPublicKey:data44];
            [self.wallets addObject:data32Account];
            [self.wallets addObject:data32Account];
            [data32Account startUp];
            [data44Account startUp];
            if (completion) completion(TRUE);
        });
    }];
}


- (DCServerBloomFilter *)bloomFilter
{
    NSMutableArray * addresses = [NSMutableArray array];
    for (DCWalletAccount * walletAccount in self.wallets) {
    // every time a new wallet address is added, the bloom filter has to be rebuilt, and each address is only used for
    // one transaction, so here we generate some spare addresses to avoid rebuilding the filter each time a wallet
    // transaction is encountered during the blockchain download
        [addresses addObjectsFromArray:[walletAccount addressesWithGapLimit:SEQUENCE_GAP_LIMIT_EXTERNAL + 100 internal:NO]];
        [addresses addObjectsFromArray:[walletAccount addressesWithGapLimit:SEQUENCE_GAP_LIMIT_INTERNAL + 100 internal:YES]];
    }
    
    
    DCServerBloomFilter *filter = [[DCServerBloomFilter alloc] initWithFalsePositiveRate:BLOOM_REDUCED_FALSEPOSITIVE_RATE
                                                             forElementCount:addresses.count];
    
    for (NSString *addr in addresses) {// add addresses to watch for tx receiveing money to the wallet
        NSData *hash = addr.addressToHash160;
        
        if (hash && ! [filter containsData:hash]) [filter insertData:hash];
    }
    

    return filter;
}

@end
