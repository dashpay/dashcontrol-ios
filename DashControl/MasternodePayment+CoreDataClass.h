//
//  MasternodePayment+CoreDataClass.h
//  DashControl
//
//  Created by Sam Westrich on 10/3/17.
//  Copyright © 2017 dashfoundation. All rights reserved.
//
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Masternode;

NS_ASSUME_NONNULL_BEGIN

@interface MasternodePayment : NSManagedObject

@end

NS_ASSUME_NONNULL_END

#import "MasternodePayment+CoreDataProperties.h"
