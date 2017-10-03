//
//  MasternodePayment+CoreDataProperties.m
//  DashControl
//
//  Created by Sam Westrich on 10/3/17.
//  Copyright © 2017 dashfoundation. All rights reserved.
//
//

#import "MasternodePayment+CoreDataProperties.h"

@implementation MasternodePayment (CoreDataProperties)

+ (NSFetchRequest<MasternodePayment *> *)fetchRequest {
	return [[NSFetchRequest alloc] initWithEntityName:@"MasternodePayment"];
}

@dynamic amount;
@dynamic date;
@dynamic height;
@dynamic masternode;

@end
