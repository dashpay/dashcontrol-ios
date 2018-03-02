//
//  Created by Andrew Podkovyrin
//  Copyright © 2018 dashfoundation. All rights reserved.
//
//  Licensed under the MIT License (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//  https://opensource.org/licenses/MIT
//
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  See the License for the specific language governing permissions and
//  limitations under the License.
//
//

#import "DCBudgetProposalEntity+CoreDataClass.h"


NS_ASSUME_NONNULL_BEGIN

@class DCBudgetProposalCommentEntity;

@interface DCBudgetProposalEntity (CoreDataProperties)

+ (NSFetchRequest<DCBudgetProposalEntity *> *)fetchRequest;

@property (nonatomic) int32_t abstainVotesCount;
@property (nonatomic) int32_t commentsCount;
@property (nullable, nonatomic, copy) NSDate *dateAdded;
@property (nullable, nonatomic, copy) NSDate *dateEnd;
@property (nonatomic) BOOL inNextBudget;
@property (nonatomic) int32_t monthlyAmount;
@property (nullable, nonatomic, copy) NSString *name;
@property (nonatomic) int32_t noVotesCount;
@property (nullable, nonatomic, copy) NSString *ownerUsername;
@property (nullable, nonatomic, copy) NSString *proposalHash;
@property (nonatomic) int32_t remainingPaymentCount;
@property (nonatomic) int32_t remainingYesVotesUntilFunding;
@property (nonatomic) int32_t sortOrder;
@property (nullable, nonatomic, copy) NSString *title;
@property (nonatomic) int32_t totalPaymentCount;
@property (nullable, nonatomic, copy) NSString *votingDeadlineInfo;
@property (nonatomic) BOOL willBeFunded;
@property (nonatomic) int32_t yesVotesCount;
@property (nullable, nonatomic, retain) NSSet<DCBudgetProposalCommentEntity *> *comments;

@end

@interface DCBudgetProposalEntity (CoreDataGeneratedAccessors)

- (void)addCommentsObject:(DCBudgetProposalCommentEntity *)value;
- (void)removeCommentsObject:(DCBudgetProposalCommentEntity *)value;
- (void)addComments:(NSSet<DCBudgetProposalCommentEntity *> *)values;
- (void)removeComments:(NSSet<DCBudgetProposalCommentEntity *> *)values;

@end

NS_ASSUME_NONNULL_END
