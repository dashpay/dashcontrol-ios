//
//  DCWalletAccount.m
//  DashControl
//
//  Created by Sam Westrich on 10/24/17.
//  Copyright © 2017 dashfoundation. All rights reserved.
//

#import "DCWalletAccount.h"
#import "DCServerBloomFilter.h"
#import "BRBIP32Sequence.h"
#import "BRKey.h"
#import "DCWalletAddressEntity+CoreDataProperties.h"
#import "DCWalletAccountEntity+CoreDataProperties.h"

#define SEQUENCE_GAP_LIMIT_EXTERNAL 10
#define SEQUENCE_GAP_LIMIT_INTERNAL 5

@interface DCWalletAccount()

@property (nonatomic,strong) NSData * publicKey;
@property (nonatomic,strong) NSMutableArray * internalAddresses;
@property (nonatomic,strong) NSMutableArray * externalAddresses;
@property (nonatomic,strong) NSMutableArray * usedAddresses;
@property (nonatomic,strong) BRBIP32Sequence * sequence;

@end

@implementation DCWalletAccount


-(id)initWithAccountPublicKey:(NSData*)accountPublicKey hash:(NSString*)hash inContext:(NSManagedObjectContext*)context {
    if (self = [super init]) {
        NSError * error = nil;
        DCWalletAccountEntity * walletAccountEntity = [[DCCoreDataManager sharedInstance] walletAccountWithPublicKeyHash:hash inContext:context error:&error];
        self.publicKey = accountPublicKey;
        self.state = WalletAccountStopped;

        NSArray * previousInternalAddresses = [[walletAccountEntity.addresses filteredSetUsingPredicate:[NSPredicate predicateWithFormat:@"internal == %@",[NSNumber numberWithBool:TRUE]]] sortedArrayUsingDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:@"index" ascending:TRUE]]];
        NSArray * previousExternalAddresses = [[walletAccountEntity.addresses filteredSetUsingPredicate:[NSPredicate predicateWithFormat:@"internal == %@",[NSNumber numberWithBool:FALSE]]] sortedArrayUsingDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:@"index" ascending:TRUE]]];
        self.internalAddresses = [previousInternalAddresses mutableArrayReferencedByKeyPath:@"address"] ;
        self.externalAddresses = [previousExternalAddresses mutableArrayReferencedByKeyPath:@"address"];
        self.usedAddresses = [NSMutableArray array];
        self.sequence = [[BRBIP32Sequence alloc] init];
    }
    return self;
}

// Wallets are composed of chains of addresses. Each chain is traversed until a gap of a certain number of addresses is
// found that haven't been used in any transactions. This method returns an array of <gapLimit> unused addresses
// following the last used address in the chain. The internal chain is used for change addresses and the external chain
// for receive addresses.
- (NSArray * _Nonnull)addressesWithGapLimit:(NSUInteger)gapLimit internal:(BOOL)internal withWalletAccountEntity:(DCWalletAccountEntity*)walletAccountEntity
{
    NSMutableArray *a;
    @synchronized(self) {
        a = [NSMutableArray arrayWithArray:(internal) ? self.internalAddresses : self.externalAddresses];
        NSUInteger i = a.count;
        
        __block unsigned n = (unsigned)i;
        
        // keep only the trailing contiguous block of addresses with no transactions
        while (i > 0 && ! [self.usedAddresses containsObject:a[i - 1]]) {
            i--;
        }
        
        if (i > 0) [a removeObjectsInRange:NSMakeRange(0, i)];
        if (a.count >= gapLimit) return [a subarrayWithRange:NSMakeRange(0, gapLimit)];
        
        __block NSMutableSet * createdAddresses = [NSMutableSet set];
        while (a.count < gapLimit) { // generate new addresses up to gapLimit
            NSData *pubKey = [self.sequence publicKey:n internal:internal masterPublicKey:self.publicKey];
            NSString *addr = [BRKey keyWithPublicKey:pubKey].address;
            
            if (! addr) {
                NSLog(@"error generating keys");
                return nil;
            }
            
            [createdAddresses addObject:@{@"address":addr,@"index":@(n),@"internal":@(internal)}];
            
            [(internal) ? self.internalAddresses : self.externalAddresses addObject:addr];
            [a addObject:addr];
            n++;
        }
        for (NSDictionary * createdAddress in createdAddresses) {
            DCWalletAddressEntity *e = [NSEntityDescription insertNewObjectForEntityForName:@"DCWalletAddressEntity" inManagedObjectContext:walletAccountEntity.managedObjectContext];
            e.address = createdAddress[@"address"];
            e.index = [createdAddress[@"index"] intValue];
            e.internal = [createdAddress[@"internal"] boolValue];
            e.walletAccount = walletAccountEntity;
        }
        NSError * error = nil;
        if (![walletAccountEntity.managedObjectContext save:&error]) {
            NSLog(@"Failure to save context: %@\n%@", [error localizedDescription], [error userInfo]);
        }
    }
    return a;
}

-(void)startUpWithWalletAccountEntity:(DCWalletAccountEntity*)walletAccountEntity {
    self.state = WalletAccountStarting;
    [self addressesWithGapLimit:SEQUENCE_GAP_LIMIT_EXTERNAL internal:NO withWalletAccountEntity:walletAccountEntity];
    [self addressesWithGapLimit:SEQUENCE_GAP_LIMIT_INTERNAL internal:YES withWalletAccountEntity:walletAccountEntity];
}

@end
