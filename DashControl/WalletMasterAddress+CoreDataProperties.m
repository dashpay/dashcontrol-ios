//
//  WalletMasterAddress+CoreDataProperties.m
//  DashControl
//
//  Created by Sam Westrich on 10/3/17.
//  Copyright © 2017 dashfoundation. All rights reserved.
//
//

#import "WalletMasterAddress+CoreDataProperties.h"

@implementation WalletMasterAddress (CoreDataProperties)

+ (NSFetchRequest<WalletMasterAddress *> *)fetchRequest {
	return [[NSFetchRequest alloc] initWithEntityName:@"WalletMasterAddress"];
}

@dynamic masterBIP32Node;
@dynamic masterBIP44Node;
@dynamic name;
@dynamic dateAdded;

@end
