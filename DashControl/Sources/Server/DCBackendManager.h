//
//  ChartDataImportManager.h
//  DashControl
//
//  Created by Manuel Boyer on 22/08/2017.
//  Copyright © 2017 dashfoundation. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DCServerBloomFilter.h"
#import "DCTrigger.h"


#define CURRENT_EXCHANGE_MARKET_PAIR @"CURRENT_EXCHANGE_MARKET_PAIR"

@class HTTPLoaderManager;

@interface DCBackendManager : NSObject

@property (nonatomic, strong, nonnull) InjectedClass(HTTPLoaderManager) httpManager;

@property (nonatomic, strong) NSManagedObjectContext * _Nullable mainObjectContext;
@property (nonatomic, strong) NSPersistentContainer * _Nullable persistentContainer;

+ (id _Nonnull )sharedInstance;

-(void)startUp;

-(void)getChartDataForExchange:(NSString* _Nonnull)exchange forMarket:(NSString* _Nonnull)market start:(NSDate* _Nullable)start end:(NSDate* _Nullable)end clb:(void (^_Nullable)(NSError * _Nullable error))clb;

-(void)updateBloomFilter:(DCServerBloomFilter* _Nonnull)filter completion:(void (^ _Nullable)(NSError * _Nullable error))completion;

-(void)registerDeviceForDeviceToken:(NSData* _Nonnull)deviceToken;

-(void)postTrigger:(DCTrigger* _Nonnull)trigger completion:(void (^ _Nullable)(NSError * _Nullable error,NSUInteger statusCode, id  _Nullable responseObject))completion;

-(void)deleteTriggerWithId:(u_int64_t)triggerId completion:(void (^ _Nullable)(NSError * _Nullable error,NSUInteger statusCode, id  _Nullable responseObject))completion;

-(void)getTriggers:(void (^ _Nullable)(NSError * _Nullable error,NSUInteger statusCode, NSArray * _Nullable responseObject))completion;

-(void)getBalancesInAddresses:(NSArray* _Nonnull)addresses  completion:(void (^ _Nullable)(NSError * _Nullable error,NSUInteger statusCode, NSArray * _Nullable responseObject))completion;

@end
