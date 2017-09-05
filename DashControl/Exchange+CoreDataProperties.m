//
//  Exchange+CoreDataProperties.m
//  DashControl
//
//  Created by Sam Westrich on 9/4/17.
//  Copyright © 2017 dashfoundation. All rights reserved.
//

#import "Exchange+CoreDataProperties.h"

@implementation Exchange (CoreDataProperties)

+ (NSFetchRequest<Exchange *> *)fetchRequest {
	return [[NSFetchRequest alloc] initWithEntityName:@"Exchange"];
}

@dynamic identifier;
@dynamic name;
@dynamic markets;
@dynamic chartData;

@end
