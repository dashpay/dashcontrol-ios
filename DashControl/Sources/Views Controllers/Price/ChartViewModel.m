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

#import "ChartViewModel.h"

#import <Charts/Charts.h>

#import "DCChartDataEntryEntity+Extensions.h"
#import "DCExchangeEntity+Extensions.h"
#import "DCMarketEntity+Extensions.h"
#import "NSManagedObject+DCExtensions.h"
#import "APIPrice.h"
#import "DCPersistenceStack.h"

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSUInteger, ChartViewModelFetchState) {
    ChartViewModelFetchState_None,
    ChartViewModelFetchState_Fetching,
    ChartViewModelFetchState_Done,
    ChartViewModelFetchState_Error,
};

@interface ChartViewModel ()

@property (assign, nonatomic) ChartViewModelFetchState marketsState;
@property (assign, nonatomic) ChartViewModelFetchState chartPrefetchState;
@property (nullable, strong, nonatomic) NSNumber *currentExchangeIdentifier;
@property (nullable, strong, nonatomic) NSNumber *currentMarketIdentifier;
@property (assign, nonatomic) ChartTimeFrame timeFrame;
@property (assign, nonatomic) ChartTimeInterval timeInterval;
@property (copy, nonatomic) NSArray<NSSortDescriptor *> *defaultSortDescriptors;
@property (assign, nonatomic) BOOL shouldPerformFirstChartDataPrefetch; // controller is loaded, fresh data needed

@property (nullable, strong, nonatomic) DCExchangeEntity *exchange;
@property (nullable, strong, nonatomic) DCMarketEntity *market;
@property (nullable, strong, nonatomic) CombinedChartData *chartData;

@end

@implementation ChartViewModel

+ (NSSet<NSString *> *)keyPathsForValuesAffectingValueForKey:(NSString *)key {
    NSSet *keyPaths = @{
        @"state" : [NSSet setWithArray:@[
            @"marketsState",
            @"chartPrefetchState",
            @"chartData",
        ]],
    }[key];
    return keyPaths ?: [super keyPathsForValuesAffectingValueForKey:key];
}

- (instancetype)init {
    self = [super init];
    if (self) {
        if (self.currentExchangeIdentifier && self.currentMarketIdentifier) {
            NSInteger exchangeIdentifier = self.currentExchangeIdentifier.integerValue;
            NSInteger marketIdentifier = self.currentMarketIdentifier.integerValue;

            NSManagedObjectContext *viewContext = self.stack.persistentContainer.viewContext;
            DCExchangeEntity *exchange = [DCExchangeEntity exchangeWithIdentifier:exchangeIdentifier inContext:viewContext];
            DCMarketEntity *market = [DCMarketEntity marketWithIdentifier:marketIdentifier inContext:viewContext];

            NSAssert(exchange && market, @"");
            if (exchange && market) {
                _exchange = exchange;
                _market = market;
            }
        }

        [self performMarketsFetch];

        _defaultSortDescriptors = @[ [NSSortDescriptor sortDescriptorWithKey:@"name" ascending:YES] ];
    }
    return self;
}

- (ChartViewModelState)state {
    if (self.chartData) {
        return ChartViewModelState_Done;
    }
    else if (self.marketsState == ChartViewModelFetchState_Fetching || self.chartPrefetchState == ChartViewModelFetchState_Fetching) {
        return ChartViewModelState_Loading;
    }
    else {
        return ChartViewModelState_Done;
    }
}

- (void)setExchange:(nullable DCExchangeEntity *)exchange {
    _exchange = exchange;
    self.currentExchangeIdentifier = exchange ? @(exchange.identifier) : nil;
}

- (void)setMarket:(nullable DCMarketEntity *)market {
    _market = market;
    self.currentMarketIdentifier = market ? @(market.identifier) : nil;
}

- (nullable NSArray<DCExchangeEntity *> *)availableExchanges {
    NSManagedObjectContext *viewContext = self.stack.persistentContainer.viewContext;
    NSArray<DCExchangeEntity *> *exchanges = [DCExchangeEntity dc_objectsWithPredicate:nil
                                                                             inContext:viewContext
                                                                 requestConfigureBlock:^(NSFetchRequest *_Nonnull fetchRequest) {
                                                                     fetchRequest.sortDescriptors = self.defaultSortDescriptors;
                                                                 }];
    return exchanges;
}

- (nullable NSArray<DCMarketEntity *> *)availableMarkets {
    NSArray *markets = [self.exchange.markets sortedArrayUsingDescriptors:self.defaultSortDescriptors];
    return markets;
}

- (void)selectExchange:(DCExchangeEntity *)exchange {
    NSParameterAssert(exchange);

    NSSet<DCMarketEntity *> *availableMarketsForExchange = exchange.markets;
    if (![availableMarketsForExchange containsObject:self.market]) {
        NSArray *markets = [availableMarketsForExchange sortedArrayUsingDescriptors:self.defaultSortDescriptors];
        self.market = markets.firstObject;
    }

    self.exchange = exchange;
    self.timeFrame = ChartTimeFrame_6H; // reset time frame to load less data

    [self reloadChartData];
    [self performChartDataFetch];
}

- (void)selectMarket:(DCMarketEntity *)market {
    NSParameterAssert(market);

    self.market = market;
    self.timeFrame = ChartTimeFrame_6H; // reset time frame to load less data

    [self reloadChartData];
    [self performChartDataFetch];
}

- (void)selectTimeFrame:(ChartTimeFrame)timeFrame {
    self.timeFrame = timeFrame;

    [self reloadChartData];
    [self performChartDataFetch];
}

- (void)selectTimeInterval:(ChartTimeInterval)timeInterval {
    self.timeInterval = timeInterval;

    [self reloadChartData];
}

- (void)prefetchInitialChartData {
    self.shouldPerformFirstChartDataPrefetch = YES;

    if (self.marketsState == ChartViewModelFetchState_Fetching) {
        return;
    }

    if (self.marketsState == ChartViewModelFetchState_Error) {
        [self performMarketsFetch];
    }
    else {
        [self reloadChartData];
        [self performFirstChartDataPrefetch];
    }
}

#pragma mark - Private

- (void)performMarketsFetch {
    self.marketsState = ChartViewModelFetchState_Fetching;
    weakify;
    [self.apiPrice fetchMarketsCompletion:^(NSError *_Nullable error, NSInteger defaultExchangeIdentifier, NSInteger defaultMarketIdentifier) {
        strongify;

        if (error) {
            self.marketsState = ChartViewModelFetchState_Error;

            return;
        }

        NSManagedObjectContext *viewContext = self.stack.persistentContainer.viewContext;
        NSInteger exchangeIdentifier = self.currentExchangeIdentifier ? self.currentExchangeIdentifier.integerValue : defaultExchangeIdentifier;
        NSInteger marketIdentifier = self.currentMarketIdentifier ? self.currentMarketIdentifier.integerValue : defaultMarketIdentifier;

        DCExchangeEntity *exchange = [DCExchangeEntity exchangeWithIdentifier:exchangeIdentifier inContext:viewContext];
        DCMarketEntity *market = [DCMarketEntity marketWithIdentifier:marketIdentifier inContext:viewContext];

        NSAssert(exchange && market, @"");
        self.exchange = exchange;
        self.market = market;

        self.marketsState = ChartViewModelFetchState_Done;

        if (self.shouldPerformFirstChartDataPrefetch) {
            [self reloadChartData];
            [self performFirstChartDataPrefetch];
        }
    }];
}

- (void)performFirstChartDataPrefetch {
    NSDate *start = [[NSDate date] dateByAddingTimeInterval:-[self defaultChartDataTimeInterval]];
    [self fetchChartDataForStart:start end:nil completion:nil];
}

- (void)performChartDataFetch {
    NSDate *intervalStart = [APIPrice intervalStartDateForExchangeName:self.exchange.name marketName:self.market.name];
    NSDate *selectedStart = [NSDate dateWithTimeIntervalSinceNow:-[DCChartTimeFormatter timeIntervalForChartTimeFrame:self.timeFrame]];
    if (!intervalStart || [intervalStart compare:selectedStart] == NSOrderedDescending) {
        if (!intervalStart) {
            intervalStart = [NSDate date];
        }
        NSDate *oneWeekBefore = [intervalStart dateByAddingTimeInterval:-[self defaultChartDataTimeInterval]];
        NSDate *start = ([selectedStart compare:oneWeekBefore] == NSOrderedAscending) ? oneWeekBefore : selectedStart;
        weakify;
        [self fetchChartDataForStart:start end:nil completion:^(BOOL success) {
            strongify;

            if (success) {
                [self performChartDataFetch];
            }
        }];
    }
}

- (void)fetchChartDataForStart:(nullable NSDate *)start end:(nullable NSDate *)end completion:(void (^_Nullable)(BOOL success))completion {
    self.chartPrefetchState = ChartViewModelFetchState_Fetching;

    weakify;
    [self.apiPrice fetchChartDataForExchange:self.exchange market:self.market start:start end:end completion:^(BOOL success) {
        strongify;

        if (success) {
            [self reloadChartData];
            self.chartPrefetchState = ChartViewModelFetchState_Done;
        }
        else {
            self.chartPrefetchState = ChartViewModelFetchState_Error;
        }

        if (completion) {
            completion(success);
        }
    }];
}

- (void)reloadChartData {
    if (!self.exchange || !self.market) {
        return;
    }

    NSManagedObjectContext *viewContext = self.stack.persistentContainer.viewContext;
    NSDate *startTime = [NSDate dateWithTimeIntervalSinceNow:-[DCChartTimeFormatter timeIntervalForChartTimeFrame:self.timeFrame]];
    NSArray<DCChartDataEntryEntity *> *items = [DCChartDataEntryEntity chartDataForExchangeIdentifier:self.exchange.identifier
                                                                                     marketIdentifier:self.market.identifier
                                                                                             interval:self.timeInterval
                                                                                            startTime:startTime
                                                                                              endTime:nil
                                                                                            inContext:viewContext];
    if (!items || items.count == 0) {
        self.chartData = nil;

        return;
    }

    NSMutableArray<CandleChartDataEntry *> *candleValues = [NSMutableArray array];

    NSTimeInterval baseTime = items.firstObject.time.timeIntervalSince1970;
    NSTimeInterval selectedTimeInterval = [DCChartTimeFormatter timeIntervalForChartTimeInterval:self.timeInterval];
    for (DCChartDataEntryEntity *entity in items) {
        NSInteger xIndex = (entity.time.timeIntervalSince1970 - baseTime) / selectedTimeInterval;
        [candleValues addObject:[[CandleChartDataEntry alloc] initWithX:xIndex
                                                                shadowH:entity.high
                                                                shadowL:entity.low
                                                                   open:entity.open
                                                                  close:entity.close]];
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

    CombinedChartData *chartData = [[CombinedChartData alloc] init];
    chartData.candleData = [[CandleChartData alloc] initWithDataSet:candleDataSet];
    
    self.chartData = chartData;
}

- (NSNumber *_Nullable)currentExchangeIdentifier {
    return [[NSUserDefaults standardUserDefaults] objectForKey:@"currentExchangeIdentifier"];
}

- (void)setCurrentExchangeIdentifier:(NSNumber *_Nullable)currentExchangeIdentifier {
    [[NSUserDefaults standardUserDefaults] setObject:currentExchangeIdentifier forKey:@"currentExchangeIdentifier"];
}

- (NSNumber *_Nullable)currentMarketIdentifier {
    return [[NSUserDefaults standardUserDefaults] objectForKey:@"currentMarketIdentifier"];
}

- (void)setCurrentMarketIdentifier:(NSNumber *_Nullable)currentMarketIdentifier {
    [[NSUserDefaults standardUserDefaults] setObject:currentMarketIdentifier forKey:@"currentMarketIdentifier"];
}

- (NSTimeInterval)defaultChartDataTimeInterval {
    NSTimeInterval timeInterval = [DCChartTimeFormatter timeIntervalForChartTimeFrame:ChartTimeFrame_1W];
    return timeInterval;
}

@end

NS_ASSUME_NONNULL_END
