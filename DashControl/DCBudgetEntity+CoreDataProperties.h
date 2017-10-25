//
//  DCBudgetEntity+CoreDataProperties.h
//  DashControl
//
//  Created by Manuel Boyer on 06/09/2017.
//  Copyright © 2017 dashfoundation. All rights reserved.
//

#import "DCBudgetEntity+CoreDataClass.h"


NS_ASSUME_NONNULL_BEGIN

@interface DCBudgetEntity (CoreDataProperties)

+ (NSFetchRequest<DCBudgetEntity *> *)fetchRequest;

@property (nonatomic) double allotedAmount;
@property (nullable, nonatomic, copy) NSDate *paymentDate;
@property (nullable, nonatomic, copy) NSString *paymentDateHuman;
@property (nonatomic) int32_t superblock;
@property (nonatomic) double totalAmount;

@end

NS_ASSUME_NONNULL_END
