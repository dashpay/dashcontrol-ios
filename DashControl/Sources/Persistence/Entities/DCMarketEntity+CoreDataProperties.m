//
//  DCMarketEntity+CoreDataProperties.m
//  DashControl
//
//  Created by Sam Westrich on 9/4/17.
//  Copyright © 2017 dashfoundation. All rights reserved.
//

#import "DCMarketEntity+CoreDataProperties.h"

@implementation DCMarketEntity (CoreDataProperties)

+ (NSFetchRequest<DCMarketEntity *> *)fetchRequest {
	return [[NSFetchRequest alloc] initWithEntityName:@"DCMarketEntity"];
}

@dynamic identifier;
@dynamic name;
@dynamic onExchanges;
@dynamic chartData;

@end
