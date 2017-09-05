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

-(NSArray * _Nonnull)fetchChartDataForExchangeIdentifier:(NSUInteger)exchangeIdentifier forMarketIdentifier:(NSUInteger)marketIdentifier startTime:(NSDate* _Nullable)startTime endTime:(NSDate* _Nullable)endTime inContext:(NSManagedObjectContext * _Nullable)context error:(NSError*_Nullable* _Nullable)error;

-(NSInteger)fetchAutoIncrementIdForExchangeinContext:(NSManagedObjectContext * _Nullable)context error:(NSError*_Nullable* _Nullable)error;

-(NSInteger)fetchAutoIncrementIdForMarketinContext:(NSManagedObjectContext * _Nullable)context error:(NSError*_Nullable* _Nullable)error;

-(NSArray* _Nonnull)allMarketsInContext:(NSManagedObjectContext * _Nullable)context error:(NSError*_Nullable* _Nullable)error;

-(NSArray* _Nonnull)marketsForNames:(NSArray* _Nonnull)names inContext:(NSManagedObjectContext * _Nullable)context error:(NSError*_Nullable* _Nullable)error;
-(NSArray* _Nonnull)exchangesForNames:(NSArray* _Nonnull)names inContext:(NSManagedObjectContext * _Nullable)context error:(NSError*_Nullable* _Nullable)error;

-(Market* _Nullable)marketNamed:(NSString* _Nonnull)marketName inContext:(NSManagedObjectContext * _Nullable)context error:(NSError*_Nullable* _Nullable)error;

-(Exchange* _Nullable)exchangeNamed:(NSString* _Nonnull)exchangeName inContext:(NSManagedObjectContext * _Nullable)context error:(NSError*_Nullable* _Nullable)error;

-(Market* _Nullable)marketWithIdentifier:(NSUInteger)marketIdentifier inContext:(NSManagedObjectContext * _Nullable)context error:(NSError*_Nullable* _Nullable)error;

-(Exchange* _Nullable)exchangeWithIdentifier:(NSUInteger)exchangeIdentifier inContext:(NSManagedObjectContext * _Nullable)context error:(NSError*_Nullable* _Nullable)error;

@end
