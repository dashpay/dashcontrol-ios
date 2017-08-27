//
//  Budget+CoreDataProperties.h
//  DashControl
//
//  Created by Manuel Boyer on 27/08/2017.
//  Copyright © 2017 dashfoundation. All rights reserved.
//

#import "Budget+CoreDataClass.h"


NS_ASSUME_NONNULL_BEGIN

@interface Budget (CoreDataProperties)

+ (NSFetchRequest<Budget *> *)fetchRequest;

@property (nullable, nonatomic, copy) NSString *totalAmount;
@property (nonatomic) double allotedAmount;
@property (nullable, nonatomic, copy) NSDate *paymentDate;
@property (nullable, nonatomic, copy) NSString *paymentDateHuman;
@property (nullable, nonatomic, copy) NSString *superblock;

@end

NS_ASSUME_NONNULL_END
