//
//  DCBudgetEntity+CoreDataProperties.m
//  DashControl
//
//  Created by Manuel Boyer on 06/09/2017.
//  Copyright © 2017 dashfoundation. All rights reserved.
//

#import "DCBudgetEntity+CoreDataProperties.h"

@implementation DCBudgetEntity (CoreDataProperties)

+ (NSFetchRequest<DCBudgetEntity *> *)fetchRequest {
	return [[NSFetchRequest alloc] initWithEntityName:@"DCBudgetEntity"];
}

@dynamic allotedAmount;
@dynamic paymentDate;
@dynamic paymentDateHuman;
@dynamic superblock;
@dynamic totalAmount;

@end
