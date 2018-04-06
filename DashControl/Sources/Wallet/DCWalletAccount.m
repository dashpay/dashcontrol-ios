//
//  DCWalletAccount.m
//  DashControl
//
//  Created by Sam Westrich on 10/24/17.
//  Copyright © 2017 dashfoundation. All rights reserved.
//

#import "DCWalletAccount.h"

#import "DCWalletAccountEntity+CoreDataProperties.h"
#import "DCWalletAccountEntity+Extensions.h"
#import "DCWalletAddressEntity+CoreDataProperties.h"
#import "BRBIP32Sequence.h"
#import "BRKey.h"
#import "DCServerBloomFilter.h"

NS_ASSUME_NONNULL_BEGIN

#define SEQUENCE_GAP_LIMIT_EXTERNAL 10
#define SEQUENCE_GAP_LIMIT_INTERNAL 5

@interface DCWalletAccount ()

@property (assign, nonatomic) WalletAccountState state;
@property (strong, nonatomic) NSData *publicKey;
@property (strong, nonatomic) NSMutableArray *internalAddresses;
@property (strong, nonatomic) NSMutableArray *externalAddresses;
@property (strong, nonatomic) NSMutableArray *usedAddresses;
@property (strong, nonatomic) BRBIP32Sequence *sequence;

@end

@implementation DCWalletAccount

- (instancetype)initWithAccountPublicKey:(NSData *)accountPublicKey
                                    hash:(nullable NSString *)hash
                               inContext:(NSManagedObjectContext *)context {
    self = [super init];
    if (self) {
        DCWalletAccountEntity *walletAccountEntity = nil;
        NSArray<DCWalletAddressEntity *> *previousInternalAddresses = nil;
        NSArray<DCWalletAddressEntity *> *previousExternalAddresses = nil;
        if (hash) {
            walletAccountEntity = [DCWalletAccountEntity walletAccountForPublicKeyHash:hash inContext:context];

            NSArray *sortDescriptors = @[ [NSSortDescriptor sortDescriptorWithKey:@"index" ascending:YES] ];
            NSPredicate *internalPredicate = [NSPredicate predicateWithFormat:@"internal == %@", @YES];
            NSPredicate *externalPredicate = [NSPredicate predicateWithFormat:@"internal == %@", @NO];
            previousInternalAddresses = [[walletAccountEntity.addresses filteredSetUsingPredicate:internalPredicate]
                sortedArrayUsingDescriptors:sortDescriptors];
            previousExternalAddresses = [[walletAccountEntity.addresses filteredSetUsingPredicate:externalPredicate]
                sortedArrayUsingDescriptors:sortDescriptors];
        }
        if (!previousInternalAddresses) {
            previousInternalAddresses = [NSArray array];
        }
        if (!previousExternalAddresses) {
            previousExternalAddresses = [NSArray array];
        }
        self.publicKey = accountPublicKey;
        self.state = WalletAccountStopped;

        self.internalAddresses = [previousInternalAddresses mutableArrayReferencedByKeyPath:@"address"];
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
- (NSArray *)addressesWithGapLimit:(NSUInteger)gapLimit internal:(BOOL)internal withWalletAccountEntity:(nullable DCWalletAccountEntity *)walletAccountEntity {
    NSMutableArray *a;
    @synchronized(self) {
        a = [NSMutableArray arrayWithArray:(internal) ? self.internalAddresses : self.externalAddresses];
        NSUInteger i = a.count;
        uint32_t n = (uint32_t)i;

        // keep only the trailing contiguous block of addresses with no transactions
        while (i > 0 && ![self.usedAddresses containsObject:a[i - 1]]) {
            i--;
        }

        if (i > 0) {
            [a removeObjectsInRange:NSMakeRange(0, i)];
        }
        if (a.count >= gapLimit) {
            return [a subarrayWithRange:NSMakeRange(0, gapLimit)];
        }

        NSMutableSet *createdAddresses = [NSMutableSet set];
        while (a.count < gapLimit) { // generate new addresses up to gapLimit
            NSData *pubKey = [self.sequence publicKey:n internal:internal masterPublicKey:self.publicKey];
            NSString *addr = [BRKey keyWithPublicKey:pubKey].address;
            if (!addr) {
                DCDebugLog(self.class, @"error generating keys");
                return @[];
            }

            [createdAddresses addObject:@{
                @"address" : addr,
                @"index" : @(n),
                @"internal" : @(internal),
            }];

            [(internal) ? self.internalAddresses : self.externalAddresses addObject:addr];
            [a addObject:addr];
            n++;
        }
        if (walletAccountEntity) {
            for (NSDictionary *createdAddress in createdAddresses) {
                DCWalletAddressEntity *e = [NSEntityDescription insertNewObjectForEntityForName:@"DCWalletAddressEntity" inManagedObjectContext:walletAccountEntity.managedObjectContext];
                e.address = createdAddress[@"address"];
                e.index = [createdAddress[@"index"] intValue];
                e.internal = [createdAddress[@"internal"] boolValue];
                e.walletAccount = walletAccountEntity;
            }
            NSError *error = nil;
            if (![walletAccountEntity.managedObjectContext save:&error]) {
                NSLog(@"Failure to save context: %@\n%@", [error localizedDescription], [error userInfo]);
            }
        }
    }
    return a;
}

- (void)startUpWithWalletAccountEntity:(DCWalletAccountEntity *)walletAccountEntity {
    self.state = WalletAccountStarting;
    [self addressesWithGapLimit:SEQUENCE_GAP_LIMIT_EXTERNAL internal:NO withWalletAccountEntity:walletAccountEntity];
    [self addressesWithGapLimit:SEQUENCE_GAP_LIMIT_INTERNAL internal:YES withWalletAccountEntity:walletAccountEntity];
}

@end

NS_ASSUME_NONNULL_END
