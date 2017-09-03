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

-(NSArray * _Nonnull)fetchChartDataForExchange:(Exchange*)exchange forMarket:(Market*)market startTime:(NSDate* _Nullable)startTime endTime:(NSDate* _Nullable)endTime inContext:(NSManagedObjectContext * _Nullable)context error:(NSError*_Nullable* _Nullable)error;

-(NSInteger)fetchAutoIncrementIdForExchangeinContext:(NSManagedObjectContext * _Nullable)context error:(NSError*_Nullable* _Nullable)error;

-(NSInteger)fetchAutoIncrementIdForMarketinContext:(NSManagedObjectContext * _Nullable)context error:(NSError*_Nullable* _Nullable)error;

-(NSArray* _Nonnull)marketsForNames:(NSArray* _Nonnull)names inContext:(NSManagedObjectContext * _Nullable)context error:(NSError*_Nullable* _Nullable)error;
-(NSArray* _Nonnull)exchangesForNames:(NSArray* _Nonnull)names inContext:(NSManagedObjectContext * _Nullable)context error:(NSError*_Nullable* _Nullable)error;

@end
