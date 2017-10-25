//
//  DCWalletMasterAddressEntity+CoreDataProperties.h
//  DashControl
//
//  Created by Sam Westrich on 10/24/17.
//  Copyright © 2017 dashfoundation. All rights reserved.
//
//

#import "DCWalletMasterAddressEntity+CoreDataClass.h"


NS_ASSUME_NONNULL_BEGIN

@interface DCWalletMasterAddressEntity (CoreDataProperties)

+ (NSFetchRequest<DCWalletMasterAddressEntity *> *)fetchRequest;

@property (nullable, nonatomic, copy) NSDate *dateAdded;
@property (nullable, nonatomic, copy) NSString *masterBIP32NodeKey;
@property (nullable, nonatomic, copy) NSString *masterBIP44NodeKey;
@property (nullable, nonatomic, copy) NSString *name;
@property (nullable, nonatomic, retain) NSSet<DCWalletAddressEntity *> *walletAddresses;

@end

@interface DCWalletMasterAddressEntity (CoreDataGeneratedAccessors)

- (void)addWalletAddressesObject:(DCWalletAddressEntity *)value;
- (void)removeWalletAddressesObject:(DCWalletAddressEntity *)value;
- (void)addWalletAddresses:(NSSet<DCWalletAddressEntity *> *)values;
- (void)removeWalletAddresses:(NSSet<DCWalletAddressEntity *> *)values;

@end

NS_ASSUME_NONNULL_END
