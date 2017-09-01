//
//  DCCoreDataManager.h
//  DashControl
//
//  Created by Sam Westrich on 9/1/17.
//  Copyright © 2017 dashfoundation. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DCCoreDataManager : NSObject

@property (nonatomic, strong) NSManagedObjectContext * _Nullable mainObjectContext;

+ (id _Nonnull )sharedManager;

-(NSArray * _Nonnull)fetchChartDataForExchange:(DCExchangeSource)exchange forMarket:(DCMarketSource)market startTime:(NSDate* _Nullable)startTime endTime:(NSDate* _Nullable)endTime inContext:(NSManagedObjectContext * _Nullable)context;

@end
