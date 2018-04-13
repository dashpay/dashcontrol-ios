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

#import "ExchangeMarketPairObject.h"

#import "DCExchangeEntity+CoreDataClass.h"
#import "DCMarketEntity+CoreDataClass.h"
#import "NSManagedObject+DCExtensions.h"
#import "DCPersistenceStack.h"

NS_ASSUME_NONNULL_BEGIN

@interface ExchangeMarketPairObject ()

@property (copy, nonatomic) NSArray<NSSortDescriptor *> *defaultSortDescriptors;
@property (nullable, strong, nonatomic) DCExchangeEntity *exchange;
@property (nullable, strong, nonatomic) DCMarketEntity *market;

@end

@implementation ExchangeMarketPairObject

- (instancetype)initWithExchange:(nullable DCExchangeEntity *)exchange market:(nullable DCMarketEntity *)market {
    self = [super init];
    if (self) {
        _defaultSortDescriptors = @[ [NSSortDescriptor sortDescriptorWithKey:@"name" ascending:YES] ];

        _exchange = exchange;
        _market = market;
    }
    return self;
}

#pragma mark Public

#define DASH_USDT @"DASH_USDT"
#define DASH_USD @"DASH_USD"

- (void)selectExchange:(nullable DCExchangeEntity *)exchange {
    if (exchange) {
        NSSet<DCMarketEntity *> *availableMarketsForExchange = exchange.markets;
        if (![availableMarketsForExchange containsObject:self.market]) {
            if ([self.market.name isEqualToString:DASH_USDT] || [self.market.name isEqualToString:DASH_USD]) {
                NSString *invertedName = [self.market.name isEqualToString:DASH_USDT] ? DASH_USD : DASH_USDT;
                for (DCMarketEntity * market in availableMarketsForExchange) {
                    if ([market.name isEqualToString:invertedName]) {
                        self.market = market;
                        break;
                    }
                }
            }
            else {
                NSArray *markets = [availableMarketsForExchange sortedArrayUsingDescriptors:self.defaultSortDescriptors];
                self.market = markets.firstObject;
            }
        }
    }

    self.exchange = exchange;
}

- (void)selectMarket:(nullable DCMarketEntity *)market {
    self.market = market;
}

#pragma mark ExchangeMarketPair

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
    if (self.exchange) {
        NSArray *markets = [self.exchange.markets sortedArrayUsingDescriptors:self.defaultSortDescriptors];
        return markets;
    }
    else {
        NSManagedObjectContext *viewContext = self.stack.persistentContainer.viewContext;
        NSArray<DCMarketEntity *> *markets = [DCMarketEntity dc_objectsWithPredicate:nil
                                                                           inContext:viewContext
                                                               requestConfigureBlock:^(NSFetchRequest *_Nonnull fetchRequest) {
                                                                   fetchRequest.sortDescriptors = self.defaultSortDescriptors;
                                                               }];
        return markets;
    }
}

#pragma mark NSCopying

- (id)copyWithZone:(nullable NSZone *)zone {
    __typeof(self) copy = [[self.class alloc] initWithExchange:self.exchange market:self.market];
    return copy;
}

@end

NS_ASSUME_NONNULL_END
