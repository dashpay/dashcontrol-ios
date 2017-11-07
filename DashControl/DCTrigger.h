//
//  DCTrigger.h
//  DashControl
//
//  Created by Sam Westrich on 11/5/17.
//  Copyright © 2017 dashfoundation. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DCTriggerEntity+CoreDataProperties.h"

typedef NS_ENUM(uint16_t,DCTriggerType) {
    DCTriggerUnknown = 0,
    DCTriggerAbove = 1 << 1,
    DCTriggerBelow = 1 << 2,
    DCTriggerForType = 1 << 3,
    DCTriggerAboveFor = DCTriggerForType | DCTriggerAbove,
    DCTriggerBelowFor = DCTriggerForType | DCTriggerBelow,
    DCTriggerSpikeType = 1 << 4,
    DCTriggerSpikeUp = DCTriggerSpikeType | DCTriggerAbove,
    DCTriggerSpikeDown = DCTriggerSpikeType | DCTriggerBelow
};


@interface DCTrigger : NSObject

@property (nonatomic,strong,nonnull) NSNumber * value;
@property (nonatomic,assign) DCTriggerType type;
@property (nonatomic,strong,nonnull) NSString * market;
@property (nonatomic,strong,nonnull) NSString * exchange;
@property (nonatomic,assign) BOOL standardizeTether;

-(id _Nonnull)initWithType:(DCTriggerType)type value:(NSNumber* _Nonnull)value market:(NSString* _Nonnull)market;

+(NSString* _Nonnull)networkStringForType:(DCTriggerType)triggerType;

+(DCTriggerType)typeForNetworkString:(NSString* _Nonnull)networkString;

@end
