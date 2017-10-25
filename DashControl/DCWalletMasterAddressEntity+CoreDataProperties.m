//
//  DCWalletMasterAddressEntity+CoreDataProperties.m
//  DashControl
//
//  Created by Sam Westrich on 10/24/17.
//  Copyright © 2017 dashfoundation. All rights reserved.
//
//

#import "DCWalletMasterAddressEntity+CoreDataProperties.h"

@implementation DCWalletMasterAddressEntity (CoreDataProperties)

+ (NSFetchRequest<DCWalletMasterAddressEntity *> *)fetchRequest {
	return [[NSFetchRequest alloc] initWithEntityName:@"DCWalletMasterAddressEntity"];
}

@dynamic dateAdded;
@dynamic masterBIP32NodeKey;
@dynamic masterBIP44NodeKey;
@dynamic name;
@dynamic walletAddresses;

@end
