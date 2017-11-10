//
//  DCWalletAddressEntity+CoreDataProperties.m
//  DashControl
//
//  Created by Sam Westrich on 10/27/17.
//  Copyright © 2017 dashfoundation. All rights reserved.
//
//

#import "DCWalletAddressEntity+CoreDataProperties.h"

@implementation DCWalletAddressEntity (CoreDataProperties)

+ (NSFetchRequest<DCWalletAddressEntity *> *)fetchRequest {
	return [[NSFetchRequest alloc] initWithEntityName:@"DCWalletAddressEntity"];
}

@dynamic address;
@dynamic amount;
@dynamic extendedKeyHash;
@dynamic index;
@dynamic internal;
@dynamic walletAccount;
@dynamic lastUpdatedAmount;

@end
