//
//  DCTriggerEntity+CoreDataProperties.h
//  DashControl
//
//  Created by Sam Westrich on 11/7/17.
//  Copyright © 2017 dashfoundation. All rights reserved.
//
//

#import "DCTriggerEntity+CoreDataClass.h"

NS_ASSUME_NONNULL_BEGIN

@interface DCTriggerEntity (CoreDataProperties)

+ (NSFetchRequest<DCTriggerEntity *> *)fetchRequest;

@property (nonatomic) int64_t conditionalValue;
@property (nonatomic) BOOL consume;
@property (nonatomic) BOOL standardizeTether;
@property (nonatomic) int64_t ignoreFor;
@property (nonatomic) int64_t identifier;
@property (nonatomic) int16_t type;
@property (nonatomic) int64_t value;
@property (nullable, nonatomic, copy) NSString *exchangeNamed;
@property (nullable, nonatomic, copy) NSString *marketNamed;
@property (nullable, nonatomic, retain) DCExchangeEntity *exchange;
@property (nullable, nonatomic, retain) DCMarketEntity *market;

@end

NS_ASSUME_NONNULL_END
