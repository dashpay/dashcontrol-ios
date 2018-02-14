//
//  DCWalletAccountEntity+CoreDataProperties.h
//  DashControl
//
//  Created by Sam Westrich on 10/27/17.
//  Copyright © 2017 dashfoundation. All rights reserved.
//
//

#import "DCWalletAccountEntity+CoreDataClass.h"


NS_ASSUME_NONNULL_BEGIN

@interface DCWalletAccountEntity (CoreDataProperties)

+ (NSFetchRequest<DCWalletAccountEntity *> *)fetchRequest;

@property (nullable, nonatomic, copy) NSString *hash160Key;
@property (nullable, nonatomic, retain) NSSet<DCWalletAddressEntity *> *addresses;
@property (nullable, nonatomic, retain) NSSet<DCWalletEntity *> *wallet;

@end

@interface DCWalletAccountEntity (CoreDataGeneratedAccessors)

- (void)addAddressesObject:(DCWalletAddressEntity *)value;
- (void)removeAddressesObject:(DCWalletAddressEntity *)value;
- (void)addAddresses:(NSSet<DCWalletAddressEntity *> *)values;
- (void)removeAddresses:(NSSet<DCWalletAddressEntity *> *)values;

- (void)addWalletObject:(DCWalletEntity *)value;
- (void)removeWalletObject:(DCWalletEntity *)value;
- (void)addWallet:(NSSet<DCWalletEntity *> *)values;
- (void)removeWallet:(NSSet<DCWalletEntity *> *)values;

@end

NS_ASSUME_NONNULL_END
