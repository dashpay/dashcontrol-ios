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

#import "ProposalDetailViewModel.h"

#import "NSManagedObject+DCExtensions.h"
#import "APIBudget.h"
#import "DCPersistenceStack.h"
#import "HTTPLoaderOperationProtocol.h"
#import "ProposalDetailHeaderViewModel.h"
#import "ProposalDetailTableViewCellModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface ProposalDetailViewModel ()

@property (strong, nonatomic) DCBudgetProposalEntity *proposal;

@property (weak, nonatomic) id<HTTPLoaderOperationProtocol> request;

@end

@implementation ProposalDetailViewModel

- (instancetype)initWithProposal:(DCBudgetProposalEntity *)proposal {
    self = [super init];
    if (self) {
        _proposal = proposal;

        _headerViewModel = [[ProposalDetailHeaderViewModel alloc] init];
        [_headerViewModel updateWithProposal:_proposal];

        _cellViewModel = [[ProposalDetailTableViewCellModel alloc] init];
        [_cellViewModel updateWithProposal:proposal];
    }
    return self;
}

- (void)reloadWithCompletion:(void (^)(BOOL success))completion {
    if (self.request) {
        [self.request cancel];
    }

    weakify;
    self.request = [self.api fetchProposalDetails:self.proposal completion:^(BOOL success) {
        strongify;

        NSAssert([NSThread isMainThread], nil);

        NSManagedObjectContext *viewContext = self.stack.persistentContainer.viewContext;
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"proposalHash == %@", self.proposal.proposalHash];
        DCBudgetProposalEntity *proposal = [DCBudgetProposalEntity dc_objectWithPredicate:predicate inContext:viewContext];
        self.proposal = proposal;

        [self.headerViewModel updateWithProposal:self.proposal];
        [self.cellViewModel updateWithProposal:self.proposal];

        if (completion) {
            completion(success);
        }
    }];
}

@end

NS_ASSUME_NONNULL_END
