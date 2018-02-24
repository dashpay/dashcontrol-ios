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

#import "APIPrice.h"

#import "DCChartDataEntryEntity+Extensions.h"
#import "DCExchangeEntity+Extensions.h"
#import "DCMarketEntity+Extensions.h"
#import "NSManagedObjectContext+DCExtensions.h"
#import "DCPersistenceStack.h"
#import "Networking.h"

NS_ASSUME_NONNULL_BEGIN

#define USE_PRODUCTION 1

#ifdef USE_PRODUCTION
static NSString *const API_BASE_URL = @"https://dashpay.info/api/v0/";
#else
static NSString *const API_BASE_URL = @"https://dev.dashpay.info/api/v0/";
#endif

#define KEY_NAME @"name"

@interface APIPrice ()

@property (strong, nonatomic) NSDateFormatter *dateFormatter;

@end

@implementation APIPrice

- (instancetype)init {
    self = [super init];
    if (self) {
        _dateFormatter = [[NSDateFormatter alloc] init];
        _dateFormatter.dateFormat = @"yyyy-MM-dd'T'HH:mm:ss.SSSZ";
        _dateFormatter.locale = [NSLocale localeWithLocaleIdentifier:@"en_US_POSIX"];
        _dateFormatter.timeZone = [NSTimeZone timeZoneWithAbbreviation:@"UTC"];
    }
    return self;
}

- (id<HTTPLoaderOperationProtocol>)fetchMarketsCompletion:(void (^)(NSError *_Nullable error, NSInteger defaultExchangeIdentifier, NSInteger defaultMarketIdentifier))completion {
    NSString *urlString = [API_BASE_URL stringByAppendingString:@"markets"];
    NSURL *url = [NSURL URLWithString:urlString];
    HTTPRequest *request = [HTTPRequest requestWithURL:url method:HTTPRequestMethod_GET parameters:nil];
    return [self.httpManager sendRequest:request completion:^(id _Nullable parsedData, NSDictionary *_Nullable responseHeaders, NSInteger statusCode, NSError *_Nullable error) {
        if (error) {
            if (completion) {
                completion(error, NSNotFound, NSNotFound);
            }

            return;
        }

        NSPersistentContainer *container = self.stack.persistentContainer;
        [container performBackgroundTask:^(NSManagedObjectContext *context) {
            DCMarketEntity *defaultMarket = nil;
            DCExchangeEntity *defaultExchange = nil;
            NSString *defaultMarketName = nil;
            NSString *defaultExchangeName = nil;
            if (parsedData[@"default"]) {
                NSDictionary *defaultMarketplace = parsedData[@"default"];
                if (defaultMarketplace[@"exchange"] && defaultMarketplace[@"market"]) {
                    defaultMarketName = defaultMarketplace[@"market"];
                    defaultExchangeName = defaultMarketplace[@"exchange"];
                }
            }

            if (parsedData[@"markets"]) {
                NSArray<NSString *> *markets = [parsedData[@"markets"] allKeys];
                NSArray<NSString *> *exchanges = [[parsedData[@"markets"] allValues] valueForKeyPath:@"@distinctUnionOfArrays.self"];
                NSMutableArray<DCMarketEntity *> *knownMarkets = [[DCMarketEntity marketsForNames:markets inContext:context] mutableCopy];
                NSMutableArray<DCExchangeEntity *> *knownExchanges = knownMarkets ? [[DCExchangeEntity exchangesForNames:exchanges inContext:context] mutableCopy] : nil;

                if (knownMarkets) {
                    NSArray<NSString *> *novelMarkets = [markets arrayByRemovingObjectsFromArray:[knownMarkets arrayReferencedByKeyPath:KEY_NAME]];
                    if (novelMarkets.count > 0) {
                        NSInteger marketIdentifier = [DCMarketEntity autoIncrementIDInContext:context];
                        for (NSString *marketName in novelMarkets) {
                            DCMarketEntity *market = [[DCMarketEntity alloc] initWithContext:context];
                            market.identifier = marketIdentifier;
                            market.name = marketName;
                            marketIdentifier++;
                            [knownMarkets addObject:market];
                        }
                    }
                }

                if (knownExchanges) {
                    NSArray<NSString *> *novelExchanges = [exchanges arrayByRemovingObjectsFromArray:[knownExchanges arrayReferencedByKeyPath:KEY_NAME]];
                    if (novelExchanges.count > 0) {
                        NSInteger exchangeIdentifier = [DCExchangeEntity autoIncrementIDInContext:context];
                        for (NSString *exchangeName in novelExchanges) {
                            DCExchangeEntity *exchange = [[DCExchangeEntity alloc] initWithContext:context];
                            exchange.identifier = exchangeIdentifier;
                            exchange.name = exchangeName;
                            exchangeIdentifier++;
                            [knownExchanges addObject:exchange];
                        }
                    }
                }

                defaultMarket = [[knownMarkets filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"name == %@", defaultMarketName]] firstObject];
                defaultExchange = [[knownExchanges filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"name == %@", defaultExchangeName]] firstObject];

                context.mergePolicy = NSRollbackMergePolicy;
                BOOL saveResult = [context dc_saveIfNeeded];

                //now let's make sure all the relationships are correct
                if (saveResult) {
                    NSDictionary *exchangeDictionary = [knownExchanges dictionaryReferencedByKeyPath:KEY_NAME];
                    for (DCMarketEntity *market in knownMarkets) {
                        NSArray<NSString *> *serverExchangesForMarket = parsedData[@"markets"][market.name];
                        NSArray<NSString *> *knownExchangesForMarket = [market.onExchanges.allObjects arrayReferencedByKeyPath:KEY_NAME];
                        NSArray<NSString *> *novelExchangesForMarket = [serverExchangesForMarket arrayByRemovingObjectsFromArray:knownExchangesForMarket];
                        for (NSString *novelExchangeForMarket in novelExchangesForMarket) {
                            DCExchangeEntity *exchange = exchangeDictionary[novelExchangeForMarket];
                            [market addOnExchangesObject:exchange];
                        }
                    }

                    [context dc_saveIfNeeded];
                }

                NSInteger defaultExhangeIdentifier = NSNotFound;
                NSInteger defaultMarketIdentifier = NSNotFound;
                if (defaultExchange && defaultMarket) {
                    defaultExhangeIdentifier = defaultExchange.identifier;
                    defaultMarketIdentifier = defaultMarket.identifier;
                }

                dispatch_async(dispatch_get_main_queue(), ^{
                    completion(nil, defaultExhangeIdentifier, defaultMarketIdentifier);
                });
            }
        }];
    }];
}

- (id<HTTPLoaderOperationProtocol>)fetchChartDataForExchange:(DCExchangeEntity *)exchange
                                                      market:(DCMarketEntity *)market
                                                       start:(nullable NSDate *)start
                                                         end:(nullable NSDate *)end
                                                  completion:(void (^)(BOOL success))completion {
    NSParameterAssert(exchange);
    NSParameterAssert(market);
    NSAssert(start || end, @"You can not supply both start and end");

    NSString *exchangeName = exchange.name;
    NSString *marketName = market.name;
    NSInteger exchangeIdentifier = exchange.identifier;
    NSInteger marketIdentifier = market.identifier;

    NSString *urlString = [API_BASE_URL stringByAppendingString:@"chart_data"];
    NSURL *url = [NSURL URLWithString:urlString];

    NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
    parameters[@"market"] = marketName;
    parameters[@"exchange"] = exchangeName;
#ifdef DEBUG
    parameters[@"noLimit"] = @"1";
#endif

    NSDate *intervalStart = [[self class] intervalStartDateForExchangeName:exchangeName marketName:marketName];
    NSDate *intervalEnd = [[self class] intervalEndDateForExchangeName:exchangeName marketName:marketName];
    NSDate *realStart = nil;
    NSDate *realEnd = nil;
    NSDate *knownDataStart = nil;
    NSDate *knownDataEnd = nil;
    if (start) {
        // if start is set it must be before interval start if there's an interval start otherwise set it to the end of the interval
        if (!intervalStart) {
            realStart = start; // no interval yet
            knownDataStart = start;
        }
        else if ([start compare:intervalStart] != NSOrderedAscending) {
            realStart = intervalEnd; // after the interval
            knownDataStart = intervalStart;
        }
        else {
            realStart = start;
            knownDataStart = start;
            realEnd = intervalStart;
            knownDataEnd = intervalEnd;
        }
    }
    else if (end) {
        // if there is an end it must be after the interval end if there's an interval end otherwise set it to the start of the interval
        if (!intervalEnd) {
            realEnd = end;
            knownDataEnd = end;
        }
        else if ([end compare:intervalEnd] != NSOrderedDescending) {
            realEnd = intervalStart; // before the interval
            knownDataEnd = intervalEnd;
        }
        else {
            realEnd = end; // after the interval
            knownDataEnd = end;
            realStart = intervalEnd;
            knownDataStart = intervalStart;
        }
    }
    if (realEnd) {
        parameters[@"end"] = [NSString stringWithFormat:@"%.0f", [realEnd timeIntervalSince1970]];
    }
    else {
        realEnd = [NSDate date];
        knownDataEnd = realEnd;
    }
    if (realStart) {
        parameters[@"start"] = [NSString stringWithFormat:@"%.0f", [realStart timeIntervalSince1970]];
    }
    else {
        realStart = [NSDate distantPast];
        knownDataStart = realStart;
    }

    HTTPRequest *request = [HTTPRequest requestWithURL:url method:HTTPRequestMethod_GET parameters:parameters];
    request.jsonReadingOptions = NSJSONReadingMutableContainers;
    return [self.httpManager sendRequest:request completion:^(id _Nullable parsedData, NSDictionary *_Nullable responseHeaders, NSInteger statusCode, NSError *_Nullable error) {
        if (error) {
            if (completion) {
                completion(error == nil);
            }
        }
        else {
            if (![parsedData isKindOfClass:[NSArray class]] || ((NSArray *)parsedData).count == 0) {
                if (completion) {
                    completion(NO);
                }

                return;
            }

            [self importJSONArray:parsedData exchangeIdentifier:exchangeIdentifier marketIdentifier:marketIdentifier completion:^void(BOOL success) {
                if (success) {
                    NSString *intervalStartKey = [[self class] chartDataIntervalStartKeyForExchangeName:exchangeName marketName:marketName];
                    NSString *intervalEndKey = [[self class] chartDataIntervalEndKeyForExchangeName:exchangeName marketName:marketName];
                    NSDate *intervalStartDate = [[self class] intervalStartDateForExchangeName:exchangeName marketName:marketName];
                    NSDate *intervalEndDate = [[self class] intervalEndDateForExchangeName:exchangeName marketName:marketName];

                    if (!intervalEndDate || (intervalEndDate && ([knownDataEnd compare:intervalEndDate] != NSOrderedSame))) {
                        [[NSUserDefaults standardUserDefaults] setObject:knownDataEnd forKey:intervalEndKey];
                    }
                    if (!intervalStartDate || (intervalStartDate && ([knownDataStart compare:intervalStartDate] != NSOrderedSame))) {
                        [[NSUserDefaults standardUserDefaults] setObject:knownDataStart forKey:intervalStartKey];
                    }
                }

                if (completion) {
                    completion(success);
                }
            }];
        }
    }];
}

+ (nullable NSDate *)intervalStartDateForExchangeName:(NSString *)exchangeName marketName:(NSString *)marketName {
    NSString *chatDataIntervalStartKey = [self chartDataIntervalStartKeyForExchangeName:exchangeName marketName:marketName];
    if (chatDataIntervalStartKey) {
        return [[NSUserDefaults standardUserDefaults] objectForKey:chatDataIntervalStartKey];
    }
    else {
        return nil;
    }
}

+ (nullable NSDate *)intervalEndDateForExchangeName:(NSString *)exchangeName marketName:(NSString *)marketName {
    NSString *chatDataIntervalEndKey = [self chartDataIntervalEndKeyForExchangeName:exchangeName marketName:marketName];
    if (chatDataIntervalEndKey) {
        return [[NSUserDefaults standardUserDefaults] objectForKey:chatDataIntervalEndKey];
    }
    else {
        return nil;
    }
}

#pragma mark - Private

static NSString *FormatChartTimeInterval(NSInteger timeInterval) {
    return [NSString stringWithFormat:@"CT%ld", (long)timeInterval];
}

- (void)importJSONArray:(NSArray *)jsonArray
     exchangeIdentifier:(NSInteger)exchangeIdentifier
       marketIdentifier:(NSInteger)marketIdentifier
             completion:(void (^)(BOOL success))completion {
    NSInteger const batchSize = 2016; // 1 week of data

    NSPersistentContainer *container = self.stack.persistentContainer;
    [container performBackgroundTask:^(NSManagedObjectContext *context) {
        context.mergePolicy = NSMergeByPropertyStoreTrumpMergePolicy;

        NSInteger const additionalIntervalsCount = 5;
        ChartTimeInterval const additionalIntervals[additionalIntervalsCount] = {ChartTimeInterval_15Mins, ChartTimeInterval_30Mins, ChartTimeInterval_2Hour, ChartTimeInterval_4Hours, ChartTimeInterval_1Day};
        for (NSMutableDictionary *jsonObject in jsonArray) {
            NSDate *date = [self.dateFormatter dateFromString:jsonObject[@"time"]];
            NSTimeInterval timestamp = date.timeIntervalSince1970;
            jsonObject[@"time"] = date;
            for (NSInteger i = 0; i < additionalIntervalsCount; i++) {
                ChartTimeInterval ti = additionalIntervals[i];
                jsonObject[FormatChartTimeInterval(ti)] = @(floor(timestamp / [DCChartTimeFormatter timeIntervalForChartTimeInterval:ti]));
            }
        }

        BOOL success = YES;
        NSInteger count = 0;
        for (NSInteger i = 0; i < additionalIntervalsCount; i++) {
            if (!success) {
                break;
            }

            @autoreleasepool {
                ChartTimeInterval chartTimeInterval = additionalIntervals[i];

                NSDictionary<NSNumber *, NSMutableArray<NSDictionary *> *> *jsonGroupedArray =
                    [jsonArray mutableDictionaryOfMutableArraysReferencedByKeyPath:FormatChartTimeInterval(chartTimeInterval)];

                for (NSNumber *intervalNumber in jsonGroupedArray) {
                    NSMutableArray<NSDictionary *> *intervalArray = jsonGroupedArray[intervalNumber];

                    // there's a slight problem that needs addressing before we start computing aggregates.
                    // Data is returned from the server by 5 minute intervals.
                    // To get proper longer intervals we need to combine this with local 5 minute interval data
                    // And then do the aggregates

                    NSTimeInterval startTimeInterval = [intervalArray.firstObject[FormatChartTimeInterval(chartTimeInterval)] doubleValue] * [DCChartTimeFormatter timeIntervalForChartTimeInterval:chartTimeInterval];
                    NSDate *intervalStartDate = [NSDate dateWithTimeIntervalSince1970:startTimeInterval];

                    NSTimeInterval const timeInterval5Mins = [DCChartTimeFormatter timeIntervalForChartTimeInterval:ChartTimeInterval_5Mins];

                    if (intervalArray.firstObject == jsonArray.firstObject) {
                        NSDate *additionalDataPointIntervalEndDate = [intervalArray.firstObject[@"time"] dateByAddingTimeInterval:-timeInterval5Mins];
                        if ([additionalDataPointIntervalEndDate compare:intervalStartDate] == NSOrderedDescending) {
                            NSArray<DCChartDataEntryEntity *> *additionalDataPoints =
                                [DCChartDataEntryEntity chartDataForExchangeIdentifier:exchangeIdentifier
                                                                      marketIdentifier:marketIdentifier
                                                                              interval:ChartTimeInterval_5Mins
                                                                             startTime:intervalStartDate
                                                                               endTime:additionalDataPointIntervalEndDate
                                                                             inContext:context];
                            success = (additionalDataPoints != nil);

                            for (DCChartDataEntryEntity *chartDataEntry in [additionalDataPoints reverseObjectEnumerator]) {
                                NSMutableDictionary *additionalDataPoint = [NSMutableDictionary dictionary];
                                additionalDataPoint[@"time"] = chartDataEntry.time;
                                additionalDataPoint[@"open"] = @(chartDataEntry.open);
                                additionalDataPoint[@"high"] = @(chartDataEntry.high);
                                additionalDataPoint[@"low"] = @(chartDataEntry.low);
                                additionalDataPoint[@"close"] = @(chartDataEntry.close);
                                additionalDataPoint[@"volume"] = @(chartDataEntry.volume);
                                additionalDataPoint[@"pairVolume"] = @(chartDataEntry.pairVolume);
                                additionalDataPoint[@"trades"] = @(chartDataEntry.trades);
                                [intervalArray insertObject:additionalDataPoint atIndex:0];
                            }
                        }
                    }
                    else if (intervalArray.lastObject == jsonArray.lastObject) {
                        NSDate *additionalDataPointIntervalStartDate = [intervalArray.lastObject[@"time"] dateByAddingTimeInterval:timeInterval5Mins];
                        NSDate *additionalDataPointIntervalEndDate = [intervalStartDate dateByAddingTimeInterval:[DCChartTimeFormatter timeIntervalForChartTimeInterval:chartTimeInterval]];
                        NSArray<DCChartDataEntryEntity *> *additionalDataPoints =
                            [DCChartDataEntryEntity chartDataForExchangeIdentifier:exchangeIdentifier
                                                                  marketIdentifier:marketIdentifier
                                                                          interval:ChartTimeInterval_5Mins
                                                                         startTime:additionalDataPointIntervalStartDate
                                                                           endTime:additionalDataPointIntervalEndDate
                                                                         inContext:context];
                        success = (additionalDataPoints != nil);

                        for (DCChartDataEntryEntity *chartDataEntry in additionalDataPoints) {
                            NSMutableDictionary *additionalDataPoint = [NSMutableDictionary dictionary];
                            additionalDataPoint[@"time"] = chartDataEntry.time;
                            additionalDataPoint[@"open"] = @(chartDataEntry.open);
                            additionalDataPoint[@"high"] = @(chartDataEntry.high);
                            additionalDataPoint[@"low"] = @(chartDataEntry.low);
                            additionalDataPoint[@"close"] = @(chartDataEntry.close);
                            additionalDataPoint[@"volume"] = @(chartDataEntry.volume);
                            additionalDataPoint[@"pairVolume"] = @(chartDataEntry.pairVolume);
                            additionalDataPoint[@"trades"] = @(chartDataEntry.trades);
                            [intervalArray addObject:additionalDataPoint];
                        }
                    }

                    if (!success) {
                        NSAssert(NO, @"TODO: Find out - Does smth really went wrong or it's a valid case?");
                        break;
                    }

                    DCChartDataEntryEntity *chartDataEntry = [[DCChartDataEntryEntity alloc] initWithContext:context];
                    chartDataEntry.time = intervalStartDate;
                    chartDataEntry.open = [intervalArray.firstObject[@"open"] doubleValue];
                    chartDataEntry.high = [[intervalArray valueForKeyPath:@"@max.high"] doubleValue];
                    chartDataEntry.low = [[intervalArray valueForKeyPath:@"@min.low"] doubleValue];
                    chartDataEntry.close = [intervalArray.lastObject[@"close"] doubleValue];
                    chartDataEntry.volume = [[intervalArray valueForKeyPath:@"@sum.volume"] doubleValue];
                    chartDataEntry.pairVolume = [[intervalArray valueForKeyPath:@"@sum.pairVolume"] doubleValue];
                    chartDataEntry.trades = [[intervalArray valueForKeyPath:@"@sum.trades"] longValue];
                    chartDataEntry.marketIdentifier = marketIdentifier;
                    chartDataEntry.exchangeIdentifier = exchangeIdentifier;
                    chartDataEntry.interval = chartTimeInterval;

                    count++;
                    if (count % batchSize == 0) {
                        success = [context dc_saveIfNeeded];
                    }
                }
            }
        }

        if (success) {
            for (NSDictionary *jsonObject in jsonArray) {
                DCChartDataEntryEntity *chartDataEntry = [[DCChartDataEntryEntity alloc] initWithContext:context];
                chartDataEntry.time = jsonObject[@"time"];
                chartDataEntry.open = [jsonObject[@"open"] doubleValue];
                chartDataEntry.high = [jsonObject[@"high"] doubleValue];
                chartDataEntry.low = [jsonObject[@"low"] doubleValue];
                chartDataEntry.close = [jsonObject[@"close"] doubleValue];
                chartDataEntry.volume = [jsonObject[@"volume"] doubleValue];
                chartDataEntry.pairVolume = [jsonObject[@"pairVolume"] doubleValue];
                chartDataEntry.trades = [jsonObject[@"trades"] longValue];
                chartDataEntry.marketIdentifier = marketIdentifier;
                chartDataEntry.exchangeIdentifier = exchangeIdentifier;
                chartDataEntry.interval = ChartTimeInterval_5Mins;

                count++;
                if (count % batchSize == 0) {
                    success = [context dc_saveIfNeeded];
                }
            }

            success = [context dc_saveIfNeeded];
        }

        dispatch_async(dispatch_get_main_queue(), ^{
            completion(success);
        });
    }];
}

+ (NSString *)chartDataIntervalStartKeyForExchangeName:(NSString *)exchangeName marketName:(NSString *)marketName {
    return [[exchangeName stringByAppendingString:marketName] stringByAppendingString:@"chartDataIntervalStart"];
}

+ (NSString *)chartDataIntervalEndKeyForExchangeName:(NSString *)exchangeName marketName:(NSString *)marketName {
    return [[exchangeName stringByAppendingString:marketName] stringByAppendingString:@"chartDataIntervalEnd"];
}

@end

NS_ASSUME_NONNULL_END
