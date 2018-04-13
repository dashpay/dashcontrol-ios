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

NS_ASSUME_NONNULL_BEGIN

@implementation ChartViewDataSource

- (instancetype)initWithItems:(NSArray<DCChartDataEntryEntity *> *)items timeInterval:(ChartTimeInterval)timeInterval {
    self = [super init];
    if (self) {
        NSAssert(items.count > 0, @"DataSource should have non empty items array");
        if (items.count == 0) {
            _chartData = nil;
        }
        else {
            NSMutableArray<CandleChartDataEntry *> *candleValues = [NSMutableArray array];
            NSMutableArray<BarChartDataEntry *> *barValues = [NSMutableArray array];

            double leftAxisMinimum = DBL_MAX;
            double leftAxisMaximum = 0.0;

            NSUInteger index = 0;
            for (DCChartDataEntryEntity *entity in items) {
                [candleValues addObject:[[CandleChartDataEntry alloc] initWithX:index
                                                                        shadowH:entity.high
                                                                        shadowL:entity.low
                                                                           open:entity.open
                                                                          close:entity.close
                                                                           data:entity.time]];
                [barValues addObject:[[BarChartDataEntry alloc] initWithX:index y:entity.volume]];

                if (entity.low < leftAxisMinimum) {
                    leftAxisMinimum = entity.low;
                }
                if (entity.high > leftAxisMaximum) {
                    leftAxisMaximum = entity.high;
                }
                index += 1;
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
            _leftAxisMinimum = MAX(leftAxisMinimum - offset, 0.0);
            _leftAxisMaximum = leftAxisMaximum + offset;
            _chartData = chartData;
        }
    }
    return self;
}

@end

NS_ASSUME_NONNULL_END
