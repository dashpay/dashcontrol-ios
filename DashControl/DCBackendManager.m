//
//  ChartDataImportManager.m
//  DashControl
//
//  Created by Manuel Boyer on 22/08/2017.
//  Copyright © 2017 dashfoundation. All rights reserved.
//

#import "DCBackendManager.h"
#import <AFNetworking/AFNetworking.h>
//#import "Market+CoreDataClass.h"
//#import "Exchange+CoreDataClass.h"

#define DASHCONTROL_SERVER_VERSION 0

#define DASHCONTROL_SERVER [NSString stringWithFormat:@"http://dashpay.info/api/v%d/",DASHCONTROL_SERVER_VERSION]

#define DASHCONTROL_URL(x)  [DASHCONTROL_SERVER stringByAppendingString:x]

#define TICKER_REFRESH_TIME 60.0

#define DEFAULT_MARKET @"DEFAULT_MARKET"
#define DEFAULT_EXCHANGE @"DEFAULT_EXCHANGE"



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

@interface DCBackendManager ()
@property (nonatomic, strong) Reachability *reachability;
@end

@implementation DCBackendManager

#pragma mark - Singleton Init Methods

+ (id)sharedManager {
    static DCBackendManager *sharedChartDataImportManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedChartDataImportManager = [[self alloc] init];
    });
    return sharedChartDataImportManager;
}

- (id)init {
    if (self = [super init]) {
        self.mainObjectContext = [[(AppDelegate*)[[UIApplication sharedApplication] delegate] persistentContainer] viewContext];
        self.reachability = [Reachability reachabilityForInternetConnection];
        //[self getAllPriceData];
        [self fetchMarkets];
    }
    return self;
}

#pragma mark - Import Chart Data


-(void)getAllPriceData {
    
    NSDictionary * exchangePaths = @{@(DCExchangeSourceKraken):@[@(DCMarketDashBtc),@(DCMarketDashUsd)],@(DCExchangeSourcePoloniex):@[@(DCMarketDashBtc),@(DCMarketDashUsdt)],@(DCExchangeSourceBitfinex):@[@(DCMarketDashBtc),@(DCMarketDashUsd)]};
    
    for (NSString * exchangePath in exchangePaths) {
        NSArray * markets = [exchangePaths objectForKey:exchangePath];
        for (NSNumber * market in markets) {
            [self getChartDataForExchange:[exchangePath integerValue] forMarket:[market integerValue]];
        }
    }
    
    //Some historical poloniex chart data USD_DASH, so we can get started with the graph thing.
    //[self fetchHistoricalPoloniex];
}

-(void)fetchMarkets {
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    [manager GET:DASHCONTROL_URL(@"markets") parameters:nil progress:nil success:^(NSURLSessionTask *task, id responseObject) {
        NSPersistentContainer *container = [(AppDelegate*)[[UIApplication sharedApplication] delegate] persistentContainer];
        [container performBackgroundTask:^(NSManagedObjectContext *context) {
            
            if ([responseObject objectForKey:@"default"]) {
                NSDictionary * defaultMarketplace = [responseObject objectForKey:@"default"];
                if ([defaultMarketplace objectForKey:@"exchange"] && [defaultMarketplace objectForKey:@"market"]) {
                    NSUserDefaults * userDefaults = [NSUserDefaults standardUserDefaults];
                    [userDefaults setObject:[defaultMarketplace objectForKey:@"market"] forKey:DEFAULT_MARKET];
                    [userDefaults setObject:[defaultMarketplace objectForKey:@"exchange"] forKey:DEFAULT_EXCHANGE];
                    [userDefaults synchronize];
                }
            }
            if ([responseObject objectForKey:@"markets"]) {
                NSArray * markets = [[responseObject objectForKey:@"markets"] allKeys];
                NSArray * exchanges = [[[responseObject objectForKey:@"markets"] allValues] valueForKeyPath: @"@distinctUnionOfArrays.self"];
//                for (NSDictionary *jsonObject in [responseObject objectForKey:@"markets"]) {
//                    //Market *market = [NSEntityDescription insertNewObjectForEntityForName:@"Market" inManagedObjectContext:context];
//                    
//                }
//                context.automaticallyMergesChangesFromParent = TRUE;
//                context.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy;
//                
//                NSError * error = nil;
//                if (![context save:&error]) {
//                    NSLog(@"Failure to save context: %@\n%@", [error localizedDescription], [error userInfo]);
//                    abort();
//                }
            }

        }];

        NSLog(@"JSON: %@", responseObject);
    } failure:^(NSURLSessionTask *operation, NSError *error) {
        NSLog(@"Error: %@", error);
    }];
}

-(void)getChartDataForExchange:(DCExchangeSource)exchange forMarket:(DCMarketSource)market {
    NSURLSessionConfiguration* sessionConfig = [NSURLSessionConfiguration defaultSessionConfiguration];
    NSURLSession* session = [NSURLSession sessionWithConfiguration:sessionConfig delegate:nil delegateQueue:nil];
    NSURL* URL = [NSURL URLWithString:DASHCONTROL_URL(@"chart_data")];
    NSMutableDictionary *URLParams = [NSMutableDictionary new];
    NSString * exchangeString = [self convertExchangeEnumToString:exchange];
    NSString * marketString = [self convertMarketEnumToString:market];
    [URLParams setObject:exchangeString forKey:@"exchange"];
    [URLParams setObject:marketString forKey:@"market"];
#ifdef DEBUG
    [URLParams setObject:@"1" forKey:@"noLimit"];
#endif
    NSString * lastGetPath = [[exchangeString stringByAppendingString:marketString] stringByAppendingString:@"lastGet"];
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    if ([userDefaults objectForKey:lastGetPath]) {
        [URLParams setObject:[NSString stringWithFormat:@"%.0f", [[userDefaults objectForKey:lastGetPath] timeIntervalSince1970]] forKey:@"start"];
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
                [self importJSONData:jsonArray forExchange:exchange andMarket:market error:&e];
                if (!e) {
                    NSUserDefaults *defs = [NSUserDefaults standardUserDefaults];
                    [defs setObject:[NSDate date]  forKey:lastGetPath];
                    [defs synchronize];
                }
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

-(void)importJSONData:(NSArray*)jsonArray forExchange:(DCExchangeSource)exchange andMarket:(DCMarketSource)market error:(NSError**)error {
    
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
        
        context.automaticallyMergesChangesFromParent = TRUE;
        context.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy;
        
        
        if (![context save:error]) {
            NSLog(@"Failure to save context: %@\n%@", [*error localizedDescription], [*error userInfo]);
            abort();
        }
    }];
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
        case 3:
            result = @"DASH_USDT";
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
    if ([market isEqualToString:@"DASH_USDT"]) {
        return DCMarketDashUsdt;
    }
    return -1;
}

@end
