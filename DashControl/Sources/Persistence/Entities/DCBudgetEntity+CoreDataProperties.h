//
//  DCBudgetEntity+CoreDataProperties.h
//  
//
//  Created by Andrew Podkovyrin on 02/03/2018.
//
//

#import "DCBudgetEntity+CoreDataClass.h"


NS_ASSUME_NONNULL_BEGIN

@interface DCBudgetEntity (CoreDataProperties)

+ (NSFetchRequest<DCBudgetEntity *> *)fetchRequest;

@property (nonatomic) double allotedAmount;
@property (nullable, nonatomic, copy) NSDate *paymentDate;
@property (nonatomic) int32_t superblock;
@property (nonatomic) double totalAmount;

@end

NS_ASSUME_NONNULL_END
