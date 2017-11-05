//
//  DCTrigger.m
//  DashControl
//
//  Created by Sam Westrich on 11/5/17.
//  Copyright © 2017 dashfoundation. All rights reserved.
//

#import "DCTrigger.h"

@implementation DCTrigger

-(id)initWithType:(DCTriggerType)type value:(NSNumber*)value market:(NSString*)market {
    if (self = [super init]) {
        self.type = type;
        self.value = value;
        self.market = market;
        self.exchange = @"any";
    }
    return self;
}

+(NSString*)networkStringForType:(DCTriggerType)triggerType {
    switch (triggerType) {
        case DCTriggerAbove:
            return @"above";
            break;
        case DCTriggerBelow:
            return @"below";
            break;
        case DCTriggerAboveFor:
            return @"above_for";
            break;
        case DCTriggerBelowFor:
            return @"below_for";
            break;
        case DCTriggerSpikeUp:
            return @"spike_up";
            break;
        case DCTriggerSpikeDown:
            return @"spike_down";
            break;
        default:
            break;
    }
    return nil;
}

@end
