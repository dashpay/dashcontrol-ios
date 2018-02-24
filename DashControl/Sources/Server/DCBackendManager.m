//
//  ChartDataImportManager.m
//  DashControl
//
//  Created by Manuel Boyer on 22/08/2017.
//  Copyright © 2017 dashfoundation. All rights reserved.
//

#import "DCBackendManager.h"

#import "DCMarketEntity+CoreDataClass.h"
#import "DCExchangeEntity+CoreDataClass.h"
#import "DCChartTimeFormatter.h"
#import <sys/utsname.h>
#import "NSURL+Sugar.h"
#import "DCEnvironment.h"
#import "Networking.h"
#import "APIPrice.h"
#import "DCPersistenceStack.h"

#define DASHCONTROL_SERVER_VERSION 0

#define PRODUCTION_URL @"https://dashpay.info"

#define DEVELOPMENT_URL @"https://dev.dashpay.info"

#define USE_PRODUCTION 1

#define DASHCONTROL_SERVER [NSString stringWithFormat:@"%@/api/v%d/",USE_PRODUCTION?PRODUCTION_URL:DEVELOPMENT_URL,DASHCONTROL_SERVER_VERSION]

#define DASHCONTROL_URL(x)  [DASHCONTROL_SERVER stringByAppendingString:x]
#define DASHCONTROL_MODIFY_URL(x,y) [NSString stringWithFormat:@"%@%@/%@",DASHCONTROL_SERVER,x,y]

#define TICKER_REFRESH_TIME 60.0

#define DEFAULT_MARKET @"DEFAULT_MARKET"
#define DEFAULT_EXCHANGE @"DEFAULT_EXCHANGE"

@interface DCBackendManager ()
@property (nonatomic, strong) Reachability *reachability;
@property (nonatomic, strong) NSDateFormatter * dateFormatter;
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
             NSManagedObjectContext *viewContext = self.stack.persistentContainer.viewContext;
             NSError * innerError = nil;
             DCMarketEntity * defaultMarket = [[DCCoreDataManager sharedInstance] marketWithIdentifier:defaultMarketIdentifier inContext:viewContext  error:&innerError];
             DCExchangeEntity * defaultExchange = innerError?nil:[[DCCoreDataManager sharedInstance] exchangeWithIdentifier:defaultExchangeIdentifier inContext:viewContext  error:&innerError];
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
                     NSError *error = nil;
                     DCExchangeEntity *exchange = [[DCCoreDataManager sharedInstance] exchangeNamed:[currentMarketExchangePair objectForKey:@"exchange"] inContext:viewContext error:&error];
                     DCMarketEntity * market = [[DCCoreDataManager sharedInstance] marketNamed:[currentMarketExchangePair objectForKey:@"market"] inContext:viewContext error:&error];
                     [self.apiPrice fetchChartDataForExchange:exchange market:market start:lastWeek end:nil completion:^(BOOL success) {
                         
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
            NSPersistentContainer *container = self.stack.persistentContainer;
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
                            trigger.value = [triggerToAdd[@"value"] doubleValue];
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

#pragma mark - Import Chart Data


-(void)fetchMarkets:(void (^)(NSError * error, NSUInteger defaultExchangeIdentifier, NSUInteger defaultMarketIdentifier))clb {
    NSURL *url = [NSURL URLWithString:DASHCONTROL_URL(@"markets")];
    HTTPRequest *request = [HTTPRequest requestWithURL:url method:HTTPRequestMethod_GET parameters:nil];
    [self.httpManager sendRequest:request completion:^(id  _Nullable parsedData, NSDictionary * _Nullable responseHeaders, NSInteger statusCode, NSError * _Nullable error) {
        if (error) {
            // TODO: handle error
            NSLog(@"%@", error);
            return;
        }
        
        NSPersistentContainer *container = self.stack.persistentContainer;
        [container performBackgroundTask:^(NSManagedObjectContext *context) {
            DCMarketEntity * defaultMarket = nil;
            DCExchangeEntity * defaultExchange = nil;
            NSString * defaultMarketName = nil;
            NSString * defaultExchangeName = nil;
            if ([parsedData objectForKey:@"default"]) {
                NSDictionary * defaultMarketplace = [parsedData objectForKey:@"default"];
                if ([defaultMarketplace objectForKey:@"exchange"] && [defaultMarketplace objectForKey:@"market"]) {
                    defaultMarketName = [defaultMarketplace objectForKey:@"market"];
                    defaultExchangeName = [defaultMarketplace objectForKey:@"exchange"];
                }
            }
            if ([parsedData objectForKey:@"markets"]) {
                NSArray * markets = [[parsedData objectForKey:@"markets"] allKeys];
                NSArray * exchanges = [[[parsedData objectForKey:@"markets"] allValues] valueForKeyPath: @"@distinctUnionOfArrays.self"];
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
                        NSArray * serverExchangesForMarket = [[parsedData objectForKey:@"markets"] objectForKey:market.name];
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
    }];
}

#pragma mark - Registering

-(void)registerDeviceForDeviceToken:(NSData*)deviceToken {
    NSURL *url = [NSURL URLWithString:DASHCONTROL_URL(@"device")];
    
    struct utsname systemInfo;
    uname(&systemInfo);
    NSString * deviceName = [NSString stringWithCString:systemInfo.machine encoding:NSUTF8StringEncoding];
    
    NSString *token_string = [[[[deviceToken description]    stringByReplacingOccurrencesOfString:@"<"withString:@""]
                               stringByReplacingOccurrencesOfString:@">" withString:@""]
                              stringByReplacingOccurrencesOfString: @" " withString: @""];
    
    
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
    HTTPRequest *request = [HTTPRequest requestWithURL:url method:HTTPRequestMethod_POST parameters:parameters];
    [self.httpManager sendRequest:request completion:^(id  _Nullable parsedData, NSDictionary * _Nullable responseHeaders, NSInteger statusCode, NSError * _Nullable error) {
        if (error) {
            NSLog(@"%@", error);
        }
        else {
            [[DCEnvironment sharedInstance] setHasRegistered];
        }
    }];
}

#pragma mark - Trigger

-(void)postTrigger:(DCTrigger* _Nonnull)trigger completion:(void (^ _Nullable)(NSError * _Nullable error,NSUInteger statusCode, id  _Nullable responseObject))completion {
    NSURL *url = [NSURL URLWithString:DASHCONTROL_URL(@"trigger")];
    NSDictionary *parameters = @{
                                 @"value": trigger.value,
                                 @"type": [DCTrigger networkStringForType:trigger.type],
                                 @"market": trigger.market,
                                 @"exchange": trigger.exchange ? trigger.exchange : @"any",
                                 @"standardize_tether": @(trigger.standardizeTether)
                                 };
    HTTPRequest *request = [HTTPRequest requestWithURL:url method:HTTPRequestMethod_POST parameters:parameters];
    [self sendAuthorizedRequest:request completion:^(id  _Nullable parsedData, NSDictionary * _Nullable responseHeaders, NSInteger statusCode, NSError * _Nullable error) {
        if (completion) {
            completion(error, statusCode, parsedData);
        }
    }];
}

-(void)deleteTriggerWithId:(u_int64_t)triggerId completion:(void (^ _Nullable)(NSError * _Nullable error,NSUInteger statusCode, id  _Nullable responseObject))completion {
    NSURL *url = [NSURL URLWithString:DASHCONTROL_MODIFY_URL(@"trigger", @(triggerId))];
    HTTPRequest *request = [HTTPRequest requestWithURL:url method:HTTPRequestMethod_DELETE parameters:nil];
    [self sendAuthorizedRequest:request completion:^(id  _Nullable parsedData, NSDictionary * _Nullable responseHeaders, NSInteger statusCode, NSError * _Nullable error) {
        if (completion) {
            completion(error, statusCode, parsedData);
        }
    }];
}


-(void)getTriggers:(void (^)(NSError * error,NSUInteger statusCode, NSArray * triggers))completion {
    NSURL *url = [NSURL URLWithString:DASHCONTROL_URL(@"trigger")];
    HTTPRequest *request = [HTTPRequest requestWithURL:url method:HTTPRequestMethod_GET parameters:nil];
    [self sendAuthorizedRequest:request completion:^(id  _Nullable parsedData, NSDictionary * _Nullable responseHeaders, NSInteger statusCode, NSError * _Nullable error) {
        if (completion) {
            completion(error, statusCode, parsedData);
        }
    }];
}

#pragma mark - Balances

-(void)getBalancesInAddresses:(NSArray* _Nonnull)addresses  completion:(void (^ _Nullable)(NSError * _Nullable error,NSUInteger statusCode, NSArray * _Nullable responseObject))completion {
    NSURL *url = [NSURL URLWithString:DASHCONTROL_URL(@"address_info")];
    NSDictionary* parameters =@{
                                @"addresses": addresses,
                                };
    HTTPRequest *request = [HTTPRequest requestWithURL:url method:HTTPRequestMethod_POST parameters:parameters];
    [self.httpManager sendRequest:request completion:^(id  _Nullable parsedData, NSDictionary * _Nullable responseHeaders, NSInteger statusCode, NSError * _Nullable error) {
        if (completion) {
            completion(error, statusCode, parsedData);
        }
    }];
}

#pragma mark - Notifications

-(void)updateBloomFilter:(DCServerBloomFilter*)filter completion:(void (^)(NSError * error))completion {
    NSURL *url = [NSURL URLWithString:DASHCONTROL_URL(@"filter")];
    NSDictionary *parameters = @{
                                 @"filter": [filter.filterData base64EncodedStringWithOptions:kNilOptions],
                                 @"filter_length": @(filter.length),
                                 @"hash_count": @(filter.hashFuncs),
                                 };
    
    HTTPRequest *request = [HTTPRequest requestWithURL:url method:HTTPRequestMethod_POST parameters:parameters];
    [self sendAuthorizedRequest:request completion:^(id  _Nullable parsedData, NSDictionary * _Nullable responseHeaders, NSInteger statusCode, NSError * _Nullable error) {
        if (completion) {
            completion(error);
        }
    }];
}

#pragma mark - Private

- (void)sendAuthorizedRequest:(HTTPRequest *)request completion:(HTTPLoaderCompletionBlock)completion {
    NSString *username = [[DCEnvironment sharedInstance] deviceId];
    NSString *password = [[DCEnvironment sharedInstance] devicePassword];
    NSData *basicAuthCredentials = [[NSString stringWithFormat:@"%@:%@", username, password] dataUsingEncoding:NSUTF8StringEncoding];
    NSString *base64AuthCredentials = [basicAuthCredentials base64EncodedStringWithOptions:kNilOptions];
    [request addValue:[NSString stringWithFormat:@"Basic %@", base64AuthCredentials] forHeader:@"Authorization"];
    [self.httpManager sendRequest:request completion:completion];
}

@end
