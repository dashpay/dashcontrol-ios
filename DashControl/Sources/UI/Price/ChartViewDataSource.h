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

#import <Foundation/Foundation.h>

#import "DCChartTimeFormatter.h"

NS_ASSUME_NONNULL_BEGIN

@class CombinedChartData;
@class DCChartDataEntryEntity;
@class DCPersistenceStack;
@class ChartViewDataSource;

@protocol ChartViewDataSourceUpdatesDelegate <NSObject>

- (void)chartViewDataSourceDidFetch:(ChartViewDataSource *)dataSource;

@end

@interface ChartViewDataSource : NSObject

@property (strong, nonatomic) InjectedClass(DCPersistenceStack) stack;

@property (readonly, nullable, strong, nonatomic) CombinedChartData *chartData;
@property (readonly, assign, nonatomic) double leftAxisMinimum;
@property (readonly, assign, nonatomic) double leftAxisMaximum;
@property (nullable, weak, nonatomic) id<ChartViewDataSourceUpdatesDelegate> updatesDelegate;

- (instancetype)initWithExchangeIdentifier:(NSInteger)exchangeIdentifier
                          marketIdentifier:(NSInteger)marketIdentifier
                                 startTime:(NSDate *)startTime
                              timeInterval:(ChartTimeInterval)timeInterval;

@end

NS_ASSUME_NONNULL_END
