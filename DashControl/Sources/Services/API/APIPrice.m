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

- (void)fetchMarketsCompletion:(void (^)(NSError *_Nullable error, NSInteger defaultExchangeIdentifier, NSInteger defaultMarketIdentifier))completion {
    NSString *urlString = [API_BASE_URL stringByAppendingString:@"markets"];
    NSURL *url = [NSURL URLWithString:urlString];
    HTTPRequest *request = [HTTPRequest requestWithURL:url method:HTTPRequestMethod_GET parameters:nil];
    [self.httpManager sendRequest:request completion:^(id _Nullable parsedData, NSDictionary *_Nullable responseHeaders, NSInteger statusCode, NSError *_Nullable error) {
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

@end

NS_ASSUME_NONNULL_END
