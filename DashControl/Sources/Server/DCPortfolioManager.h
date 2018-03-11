//
//  DCPortfolioManager.h
//  DashControl
//
//  Created by Sam Westrich on 10/4/17.
//  Copyright © 2017 dashfoundation. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

#define PORTFOLIO_DID_UPDATE_NOTIFICATION @"PORTFOLIO_DID_UPDATE_NOTIFICATION"

@class DCPersistenceStack;
@class HTTPLoaderManager;
@class NSManagedObjectContext;

@interface DCPortfolioManager : NSObject

@property (strong, nonatomic) InjectedClass(DCPersistenceStack) stack;
@property (strong, nonatomic) InjectedClass(HTTPLoaderManager) httpManager;

+ (id)sharedInstance;

- (uint64_t)totalWorthInContext:(NSManagedObjectContext *_Nullable)context error:(NSError *_Nullable *_Nullable)error;

- (void)amountAtAddress:(NSString *)address clb:(void (^)(uint64_t amount, NSError *_Nullable error))clb;

- (void)updateAmounts;

@end

NS_ASSUME_NONNULL_END
