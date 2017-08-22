//
//  ChartDataEntry+CoreDataProperties.h
//  DashControl
//
//  Created by Manuel Boyer on 23/08/2017.
//  Copyright © 2017 dashfoundation. All rights reserved.
//

#import "ChartDataEntry+CoreDataClass.h"


NS_ASSUME_NONNULL_BEGIN

@interface ChartDataEntry (CoreDataProperties)

+ (NSFetchRequest<ChartDataEntry *> *)fetchRequest;

@property (nonatomic) double close;
@property (nonatomic) int32_t exchange;
@property (nonatomic) double high;
@property (nonatomic) double low;
@property (nonatomic) int32_t market;
@property (nonatomic) double open;
@property (nonatomic) double pairVolume;
@property (nullable, nonatomic, copy) NSDate *time;
@property (nonatomic) int32_t trades;
@property (nonatomic) double volume;

@end

NS_ASSUME_NONNULL_END
