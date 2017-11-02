//
//  DCWalletAccountEntity+CoreDataProperties.m
//  DashControl
//
//  Created by Sam Westrich on 10/27/17.
//  Copyright © 2017 dashfoundation. All rights reserved.
//
//

#import "DCWalletAccountEntity+CoreDataProperties.h"

@implementation DCWalletAccountEntity (CoreDataProperties)

+ (NSFetchRequest<DCWalletAccountEntity *> *)fetchRequest {
	return [[NSFetchRequest alloc] initWithEntityName:@"DCWalletAccountEntity"];
}

@dynamic hash160Key;
@dynamic addresses;
@dynamic wallet;

@end
