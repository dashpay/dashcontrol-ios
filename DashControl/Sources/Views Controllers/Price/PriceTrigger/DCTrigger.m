//
//  DCTrigger.m
//  DashControl
//
//  Created by Sam Westrich on 11/5/17.
//  Copyright © 2017 dashfoundation. All rights reserved.
//

#import "DCTrigger.h"

NS_ASSUME_NONNULL_BEGIN

@implementation DCTrigger

- (instancetype)initWithType:(DCTriggerType)type value:(NSNumber *)value exchange:(NSString *)exchange market:(NSString *)market {
    self = [super init];
    if (self) {
        _type = type;
        _value = value;
        _exchange = exchange;
        _market = market;
        _standardizeTether = YES;
    }
    return self;
}

+ (NSString *)networkStringForType:(DCTriggerType)triggerType {
    switch (triggerType) {
        case DCTriggerAbove:
            return @"above";
        case DCTriggerBelow:
            return @"below";
        case DCTriggerMovingAverageAbove:
            return @"moving_average_above";
        case DCTriggerMovingAverageBelow:
            return @"moving_average_below";
        case DCTriggerSpikeUp:
            return @"spike_up";
        case DCTriggerSpikeDown:
            return @"spike_down";
        default:
            return nil;
    }
}

+ (DCTriggerType)typeForNetworkString:(NSString *)networkString {
    if ([networkString isEqualToString:@"above"]) {
        return DCTriggerAbove;
    }
    else if ([networkString isEqualToString:@"below"]) {
        return DCTriggerBelow;
    }
    else if ([networkString isEqualToString:@"spike_up"]) {
        return DCTriggerSpikeUp;
    }
    else if ([networkString isEqualToString:@"spike_down"]) {
        return DCTriggerSpikeDown;
    }
    return DCTriggerUnknown;
}

@end

NS_ASSUME_NONNULL_END
