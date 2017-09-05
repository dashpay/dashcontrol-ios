//
//  Market+CoreDataClass.h
//  DashControl
//
//  Created by Sam Westrich on 9/4/17.
//  Copyright © 2017 dashfoundation. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class ChartDataEntry, Exchange;

NS_ASSUME_NONNULL_BEGIN

@interface Market : NSManagedObject

@end

NS_ASSUME_NONNULL_END

#import "Market+CoreDataProperties.h"
