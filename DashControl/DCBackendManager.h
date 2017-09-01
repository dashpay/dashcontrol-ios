//
//  ChartDataImportManager.h
//  DashControl
//
//  Created by Manuel Boyer on 22/08/2017.
//  Copyright © 2017 dashfoundation. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, DCMarketSource) {
    DCMarketDashBtc = 0, //DASH_BTC
    DCMarketDashUsd = 1, //DASH_USD
    DCMarketDashEuro = 2, //DASH_EUR
    DCMarketDashUsdt = 3 //DASH_USD
};

typedef NS_ENUM(NSInteger, DCExchangeSource) {
    DCExchangeSourceKraken = 0, //kraken
    DCExchangeSourcePoloniex = 1, //poloniex
    DCExchangeSourceBitfinex = 2 //bitfinex
};

@interface DCBackendManager : NSObject

@property (nonatomic, strong) NSManagedObjectContext * _Nullable mainObjectContext;

+ (id _Nonnull )sharedManager;

- (NSString*_Nullable)convertExchangeEnumToString:(DCExchangeSource)exchangeSource;
- (DCExchangeSource)convertExchangeStringToEnum:(NSString*_Nullable)exchangeSource;
- (NSString*_Nullable)convertMarketEnumToString:(DCMarketSource)marketSource;
- (DCMarketSource) convertMarketStringToEnum:(NSString*_Nullable)market;

@end
