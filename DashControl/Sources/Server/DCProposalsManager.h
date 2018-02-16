//
//  DCProposalsManager.h
//  DashControl
//
//  Created by Manuel Boyer on 23/08/2017.
//  Copyright © 2017 dashfoundation. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface DCProposalsManager : NSObject

#define PROPOSAL_DID_UPDATE_NOTIFICATION @"PROPOSAL_DID_UPDATE_NOTIFICATION"
#define BUDGET_DID_UPDATE_NOTIFICATION @"BUDGET_DID_UPDATE_NOTIFICATION"

@property (strong, nonatomic) InjectedClass(DCPersistenceStack) stack;

+ (id)sharedManager;

-(void)fetchBudgetAndProposals;
-(void)fetchProposalsWithHash:(NSString *_Nullable)hashProposal;

//Utils
-(NSMutableArray*_Nullable)fetchAllObjectsForEntity:(NSString*_Nullable)entityName inContext:(NSManagedObjectContext *_Nullable)context;

@end

NS_ASSUME_NONNULL_END
