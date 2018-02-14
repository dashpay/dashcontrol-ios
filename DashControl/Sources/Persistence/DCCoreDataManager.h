//
//  DCCoreDataManager.h
//  DashControl
//
//  Created by Sam Westrich on 9/1/17.
//  Copyright © 2017 dashfoundation. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DCChartTimeFormatter.h"

@class DCWalletEntity,DCWalletAccountEntity;

@interface DCCoreDataManager : NSObject

@property (nonatomic, strong) NSManagedObjectContext * _Nullable mainObjectContext;

+ (instancetype)sharedInstance;

// MARK: - Chart Data

-(NSArray * _Nonnull)fetchChartDataForExchangeIdentifier:(NSUInteger)exchangeIdentifier forMarketIdentifier:(NSUInteger)marketIdentifier interval:(ChartTimeInterval)timeInterval startTime:(NSDate* _Nullable)startTime endTime:(NSDate* _Nullable)endTime inContext:(NSManagedObjectContext * _Nullable)context error:(NSError*_Nullable* _Nullable)error;

-(NSInteger)fetchAutoIncrementIdForExchangeinContext:(NSManagedObjectContext * _Nullable)context error:(NSError*_Nullable* _Nullable)error;

-(NSInteger)fetchAutoIncrementIdForMarketInContext:(NSManagedObjectContext * _Nullable)context error:(NSError*_Nullable* _Nullable)error;

-(NSArray* _Nonnull)marketsInContext:(NSManagedObjectContext * _Nullable)context error:(NSError*_Nullable* _Nullable)error;
-(NSArray* _Nonnull)exchangesInContext:(NSManagedObjectContext * _Nullable)context error:(NSError*_Nullable* _Nullable)error;

-(NSArray* _Nonnull)marketsForNames:(NSArray* _Nonnull)names inContext:(NSManagedObjectContext * _Nullable)context error:(NSError*_Nullable* _Nullable)error;
-(NSArray* _Nonnull)exchangesForNames:(NSArray* _Nonnull)names inContext:(NSManagedObjectContext * _Nullable)context error:(NSError*_Nullable* _Nullable)error;

-(DCMarketEntity* _Nullable)marketNamed:(NSString* _Nonnull)marketName inContext:(NSManagedObjectContext * _Nullable)context error:(NSError*_Nullable* _Nullable)error;

-(DCExchangeEntity* _Nullable)exchangeNamed:(NSString* _Nonnull)exchangeName inContext:(NSManagedObjectContext * _Nullable)context error:(NSError*_Nullable* _Nullable)error;

-(DCMarketEntity* _Nullable)marketWithIdentifier:(NSUInteger)marketIdentifier inContext:(NSManagedObjectContext * _Nullable)context error:(NSError*_Nullable* _Nullable)error;

-(DCExchangeEntity* _Nullable)exchangeWithIdentifier:(NSUInteger)exchangeIdentifier inContext:(NSManagedObjectContext * _Nullable)context error:(NSError*_Nullable* _Nullable)error;

// MARK: - Portfolio

-(DCWalletEntity* _Nullable)walletHavingOneOfAccounts:(NSArray* _Nonnull)accounts withIdentifier:(NSString* _Nonnull)identifier inContext:(NSManagedObjectContext * _Nullable)context error:(NSError*_Nullable* _Nullable)error;

-(BOOL)hasWalletAccount:(NSString* _Nonnull)accountPublicKeyHash inContext:(NSManagedObjectContext * _Nullable)context error:(NSError*_Nullable* _Nullable)error;

-(NSArray * _Nonnull)walletAddressesInContext:(NSManagedObjectContext * _Nullable)context error:(NSError*_Nullable* _Nullable)error;

-(NSArray * _Nonnull)masternodesInContext:(NSManagedObjectContext * _Nullable)context error:(NSError*_Nullable* _Nullable)error;

-(NSUInteger)countMasternodesInContext:(NSManagedObjectContext * _Nullable)context error:(NSError*_Nullable* _Nullable)error;

// MARK: - Wallet Accounts

-(NSArray * _Nonnull)walletAccountsInContext:(NSManagedObjectContext * _Nullable)context error:(NSError*_Nullable* _Nullable)error;

-(DCWalletAccountEntity* _Nullable)walletAccountWithPublicKeyHash:(NSString* _Nonnull)publicKeyHash inContext:(NSManagedObjectContext * _Nullable)context error:(NSError*_Nullable* _Nullable)error;

// MARK: - Wallet

-(NSArray * _Nonnull)walletsWithIndentifier:(NSString* _Nonnull)sourceName inContext:(NSManagedObjectContext * _Nullable)context error:(NSError*_Nullable* _Nullable)error;

// MARK: - Triggers

-(NSArray * _Nonnull)triggersInContext:(NSManagedObjectContext * _Nullable)context error:(NSError*_Nullable* _Nullable)error;

@end
