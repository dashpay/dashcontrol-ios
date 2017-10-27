//
//  ChartDataImportManager.h
//  DashControl
//
//  Created by Manuel Boyer on 22/08/2017.
//  Copyright © 2017 dashfoundation. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DCServerBloomFilter.h"

#define CURRENT_EXCHANGE_MARKET_PAIR @"CURRENT_EXCHANGE_MARKET_PAIR"

@interface DCBackendManager : NSObject

@property (nonatomic, strong) NSManagedObjectContext * _Nullable mainObjectContext;
@property (nonatomic, strong) NSPersistentContainer * _Nullable persistentContainer;

+ (id _Nonnull )sharedInstance;

-(void)getChartDataForExchange:(NSString* _Nonnull)exchange forMarket:(NSString* _Nonnull)market start:(NSDate* _Nullable)start end:(NSDate* _Nullable)end clb:(void (^_Nullable)(NSError * _Nullable error))clb;

-(void)updateBloomFilter:(DCServerBloomFilter* _Nonnull)filter;

-(void)registerDeviceForDeviceToken:(NSData* _Nonnull)deviceToken;

@end
