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

#import "DCChartDataEntryEntity+Extensions.h"
#import "DCChartDataTimeIntervalEntity+Extensions.h"
#import "DCExchangeEntity+Extensions.h"
#import "DCMarketEntity+Extensions.h"
#import "NSManagedObject+DCExtensions.h"
#import "NSManagedObjectContext+DCExtensions.h"
#import "APIPrice.h"
#import "ChartViewDataSource.h"
#import "DCPersistenceStack.h"
#import "TimestampIntervalArray.h"
#import "ExchangeMarketPairObject.h"

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSUInteger, ChartViewModelFetchState) {
    ChartViewModelFetchState_None,
    ChartViewModelFetchState_Fetching,
    ChartViewModelFetchState_Done,
    ChartViewModelFetchState_Error,
};

@interface ChartViewModel ()

@property (assign, nonatomic) ChartViewModelState state;
@property (assign, nonatomic) ChartViewModelFetchState marketsState;
@property (assign, nonatomic) ChartViewModelFetchState chartPrefetchState;
@property (nullable, strong, nonatomic) NSNumber *currentExchangeIdentifier;
@property (nullable, strong, nonatomic) NSNumber *currentMarketIdentifier;
@property (assign, nonatomic) ChartTimeFrame timeFrame;
@property (assign, nonatomic) ChartTimeInterval timeInterval;
@property (copy, nonatomic) NSArray<NSSortDescriptor *> *defaultSortDescriptors;
@property (assign, nonatomic) BOOL shouldPerformFirstChartDataPrefetch; // controller is loaded, fresh data needed
@property (strong, nonatomic) NSMutableArray<TimestampInterval *> *loadPendingIntervals;

@property (nullable, strong, nonatomic) ExchangeMarketPairObject *exchangeMarketPair;
@property (nullable, strong, nonatomic) ChartViewDataSource *chartDataSource;

@end

@implementation ChartViewModel

- (instancetype)init {
    self = [super init];
    if (self) {
        _loadPendingIntervals = [NSMutableArray array];

        if (self.currentExchangeIdentifier && self.currentMarketIdentifier) {
            NSInteger exchangeIdentifier = self.currentExchangeIdentifier.integerValue;
            NSInteger marketIdentifier = self.currentMarketIdentifier.integerValue;

            NSManagedObjectContext *viewContext = self.stack.persistentContainer.viewContext;
            DCExchangeEntity *exchange = [DCExchangeEntity exchangeWithIdentifier:exchangeIdentifier inContext:viewContext];
            DCMarketEntity *market = [DCMarketEntity marketWithIdentifier:marketIdentifier inContext:viewContext];

            NSAssert(exchange && market, @"");
            if (exchange && market) {
                _exchangeMarketPair = [[ExchangeMarketPairObject alloc] initWithExchange:exchange market:market];
            }
        }

        [self performMarketsFetch];

        _defaultSortDescriptors = @[ [NSSortDescriptor sortDescriptorWithKey:@"name" ascending:YES] ];
    }
    return self;
}

- (void)selectExchange:(DCExchangeEntity *)exchange {
    NSParameterAssert(exchange);

    ExchangeMarketPairObject *exchangeMarketPair = self.exchangeMarketPair;
    [exchangeMarketPair selectExchange:exchange];
    self.currentExchangeIdentifier = exchange ? @(exchange.identifier) : nil;
    DCMarketEntity *market = exchangeMarketPair.market;
    self.currentMarketIdentifier = market ? @(market.identifier) : nil;
    
    self.timeFrame = ChartTimeFrame_6H; // reset time frame to load less data

    [self reloadChartData];
    [self performChartDataFetch];
}

- (void)selectMarket:(DCMarketEntity *)market {
    NSParameterAssert(market);

    ExchangeMarketPairObject *exchangeMarketPair = self.exchangeMarketPair;
    [exchangeMarketPair selectMarket:market];
    self.currentMarketIdentifier = market ? @(market.identifier) : nil;
    
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

- (void)setMarketsState:(ChartViewModelFetchState)marketsState {
    _marketsState = marketsState;
    [self updateState];
}

- (void)setChartPrefetchState:(ChartViewModelFetchState)chartPrefetchState {
    _chartPrefetchState = chartPrefetchState;
    [self updateState];
}

- (void)setChartDataSource:(nullable ChartViewDataSource *)chartDataSource {
    _chartDataSource = chartDataSource;
    [self updateState];
}

- (void)updateState {
    if (self.chartDataSource) {
        self.state = ChartViewModelState_Done;
    }
    else if (self.marketsState == ChartViewModelFetchState_Fetching || self.chartPrefetchState == ChartViewModelFetchState_Fetching) {
        self.state = ChartViewModelState_Loading;
    }
    else {
        self.state = ChartViewModelState_Done;
    }
}

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
        self.exchangeMarketPair = [[ExchangeMarketPairObject alloc] initWithExchange:exchange market:market];

        self.marketsState = ChartViewModelFetchState_Done;

        if (self.shouldPerformFirstChartDataPrefetch) {
            [self reloadChartData];
            [self performFirstChartDataPrefetch];
        }
    }];
}

- (void)performFirstChartDataPrefetch {
    NSDate *start = [[NSDate date] dateByAddingTimeInterval:-[self defaultChartDataTimeInterval]];
    [self fetchChartDataForStartDate:start];
}

- (void)performChartDataFetch {
    NSDate *selectedStart = [NSDate dateWithTimeIntervalSinceNow:-[DCChartTimeFormatter timeIntervalForChartTimeFrame:self.timeFrame]];
    NSDate *oneWeekBefore = [[NSDate date] dateByAddingTimeInterval:-[self defaultChartDataTimeInterval]];
    NSDate *start = ([oneWeekBefore compare:selectedStart] == NSOrderedAscending) ? oneWeekBefore : selectedStart;
    [self fetchChartDataForStartDate:start];
}

- (void)fetchChartDataForStartDate:(NSDate *)start {
    NSMutableArray<TimestampInterval *> *intervals = [[self intervalsToLoadForExchange:self.exchangeMarketPair.exchange
                                                                                market:self.exchangeMarketPair.market
                                                                                 start:start] mutableCopy];
    self.loadPendingIntervals = intervals;
    [self fetchChartDataForPendingIntervals];
}

- (void)fetchChartDataForPendingIntervals {
    NSAssert([NSThread isMainThread], nil);

    if (self.loadPendingIntervals.count == 0) {
        return;
    }

    self.chartPrefetchState = ChartViewModelFetchState_Fetching;

    TimestampInterval *interval = self.loadPendingIntervals.lastObject;
    [self.loadPendingIntervals removeLastObject];
    NSUInteger start = interval.start;
    NSUInteger end = interval.end;

    weakify;
    [self.apiPrice fetchChartDataForExchange:self.exchangeMarketPair.exchange market:self.exchangeMarketPair.market start:start end:end completion:^(BOOL success) {
        strongify;

        NSAssert([NSThread isMainThread], nil);

        if (success) {
            [self updateChartDataTimeIntervalsForExchange:self.exchangeMarketPair.exchange market:self.exchangeMarketPair.market start:start end:end];
            [self reloadChartData];
            self.chartPrefetchState = ChartViewModelFetchState_Done;

            // load next portion of data recursively
            [self fetchChartDataForPendingIntervals];
        }
        else {
            self.loadPendingIntervals = [NSMutableArray array];
            self.chartPrefetchState = ChartViewModelFetchState_Error;
        }
    }];
}

- (void)reloadChartData {
    if (!self.exchangeMarketPair.exchange || !self.exchangeMarketPair.market) {
        return;
    }

    NSManagedObjectContext *viewContext = self.stack.persistentContainer.viewContext;
    NSDate *startTime = [NSDate dateWithTimeIntervalSinceNow:-[DCChartTimeFormatter timeIntervalForChartTimeFrame:self.timeFrame]];
    NSArray<DCChartDataEntryEntity *> *items = [DCChartDataEntryEntity chartDataForExchangeIdentifier:self.exchangeMarketPair.exchange.identifier
                                                                                     marketIdentifier:self.exchangeMarketPair.market.identifier
                                                                                             interval:self.timeInterval
                                                                                            startTime:startTime
                                                                                              endTime:nil
                                                                                            inContext:viewContext];
    if (items.count > 0) {
        self.chartDataSource = [[ChartViewDataSource alloc] initWithItems:items timeInterval:self.timeInterval];
    }
    else {
        self.chartDataSource = nil;
    }
}

- (void)updateChartDataTimeIntervalsForExchange:(DCExchangeEntity *)exchange
                                         market:(DCMarketEntity *)market
                                          start:(NSUInteger)start
                                            end:(NSUInteger)end {
    NSInteger exchangeIdentifier = exchange.identifier;
    NSInteger marketIdentifier = market.identifier;

    NSPersistentContainer *container = self.stack.persistentContainer;
    [container performBackgroundTask:^(NSManagedObjectContext *context) {
        context.mergePolicy = NSOverwriteMergePolicy;

        NSArray<DCChartDataTimeIntervalEntity *> *availableIntervals =
            [DCChartDataTimeIntervalEntity timeIntervalsForExchangeIdentifier:exchangeIdentifier
                                                             marketIdentifier:marketIdentifier
                                                                    inContext:context];

        NSMutableArray<TimestampInterval *> *inputIntervals = [NSMutableArray array];
        for (DCChartDataTimeIntervalEntity *interval in availableIntervals) {
            TimestampInterval *ti = [TimestampInterval start:interval.start end:interval.end];
            [inputIntervals addObject:ti];
        }
        TimestampInterval *current = [TimestampInterval start:start end:end];
        [inputIntervals addObject:current];

        NSFetchRequest *fetchRequest = [DCChartDataTimeIntervalEntity fetchRequest];
        fetchRequest.predicate = [DCChartDataTimeIntervalEntity predicateForExchangeIdentifier:exchangeIdentifier marketIdentifier:marketIdentifier];
        NSBatchDeleteRequest *batchDeleteRequest = [[NSBatchDeleteRequest alloc] initWithFetchRequest:fetchRequest];
        batchDeleteRequest.resultType = NSBatchDeleteResultTypeStatusOnly;
        NSError *error = nil;
        [context executeRequest:batchDeleteRequest error:&error];
        if (error) {
            NSAssert(NO, error.description);
            DCDebugLog([self class], @"Failed to delete time intervals %@", error);
        }

        TimestampIntervalArray *intervalArray = [[TimestampIntervalArray alloc] initWithArray:inputIntervals];
        NSArray<TimestampInterval *> *mergedIntervals = intervalArray.mergedOverlappingIntervals;

        for (TimestampInterval *ti in mergedIntervals) {
            DCChartDataTimeIntervalEntity *interval = [[DCChartDataTimeIntervalEntity alloc] initWithContext:context];
            interval.exchangeIdentifier = exchangeIdentifier;
            interval.marketIdentifier = marketIdentifier;
            interval.start = ti.start;
            interval.end = ti.end;
        }

        DCDebugLog([self class], @"Merged intervals %@", mergedIntervals);

        [context dc_saveIfNeeded];
    }];
}

- (NSArray<TimestampInterval *> *)intervalsToLoadForExchange:(DCExchangeEntity *)exchange
                                                      market:(DCMarketEntity *)market
                                                       start:(NSDate *)start {
    NSManagedObjectContext *viewContext = self.stack.persistentContainer.viewContext;
    NSArray<DCChartDataTimeIntervalEntity *> *availableIntervals =
        [DCChartDataTimeIntervalEntity timeIntervalsForExchangeIdentifier:exchange.identifier
                                                         marketIdentifier:market.identifier
                                                                inContext:viewContext];

    NSMutableArray<TimestampInterval *> *inputIntervals = [NSMutableArray array];
    for (DCChartDataTimeIntervalEntity *interval in availableIntervals) {
        TimestampInterval *ti = [TimestampInterval start:interval.start end:interval.end];
        [inputIntervals addObject:ti];
    }
    DCDebugLog([self class], @"Existing intervals %@", inputIntervals);

    TimestampIntervalArray *intervalArray = [[TimestampIntervalArray alloc] initWithArray:inputIntervals];

    NSDate *end = [NSDate date]; // an end date is always 'now'
    TimestampInterval *desired = [TimestampInterval startDate:start endDate:end];
    NSUInteger allowedDistance = [self defaultChartDataTimeInterval];
    NSArray<TimestampInterval *> *emptyGaps = [intervalArray findEmptyGapsDesiredInterval:desired
                                                             maximumAllowedDistanceToJoin:allowedDistance];
    
    NSUInteger maxIntervalLength = (NSUInteger)[self defaultChartDataTimeInterval];
    const NSUInteger minIntervalLength = 60; // 1 min
    NSMutableArray<TimestampInterval *> *splittedEmptyGaps = [NSMutableArray array];
    for (TimestampInterval *interval in emptyGaps) {
        // case with intervals where interval.start == interval.end intentionally ignored
        NSUInteger start = interval.start;
        while (start < interval.end) {
            TimestampInterval *ti = [TimestampInterval start:start end:MIN(start + maxIntervalLength, interval.end)];
            if (ti.end - ti.start > minIntervalLength) {
                [splittedEmptyGaps addObject:ti];
            }
            start = ti.end;
        }
    }
    
    DCDebugLog([self class], @"Gaps to load %@", splittedEmptyGaps);
    
    return [splittedEmptyGaps copy];
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
