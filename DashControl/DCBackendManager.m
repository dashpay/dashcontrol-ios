//
//  ChartDataImportManager.m
//  DashControl
//
//  Created by Manuel Boyer on 22/08/2017.
//  Copyright © 2017 dashfoundation. All rights reserved.
//

#import "DCBackendManager.h"
#import <AFNetworking/AFNetworking.h>
#import "DCMarketEntity+CoreDataClass.h"
#import "DCExchangeEntity+CoreDataClass.h"
#import "DCChartTimeFormatter.h"
#import <sys/utsname.h>
#import "NSURL+Sugar.h"
#import "DCEnvironment.h"

#define DASHCONTROL_SERVER_VERSION 0

#define PRODUCTION_URL @"https://dashpay.info"

#define DEVELOPMENT_URL @"https://dev.dashpay.info"

#define USE_PRODUCTION 0

#define DASHCONTROL_SERVER [NSString stringWithFormat:@"%@/api/v%d/",USE_PRODUCTION?PRODUCTION_URL:DEVELOPMENT_URL,DASHCONTROL_SERVER_VERSION]

#define DASHCONTROL_URL(x)  [DASHCONTROL_SERVER stringByAppendingString:x]
#define DASHCONTROL_MODIFY_URL(x,y) [NSString stringWithFormat:@"%@%@/%@",DASHCONTROL_SERVER,x,y]

#define TICKER_REFRESH_TIME 60.0

#define DEFAULT_MARKET @"DEFAULT_MARKET"
#define DEFAULT_EXCHANGE @"DEFAULT_EXCHANGE"

@interface DCBackendManager ()
@property (nonatomic, strong) Reachability *reachability;
@property (nonatomic, strong) NSDateFormatter * dateFormatter;
@property (nonatomic, strong) AFHTTPSessionManager * authenticatedManager;
@end

@implementation DCBackendManager

#pragma mark - Singleton Init Methods

+ (id)sharedInstance {
    static DCBackendManager *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[self alloc] init];
    });
    return sharedInstance;
}

- (id)init {
    if (self = [super init]) {
        
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        NSLocale *enUSPOSIXLocale = [NSLocale localeWithLocaleIdentifier:@"en_US_POSIX"];
        [dateFormatter setLocale:enUSPOSIXLocale];
        [dateFormatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss.SSSZ"];
        [dateFormatter setTimeZone:[NSTimeZone timeZoneWithAbbreviation:@"UTC"]];
        self.dateFormatter = dateFormatter;
        self.persistentContainer = [(AppDelegate*)[[UIApplication sharedApplication] delegate] persistentContainer];
        self.mainObjectContext = [[(AppDelegate*)[[UIApplication sharedApplication] delegate] persistentContainer] viewContext];
        self.reachability = [Reachability reachabilityForInternetConnection];
        [self startUp];
    }
    return self;
}

#pragma mark - start up

-(void)startUpFetchMarkets:(void (^)(NSError * error))completion {
    [self fetchMarkets: ^void (NSError * error, NSUInteger defaultExchangeIdentifier, NSUInteger defaultMarketIdentifier)
     {
         if (!error) {
             NSError * innerError = nil;
             DCMarketEntity * defaultMarket = [[DCCoreDataManager sharedInstance] marketWithIdentifier:defaultMarketIdentifier inContext:self.mainObjectContext  error:&innerError];
             DCExchangeEntity * defaultExchange = innerError?nil:[[DCCoreDataManager sharedInstance] exchangeWithIdentifier:defaultExchangeIdentifier inContext:self.mainObjectContext  error:&innerError];
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
                     NSDate *lastWeek  = [[NSDate date] dateByAddingTimeInterval: -1209600.0]; //one week ago
                     [self getChartDataForExchange:[currentMarketExchangePair objectForKey:@"exchange"] forMarket:[currentMarketExchangePair objectForKey:@"market"] start:lastWeek end:nil clb:^(NSError *error) {
                         //to do error handling
                         //[[NSNotificationCenter defaultCenter] postNotificationName:ERROR object:];
                     }];
                 }
                 if (completion) completion(nil);
             } else {
                 if (completion) completion(innerError);
             }
         } else {
             if (completion) completion(error);
         }
     }];
}

-(void)startUpFetchTriggers {
    [self getTriggers:^(NSError *triggerError,NSUInteger statusCode, NSArray *responseObject) {
        if (statusCode/100 == 2) {
            NSPersistentContainer *container = [(AppDelegate*)[[UIApplication sharedApplication] delegate] persistentContainer];
            [container performBackgroundTask:^(NSManagedObjectContext *context) {
                if (!triggerError) {
                    NSDictionary * triggerIdentifiers = [responseObject dictionaryReferencedByKeyPath:@"identifier"] ;
                    NSError * error = nil;
                    NSDictionary * knownTriggerIdentifiers = [[[DCCoreDataManager sharedInstance] triggersInContext:context error:&error] dictionaryReferencedByKeyPath:@"identifier"];
                    if (!error) {
                        NSArray * triggerIdentifierKeys = [triggerIdentifiers allKeys];
                        NSArray * knownTriggerIdentifierKeys = [knownTriggerIdentifiers allKeys];
                        NSArray * novelTriggerIdentifiers = [triggerIdentifierKeys arrayByRemovingObjectsFromArray:knownTriggerIdentifierKeys];
                        for (NSString * identifier in novelTriggerIdentifiers) {
                            NSDictionary * triggerToAdd = triggerIdentifiers[identifier];
                            DCTriggerEntity *trigger = [NSEntityDescription insertNewObjectForEntityForName:@"DCTriggerEntity" inManagedObjectContext:context];
                            trigger.identifier = [triggerToAdd[@"identifier"] longLongValue];
                            trigger.value = [triggerToAdd[@"value"] longLongValue];
                            trigger.type = [DCTrigger typeForNetworkString:triggerToAdd[@"type"]];
                            trigger.consume = [triggerToAdd[@"consume"] boolValue];
                            trigger.ignoreFor = [triggerToAdd[@"ignoreFor"] longLongValue];
                            NSString * exchangeName = triggerToAdd[@"echange"];
                            if (exchangeName) {
                                trigger.exchangeNamed = exchangeName;
                                trigger.exchange = [[DCCoreDataManager sharedInstance] exchangeNamed:exchangeName inContext:context error:&error];
                                if (error) return;
                            }
                            
                            NSString * marketName = triggerToAdd[@"market"];
                            trigger.marketNamed = marketName;
                            trigger.market = [[DCCoreDataManager sharedInstance] marketNamed:marketName inContext:context error:&error];
                            if (error) return;
                            
                        }
                        NSArray * deleteTriggerIdentifiers = [knownTriggerIdentifierKeys arrayByRemovingObjectsFromArray:triggerIdentifierKeys];
                        for (NSString * identifier in deleteTriggerIdentifiers) {
                            DCTriggerEntity * trigger = [knownTriggerIdentifiers objectForKey:identifier];
                            [context deleteObject:trigger];
                        }
                        context.automaticallyMergesChangesFromParent = TRUE;
                        context.mergePolicy = NSMergeByPropertyStoreTrumpMergePolicy;
                        if (![context save:&error]) {
                            NSLog(@"Failure to save context: %@\n%@", [error localizedDescription], [error userInfo]);
                            abort();
                        }
                    }
                }
            }];
        }
    }];
}

-(void)startUp {
    [self startUpFetchMarkets:^(NSError *marketError) {
        if (!marketError) {
            NSError * error = nil;
            BOOL hasRegistered = [[DCEnvironment sharedInstance] hasRegisteredWithError:&error];
            if (!error && hasRegistered) {
                [self startUpFetchTriggers];
            }
        }
    }];
    
}

-(AFHTTPSessionManager*)authenticatedManager {
    
    if (!_authenticatedManager) {
        @synchronized(self) {
            if (!_authenticatedManager) { //a second time, this time synchronized
                AFHTTPSessionManager *manager = [[AFHTTPSessionManager alloc] initWithSessionConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];
                [manager.requestSerializer setAuthorizationHeaderFieldWithUsername:[[DCEnvironment sharedInstance] deviceId] password:[[DCEnvironment sharedInstance] devicePassword]];
                self.authenticatedManager = manager;
            }
        }
    }
    return _authenticatedManager;
    
}

#pragma mark - Import Chart Data


-(void)fetchMarkets:(void (^)(NSError * error, NSUInteger defaultExchangeIdentifier, NSUInteger defaultMarketIdentifier))clb {
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    [manager GET:DASHCONTROL_URL(@"markets") parameters:nil progress:nil success:^(NSURLSessionTask *task, id responseObject) {
        NSPersistentContainer *container = [(AppDelegate*)[[UIApplication sharedApplication] delegate] persistentContainer];
        [container performBackgroundTask:^(NSManagedObjectContext *context) {
            DCMarketEntity * defaultMarket = nil;
            DCExchangeEntity * defaultExchange = nil;
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
                NSMutableArray * knownMarkets = [[[DCCoreDataManager sharedInstance] marketsForNames:markets inContext:context error:&error] mutableCopy];
                NSMutableArray * knownExchanges = error?nil:[[[DCCoreDataManager sharedInstance] exchangesForNames:exchanges inContext:context error:&error] mutableCopy];
                if (!error) {
                    NSArray * novelMarkets = [markets arrayByRemovingObjectsFromArray:[knownMarkets  arrayReferencedByKeyPath:@"name"]];
                    if (novelMarkets.count) {
                        NSInteger marketIdentifier = [[DCCoreDataManager sharedInstance] fetchAutoIncrementIdForMarketInContext:context error:&error];
                        if (!error) {
                            for (NSString * marketName in novelMarkets) {
                                DCMarketEntity *market = [NSEntityDescription insertNewObjectForEntityForName:@"DCMarketEntity" inManagedObjectContext:context];
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
                        NSInteger exchangeIdentifier = [[DCCoreDataManager sharedInstance] fetchAutoIncrementIdForExchangeinContext:context error:&error];
                        if (!error) {
                            for (NSString * exchangeName in novelExchanges) {
                                DCExchangeEntity *exchange = [NSEntityDescription insertNewObjectForEntityForName:@"DCExchangeEntity" inManagedObjectContext:context];
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
                    for (DCMarketEntity * market in knownMarkets) {
                        NSArray * serverExchangesForMarket = [[responseObject objectForKey:@"markets"] objectForKey:market.name];
                        NSArray * knownExchangesForMarket = [[market.onExchanges allObjects] arrayReferencedByKeyPath:@"name"];
                        NSArray * novelExchangesForMarket = [serverExchangesForMarket arrayByRemovingObjectsFromArray:knownExchangesForMarket];
                        for (NSString * novelExchangeForMarket in novelExchangesForMarket) {
                            DCExchangeEntity * exchange = [exchangeDictionary objectForKey:novelExchangeForMarket];
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

-(void)getChartDataForExchange:(NSString*)exchange forMarket:(NSString*)market start:(NSDate*)start end:(NSDate*)end clb:(void (^)(NSError * error))clb {
    //you may only pass either start or end
    if (start && end) {
        return clb([NSError errorWithDomain:DASH_CONTROL_ERROR_DOMAIN code:0 userInfo:@{NSLocalizedDescriptionKey : @"You can not supply both start and end"}]);
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
    
    NSDate * intervalStart = [DCChartTimeFormatter intervalStartForExchangeNamed:exchange marketNamed:market];
    NSDate * intervalEnd = [DCChartTimeFormatter intervalEndForExchangeNamed:exchange marketNamed:market];
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
    URL = [URL URLByAppendingQueryParameters:URLParams];
    NSMutableURLRequest* request = [NSMutableURLRequest requestWithURL:URL];
    request.HTTPMethod = @"GET";
    
    NSURLSessionDataTask* task = [session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        if (error == nil) {
            
            if (((((NSHTTPURLResponse*)response).statusCode /100) != 2)) {
                NSLog(@"Status %ld",(long)((NSHTTPURLResponse*)response).statusCode);
                NSString* ErrorResponse = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
                NSLog(@"ErrorResponse:%@",ErrorResponse);
                dispatch_async(dispatch_get_main_queue(), ^{
                    return clb([NSError errorWithDomain:DASH_CONTROL_ERROR_DOMAIN code:((NSHTTPURLResponse*)response).statusCode userInfo:@{NSLocalizedDescriptionKey : @"Server returned a non 200 http response"}]);
                });
                
            }
            NSError *e = nil;
            NSArray *jsonArray = [NSJSONSerialization JSONObjectWithData:data options: NSJSONReadingMutableContainers error:&e];
            
            if (!e) {
                [self importJSONData:jsonArray forExchange:exchange andMarket:market clb:^void(NSError * error) {
                    if (!error) {
                        NSUserDefaults *defs = [NSUserDefaults standardUserDefaults];
                        NSString * chartDataIntervalStartPath = [DCChartTimeFormatter chartDataIntervalStartPathForExchangeNamed:exchange marketNamed:market];
                        NSString * chartDataIntervalEndPath = [DCChartTimeFormatter chartDataIntervalEndPathForExchangeNamed:exchange marketNamed:market];
                        if (![defs objectForKey:chartDataIntervalEndPath] || ([defs objectForKey:chartDataIntervalEndPath] && ([knownDataEnd compare:[defs objectForKey:chartDataIntervalEndPath]] != NSOrderedSame))) {
                            [defs setObject:knownDataEnd  forKey:chartDataIntervalEndPath];
                        }
                        if (![defs objectForKey:chartDataIntervalStartPath] || ([defs objectForKey:chartDataIntervalStartPath] && ([knownDataStart compare:[defs objectForKey:chartDataIntervalStartPath]] != NSOrderedSame))) {
                            [defs setObject:knownDataStart  forKey:chartDataIntervalStartPath];
                        }
                        [defs synchronize];
                    }
                    dispatch_async(dispatch_get_main_queue(), ^{
                        return clb(error);
                    });
                }];
            } else {
                dispatch_async(dispatch_get_main_queue(), ^{
                    return clb(e);
                });
            }
        }
        else {
            // Failure
            NSLog(@"URL Session Task Failed: %@", [error localizedDescription]);
            dispatch_async(dispatch_get_main_queue(), ^{
                return clb(error);
            });
        }
    }];
    
    [task resume];
    [session finishTasksAndInvalidate];
}

-(void)importJSONData:(NSArray*)jsonArray forExchange:(NSString*)exchangeName andMarket:(NSString*)marketName clb:(void (^)(NSError * error))clb {
    
    if (!jsonArray) {
        return;
    }
    
    
    [self.persistentContainer performBackgroundTask:^(NSManagedObjectContext *context) {
        __block NSError * error;
        DCMarketEntity * market = [[DCCoreDataManager sharedInstance] marketNamed:marketName inContext:context error:&error];
        DCExchangeEntity * exchange = error?nil:[[DCCoreDataManager sharedInstance] exchangeNamed:exchangeName inContext:context error:&error];
        if (!error && market && exchange && [jsonArray count]) {
            context.automaticallyMergesChangesFromParent = TRUE;
            context.mergePolicy = NSMergeByPropertyStoreTrumpMergePolicy;
            NSInteger count = 0;
            
#define FormatChartTimeInterval(x) [NSString stringWithFormat:@"CT%ld",(long)x]
            
            
            
            [[jsonArray firstObject] setObject:[NSNumber numberWithBool:true] forKey:@"isFirst"];
            
            [[jsonArray lastObject] setObject:[NSNumber numberWithBool:true] forKey:@"isLast"];
            
            for (NSMutableDictionary *jsonObject in jsonArray) {
                NSDate * date = [self.dateFormatter dateFromString:[jsonObject objectForKey:@"time"]];
                NSTimeInterval timestamp = [date timeIntervalSince1970];
                [jsonObject setObject:date forKey:@"time"];
                [jsonObject setObject:@(floor(timestamp/900.0)) forKey:FormatChartTimeInterval(ChartTimeInterval_15Mins)];
                [jsonObject setObject:@(floor(timestamp/1800.0)) forKey:FormatChartTimeInterval(ChartTimeInterval_30Mins)];
                [jsonObject setObject:@(floor(timestamp/7200.0)) forKey:FormatChartTimeInterval(ChartTimeInterval_2Hour)];
                [jsonObject setObject:@(floor(timestamp/14400.0)) forKey:FormatChartTimeInterval(ChartTimeInterval_4Hours)];
                [jsonObject setObject:@(floor(timestamp/86400.0)) forKey:FormatChartTimeInterval(ChartTimeInterval_1Day)];
            }
            
            
            
            for (int chartTimeInterval=1;chartTimeInterval<=ChartTimeInterval_1Day;chartTimeInterval++) {
                if (!error) {
                    @autoreleasepool {
                        NSDictionary * jsonGroupedArray = [jsonArray mutableDictionaryOfMutableArraysReferencedByKeyPath:FormatChartTimeInterval(chartTimeInterval)];
                        
                        for (NSNumber *intervalNumber in jsonGroupedArray) {
                            NSMutableArray * intervalArray = [jsonGroupedArray objectForKey:intervalNumber];
                            
                            //there's a slight problem that needs addressing before we start computing aggregates.
                            //Data is returned from the server by 5 minute intervals.
                            //To get proper longer intervals we need to combine this with local 5 minute interval data
                            //And then do the aggregates
                            
                            NSDate * intervalStartTime = [NSDate dateWithTimeIntervalSince1970:[[[intervalArray firstObject] objectForKey:FormatChartTimeInterval(chartTimeInterval)] doubleValue] * [DCChartTimeFormatter timeIntervalForChartTimeInterval:chartTimeInterval]];
                            
                            
                            if ([[intervalArray firstObject] objectForKey:@"isFirst"]) {
                                NSDate * additionalDataPointIntervalEndTime = [[[intervalArray firstObject] objectForKey:@"time"] dateByAddingTimeInterval:-[DCChartTimeFormatter timeIntervalForChartTimeInterval:ChartTimeInterval_5Mins]];
                                if ([additionalDataPointIntervalEndTime compare:intervalStartTime] == NSOrderedDescending) {
                                    NSArray * additionalDataPoints = [[DCCoreDataManager sharedInstance] fetchChartDataForExchangeIdentifier:exchange.identifier forMarketIdentifier:market.identifier interval:ChartTimeInterval_5Mins startTime:intervalStartTime endTime:additionalDataPointIntervalEndTime inContext:context error:&error];
                                    for (DCChartDataEntryEntity * chartDataEntry in [additionalDataPoints reverseObjectEnumerator]) {
                                        NSMutableDictionary * additionalDataPoint = [NSMutableDictionary dictionary];
                                        [additionalDataPoint setObject:[chartDataEntry valueForKey:@"time"] forKey:@"time"];
                                        [additionalDataPoint setObject:[chartDataEntry valueForKey:@"open"] forKey:@"open"];
                                        [additionalDataPoint setObject:[chartDataEntry valueForKey:@"high"] forKey:@"high"];
                                        [additionalDataPoint setObject:[chartDataEntry valueForKey:@"low"] forKey:@"low"];
                                        [additionalDataPoint setObject:[chartDataEntry valueForKey:@"close"] forKey:@"close"];
                                        [additionalDataPoint setObject:[chartDataEntry valueForKey:@"volume"] forKey:@"volume"];
                                        [additionalDataPoint setObject:[chartDataEntry valueForKey:@"pairVolume"] forKey:@"pairVolume"];
                                        [additionalDataPoint setObject:[chartDataEntry valueForKey:@"trades"] forKey:@"trades"];
                                        [intervalArray insertObject:additionalDataPoint atIndex:0];
                                    }
                                }
                            } else if ([[intervalArray firstObject] objectForKey:@"isLast"]) {
                                NSDate * additionalDataPointIntervalStartTime = [[[intervalArray lastObject] objectForKey:@"time"] dateByAddingTimeInterval:[DCChartTimeFormatter timeIntervalForChartTimeInterval:ChartTimeInterval_5Mins]];
                                NSDate * additionalDataPointIntervalEndTime = [intervalStartTime dateByAddingTimeInterval:[DCChartTimeFormatter timeIntervalForChartTimeInterval:chartTimeInterval]];
                                NSArray * additionalDataPoints = [[DCCoreDataManager sharedInstance] fetchChartDataForExchangeIdentifier:exchange.identifier forMarketIdentifier:market.identifier interval:ChartTimeInterval_5Mins startTime:additionalDataPointIntervalStartTime endTime:additionalDataPointIntervalEndTime inContext:context error:&error];
                                for (DCChartDataEntryEntity * chartDataEntry in additionalDataPoints) {
                                    NSMutableDictionary * additionalDataPoint = [NSMutableDictionary dictionary];
                                    [additionalDataPoint setObject:[chartDataEntry valueForKey:@"time"] forKey:@"time"];
                                    [additionalDataPoint setObject:[chartDataEntry valueForKey:@"open"] forKey:@"open"];
                                    [additionalDataPoint setObject:[chartDataEntry valueForKey:@"high"] forKey:@"high"];
                                    [additionalDataPoint setObject:[chartDataEntry valueForKey:@"low"] forKey:@"low"];
                                    [additionalDataPoint setObject:[chartDataEntry valueForKey:@"close"] forKey:@"close"];
                                    [additionalDataPoint setObject:[chartDataEntry valueForKey:@"volume"] forKey:@"volume"];
                                    [additionalDataPoint setObject:[chartDataEntry valueForKey:@"pairVolume"] forKey:@"pairVolume"];
                                    [additionalDataPoint setObject:[chartDataEntry valueForKey:@"trades"] forKey:@"trades"];
                                    [intervalArray addObject:additionalDataPoint];
                                }
                            }
                            if (error) break;
                            
                            DCChartDataEntryEntity *chartDataEntry = (DCChartDataEntryEntity*)[NSEntityDescription insertNewObjectForEntityForName:@"DCChartDataEntryEntity" inManagedObjectContext:context];
                            chartDataEntry.time = intervalStartTime;
                            chartDataEntry.open = [[[intervalArray firstObject] objectForKey:@"open"] doubleValue];
                            chartDataEntry.high = [[intervalArray valueForKeyPath:@"@max.high"] doubleValue];
                            chartDataEntry.low = [[intervalArray valueForKeyPath:@"@min.low"] doubleValue];
                            chartDataEntry.close = [[[intervalArray lastObject] objectForKey:@"close"] doubleValue];
                            chartDataEntry.volume = [[intervalArray valueForKeyPath:@"@sum.volume"] doubleValue];
                            chartDataEntry.pairVolume = [[intervalArray valueForKeyPath:@"@sum.pairVolume"] doubleValue];
                            chartDataEntry.trades = [[intervalArray valueForKeyPath:@"@sum.trades"] longValue];
                            chartDataEntry.marketIdentifier = market.identifier;
                            chartDataEntry.exchangeIdentifier = exchange.identifier;
                            chartDataEntry.interval = chartTimeInterval;
                            count++;
                            if (count % 2016 == 0) { //one week of data
                                if (![context save:&error]) {
                                    NSLog(@"Failure to save context: %@\n%@", [error localizedDescription], [error userInfo]);
                                    abort();
                                    break;
                                }
                            }
                        }
                    }
                }
            }
            if (!error) {
                
                for (NSDictionary *jsonObject in jsonArray) {
                    DCChartDataEntryEntity *chartDataEntry = (DCChartDataEntryEntity*)[NSEntityDescription insertNewObjectForEntityForName:@"DCChartDataEntryEntity" inManagedObjectContext:context];
                    chartDataEntry.time = [jsonObject objectForKey:@"time"];
                    chartDataEntry.open = [[jsonObject objectForKey:@"open"] doubleValue];
                    chartDataEntry.high = [[jsonObject objectForKey:@"high"] doubleValue];
                    chartDataEntry.low = [[jsonObject objectForKey:@"low"] doubleValue];
                    chartDataEntry.close = [[jsonObject objectForKey:@"close"] doubleValue];
                    chartDataEntry.volume = [[jsonObject objectForKey:@"volume"] doubleValue];
                    chartDataEntry.pairVolume = [[jsonObject objectForKey:@"pairVolume"] doubleValue];
                    chartDataEntry.trades = [[jsonObject objectForKey:@"trades"] longValue];
                    chartDataEntry.marketIdentifier = market.identifier;
                    chartDataEntry.exchangeIdentifier = exchange.identifier;
                    chartDataEntry.interval = ChartTimeInterval_5Mins;
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
                
            }
            
            dispatch_async(dispatch_get_main_queue(), ^{
                clb(error);
            });
        } else {
            clb(error);
        }
    }];
}

#pragma mark - Registering

-(void)registerDeviceForDeviceToken:(NSData*)deviceToken {
    
    struct utsname systemInfo;
    uname(&systemInfo);
    NSString * deviceName = [NSString stringWithCString:systemInfo.machine encoding:NSUTF8StringEncoding];
    
    NSString *token_string = [[[[deviceToken description]    stringByReplacingOccurrencesOfString:@"<"withString:@""]
                               stringByReplacingOccurrencesOfString:@">" withString:@""]
                              stringByReplacingOccurrencesOfString: @" " withString: @""];
    
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    
    
    NSMutableDictionary* parameters = [@{
                                         @"version": [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleShortVersionString"],
                                         @"model": deviceName,
                                         @"os": @"ios",
                                         @"device_id": [[DCEnvironment sharedInstance] deviceId],
                                         @"password": [[DCEnvironment sharedInstance] devicePassword],
                                         @"os_version": [[UIDevice currentDevice] systemVersion],
                                         @"app_name": @"dashcontrol",
                                         } mutableCopy];
    
    if (token_string && ![token_string isEqualToString:@""]) {
        [parameters setObject:token_string forKey:@"token"];
    }
    
    [manager POST:DASHCONTROL_URL(@"device") parameters:parameters progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        [[DCEnvironment sharedInstance] setHasRegistered];
        NSLog(@"Device registered %@", token_string);
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        NSLog(@"URL Session Task Failed: %@", [error localizedDescription]);
    }];
}

#pragma mark - Trigger

-(void)postTrigger:(DCTrigger* _Nonnull)trigger completion:(void (^ _Nullable)(NSError * _Nullable error,NSUInteger statusCode, id  _Nullable responseObject))completion {
    [self.authenticatedManager POST:DASHCONTROL_URL(@"trigger") parameters: @{ @"value":trigger.value, @"type":[DCTrigger networkStringForType:trigger.type], @"market":trigger.market, @"exchange":trigger.exchange?trigger.exchange:@"any", @"standardize_tether":@(trigger.standardizeTether)} progress:^(NSProgress * _Nonnull uploadProgress) {
        
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)task.response;
        if (completion) completion(nil,httpResponse.statusCode,responseObject);
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)task.response;
        if (completion) completion(error,httpResponse.statusCode,nil);
    }];
}

-(void)deleteTriggerWithId:(u_int64_t)triggerId completion:(void (^ _Nullable)(NSError * _Nullable error,NSUInteger statusCode, id  _Nullable responseObject))completion {
    [self.authenticatedManager DELETE:DASHCONTROL_MODIFY_URL(@"trigger",@(triggerId)) parameters: @{}
                              success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
                                  NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)task.response;
                                  if (completion) completion(nil,httpResponse.statusCode,responseObject);
                              } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
                                  NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)task.response;
                                  if (completion) completion(error,httpResponse.statusCode,nil);
                              }];
}


-(void)getTriggers:(void (^)(NSError * error,NSUInteger statusCode, NSArray * triggers))completion {
    [self.authenticatedManager GET:DASHCONTROL_URL(@"trigger") parameters:nil progress:nil success:^(NSURLSessionTask *task, id responseObject) {
        NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)task.response;
        if (completion) completion(nil,httpResponse.statusCode,responseObject);
    } failure:^(NSURLSessionTask *task, NSError *error) {
        NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)task.response;
        if (completion) completion(error,httpResponse.statusCode,nil);
    }];
}

#pragma mark - Notifications

-(void)updateBloomFilter:(DCServerBloomFilter*)filter completion:(void (^)(NSError * error))completion {
    [self.authenticatedManager POST:DASHCONTROL_URL(@"filter") parameters:@{@"filter":[filter.filterData base64EncodedStringWithOptions:0],@"filter_length":@(filter.length),@"hash_count":@(filter.hashFuncs)} progress:^(NSProgress * _Nonnull uploadProgress) {
        
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        if (completion) completion(nil);
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        if (completion) completion(error);
    }];
}

@end
