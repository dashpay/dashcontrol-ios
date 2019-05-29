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
#import "DSNetworking.h"

NS_ASSUME_NONNULL_BEGIN

#define KEY_NAME @"name"

static NSTimeInterval const RATELIMIT_WINDOW = 60.0;
static NSUInteger const RATELIMIT_DELAYAFTER = 2;
static NSTimeInterval const RATELIMIT_DELAY = 1.0;
static NSUInteger const RATELIMIT_MAXIMUM = 0;

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

        HTTPRateLimiter *rateLimiter = [[HTTPRateLimiter alloc] initWithWindow:RATELIMIT_WINDOW
                                                                    delayAfter:RATELIMIT_DELAYAFTER
                                                                         delay:RATELIMIT_DELAY
                                                                       maximum:RATELIMIT_MAXIMUM];
        NSString *urlString = [self.baseURLString stringByAppendingString:@"chart_data"];
        NSURL *url = [NSURL URLWithString:urlString];
        [self.httpService.rateLimiterMap setRateLimiter:rateLimiter forURL:url];
    }
    return self;
}

- (id<HTTPLoaderOperationProtocol>)fetchMarketsCompletion:(void (^)(NSError *_Nullable error, NSInteger defaultExchangeIdentifier, NSInteger defaultMarketIdentifier))completion {
    NSString *urlString = [self.baseURLString stringByAppendingString:@"markets"];
    NSURL *url = [NSURL URLWithString:urlString];
    HTTPRequest *request = [HTTPRequest requestWithURL:url method:HTTPRequestMethod_GET parameters:nil];
    request.maximumRetryCount = 2; // this request is important
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
                                                       start:(NSUInteger)start
                                                         end:(NSUInteger)end
                                                  completion:(void (^)(BOOL success))completion {
    NSParameterAssert(exchange);
    NSParameterAssert(market);

    NSString *exchangeName = exchange.name;
    NSString *marketName = market.name;
    NSInteger exchangeIdentifier = exchange.identifier;
    NSInteger marketIdentifier = market.identifier;

    NSString *urlString = [self.baseURLString stringByAppendingString:@"chart_data"];
    NSURL *url = [NSURL URLWithString:urlString];

    NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
    parameters[@"market"] = marketName;
    parameters[@"exchange"] = exchangeName;
    parameters[@"start"] = [NSString stringWithFormat:@"%lu", start];
    parameters[@"end"] = [NSString stringWithFormat:@"%lu", end];
// to debug without rate-limits uncomment code below:
//#ifdef DEBUG
//    parameters[@"noLimit"] = @"1";
//#endif

#ifdef DEBUG
    DCDebugLog([self class], @"REQ date [ %@ -- %@ ]",
               [NSDateFormatter localizedStringFromDate:[NSDate dateWithTimeIntervalSince1970:start]
                                              dateStyle:NSDateFormatterShortStyle
                                              timeStyle:NSDateFormatterShortStyle],
               [NSDateFormatter localizedStringFromDate:[NSDate dateWithTimeIntervalSince1970:end]
                                              dateStyle:NSDateFormatterShortStyle
                                              timeStyle:NSDateFormatterShortStyle]);
#endif

    HTTPRequest *request = [HTTPRequest requestWithURL:url method:HTTPRequestMethod_GET parameters:parameters];
    request.jsonReadingOptions = NSJSONReadingMutableContainers;
    return [self.httpManager sendRequest:request completion:^(id _Nullable parsedData, NSDictionary *_Nullable responseHeaders, NSInteger statusCode, NSError *_Nullable error) {
        if (error) {
            if (completion) {
                completion(NO);
            }
        }
        else {
#ifdef DEBUG
            if (((NSArray *)parsedData).count > 0) {
                DCDebugLog([self class], @"RCV data [ %@ -- %@ ]",
                           [NSDateFormatter localizedStringFromDate:[self.dateFormatter dateFromString:((NSArray *)parsedData).firstObject[@"time"]]
                                                          dateStyle:NSDateFormatterShortStyle
                                                          timeStyle:NSDateFormatterShortStyle],
                           [NSDateFormatter localizedStringFromDate:[self.dateFormatter dateFromString:((NSArray *)parsedData).lastObject[@"time"]]
                                                          dateStyle:NSDateFormatterShortStyle
                                                          timeStyle:NSDateFormatterShortStyle]);
            }
            else {
                DCDebugLog([self class], @"RCV empty response");
            }
#endif

            if (![parsedData isKindOfClass:[NSArray class]] || ((NSArray *)parsedData).count == 0) {
                if (completion) {
                    completion(YES);
                }

                return;
            }

            [self importJSONArray:parsedData exchangeIdentifier:exchangeIdentifier marketIdentifier:marketIdentifier completion:^{
                if (completion) {
                    completion(YES);
                }
            }];
        }
    }];
}

#pragma mark - Private

- (void)importJSONArray:(NSArray *)jsonArray
     exchangeIdentifier:(NSInteger)exchangeIdentifier
       marketIdentifier:(NSInteger)marketIdentifier
             completion:(void (^)(void))completion {
    NSInteger const batchSize = 2016; // 1 week of data

    NSPersistentContainer *container = self.stack.persistentContainer;
    [container performBackgroundTask:^(NSManagedObjectContext *context) {
        context.mergePolicy = NSMergeByPropertyStoreTrumpMergePolicy;

        NSInteger count = 0;
        for (NSDictionary *jsonObject in jsonArray) {
            DCChartDataEntryEntity *chartDataEntry = [[DCChartDataEntryEntity alloc] initWithContext:context];
            chartDataEntry.time = [self.dateFormatter dateFromString:jsonObject[@"time"]];
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
                [context dc_saveIfNeeded];
            }
        }

        [context dc_saveIfNeeded];

        dispatch_async(dispatch_get_main_queue(), completion);
    }];
}

@end

NS_ASSUME_NONNULL_END
