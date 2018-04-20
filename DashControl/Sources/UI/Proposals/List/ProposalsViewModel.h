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

#import <Foundation/Foundation.h>

#import "DCBudgetInfoEntity+CoreDataClass.h"
#import "DCBudgetProposalEntity+CoreDataClass.h"

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSUInteger, ProposalsSegmentIndex) {
    ProposalsSegmentIndex_Current,
    ProposalsSegmentIndex_Ongoing,
    ProposalsSegmentIndex_Past,
};

@class DCPersistenceStack;
@class APIBudget;
@class ProposalsHeaderViewModel;

@interface ProposalsViewModel : NSObject

@property (strong, nonatomic) InjectedClass(DCPersistenceStack) stack;
@property (strong, nonatomic) InjectedClass(APIBudget) api;

@property (strong, nonatomic) ProposalsHeaderViewModel *headerViewModel;

@property (readonly, strong, nonatomic) NSFetchedResultsController<DCBudgetProposalEntity *> *fetchedResultsController;
@property (readonly, strong, nonatomic) NSFetchedResultsController<DCBudgetProposalEntity *> *searchFetchedResultsController;

- (void)updateMasternodesCount;
- (void)reloadWithCompletion:(void (^)(BOOL success))completion;

- (void)searchWithQuery:(NSString *)query;
- (void)updateSegmentIndex:(ProposalsSegmentIndex)segmentIndex;
- (void)updateSearchSegmentIndex:(ProposalsSegmentIndex)segmentIndex;

@end

NS_ASSUME_NONNULL_END
