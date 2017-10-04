//
//  PortfolioManager.h
//  DashControl
//
//  Created by Sam Westrich on 10/4/17.
//  Copyright © 2017 dashfoundation. All rights reserved.
//

#import <Foundation/Foundation.h>

#define PORTFOLIO_DID_UPDATE_NOTIFICATION @"PORTFOLIO_DID_UPDATE_NOTIFICATION"

@interface PortfolioManager : NSObject

@property (nonatomic, strong) NSManagedObjectContext * _Nullable managedObjectContext;

+ (id _Nonnull )sharedManager;

-(uint64_t)totalWorthInContext:(NSManagedObjectContext* _Nullable)context error:(NSError*_Nullable* _Nullable)error;

-(void)updateAmounts;

@end
