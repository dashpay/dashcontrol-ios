//
//  ChartDataImportManager.m
//  DashControl
//
//  Created by Manuel Boyer on 22/08/2017.
//  Copyright © 2017 dashfoundation. All rights reserved.
//

#import "ChartDataImportManager.h"

#define DASHCONTROL_CHART_DATA_URL  @"http://dashpay.info/api/v0/chart_data"

#define TICKER_REFRESH_TIME 60.0

#define CHART_DATA_KRAKEN_DASH_BTC_LAST_IMPORT_TIME  @"CHART_DATA_KRAKEN_DASH_BTC_LAST_IMPORT_TIME"
#define CHART_DATA_KRAKEN_DASH_USD_LAST_IMPORT_TIME  @"CHART_DATA_KRAKEN_DASH_USD_LAST_IMPORT_TIME"
#define CHART_DATA_KRAKEN_DASH_EUR_LAST_IMPORT_TIME  @"CHART_DATA_KRAKEN_DASH_EUR_LAST_IMPORT_TIME"

#define CHART_DATA_POLONIEX_DASH_BTC_LAST_IMPORT_TIME  @"CHART_DATA_POLONIEX_DASH_BTC_LAST_IMPORT_TIME"
#define CHART_DATA_POLONIEX_DASH_USD_LAST_IMPORT_TIME  @"CHART_DATA_POLONIEX_DASH_USD_LAST_IMPORT_TIME"
#define CHART_DATA_POLONIEX_DASH_EUR_LAST_IMPORT_TIME  @"CHART_DATA_POLONIEX_DASH_EUR_LAST_IMPORT_TIME"

#define CHART_DATA_BITFINEX_DASH_BTC_LAST_IMPORT_TIME  @"CHART_DATA_BITFINEX_DASH_BTC_LAST_IMPORT_TIME"
#define CHART_DATA_BITFINEX_DASH_USD_LAST_IMPORT_TIME  @"CHART_DATA_BITFINEX_DASH_USD_LAST_IMPORT_TIME"
#define CHART_DATA_BITFINEX_DASH_EUR_LAST_IMPORT_TIME  @"CHART_DATA_BITFINEX_DASH_EUR_LAST_IMPORT_TIME"

#define HISTORICAL_CHART_DATA_POLONIEX_KEY @"HISTORICAL_CHART_DATA_POLONIEX_KEY"

/**
 This creates a new query parameters string from the given NSDictionary. For
 example, if the input is @{@"day":@"Tuesday", @"month":@"January"}, the output
 string will be @"day=Tuesday&month=January".
 @param queryParameters The input dictionary.
 @return The created parameters string.
 */

static NSString* NSStringFromQueryParameters(NSDictionary* queryParameters)
{
    NSMutableArray* parts = [NSMutableArray array];
    [queryParameters enumerateKeysAndObjectsUsingBlock:^(id key, id value, BOOL *stop) {
        NSString *part = [NSString stringWithFormat: @"%@=%@",
                          [key stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]],
                          [value stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]]
                          ];
        [parts addObject:part];
    }];
    return [parts componentsJoinedByString: @"&"];
}

/**
 Creates a new URL by adding the given query parameters.
 @param URL The input URL.
 @param queryParameters The query parameter dictionary to add.
 @return A new NSURL.
 */
static NSURL* NSURLByAppendingQueryParameters(NSURL* URL, NSDictionary* queryParameters)
{
    NSString* URLString = [NSString stringWithFormat:@"%@?%@",
                           [URL absoluteString],
                           NSStringFromQueryParameters(queryParameters)
                           ];
    return [NSURL URLWithString:URLString];
}

@interface ChartDataImportManager ()
@property (nonatomic, strong) Reachability *reachability;
@end

@implementation ChartDataImportManager

#pragma mark - Singleton Init Methods

+ (id)sharedManager {
    static ChartDataImportManager *sharedChartDataImportManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedChartDataImportManager = [[self alloc] init];
    });
    return sharedChartDataImportManager;
}

- (id)init {
    if (self = [super init]) {
        self.managedObjectContext = [[(AppDelegate*)[[UIApplication sharedApplication] delegate] persistentContainer] viewContext];
        self.reachability = [Reachability reachabilityForInternetConnection];
        [self updatePriceCharts];
    }
    return self;
}

#pragma mark - Import Chart Data

-(void)updatePriceCharts {
    [self updateChartDataKraken];
    [self updateChartDataPoloniex];
    [self updateChartDataBitfinex];
    
    //Some historical poloniex chart data USD_DASH, so we can get started with the graph thing.
    //[self fetchHistoricalPoloniex];
}

-(void)updateChartDataKraken {
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(updateChartDataKraken) object:nil];
    [self performSelector:@selector(updateChartDataKraken) withObject:nil afterDelay:TICKER_REFRESH_TIME];
    if (self.reachability.currentReachabilityStatus == NotReachable) return;
    
    [self updateChartDataKrakenForMarket:DCMarketDashUsd];
    //[self updateChartDataKrakenForMarket:DCMarketDashEuro];
    [self updateChartDataKrakenForMarket:DCMarketDashBtc];
}

-(void)updateChartDataKrakenForMarket:(DCMarketSource)market {
    NSURLSessionConfiguration* sessionConfig = [NSURLSessionConfiguration defaultSessionConfiguration];
    NSURLSession* session = [NSURLSession sessionWithConfiguration:sessionConfig delegate:nil delegateQueue:nil];
    NSURL* URL = [NSURL URLWithString:DASHCONTROL_CHART_DATA_URL];
    NSMutableDictionary *URLParams = [NSMutableDictionary new];
    [URLParams setObject:[self convertExchangeEnumToString:DCExchangeSourceKraken] forKey:@"exchange"];
    [URLParams setObject:[self convertMarketEnumToString:market] forKey:@"market"];
    if (DEBUG) {
        [URLParams setObject:@"1" forKey:@"noLimit"];
    }
    
    NSUserDefaults *defs = [NSUserDefaults standardUserDefaults];
    switch (market) {
        case DCMarketDashBtc:
            if ([defs objectForKey:CHART_DATA_KRAKEN_DASH_BTC_LAST_IMPORT_TIME]) {
                [URLParams setObject:[NSString stringWithFormat:@"%.0f", [[defs objectForKey:CHART_DATA_KRAKEN_DASH_BTC_LAST_IMPORT_TIME] timeIntervalSince1970]] forKey:@"start"];
            }
            break;
        case DCMarketDashUsd:
            if ([defs objectForKey:CHART_DATA_KRAKEN_DASH_USD_LAST_IMPORT_TIME]) {
                [URLParams setObject:[NSString stringWithFormat:@"%.0f", [[defs objectForKey:CHART_DATA_KRAKEN_DASH_USD_LAST_IMPORT_TIME] timeIntervalSince1970]] forKey:@"start"];
            }
            break;
        case DCMarketDashEuro:
            if ([defs objectForKey:CHART_DATA_KRAKEN_DASH_EUR_LAST_IMPORT_TIME]) {
                [URLParams setObject:[NSString stringWithFormat:@"%.0f", [[defs objectForKey:CHART_DATA_KRAKEN_DASH_EUR_LAST_IMPORT_TIME] timeIntervalSince1970]] forKey:@"start"];
            }
            break;
        case POLONIEXMarketUsdDash:
            break;
    }
    
    URL = NSURLByAppendingQueryParameters(URL, URLParams);
    NSMutableURLRequest* request = [NSMutableURLRequest requestWithURL:URL];
    request.HTTPMethod = @"GET";
    
    NSURLSessionDataTask* task = [session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        if (error == nil) {
            
            if (((((NSHTTPURLResponse*)response).statusCode /100) != 2)) {
                NSLog(@"Status %ld",(long)((NSHTTPURLResponse*)response).statusCode);
                NSString* ErrorResponse = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
                NSLog(@"ErrorResponse:%@",ErrorResponse);
                return;
            }
            NSError *e = nil;
            NSArray *jsonArray = [NSJSONSerialization JSONObjectWithData:data options: NSJSONReadingMutableLeaves error:&e];
            
            if (!e) {
                [self importJSONData:jsonArray forExchange:DCExchangeSourceKraken andMarket:market];
                
                NSUserDefaults *defs = [NSUserDefaults standardUserDefaults];
                switch (market) {
                    case DCMarketDashBtc:
                        [defs setObject:[NSDate date] forKey:CHART_DATA_KRAKEN_DASH_BTC_LAST_IMPORT_TIME];
                        break;
                    case DCMarketDashUsd:
                        [defs setObject:[NSDate date] forKey:CHART_DATA_KRAKEN_DASH_USD_LAST_IMPORT_TIME];
                        break;
                    case DCMarketDashEuro:
                        [defs setObject:[NSDate date] forKey:CHART_DATA_KRAKEN_DASH_EUR_LAST_IMPORT_TIME];
                        break;
                    case POLONIEXMarketUsdDash:
                        break;
                }
                [defs synchronize];
            }
            
        }
        else {
            // Failure
            NSLog(@"URL Session Task Failed: %@", [error localizedDescription]);
        }
    }];
    
    [task resume];
    [session finishTasksAndInvalidate];
}

-(void)updateChartDataPoloniex {
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(updateChartDataPoloniex) object:nil];
    [self performSelector:@selector(updateChartDataPoloniex) withObject:nil afterDelay:TICKER_REFRESH_TIME];
    if (self.reachability.currentReachabilityStatus == NotReachable) return;
    
    [self updateChartDataPoloniexForMarket:DCMarketDashUsd];
    //[self updateChartDataPoloniexForMarket:DCMarketDashEuro];
    [self updateChartDataPoloniexForMarket:DCMarketDashBtc];
}

-(void)updateChartDataPoloniexForMarket:(DCMarketSource)market {
    NSURLSessionConfiguration* sessionConfig = [NSURLSessionConfiguration defaultSessionConfiguration];
    NSURLSession* session = [NSURLSession sessionWithConfiguration:sessionConfig delegate:nil delegateQueue:nil];
    NSURL* URL = [NSURL URLWithString:DASHCONTROL_CHART_DATA_URL];
    NSMutableDictionary *URLParams = [NSMutableDictionary new];
    [URLParams setObject:[self convertExchangeEnumToString:DCExchangeSourcePoloniex] forKey:@"exchange"];
    [URLParams setObject:[self convertMarketEnumToString:market] forKey:@"market"];
    if (DEBUG) {
        [URLParams setObject:@"1" forKey:@"noLimit"];
    }
    
    NSUserDefaults *defs = [NSUserDefaults standardUserDefaults];
    switch (market) {
        case DCMarketDashBtc:
            if ([defs objectForKey:CHART_DATA_POLONIEX_DASH_BTC_LAST_IMPORT_TIME]) {
                [URLParams setObject:[NSString stringWithFormat:@"%.0f", [[defs objectForKey:CHART_DATA_POLONIEX_DASH_BTC_LAST_IMPORT_TIME] timeIntervalSince1970]] forKey:@"start"];
            }
            break;
        case DCMarketDashUsd:
            if ([defs objectForKey:CHART_DATA_POLONIEX_DASH_USD_LAST_IMPORT_TIME]) {
                [URLParams setObject:[NSString stringWithFormat:@"%.0f", [[defs objectForKey:CHART_DATA_POLONIEX_DASH_USD_LAST_IMPORT_TIME] timeIntervalSince1970]] forKey:@"start"];
            }
            break;
        case DCMarketDashEuro:
            if ([defs objectForKey:CHART_DATA_POLONIEX_DASH_EUR_LAST_IMPORT_TIME]) {
                [URLParams setObject:[NSString stringWithFormat:@"%.0f", [[defs objectForKey:CHART_DATA_POLONIEX_DASH_EUR_LAST_IMPORT_TIME] timeIntervalSince1970]] forKey:@"start"];
            }
            break;
        case POLONIEXMarketUsdDash:
            break;
    }
    
    URL = NSURLByAppendingQueryParameters(URL, URLParams);
    NSMutableURLRequest* request = [NSMutableURLRequest requestWithURL:URL];
    request.HTTPMethod = @"GET";
    
    NSURLSessionDataTask* task = [session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        if (error == nil) {
            
            if (((((NSHTTPURLResponse*)response).statusCode /100) != 2)) {
                NSLog(@"Status %ld",(long)((NSHTTPURLResponse*)response).statusCode);
                NSString* ErrorResponse = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
                NSLog(@"ErrorResponse:%@",ErrorResponse);
                return;
            }
            NSError *e = nil;
            NSArray *jsonArray = [NSJSONSerialization JSONObjectWithData:data options: NSJSONReadingMutableLeaves error:&e];
            
            if (!e) {
                [self importJSONData:jsonArray forExchange:DCExchangeSourcePoloniex andMarket:market];
                
                NSUserDefaults *defs = [NSUserDefaults standardUserDefaults];
                switch (market) {
                    case DCMarketDashBtc:
                        [defs setObject:[NSDate date] forKey:CHART_DATA_POLONIEX_DASH_BTC_LAST_IMPORT_TIME];
                        break;
                    case DCMarketDashUsd:
                        [defs setObject:[NSDate date] forKey:CHART_DATA_POLONIEX_DASH_USD_LAST_IMPORT_TIME];
                        break;
                    case DCMarketDashEuro:
                        [defs setObject:[NSDate date] forKey:CHART_DATA_POLONIEX_DASH_EUR_LAST_IMPORT_TIME];
                        break;
                    case POLONIEXMarketUsdDash:
                        break;
                }
                [defs synchronize];
            }
            
        }
        else {
            // Failure
            NSLog(@"URL Session Task Failed: %@", [error localizedDescription]);
        }
    }];
    
    [task resume];
    [session finishTasksAndInvalidate];
}

-(void)updateChartDataBitfinex {
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(updateChartDataBitfinex) object:nil];
    [self performSelector:@selector(updateChartDataBitfinex) withObject:nil afterDelay:TICKER_REFRESH_TIME];
    if (self.reachability.currentReachabilityStatus == NotReachable) return;
    
    [self updateChartDataBitfinexForMarket:DCMarketDashUsd];
    //[self updateChartDataBitfinexForMarket:DCMarketDashEuro];
    [self updateChartDataBitfinexForMarket:DCMarketDashBtc];
}

-(void)updateChartDataBitfinexForMarket:(DCMarketSource)market {
    NSURLSessionConfiguration* sessionConfig = [NSURLSessionConfiguration defaultSessionConfiguration];
    NSURLSession* session = [NSURLSession sessionWithConfiguration:sessionConfig delegate:nil delegateQueue:nil];
    NSURL* URL = [NSURL URLWithString:DASHCONTROL_CHART_DATA_URL];
    NSMutableDictionary *URLParams = [NSMutableDictionary new];
    [URLParams setObject:[self convertExchangeEnumToString:DCExchangeSourceBitfinex] forKey:@"exchange"];
    [URLParams setObject:[self convertMarketEnumToString:market] forKey:@"market"];
    if (DEBUG) {
        [URLParams setObject:@"1" forKey:@"noLimit"];
    }
    
    NSUserDefaults *defs = [NSUserDefaults standardUserDefaults];
    switch (market) {
        case DCMarketDashBtc:
            if ([defs objectForKey:CHART_DATA_BITFINEX_DASH_BTC_LAST_IMPORT_TIME]) {
                [URLParams setObject:[NSString stringWithFormat:@"%.0f", [[defs objectForKey:CHART_DATA_BITFINEX_DASH_BTC_LAST_IMPORT_TIME] timeIntervalSince1970]] forKey:@"start"];
            }
            break;
        case DCMarketDashUsd:
            if ([defs objectForKey:CHART_DATA_BITFINEX_DASH_USD_LAST_IMPORT_TIME]) {
                [URLParams setObject:[NSString stringWithFormat:@"%.0f", [[defs objectForKey:CHART_DATA_BITFINEX_DASH_USD_LAST_IMPORT_TIME] timeIntervalSince1970]] forKey:@"start"];
            }
            break;
        case DCMarketDashEuro:
            if ([defs objectForKey:CHART_DATA_BITFINEX_DASH_EUR_LAST_IMPORT_TIME]) {
                [URLParams setObject:[NSString stringWithFormat:@"%.0f", [[defs objectForKey:CHART_DATA_BITFINEX_DASH_EUR_LAST_IMPORT_TIME] timeIntervalSince1970]] forKey:@"start"];
            }
            break;
        case POLONIEXMarketUsdDash:
            break;
    }
    
    URL = NSURLByAppendingQueryParameters(URL, URLParams);
    NSMutableURLRequest* request = [NSMutableURLRequest requestWithURL:URL];
    request.HTTPMethod = @"GET";
    
    NSURLSessionDataTask* task = [session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        if (error == nil) {
            
            if (((((NSHTTPURLResponse*)response).statusCode /100) != 2)) {
                NSLog(@"Status %ld",(long)((NSHTTPURLResponse*)response).statusCode);
                NSString* ErrorResponse = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
                NSLog(@"ErrorResponse:%@",ErrorResponse);
                return;
            }
            NSError *e = nil;
            NSArray *jsonArray = [NSJSONSerialization JSONObjectWithData:data options: NSJSONReadingMutableLeaves error:&e];
            
            if (!e) {
                [self importJSONData:jsonArray forExchange:DCExchangeSourceBitfinex andMarket:market];
                
                NSUserDefaults *defs = [NSUserDefaults standardUserDefaults];
                switch (market) {
                    case DCMarketDashBtc:
                        [defs setObject:[NSDate date] forKey:CHART_DATA_BITFINEX_DASH_BTC_LAST_IMPORT_TIME];
                        break;
                    case DCMarketDashUsd:
                        [defs setObject:[NSDate date] forKey:CHART_DATA_BITFINEX_DASH_USD_LAST_IMPORT_TIME];
                        break;
                    case DCMarketDashEuro:
                        [defs setObject:[NSDate date] forKey:CHART_DATA_BITFINEX_DASH_EUR_LAST_IMPORT_TIME];
                        break;
                    case POLONIEXMarketUsdDash:
                        break;
                }
                [defs synchronize];
            }
        }
        else {
            // Failure
            NSLog(@"URL Session Task Failed: %@", [error localizedDescription]);
        }
    }];
    
    [task resume];
    [session finishTasksAndInvalidate];
}

-(void)fetchHistoricalPoloniex {

    NSUserDefaults *defs = [NSUserDefaults standardUserDefaults];
    if ([defs objectForKey:HISTORICAL_CHART_DATA_POLONIEX_KEY] || self.reachability.currentReachabilityStatus == ReachableViaWWAN) {
        return;
    }
    
    NSURLSessionConfiguration* sessionConfig = [NSURLSessionConfiguration defaultSessionConfiguration];
    NSURLSession* session = [NSURLSession sessionWithConfiguration:sessionConfig delegate:nil delegateQueue:nil];
    NSURL* URL = [NSURL URLWithString:@"https://poloniex.com/public"];
    NSDictionary* URLParams = @{
                                @"command": @"returnChartData",
                                @"currencyPair": @"USDT_DASH",
                                @"start": @"0",
                                @"period": @"300",
                                };
    URL = NSURLByAppendingQueryParameters(URL, URLParams);
    NSMutableURLRequest* request = [NSMutableURLRequest requestWithURL:URL];
    request.HTTPMethod = @"GET";
    
    NSURLSessionDataTask* task = [session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        if (error == nil) {
            // Success
            if (((((NSHTTPURLResponse*)response).statusCode /100) != 2)) {
                NSLog(@"Status %ld",(long)((NSHTTPURLResponse*)response).statusCode);
                return;
            }
            NSError *e = nil;
            NSArray *jsonArray = [NSJSONSerialization JSONObjectWithData:data options: NSJSONReadingMutableLeaves error:&e];
            
            if (!e) {
                
                [self importLargeHistoricalPoloniexJSONData:jsonArray];
                
                NSUserDefaults *defs = [NSUserDefaults standardUserDefaults];
                [defs setObject:[NSDate date] forKey:HISTORICAL_CHART_DATA_POLONIEX_KEY];
                [defs synchronize];
            }
            
            
        }
        else {
            // Failure
            NSLog(@"URL Session Task Failed: %@", [error localizedDescription]);
        }
    }];
    [task resume];
    [session finishTasksAndInvalidate];
}

#pragma mark - Core Data related

-(void)importLargeHistoricalPoloniexJSONData:(NSArray *)jsonArray {

    NSPersistentContainer *container = [(AppDelegate*)[[UIApplication sharedApplication] delegate] persistentContainer];
    [container performBackgroundTask:^(NSManagedObjectContext *context) {
        
        for (NSDictionary *jsonObject in jsonArray) {
            ChartDataEntry *chartDataEntry = [NSEntityDescription insertNewObjectForEntityForName:@"ChartDataEntry" inManagedObjectContext:context];
            
            NSDate * myDate = [NSDate dateWithTimeIntervalSince1970:[[jsonObject objectForKey:@"date"] doubleValue]];
            chartDataEntry.time = myDate;
            
            chartDataEntry.open = [[jsonObject objectForKey:@"open"] doubleValue];
            chartDataEntry.high = [[jsonObject objectForKey:@"high"] doubleValue];
            chartDataEntry.low = [[jsonObject objectForKey:@"low"] doubleValue];
            chartDataEntry.close = [[jsonObject objectForKey:@"close"] doubleValue];
            chartDataEntry.volume = [[jsonObject objectForKey:@"volume"] doubleValue];
            
            //chartDataEntry.pairVolume = [[jsonObject objectForKey:@"pairVolume"] doubleValue];
            //chartDataEntry.trades = [[jsonObject objectForKey:@"trades"] intValue];
            
            chartDataEntry.exchange = POLHistorySource; //Temporary value until we talk about historical import.
            chartDataEntry.market = POLONIEXMarketUsdDash; //Temporary value until we talk about historical import.
        }
        
        context.automaticallyMergesChangesFromParent = TRUE;
        context.mergePolicy = NSMergeByPropertyStoreTrumpMergePolicy;
        
        NSError *error = nil;
        if (![context save:&error]) {
            NSLog(@"Failure to save context: %@\n%@", [error localizedDescription], [error userInfo]);
            abort();
        }
    }];
}

-(void)importJSONData:(NSArray*)jsonArray forExchange:(DCExchangeSource)exchange andMarket:(DCMarketSource)market {
    
    if (!jsonArray) {
        return;
    }
    
    NSPersistentContainer *container = [(AppDelegate*)[[UIApplication sharedApplication] delegate] persistentContainer];
    [container performBackgroundTask:^(NSManagedObjectContext *context) {
        
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        NSLocale *enUSPOSIXLocale = [NSLocale localeWithLocaleIdentifier:@"en_US_POSIX"];
        [dateFormatter setLocale:enUSPOSIXLocale];
        [dateFormatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss.SSSZ"];
        
        for (NSDictionary *jsonObject in jsonArray) {
            NSArray *entriesFound = [self fetchChartDataForExchange:exchange andMarket:market atTime:[dateFormatter dateFromString:[jsonObject objectForKey:@"time"]] inContext:context];
            if (!entriesFound || entriesFound.count == 0) {
                ChartDataEntry *chartDataEntry = [NSEntityDescription insertNewObjectForEntityForName:@"ChartDataEntry" inManagedObjectContext:context];
                chartDataEntry.time = [dateFormatter dateFromString:[jsonObject objectForKey:@"time"]];
                chartDataEntry.open = [[jsonObject objectForKey:@"open"] doubleValue];
                chartDataEntry.high = [[jsonObject objectForKey:@"high"] doubleValue];
                chartDataEntry.low = [[jsonObject objectForKey:@"low"] doubleValue];
                chartDataEntry.close = [[jsonObject objectForKey:@"close"] doubleValue];
                chartDataEntry.volume = [[jsonObject objectForKey:@"volume"] doubleValue];
                chartDataEntry.pairVolume = [[jsonObject objectForKey:@"pairVolume"] doubleValue];
                chartDataEntry.trades = [[jsonObject objectForKey:@"trades"] intValue];
                chartDataEntry.exchange = exchange;
                chartDataEntry.market = market;
            }
            else {
                ChartDataEntry *chartDataEntry = entriesFound.firstObject;
                chartDataEntry.open = [[jsonObject objectForKey:@"open"] doubleValue];
                chartDataEntry.high = [[jsonObject objectForKey:@"high"] doubleValue];
                chartDataEntry.low = [[jsonObject objectForKey:@"low"] doubleValue];
                chartDataEntry.close = [[jsonObject objectForKey:@"close"] doubleValue];
                chartDataEntry.volume = [[jsonObject objectForKey:@"volume"] doubleValue];
                chartDataEntry.pairVolume = [[jsonObject objectForKey:@"pairVolume"] doubleValue];
                chartDataEntry.trades = [[jsonObject objectForKey:@"trades"] intValue];
                chartDataEntry.exchange = exchange;
                chartDataEntry.market = market;
            }
        }
        
        context.automaticallyMergesChangesFromParent = TRUE;
        context.mergePolicy = NSMergeByPropertyStoreTrumpMergePolicy;
        
        NSError *error = nil;
        if (![context save:&error]) {
            NSLog(@"Failure to save context: %@\n%@", [error localizedDescription], [error userInfo]);
            abort();
        }
    }];
}

-(NSMutableArray *)fetchChartDataForExchange:(DCExchangeSource)exchange andMarket:(DCMarketSource)market atTime:(NSDate*)time inContext:(NSManagedObjectContext *)context {
    
    if (context) {
        NSEntityDescription *entityDescription = [NSEntityDescription entityForName:@"ChartDataEntry" inManagedObjectContext:context];
        NSFetchRequest *request = [[NSFetchRequest alloc] init];
        [request setEntity:entityDescription];
        
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"(exchange == %d) AND (market == %d) AND (time == %@)", exchange, market, time];
        [request setPredicate:predicate];
        
        NSError *error;
        NSArray *array = [context executeFetchRequest:request error:&error];
        if (array == nil)
        {
            NSLog(@"Error while festching %@ with predicate %@", entityDescription.name, predicate);
        }
        return [array mutableCopy];
    } else {
        return  nil;
    }
    
}

#pragma mark - Exchange & Market

- (NSString*)convertExchangeEnumToString:(DCExchangeSource)exchangeSource {
    NSString *result = nil;
    
    switch(exchangeSource) {
        case 0:
            result = @"kraken";
            break;
        case 1:
            result = @"poloniex";
            break;
        case 2:
            result = @"bitfinex";
            break;
            
        default:
            result = @"unknown";
    }
    
    return result;
}
- (DCExchangeSource)convertExchangeStringToEnum:(NSString*)exchangeSource {
    if ([exchangeSource isEqualToString:@"kraken"]) {
        return DCExchangeSourceKraken;
    }
    if ([exchangeSource isEqualToString:@"poloniex"]) {
        return DCExchangeSourcePoloniex;
    }
    if ([exchangeSource isEqualToString:@"bitfinex"]) {
        return DCExchangeSourceBitfinex;
    }
    return -1;
}

- (NSString*)convertMarketEnumToString:(DCMarketSource)marketSource {
    NSString *result = nil;
    
    switch(marketSource) {
        case 0:
            result = @"DASH_BTC";
            break;
        case 1:
            result = @"DASH_USD";
            break;
        case 2:
            result = @"DASH_EUR";
            break;
            
        default:
            result = @"unknown";
    }
    
    return result;
}
- (DCMarketSource) convertMarketStringToEnum:(NSString*)market {
    if ([market isEqualToString:@"DASH_BTC"]) {
        return DCMarketDashBtc;
    }
    if ([market isEqualToString:@"DASH_USD"]) {
        return DCMarketDashUsd;
    }
    if ([market isEqualToString:@"DASH_EUR"]) {
        return DCMarketDashEuro;
    }
    return -1;
}

@end
