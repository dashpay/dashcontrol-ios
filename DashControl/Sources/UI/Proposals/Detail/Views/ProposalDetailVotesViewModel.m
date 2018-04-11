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

#import "ProposalDetailVotesViewModel.h"

#import "DCBudgetProposalEntity+CoreDataClass.h"

NS_ASSUME_NONNULL_BEGIN

@interface ProposalDetailVotesViewModel ()

@property (copy, nonatomic) NSString *yesVotes;
@property (copy, nonatomic) NSString *noVotes;
@property (copy, nonatomic) NSString *abstainVotes;

@end

@implementation ProposalDetailVotesViewModel

- (void)updateWithProposal:(DCBudgetProposalEntity *)proposal {
    self.yesVotes = [NSString stringWithFormat:@"%d", proposal.yesVotesCount];
    self.noVotes = [NSString stringWithFormat:@"%d", proposal.noVotesCount];
    self.abstainVotes = [NSString stringWithFormat:@"%d", proposal.abstainVotesCount];
}

@end

NS_ASSUME_NONNULL_END
