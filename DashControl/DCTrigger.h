//
//  DCTrigger.h
//  DashControl
//
//  Created by Sam Westrich on 11/5/17.
//  Copyright © 2017 dashfoundation. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DCTriggerEntity+CoreDataProperties.h"

@interface DCTrigger : NSObject

@property (nonatomic,strong) NSNumber * value;
@property (nonatomic,assign) DCTriggerType type;
@property (nonatomic,strong) NSString * market;
@property (nonatomic,strong) NSString * exchange;

-(id)initWithType:(DCTriggerType)type value:(NSNumber* _Nonnull)value market:(NSString* _Nonnull)market;

+(NSString*)networkStringForType:(DCTriggerType)triggerType;

@end
