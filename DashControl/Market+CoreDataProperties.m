//
//  Market+CoreDataProperties.m
//  DashControl
//
//  Created by Sam Westrich on 9/4/17.
//  Copyright © 2017 dashfoundation. All rights reserved.
//

#import "Market+CoreDataProperties.h"

@implementation Market (CoreDataProperties)

+ (NSFetchRequest<Market *> *)fetchRequest {
	return [[NSFetchRequest alloc] initWithEntityName:@"Market"];
}

@dynamic identifier;
@dynamic name;
@dynamic onExchanges;

@end
