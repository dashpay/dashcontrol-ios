//
//  DCProposalEntity+CoreDataProperties.m
//  DashControl
//
//  Created by Manuel Boyer on 07/09/2017.
//  Copyright © 2017 dashfoundation. All rights reserved.
//

#import "DCProposalEntity+CoreDataProperties.h"

@implementation DCProposalEntity (CoreDataProperties)

+ (NSFetchRequest<DCProposalEntity *> *)fetchRequest {
	return [[NSFetchRequest alloc] initWithEntityName:@"DCProposalEntity"];
}

@dynamic abstain;
@dynamic commentAmount;
@dynamic dateAdded;
@dynamic dateAddedHuman;
@dynamic dateEnd;
@dynamic descriptionBase64Bb;
@dynamic descriptionBase64Html;
@dynamic dwUrl;
@dynamic dwUrlComments;
@dynamic hashProposal;
@dynamic inNextBudget;
@dynamic lastProgressDisplayed;
@dynamic monthlyAmount;
@dynamic name;
@dynamic no;
@dynamic ownerUsername;
@dynamic remainingPaymentCount;
@dynamic remainingYesVotesUntilFunding;
@dynamic title;
@dynamic totalPaymentCount;
@dynamic url;
@dynamic votingDeadlineHuman;
@dynamic willBeFunded;
@dynamic yes;
@dynamic order;
@dynamic comments;

@end
