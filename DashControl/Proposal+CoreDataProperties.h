//
//  Proposal+CoreDataProperties.h
//  DashControl
//
//  Created by Manuel Boyer on 23/08/2017.
//  Copyright © 2017 dashfoundation. All rights reserved.
//

#import "Proposal+CoreDataClass.h"


NS_ASSUME_NONNULL_BEGIN

@interface Proposal (CoreDataProperties)

+ (NSFetchRequest<Proposal *> *)fetchRequest;

@property (nullable, nonatomic, copy) NSString *hashProposal;
@property (nullable, nonatomic, copy) NSString *name;
@property (nullable, nonatomic, copy) NSString *url;
@property (nullable, nonatomic, copy) NSString *dwUrl;
@property (nullable, nonatomic, copy) NSString *dwUrlComments;
@property (nullable, nonatomic, copy) NSString *title;
@property (nullable, nonatomic, copy) NSDate *dateAdded;
@property (nullable, nonatomic, copy) NSString *dateAddedHuman;
@property (nullable, nonatomic, copy) NSDate *dateEnd;
@property (nullable, nonatomic, copy) NSString *votingDeadlineHuman;
@property (nonatomic) BOOL willBeFunded;
@property (nullable, nonatomic, copy) NSString *remainingYesVotesUntilFunding;
@property (nonatomic) BOOL inNextBudget;
@property (nonatomic) double monthlyAmount;
@property (nonatomic) int32_t totalPaymentCount;
@property (nonatomic) int32_t remainingPaymentCount;
@property (nonatomic) int32_t yes;
@property (nonatomic) int32_t no;
@property (nonatomic) int32_t abstain;
@property (nonatomic) int32_t commentAmount;
@property (nullable, nonatomic, copy) NSString *descriptionBase64Bb;
@property (nullable, nonatomic, copy) NSString *descriptionBase64Html;
@property (nullable, nonatomic, copy) NSString *ownerUsername;
@property (nullable, nonatomic, retain) NSSet<Comment *> *comments;

@end

@interface Proposal (CoreDataGeneratedAccessors)

- (void)addCommentsObject:(Comment *)value;
- (void)removeCommentsObject:(Comment *)value;
- (void)addComments:(NSSet<Comment *> *)values;
- (void)removeComments:(NSSet<Comment *> *)values;

@end

NS_ASSUME_NONNULL_END
