//
//  DCWalletEntity+CoreDataProperties.m
//  DashControl
//
//  Created by Sam Westrich on 10/27/17.
//  Copyright © 2017 dashfoundation. All rights reserved.
//
//

#import "DCWalletEntity+CoreDataProperties.h"

@implementation DCWalletEntity (CoreDataProperties)

+ (NSFetchRequest<DCWalletEntity *> *)fetchRequest {
	return [[NSFetchRequest alloc] initWithEntityName:@"DCWalletEntity"];
}

@dynamic dateAdded;
@dynamic name;
@dynamic identifier;
@dynamic accounts;

@end
