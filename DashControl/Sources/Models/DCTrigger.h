//
//  DCTrigger.h
//  DashControl
//
//  Created by Sam Westrich on 11/5/17.
//  Copyright © 2017 dashfoundation. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "DCTriggerEntity+CoreDataProperties.h"

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(uint16_t, DCTriggerType) {
    DCTriggerUnknown = 0,
    DCTriggerAbove = 1 << 1,
    DCTriggerBelow = 1 << 2,
    DCTriggerMovingAverageType = 1 << 3,
    DCTriggerMovingAverageAbove = DCTriggerMovingAverageType | DCTriggerAbove,
    DCTriggerMovingAverageBelow = DCTriggerMovingAverageType | DCTriggerBelow,
    DCTriggerSpikeType = 1 << 4,
    DCTriggerSpikeUp = DCTriggerSpikeType | DCTriggerAbove,
    DCTriggerSpikeDown = DCTriggerSpikeType | DCTriggerBelow
};

@interface DCTrigger : NSObject

@property (readonly, nonatomic, strong) NSNumber *value;
@property (readonly, nonatomic, assign) DCTriggerType type;
@property (readonly, nonatomic, copy) NSString *market;
@property (readonly, nonatomic, copy) NSString *exchange;
@property (readonly, nonatomic, assign) BOOL standardizeTether;

- (instancetype)initWithType:(DCTriggerType)type value:(NSNumber *)value exchange:(NSString *)exchange market:(NSString *)market;
- (instancetype)init NS_UNAVAILABLE;

+ (NSString *)networkStringForType:(DCTriggerType)triggerType;
+ (DCTriggerType)typeForNetworkString:(NSString *)networkString;

@end

NS_ASSUME_NONNULL_END
