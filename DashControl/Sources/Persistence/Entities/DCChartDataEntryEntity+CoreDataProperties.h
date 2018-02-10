//
//  DCChartDataEntryEntity+CoreDataProperties.h
//  DashControl
//
//  Created by Sam Westrich on 9/4/17.
//  Copyright © 2017 dashfoundation. All rights reserved.
//

#import "DCChartDataEntryEntity+CoreDataClass.h"


NS_ASSUME_NONNULL_BEGIN

@interface DCChartDataEntryEntity (CoreDataProperties)

+ (NSFetchRequest<DCChartDataEntryEntity *> *)fetchRequest;

@property (nonatomic) double close;
@property (nonatomic) int16_t exchangeIdentifier;
@property (nonatomic) int16_t interval;
@property (nonatomic) double high;
@property (nonatomic) double low;
@property (nonatomic) int16_t marketIdentifier;
@property (nonatomic) double open;
@property (nonatomic) double pairVolume;
@property (nullable, nonatomic, copy) NSDate *time;
@property (nonatomic) int64_t trades;
@property (nonatomic) double volume;
@property (nullable, nonatomic, retain) DCExchangeEntity *exchange;
@property (nullable, nonatomic, retain) DCMarketEntity *market;

@end

NS_ASSUME_NONNULL_END
