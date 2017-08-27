//
//  ChartDataImportManager.h
//  DashControl
//
//  Created by Manuel Boyer on 22/08/2017.
//  Copyright © 2017 dashfoundation. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, DCMarketSource) {
    DCMarketDashBtc, //DASH_BTC
    DCMarketDashUsd, //DASH_USD
    DCMarketDashEuro, //DASH_EUR
    POLONIEXMarketUsdDash //USDT_DASH Temporary Poloniex Historical Data
};

typedef NS_ENUM(NSInteger, DCExchangeSource) {
    DCExchangeSourceKraken, //kraken
    DCExchangeSourcePoloniex, //poloniex
    DCExchangeSourceBitfinex, //bitfinex
    POLHistorySource //Temporary Poloniex Historical Data
};

@interface ChartDataImportManager : NSObject

@property (nonatomic, retain) NSManagedObjectContext * _Nullable managedObjectContext;

+ (id _Nonnull )sharedManager;

- (NSString*_Nullable)convertExchangeEnumToString:(DCExchangeSource)exchangeSource;
- (DCExchangeSource)convertExchangeStringToEnum:(NSString*_Nullable)exchangeSource;
- (NSString*_Nullable)convertMarketEnumToString:(DCMarketSource)marketSource;
- (DCMarketSource) convertMarketStringToEnum:(NSString*_Nullable)market;

@end
