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

@class DCPersistenceStack;
@class APIPrice;
@class DCExchangeEntity;
@class DCMarketEntity;
@class ChartViewDataSource;

typedef NS_ENUM(NSUInteger, ChartViewModelState) {
    ChartViewModelState_None,
    ChartViewModelState_Loading,
    ChartViewModelState_Done,
};

@interface ChartViewModel : NSObject

@property (strong, nonatomic) InjectedClass(DCPersistenceStack) stack;
@property (strong, nonatomic) InjectedClass(APIPrice) apiPrice;

@property (readonly, assign, nonatomic) ChartViewModelState state;
@property (nullable, readonly, strong, nonatomic) DCExchangeEntity *exchange;
@property (nullable, readonly, strong, nonatomic) DCMarketEntity *market;
@property (readonly, assign, nonatomic) ChartTimeFrame timeFrame;
@property (nullable, readonly, strong, nonatomic) ChartViewDataSource *chartDataSource;

- (nullable NSArray<DCExchangeEntity *> *)availableExchanges;
- (nullable NSArray<DCMarketEntity *> *)availableMarkets;

- (void)selectExchange:(DCExchangeEntity *)exchange;
- (void)selectMarket:(DCMarketEntity *)market;
- (void)selectTimeFrame:(ChartTimeFrame)timeFrame;
- (void)selectTimeInterval:(ChartTimeInterval)timeInterval;

- (void)prefetchInitialChartData;

@end

NS_ASSUME_NONNULL_END
