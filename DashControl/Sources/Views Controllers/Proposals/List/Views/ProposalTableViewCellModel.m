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

#import "ProposalTableViewCellModel.h"

#import "DCBudgetProposalEntity+CoreDataClass.h"
#import "APIBudget.h"

NS_ASSUME_NONNULL_BEGIN

@implementation ProposalTableViewCellModel

- (instancetype)initWithProposal:(DCBudgetProposalEntity *)proposal {
    self = [super init];
    if (self) {
        NSInteger masternodesCount = APIBudget.masternodesCount;
        CGFloat percent = masternodesCount > 0 ? MIN(MAX((proposal.yesVotesCount - proposal.noVotesCount) / (masternodesCount * MASTERNODES_SUFFICIENT_VOTING_PERCENT), 0.0), 1.0) : 0.0;
        _completedPercent = percent * 100.0;
        _title = proposal.title;
        if (proposal.totalPaymentCount == 1) {
            _remainingPayment = NSLocalizedString(@"one-time payment", nil);
            _repeatInterval = NSLocalizedString(@"DASH", nil);
        }
        else {
            _remainingPayment = [NSString localizedStringWithFormat:NSLocalizedString(@"%d month(s) remaining", nil), proposal.remainingPaymentCount];
            _repeatInterval = NSLocalizedString(@"DASH per month", nil);
        }
        _monthlyAmount = [NSString stringWithFormat:@"%d", proposal.monthlyAmount];
        if (proposal.ownerUsername.length > 0) {
            _ownerUsername = [NSString stringWithFormat:@"%@ %@", NSLocalizedString(@"By", @"As in 'By Username'"), proposal.ownerUsername];
        }
        else {
            _ownerUsername = @"";
        }
        _likes = [NSString stringWithFormat:@"%d", proposal.yesVotesCount - proposal.noVotesCount];
        _comments = [NSString stringWithFormat:@"%d", proposal.commentsCount];
    }
    return self;
}

@end

NS_ASSUME_NONNULL_END
