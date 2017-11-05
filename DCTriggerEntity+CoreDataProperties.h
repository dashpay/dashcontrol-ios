//
//  DCTriggerEntity+CoreDataProperties.h
//  DashControl
//
//  Created by Sam Westrich on 11/5/17.
//  Copyright © 2017 dashfoundation. All rights reserved.
//
//

#import "DCTriggerEntity+CoreDataClass.h"

typedef NS_ENUM(uint16_t,DCTriggerType) {
    DCTriggerOver,
    DCTriggerUnder
};


NS_ASSUME_NONNULL_BEGIN

@interface DCTriggerEntity (CoreDataProperties)

+ (NSFetchRequest<DCTriggerEntity *> *)fetchRequest;

@property (nonatomic) int64_t value;
@property (nonatomic) int64_t conditionalValue;
@property (nonatomic) int16_t type;
@property (nonatomic) BOOL consume;
@property (nonatomic) int64_t ignoreFor;
@property (nullable, nonatomic, retain) DCExchangeEntity *exchange;
@property (nullable, nonatomic, retain) DCMarketEntity *market;

@end

NS_ASSUME_NONNULL_END
