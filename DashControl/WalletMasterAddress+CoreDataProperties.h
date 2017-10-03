//
//  WalletMasterAddress+CoreDataProperties.h
//  DashControl
//
//  Created by Sam Westrich on 10/3/17.
//  Copyright © 2017 dashfoundation. All rights reserved.
//
//

#import "WalletMasterAddress+CoreDataClass.h"


NS_ASSUME_NONNULL_BEGIN

@interface WalletMasterAddress (CoreDataProperties)

+ (NSFetchRequest<WalletMasterAddress *> *)fetchRequest;

@property (nullable, nonatomic, retain) NSData *masterBIP32Node;
@property (nullable, nonatomic, retain) NSData *masterBIP44Node;

@end

NS_ASSUME_NONNULL_END
