//
//  DCMasternodeEntity+CoreDataProperties.m
//  DashControl
//
//  Created by Sam Westrich on 10/3/17.
//  Copyright © 2017 dashfoundation. All rights reserved.
//
//

#import "DCMasternodeEntity+CoreDataProperties.h"

@implementation DCMasternodeEntity (CoreDataProperties)

+ (NSFetchRequest<DCMasternodeEntity *> *)fetchRequest {
	return [[NSFetchRequest alloc] initWithEntityName:@"DCMasternodeEntity"];
}

@dynamic address;
@dynamic secureVotingKeyPath;
@dynamic payments;
@dynamic amount;

@end
