//
//  DCBudgetEntity+CoreDataProperties.m
//  
//
//  Created by Andrew Podkovyrin on 02/03/2018.
//
//

#import "DCBudgetEntity+CoreDataProperties.h"

@implementation DCBudgetEntity (CoreDataProperties)

+ (NSFetchRequest<DCBudgetEntity *> *)fetchRequest {
	return [[NSFetchRequest alloc] initWithEntityName:@"DCBudgetEntity"];
}

@dynamic allotedAmount;
@dynamic paymentDate;
@dynamic superblock;
@dynamic totalAmount;

@end
