//
//  DCTriggerEntity+CoreDataProperties.m
//  DashControl
//
//  Created by Sam Westrich on 11/7/17.
//  Copyright © 2017 dashfoundation. All rights reserved.
//
//

#import "DCTriggerEntity+CoreDataProperties.h"

@implementation DCTriggerEntity (CoreDataProperties)

+ (NSFetchRequest<DCTriggerEntity *> *)fetchRequest {
	return [[NSFetchRequest alloc] initWithEntityName:@"DCTriggerEntity"];
}

@dynamic conditionalValue;
@dynamic standardizeTether;
@dynamic consume;
@dynamic ignoreFor;
@dynamic identifier;
@dynamic type;
@dynamic value;
@dynamic exchangeNamed;
@dynamic marketNamed;
@dynamic exchange;
@dynamic market;

@end
