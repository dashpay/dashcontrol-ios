//
//  Created by Andrew Podkovyrin
//  Copyright © 2018 dashfoundation. All rights reserved.
//
//  Licensed under the MIT License (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//  https://opensource.org/licenses/MIT
//
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  See the License for the specific language governing permissions and
//  limitations under the License.
//

#import "ChartViewDataSource.h"

@import Charts;

#import "DCChartDataEntryEntity+CoreDataClass.h"
#import "DCChartDataEntryEntity+Extensions.h"
#import "DCPersistenceStack.h"

NS_ASSUME_NONNULL_BEGIN

static ChartTimeInterval const DATA_TIMEINTERVAL = ChartTimeInterval_5Mins;

@interface ChartViewDataSource ()

@property (nullable, strong, nonatomic) CombinedChartData *chartData;
@property (assign, nonatomic) double leftAxisMinimum;
@property (assign, nonatomic) double leftAxisMaximum;

@end

@implementation ChartViewDataSource

- (instancetype)initWithExchangeIdentifier:(NSInteger)exchangeIdentifier
                          marketIdentifier:(NSInteger)marketIdentifier
                                 startTime:(NSDate *)startTime
                              timeInterval:(ChartTimeInterval)timeInterval {
    self = [super init];
    if (self) {
        weakify;
        [self.stack.persistentContainer performBackgroundTask:^(NSManagedObjectContext *_Nonnull context) {
            NSArray<DCChartDataEntryEntity *> *items = [DCChartDataEntryEntity chartDataForExchangeIdentifier:exchangeIdentifier
                                                                                             marketIdentifier:marketIdentifier
                                                                                                     interval:DATA_TIMEINTERVAL
                                                                                                    startTime:startTime
                                                                                                      endTime:nil
                                                                                                    inContext:context];

            strongify;
            [self processItems:items timeInterval:timeInterval];
        }];
    }
    return self;
}

#pragma mark Private

- (void)processItems:(NSArray<DCChartDataEntryEntity *> *)items timeInterval:(ChartTimeInterval)timeInterval {
    NSParameterAssert(![NSThread isMainThread]);

    if (items.count == 0) {
        dispatch_async(dispatch_get_main_queue(), ^{
            self.chartData = nil;
            [self.updatesDelegate chartViewDataSourceDidFetch:self];
        });

        return;
    }

    NSMutableArray<CandleChartDataEntry *> *candleValues = [NSMutableArray array];
    NSMutableArray<BarChartDataEntry *> *barValues = [NSMutableArray array];
    double leftAxisMinimum = DBL_MAX;
    double leftAxisMaximum = 0.0;

    NSUInteger batchSize = [DCChartTimeFormatter timeIntervalForChartTimeInterval:timeInterval] / [DCChartTimeFormatter timeIntervalForChartTimeInterval:DATA_TIMEINTERVAL];
    NSUInteger totalDataCount = items.count;
    NSUInteger numBatches = totalDataCount / batchSize;
    numBatches += (totalDataCount % batchSize > 0) ? 1 : 0;

    for (NSUInteger batchNumber = 0; batchNumber < numBatches; batchNumber++) {
        NSInteger rangeStart = batchNumber * batchSize;
        NSInteger rangeLength = MIN(batchSize, totalDataCount - batchNumber * batchSize);
        NSRange range = NSMakeRange(rangeStart, rangeLength);
        NSArray<DCChartDataEntryEntity *> *fetchedBatch = [items subarrayWithRange:range];

        double volume = 0.0;
        double high = -DBL_MAX;
        double low = DBL_MAX;
        double open = 0.0;
        double close = 0.0;
        NSDate *date = nil;

        for (NSUInteger i = 0; i < fetchedBatch.count; i++) {
            DCChartDataEntryEntity *entity = fetchedBatch[i];
            if (i == 0) {
                open = entity.open;
            }
            if (i == fetchedBatch.count - 1) {
                close = entity.close;
                date = entity.time;
            }
            double entityLow = entity.low;
            double entityHigh = entity.high;
            if (low > entityLow) {
                low = entityLow;
            }
            if (high < entityHigh) {
                high = entityHigh;
            }
            volume += entity.volume;
        }

        CandleChartDataEntry *candleEntry = [[CandleChartDataEntry alloc] initWithX:batchNumber
                                                                            shadowH:high
                                                                            shadowL:low
                                                                               open:open
                                                                              close:close
                                                                               data:date];
        [candleValues addObject:candleEntry];

        BarChartDataEntry *barEntry = [[BarChartDataEntry alloc] initWithX:batchNumber y:volume];
        [barValues addObject:barEntry];

        if (low < leftAxisMinimum) {
            leftAxisMinimum = low;
        }
        if (high > leftAxisMaximum) {
            leftAxisMaximum = high;
        }
    }

    CandleChartDataSet *candleDataSet = [[CandleChartDataSet alloc] initWithValues:candleValues label:@"Candles"];
    candleDataSet.axisDependency = AxisDependencyLeft;
    [candleDataSet setColor:[UIColor whiteColor]];
    candleDataSet.drawValuesEnabled = NO;
    candleDataSet.shadowColor = [UIColor colorWithWhite:1.0 alpha:0.75];
    candleDataSet.valueTextColor = [UIColor colorWithWhite:1.0 alpha:0.4];
    candleDataSet.shadowWidth = 0.7;
    candleDataSet.decreasingColor = [UIColor colorWithRed:255.0 / 255.0 green:37.0 / 255.0 blue:101.0 / 255.0 alpha:1.0];
    candleDataSet.decreasingFilled = YES;
    candleDataSet.increasingColor = [UIColor colorWithRed:140.0 / 255.0 green:203.0 / 255.f blue:0.0 / 255.f alpha:1.0];
    candleDataSet.increasingFilled = YES;
    candleDataSet.neutralColor = [UIColor whiteColor];

    BarChartDataSet *barDataSet = [[BarChartDataSet alloc] initWithValues:barValues label:@"Bar"];
    barDataSet.axisDependency = AxisDependencyRight;
    [barDataSet setColor:[UIColor colorWithRed:75 / 255.0 green:80 / 255.0 blue:92 / 255.0 alpha:1.0]];
    barDataSet.drawValuesEnabled = NO;

    CombinedChartData *chartData = [[CombinedChartData alloc] init];
    chartData.candleData = [[CandleChartData alloc] initWithDataSet:candleDataSet];
    chartData.barData = [[BarChartData alloc] initWithDataSet:barDataSet];

    double range = MAX(leftAxisMaximum - leftAxisMinimum, 0.0);
    double offset = range * 0.05; // additional 5%

    dispatch_async(dispatch_get_main_queue(), ^{
        self.leftAxisMinimum = MAX(leftAxisMinimum - offset, 0.0);
        self.leftAxisMaximum = leftAxisMaximum + offset;
        self.chartData = chartData;
        [self.updatesDelegate chartViewDataSourceDidFetch:self];
    });
}

@end

NS_ASSUME_NONNULL_END
