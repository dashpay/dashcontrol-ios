//
//  DCCoreDataManager.h
//  DashControl
//
//  Created by Sam Westrich on 9/1/17.
//  Copyright © 2017 dashfoundation. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DCChartTimeFormatter.h"

NS_ASSUME_NONNULL_BEGIN

@class DCWalletEntity, DCWalletAccountEntity;
@class DCPersistenceStack;

@interface DCCoreDataManager : NSObject

@property (strong, nonatomic) InjectedClass(DCPersistenceStack) stack;
@property (readonly, strong, nonatomic) NSManagedObjectContext *mainObjectContext;

+ (instancetype)sharedInstance;

// MARK: - Chart Data

- (NSArray *)fetchChartDataForExchangeIdentifier:(NSUInteger)exchangeIdentifier forMarketIdentifier:(NSUInteger)marketIdentifier interval:(ChartTimeInterval)timeInterval startTime:(NSDate *_Nullable)startTime endTime:(NSDate *_Nullable)endTime inContext:(NSManagedObjectContext *_Nullable)context error:(NSError *_Nullable *_Nullable)error;

- (NSInteger)fetchAutoIncrementIdForExchangeinContext:(NSManagedObjectContext *_Nullable)context error:(NSError *_Nullable *_Nullable)error;

- (NSInteger)fetchAutoIncrementIdForMarketInContext:(NSManagedObjectContext *_Nullable)context error:(NSError *_Nullable *_Nullable)error;

- (NSArray *)marketsInContext:(NSManagedObjectContext *_Nullable)context error:(NSError *_Nullable *_Nullable)error;
- (NSArray *)exchangesInContext:(NSManagedObjectContext *_Nullable)context error:(NSError *_Nullable *_Nullable)error;

- (NSArray *)marketsForNames:(NSArray *)names inContext:(NSManagedObjectContext *_Nullable)context error:(NSError *_Nullable *_Nullable)error;
- (NSArray *)exchangesForNames:(NSArray *)names inContext:(NSManagedObjectContext *_Nullable)context error:(NSError *_Nullable *_Nullable)error;

- (DCMarketEntity *_Nullable)marketNamed:(NSString *)marketName inContext:(NSManagedObjectContext *_Nullable)context error:(NSError *_Nullable *_Nullable)error;

- (DCExchangeEntity *_Nullable)exchangeNamed:(NSString *)exchangeName inContext:(NSManagedObjectContext *_Nullable)context error:(NSError *_Nullable *_Nullable)error;

- (DCMarketEntity *_Nullable)marketWithIdentifier:(NSUInteger)marketIdentifier inContext:(NSManagedObjectContext *_Nullable)context error:(NSError *_Nullable *_Nullable)error;

- (DCExchangeEntity *_Nullable)exchangeWithIdentifier:(NSUInteger)exchangeIdentifier inContext:(NSManagedObjectContext *_Nullable)context error:(NSError *_Nullable *_Nullable)error;

// MARK: - Portfolio

- (DCWalletEntity *_Nullable)walletHavingOneOfAccounts:(NSArray *)accounts withIdentifier:(NSString *)identifier inContext:(NSManagedObjectContext *_Nullable)context error:(NSError *_Nullable *_Nullable)error;

- (BOOL)hasWalletAccount:(NSString *)accountPublicKeyHash inContext:(NSManagedObjectContext *_Nullable)context error:(NSError *_Nullable *_Nullable)error;

- (NSArray *)walletAddressesInContext:(NSManagedObjectContext *_Nullable)context error:(NSError *_Nullable *_Nullable)error;

- (NSArray *)masternodesInContext:(NSManagedObjectContext *_Nullable)context error:(NSError *_Nullable *_Nullable)error;

- (NSUInteger)countMasternodesInContext:(NSManagedObjectContext *_Nullable)context error:(NSError *_Nullable *_Nullable)error;

// MARK: - Wallet Accounts

- (NSArray *)walletAccountsInContext:(NSManagedObjectContext *_Nullable)context error:(NSError *_Nullable *_Nullable)error;

- (DCWalletAccountEntity *_Nullable)walletAccountWithPublicKeyHash:(NSString *)publicKeyHash inContext:(NSManagedObjectContext *_Nullable)context error:(NSError *_Nullable *_Nullable)error;

// MARK: - Wallet

- (NSArray *)walletsWithIndentifier:(NSString *)sourceName inContext:(NSManagedObjectContext *_Nullable)context error:(NSError *_Nullable *_Nullable)error;

// MARK: - Triggers

- (NSArray *)triggersInContext:(NSManagedObjectContext *_Nullable)context error:(NSError *_Nullable *_Nullable)error;

@end

NS_ASSUME_NONNULL_END
