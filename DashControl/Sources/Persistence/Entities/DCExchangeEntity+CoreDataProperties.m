//
//  DCExchangeEntity+CoreDataProperties.m
//  DashControl
//
//  Created by Sam Westrich on 9/4/17.
//  Copyright © 2017 dashfoundation. All rights reserved.
//

#import "DCExchangeEntity+CoreDataProperties.h"

@implementation DCExchangeEntity (CoreDataProperties)

+ (NSFetchRequest<DCExchangeEntity *> *)fetchRequest {
	return [[NSFetchRequest alloc] initWithEntityName:@"DCExchangeEntity"];
}

@dynamic identifier;
@dynamic name;
@dynamic markets;
@dynamic chartData;

@end
