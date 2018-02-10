//
//  Proposal+CoreDataProperties.h
//  DashControl
//
//  Created by Manuel Boyer on 07/09/2017.
//  Copyright © 2017 dashfoundation. All rights reserved.
//

#import "DCProposalEntity+CoreDataClass.h"


NS_ASSUME_NONNULL_BEGIN

@interface DCProposalEntity (CoreDataProperties)

+ (NSFetchRequest<DCProposalEntity *> *)fetchRequest;

@property (nonatomic) int32_t abstain;
@property (nonatomic) int32_t commentAmount;
@property (nullable, nonatomic, copy) NSDate *dateAdded;
@property (nullable, nonatomic, copy) NSString *dateAddedHuman;
@property (nullable, nonatomic, copy) NSDate *dateEnd;
@property (nullable, nonatomic, copy) NSString *descriptionBase64Bb;
@property (nullable, nonatomic, copy) NSString *descriptionBase64Html;
@property (nullable, nonatomic, copy) NSString *dwUrl;
@property (nullable, nonatomic, copy) NSString *dwUrlComments;
@property (nullable, nonatomic, copy) NSString *hashProposal;
@property (nonatomic) BOOL inNextBudget;
@property (nonatomic) float lastProgressDisplayed;
@property (nonatomic) int32_t monthlyAmount;
@property (nullable, nonatomic, copy) NSString *name;
@property (nonatomic) int32_t no;
@property (nullable, nonatomic, copy) NSString *ownerUsername;
@property (nonatomic) int32_t remainingPaymentCount;
@property (nonatomic) int32_t remainingYesVotesUntilFunding;
@property (nullable, nonatomic, copy) NSString *title;
@property (nonatomic) int32_t totalPaymentCount;
@property (nullable, nonatomic, copy) NSString *url;
@property (nullable, nonatomic, copy) NSString *votingDeadlineHuman;
@property (nonatomic) BOOL willBeFunded;
@property (nonatomic) int32_t yes;
@property (nonatomic) int32_t order;
@property (nullable, nonatomic, retain) NSSet<DCCommentEntity *> *comments;

@end

@interface DCProposalEntity (CoreDataGeneratedAccessors)

- (void)addCommentsObject:(DCCommentEntity *)value;
- (void)removeCommentsObject:(DCCommentEntity *)value;
- (void)addComments:(NSSet<DCCommentEntity *> *)values;
- (void)removeComments:(NSSet<DCCommentEntity *> *)values;

@end

NS_ASSUME_NONNULL_END
