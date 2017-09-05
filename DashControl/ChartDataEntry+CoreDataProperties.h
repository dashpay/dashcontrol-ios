//
//  ChartDataEntry+CoreDataProperties.h
//  DashControl
//
//  Created by Sam Westrich on 9/4/17.
//  Copyright © 2017 dashfoundation. All rights reserved.
//

#import "ChartDataEntry+CoreDataClass.h"


NS_ASSUME_NONNULL_BEGIN

@interface ChartDataEntry (CoreDataProperties)

+ (NSFetchRequest<ChartDataEntry *> *)fetchRequest;

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
@property (nullable, nonatomic, retain) Exchange *exchange;
@property (nullable, nonatomic, retain) Market *market;

@end

NS_ASSUME_NONNULL_END
