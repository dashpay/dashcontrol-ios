//
//  WalletAddress+CoreDataProperties.m
//  DashControl
//
//  Created by Sam Westrich on 10/3/17.
//  Copyright © 2017 dashfoundation. All rights reserved.
//
//

#import "WalletAddress+CoreDataProperties.h"

@implementation WalletAddress (CoreDataProperties)

+ (NSFetchRequest<WalletAddress *> *)fetchRequest {
	return [[NSFetchRequest alloc] initWithEntityName:@"WalletAddress"];
}

@dynamic address;
@dynamic amount;

@end
