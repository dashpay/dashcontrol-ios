//
//  ProposalsManager.h
//  DashControl
//
//  Created by Manuel Boyer on 23/08/2017.
//  Copyright © 2017 dashfoundation. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ProposalsManager : NSObject

@property (nonatomic, retain) NSManagedObjectContext * _Nullable managedObjectContext;

+ (id _Nonnull )sharedManager;

-(void)fetchBudgetAndProposals;
//-(void)fetchProposalDetailWithHash:(NSString*_Nullable)hashProposal;

//Utils
-(NSMutableArray*_Nullable)fetchAllObjectsForEntity:(NSString*_Nullable)entityName inContext:(NSManagedObjectContext *_Nullable)context;

@end
