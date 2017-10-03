//
//  Masternode+CoreDataProperties.m
//  DashControl
//
//  Created by Sam Westrich on 10/3/17.
//  Copyright © 2017 dashfoundation. All rights reserved.
//
//

#import "Masternode+CoreDataProperties.h"

@implementation Masternode (CoreDataProperties)

+ (NSFetchRequest<Masternode *> *)fetchRequest {
	return [[NSFetchRequest alloc] initWithEntityName:@"Masternode"];
}

@dynamic address;
@dynamic secureVotingKeyPath;
@dynamic payments;

@end
