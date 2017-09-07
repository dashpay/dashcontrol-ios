//
//  Budget+CoreDataProperties.m
//  DashControl
//
//  Created by Manuel Boyer on 06/09/2017.
//  Copyright © 2017 dashfoundation. All rights reserved.
//

#import "Budget+CoreDataProperties.h"

@implementation Budget (CoreDataProperties)

+ (NSFetchRequest<Budget *> *)fetchRequest {
	return [[NSFetchRequest alloc] initWithEntityName:@"Budget"];
}

@dynamic allotedAmount;
@dynamic paymentDate;
@dynamic paymentDateHuman;
@dynamic superblock;
@dynamic totalAmount;

@end
