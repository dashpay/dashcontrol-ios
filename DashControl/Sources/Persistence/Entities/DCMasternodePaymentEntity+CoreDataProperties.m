//
//  DCMasternodePaymentEntity+CoreDataProperties.m
//  DashControl
//
//  Created by Sam Westrich on 10/3/17.
//  Copyright © 2017 dashfoundation. All rights reserved.
//
//

#import "DCMasternodePaymentEntity+CoreDataProperties.h"

@implementation DCMasternodePaymentEntity (CoreDataProperties)

+ (NSFetchRequest<DCMasternodePaymentEntity *> *)fetchRequest {
	return [[NSFetchRequest alloc] initWithEntityName:@"DCMasternodePaymentEntity"];
}

@dynamic amount;
@dynamic date;
@dynamic height;
@dynamic masternode;

@end
