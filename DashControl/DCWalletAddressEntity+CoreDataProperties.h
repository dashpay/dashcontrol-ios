//
//  DCWalletAddressEntity+CoreDataProperties.h
//  DashControl
//
//  Created by Sam Westrich on 10/24/17.
//  Copyright © 2017 dashfoundation. All rights reserved.
//
//

#import "DCWalletAddressEntity+CoreDataClass.h"


NS_ASSUME_NONNULL_BEGIN

@interface DCWalletAddressEntity (CoreDataProperties)

+ (NSFetchRequest<DCWalletAddressEntity *> *)fetchRequest;

@property (nullable, nonatomic, copy) NSString *address;
@property (nonatomic) int64_t amount;
@property (nonatomic) BOOL internal;
@property (nullable, nonatomic, retain) NSData *extendedKeyHash;
@property (nonatomic) int32_t index;
@property (nullable, nonatomic, retain) DCWalletMasterAddressEntity *walletMasterAddress;

@end

NS_ASSUME_NONNULL_END
