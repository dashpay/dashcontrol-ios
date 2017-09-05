//
//  ChartDataImportManager.m
//  DashControl
//
//  Created by Manuel Boyer on 22/08/2017.
//  Copyright © 2017 dashfoundation. All rights reserved.
//

#import "DCBackendManager.h"
#import <AFNetworking/AFNetworking.h>
#import "Market+CoreDataClass.h"
#import "Exchange+CoreDataClass.h"

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
        [self fetchMarkets: ^void (NSError * error, NSUInteger defaultExchangeIdentifier, NSUInteger defaultMarketIdentifier)
         {
             if (!error) {
                 NSError * innerError = nil;
                 Market * defaultMarket = [[DCCoreDataManager sharedManager] marketWithIdentifier:defaultMarketIdentifier inContext:self.mainObjectContext  error:&innerError];
                 Exchange * defaultExchange = innerError?nil:[[DCCoreDataManager sharedManager] exchangeWithIdentifier:defaultExchangeIdentifier inContext:self.mainObjectContext  error:&innerError];
                 if (!innerError) {
                     NSUserDefaults * userDefaults = [NSUserDefaults standardUserDefaults];
                     if (defaultMarket && ![[userDefaults objectForKey:DEFAULT_MARKET] isEqualToString:defaultMarket.name]) {
                         [userDefaults setObject:defaultMarket.name forKey:DEFAULT_MARKET];
                     }
                     if (defaultExchange && ![[userDefaults objectForKey:DEFAULT_EXCHANGE] isEqualToString:defaultExchange.name]) {
                         [userDefaults setObject:defaultExchange.name forKey:DEFAULT_EXCHANGE];
                     }
                     if (defaultExchange && defaultMarket && ![userDefaults objectForKey:CURRENT_EXCHANGE_MARKET_PAIR]) {
                         NSDictionary * currentMarketExchangePair = @{@"exchange":defaultExchange.name,@"market":defaultMarket.name};
                         [userDefaults setObject:currentMarketExchangePair forKey:CURRENT_EXCHANGE_MARKET_PAIR];
                     }
                     [userDefaults synchronize];
                     NSDictionary * currentMarketExchangePair = [userDefaults objectForKey:CURRENT_EXCHANGE_MARKET_PAIR];
                     if (currentMarketExchangePair && [currentMarketExchangePair objectForKey:@"exchange"] && [currentMarketExchangePair objectForKey:@"market"] ) {
                         NSError * innerError = nil;
                         NSDate *lastWeek  = [[NSDate date] dateByAddingTimeInterval: -1209600.0]; //one week ago
                         [self getChartDataForExchange:[currentMarketExchangePair objectForKey:@"exchange"] forMarket:[currentMarketExchangePair objectForKey:@"market"] start:lastWeek end:nil error:&innerError];
                     }
                 }
             }
         }];
    }
    return self;
}

#pragma mark - Import Chart Data


-(void)fetchMarkets:(void (^)(NSError * error, NSUInteger defaultExchangeIdentifier, NSUInteger defaultMarketIdentifier))clb {
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    [manager GET:DASHCONTROL_URL(@"markets") parameters:nil progress:nil success:^(NSURLSessionTask *task, id responseObject) {
        NSPersistentContainer *container = [(AppDelegate*)[[UIApplication sharedApplication] delegate] persistentContainer];
        [container performBackgroundTask:^(NSManagedObjectContext *context) {
            Market * defaultMarket = nil;
            Exchange * defaultExchange = nil;
            NSString * defaultMarketName = nil;
            NSString * defaultExchangeName = nil;
            if ([responseObject objectForKey:@"default"]) {
                NSDictionary * defaultMarketplace = [responseObject objectForKey:@"default"];
                if ([defaultMarketplace objectForKey:@"exchange"] && [defaultMarketplace objectForKey:@"market"]) {
                    defaultMarketName = [defaultMarketplace objectForKey:@"market"];
                    defaultExchangeName = [defaultMarketplace objectForKey:@"exchange"];
                }
            }
            if ([responseObject objectForKey:@"markets"]) {
                NSArray * markets = [[responseObject objectForKey:@"markets"] allKeys];
                NSArray * exchanges = [[[responseObject objectForKey:@"markets"] allValues] valueForKeyPath: @"@distinctUnionOfArrays.self"];
                NSError * error = nil;
                NSMutableArray * knownMarkets = [[[DCCoreDataManager sharedManager] marketsForNames:markets inContext:context error:&error] mutableCopy];
                NSMutableArray * knownExchanges = error?nil:[[[DCCoreDataManager sharedManager] exchangesForNames:exchanges inContext:context error:&error] mutableCopy];
                if (!error) {
                    NSArray * novelMarkets = [markets arrayByRemovingObjectsFromArray:[knownMarkets  arrayReferencedByKeyPath:@"name"]];
                    if (novelMarkets.count) {
                        NSInteger marketIdentifier = [[DCCoreDataManager sharedManager] fetchAutoIncrementIdForMarketinContext:context error:&error];
                        if (!error) {
                            for (NSString * marketName in novelMarkets) {
                                Market *market = [NSEntityDescription insertNewObjectForEntityForName:@"Market" inManagedObjectContext:context];
                                market.identifier = marketIdentifier;
                                market.name = marketName;
                                marketIdentifier++;
                                [knownMarkets addObject:market];
                            }
                        }
                    }
                }
                if (!error) {
                    NSArray * novelExchanges = [exchanges arrayByRemovingObjectsFromArray:[knownExchanges arrayReferencedByKeyPath:@"name"]];
                    if (novelExchanges.count) {
                        NSInteger exchangeIdentifier = [[DCCoreDataManager sharedManager] fetchAutoIncrementIdForExchangeinContext:context error:&error];
                        if (!error) {
                            for (NSString * exchangeName in novelExchanges) {
                                Exchange *exchange = [NSEntityDescription insertNewObjectForEntityForName:@"Exchange" inManagedObjectContext:context];
                                exchange.identifier = exchangeIdentifier;
                                exchange.name = exchangeName;
                                exchangeIdentifier++;
                                [knownExchanges addObject:exchange];
                            }
                        }
                    }
                }
                defaultMarket = [[knownMarkets filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"name = %@",defaultMarketName]] firstObject];
                defaultExchange = [[knownExchanges filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"name = %@",defaultExchangeName]] firstObject];
                if (!error) {
                    context.automaticallyMergesChangesFromParent = TRUE;
                    context.mergePolicy = NSRollbackMergePolicy;
                    
                    if (![context save:&error]) {
                        NSLog(@"Failure to save context: %@\n%@", [error localizedDescription], [error userInfo]);
                        abort();
                    }
                }
                
                //now let's make sure all the relationships are correct
                if (!error) {
                    NSDictionary * exchangeDictionary = [knownExchanges dictionaryReferencedByKeyPath:@"name"];
                    for (Market * market in knownMarkets) {
                        NSArray * serverExchangesForMarket = [[responseObject objectForKey:@"markets"] objectForKey:market.name];
                        NSArray * knownExchangesForMarket = [[market.onExchanges allObjects] arrayReferencedByKeyPath:@"name"];
                        NSArray * novelExchangesForMarket = [serverExchangesForMarket arrayByRemovingObjectsFromArray:knownExchangesForMarket];
                        for (NSString * novelExchangeForMarket in novelExchangesForMarket) {
                            Exchange * exchange = [exchangeDictionary objectForKey:novelExchangeForMarket];
                            [market addOnExchangesObject:exchange];
                        }
                    }
                    if (![context save:&error]) {
                        NSLog(@"Failure to save context: %@\n%@", [error localizedDescription], [error userInfo]);
                        abort();
                    }
                    
                }
                if (!error && defaultExchange && defaultMarket) {
                    NSUInteger defaultExhangeIdentifier = defaultExchange.identifier;
                    NSUInteger defaultMarketIdentifier = defaultMarket.identifier;
                    dispatch_async(dispatch_get_main_queue(), ^{
                        clb(error,defaultExhangeIdentifier,defaultMarketIdentifier);
                    });
                }
            }
            
        }];
    } failure:^(NSURLSessionTask *operation, NSError *error) {
        NSLog(@"Error: %@", error);
    }];
}

-(void)getChartDataForExchange:(NSString*)exchange forMarket:(NSString*)market start:(NSDate*)start end:(NSDate*)end error:(NSError**)error {
    //you may only pass either start or end
    if (start && end) {
        *error = [NSError errorWithDomain:DASH_CONTROL_ERROR_DOMAIN code:0 userInfo:@{NSLocalizedDescriptionKey : @"Trying to load a nil url"}];
        return;
    }
    NSURLSessionConfiguration* sessionConfig = [NSURLSessionConfiguration defaultSessionConfiguration];
    NSURLSession* session = [NSURLSession sessionWithConfiguration:sessionConfig delegate:nil delegateQueue:nil];
    NSURL* URL = [NSURL URLWithString:DASHCONTROL_URL(@"chart_data")];
    NSMutableDictionary *URLParams = [NSMutableDictionary new];
    [URLParams setObject:exchange forKey:@"exchange"];
    [URLParams setObject:market forKey:@"market"];
#ifdef DEBUG
    [URLParams setObject:@"1" forKey:@"noLimit"];
#endif
    NSString * chatDataIntervalStartPath = [[exchange stringByAppendingString:market] stringByAppendingString:@"chatDataIntervalStart"];
    NSString * chatDataIntervalEndPath = [[exchange stringByAppendingString:market] stringByAppendingString:@"chatDataIntervalEnd"];
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSDate * intervalStart = [userDefaults objectForKey:chatDataIntervalStartPath];
    NSDate * intervalEnd = [userDefaults objectForKey:chatDataIntervalEndPath];
    NSDate * realStart = nil;
    NSDate * realEnd = nil;
    NSDate * knownDataStart = nil;
    NSDate * knownDataEnd = nil;
    if (start) {
        //if start is set it must be before interval start if there's an interval start otherwise set it to the end of the interval
        if (!intervalStart) {
            realStart = start; //no interval yet
            knownDataStart = start;
        } else if ([start compare:intervalStart] != NSOrderedAscending) {
            realStart = intervalEnd; //after the interval
            knownDataStart = intervalStart;
        } else {
            realStart = start;
            knownDataStart = start;
            realEnd = intervalStart;
            knownDataEnd = intervalEnd;
        }
    } else if (end) {
        //if there is an end it must be after the interval end if there's an interval end otherwise set it to the start of the interval
        if (!intervalEnd) {
            realEnd = end;
            knownDataEnd = end;
        } else if ([end compare:intervalEnd] != NSOrderedDescending) {
            realEnd = intervalStart; //before the interval
            knownDataEnd = intervalEnd;
        } else {
            realEnd = end; //after the interval
            knownDataEnd = end;
            realStart = intervalEnd;
            knownDataStart = intervalStart;
        }
    }
    if (realEnd) {
        [URLParams setObject:[NSString stringWithFormat:@"%.0f", [realEnd timeIntervalSince1970]] forKey:@"end"];
    } else {
        realEnd = [NSDate date];
        knownDataEnd = realEnd;
    }
    if (realStart) {
        [URLParams setObject:[NSString stringWithFormat:@"%.0f", [realStart timeIntervalSince1970]] forKey:@"start"];
    } else {
        realStart = [NSDate distantPast];
        knownDataStart = realStart;
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
                [self importJSONData:jsonArray forExchange:exchange andMarket:market clb:^void(NSError * error) {
                    if (!error && chatDataIntervalEndPath) {
                        NSUserDefaults *defs = [NSUserDefaults standardUserDefaults];
                        if (![defs objectForKey:chatDataIntervalEndPath] || ([defs objectForKey:chatDataIntervalEndPath] && ([knownDataEnd compare:[defs objectForKey:chatDataIntervalEndPath]] != NSOrderedSame))) {
                            [defs setObject:knownDataEnd  forKey:chatDataIntervalEndPath];
                        }
                        if (![defs objectForKey:chatDataIntervalStartPath] || ([defs objectForKey:chatDataIntervalStartPath] && ([knownDataStart compare:[defs objectForKey:chatDataIntervalStartPath]] != NSOrderedSame))) {
                            [defs setObject:knownDataStart  forKey:chatDataIntervalStartPath];
                        }
                        [defs synchronize];
                    }
                }];
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

-(void)importJSONData:(NSArray*)jsonArray forExchange:(NSString*)exchangeName andMarket:(NSString*)marketName clb:(void (^)(NSError * error))clb {
    
    if (!jsonArray) {
        return;
    }
    
    NSPersistentContainer *container = [(AppDelegate*)[[UIApplication sharedApplication] delegate] persistentContainer];
    [container performBackgroundTask:^(NSManagedObjectContext *context) {
        
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        NSLocale *enUSPOSIXLocale = [NSLocale localeWithLocaleIdentifier:@"en_US_POSIX"];
        [dateFormatter setLocale:enUSPOSIXLocale];
        [dateFormatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss.SSSZ"];
        __block NSError * error;
        Market * market = [[DCCoreDataManager sharedManager] marketNamed:marketName inContext:context error:&error];
        Exchange * exchange = error?nil:[[DCCoreDataManager sharedManager] exchangeNamed:exchangeName inContext:context error:&error];
        if (!error && market && exchange) {
            context.automaticallyMergesChangesFromParent = TRUE;
            context.mergePolicy = NSOverwriteMergePolicy;
            NSInteger count = 0;
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
                chartDataEntry.marketIdentifier = exchange.identifier;
                chartDataEntry.exchangeIdentifier = exchange.identifier;
                count++;
                if (count % 2016 == 0) { //one week of data
                    if (![context save:&error]) {
                        NSLog(@"Failure to save context: %@\n%@", [error localizedDescription], [error userInfo]);
                        abort();
                    }
                }
            }
            
            if (![context save:&error]) {
                NSLog(@"Failure to save context: %@\n%@", [error localizedDescription], [error userInfo]);
                abort();
            }
            
            
            
            dispatch_async(dispatch_get_main_queue(), ^{
                clb(error);
            });
        } else {
            clb(error);
        }
    }];
}

@end
