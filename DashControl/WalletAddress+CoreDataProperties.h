//
//  WalletAddress+CoreDataProperties.h
//  DashControl
//
//  Created by Sam Westrich on 10/3/17.
//  Copyright © 2017 dashfoundation. All rights reserved.
//
//

#import "WalletAddress+CoreDataClass.h"


NS_ASSUME_NONNULL_BEGIN

@interface WalletAddress (CoreDataProperties)

+ (NSFetchRequest<WalletAddress *> *)fetchRequest;

@property (nullable, nonatomic, copy) NSString *address;
@property (nonatomic) int64_t amount;

@end

NS_ASSUME_NONNULL_END
