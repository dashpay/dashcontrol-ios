//
//  Proposal+CoreDataProperties.m
//  DashControl
//
//  Created by Manuel Boyer on 23/08/2017.
//  Copyright © 2017 dashfoundation. All rights reserved.
//

#import "Proposal+CoreDataProperties.h"

@implementation Proposal (CoreDataProperties)

+ (NSFetchRequest<Proposal *> *)fetchRequest {
	return [[NSFetchRequest alloc] initWithEntityName:@"Proposal"];
}

@dynamic hashProposal;
@dynamic name;
@dynamic url;
@dynamic dwUrl;
@dynamic dwUrlComments;
@dynamic title;
@dynamic dateAdded;
@dynamic dateAddedHuman;
@dynamic dateEnd;
@dynamic votingDeadlineHuman;
@dynamic willBeFunded;
@dynamic remainingYesVotesUntilFunding;
@dynamic inNextBudget;
@dynamic monthlyAmount;
@dynamic totalPaymentCount;
@dynamic remainingPaymentCount;
@dynamic yes;
@dynamic no;
@dynamic abstain;
@dynamic commentAmount;
@dynamic descriptionBase64Bb;
@dynamic descriptionBase64Html;
@dynamic ownerUsername;
@dynamic comments;

@end
