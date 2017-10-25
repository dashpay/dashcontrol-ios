//
//  DCWalletAddressEntity+CoreDataProperties.m
//  DashControl
//
//  Created by Sam Westrich on 10/24/17.
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
@dynamic internal;
@dynamic extendedKeyHash;
@dynamic index;
@dynamic walletMasterAddress;

@end
