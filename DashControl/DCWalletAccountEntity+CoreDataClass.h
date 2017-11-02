//
//  DCWalletAccountEntity+CoreDataClass.h
//  DashControl
//
//  Created by Sam Westrich on 10/27/17.
//  Copyright © 2017 dashfoundation. All rights reserved.
//
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class DCWalletAddressEntity, DCWalletEntity;

NS_ASSUME_NONNULL_BEGIN

@interface DCWalletAccountEntity : NSManagedObject

@end

NS_ASSUME_NONNULL_END

#import "DCWalletAccountEntity+CoreDataProperties.h"
