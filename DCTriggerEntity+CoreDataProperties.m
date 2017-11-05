//
//  DCTriggerEntity+CoreDataProperties.m
//  DashControl
//
//  Created by Sam Westrich on 11/5/17.
//  Copyright © 2017 dashfoundation. All rights reserved.
//
//

#import "DCTriggerEntity+CoreDataProperties.h"

@implementation DCTriggerEntity (CoreDataProperties)

+ (NSFetchRequest<DCTriggerEntity *> *)fetchRequest {
	return [[NSFetchRequest alloc] initWithEntityName:@"DCTriggerEntity"];
}

@dynamic value;
@dynamic conditionalValue;
@dynamic type;
@dynamic consume;
@dynamic ignoreFor;
@dynamic exchange;
@dynamic market;

@end
