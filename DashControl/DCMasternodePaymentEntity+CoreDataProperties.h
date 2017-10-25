//
//  DCMasternodePaymentEntity+CoreDataProperties.h
//  DashControl
//
//  Created by Sam Westrich on 10/3/17.
//  Copyright © 2017 dashfoundation. All rights reserved.
//
//

#import "DCMasternodePaymentEntity+CoreDataClass.h"


NS_ASSUME_NONNULL_BEGIN

@interface DCMasternodePaymentEntity (CoreDataProperties)

+ (NSFetchRequest<DCMasternodePaymentEntity *> *)fetchRequest;

@property (nonatomic) int64_t amount;
@property (nullable, nonatomic, copy) NSDate *date;
@property (nonatomic) int32_t height;
@property (nullable, nonatomic, retain) DCMasternodeEntity *masternode;

@end

NS_ASSUME_NONNULL_END
