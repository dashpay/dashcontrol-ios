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

#import "ProposalsHeaderViewModel+Protected.h"

#import "DCBudgetInfoEntity+CoreDataClass.h"
#import "NSDate+DCAdditions.h"

NS_ASSUME_NONNULL_BEGIN

// Constants below based on https://gist.github.com/strophy/9eb743f7bc717c17a2e776e461f24c49
// And https://docs.dash.org/en/latest/governance.html#budget-cycles
// And https://github.com/dashpay/dash/blob/master/src/chainparams.cpp#L81

static NSUInteger const BLOCKS_BEFORE_DEADLINE = 1662;
static double const AVG_BLOCKS_PER_MINUTE = 2.6;
static NSTimeInterval DEADLINE_SECONDS_BEFORE_VOTING_DATE = BLOCKS_BEFORE_DEADLINE * AVG_BLOCKS_PER_MINUTE * 60;

@implementation ProposalsHeaderViewModel

- (instancetype)init {
    self = [super init];
    if (self) {
        _total = @"...";
        _alloted = @"...";
        _superblockPaymentInfo = @"...";
    }
    return self;
}

- (void)updateWithBudgetInfo:(nullable DCBudgetInfoEntity *)budgetInfo {
    if (budgetInfo) {
        self.total = [NSString stringWithFormat:@"%.1f", budgetInfo.totalAmount];
        self.alloted = [NSString stringWithFormat:@"%.1f", budgetInfo.allotedAmount];

        NSDate *votingDeadlineDate = [budgetInfo.paymentDate dateByAddingTimeInterval:-DEADLINE_SECONDS_BEFORE_VOTING_DATE];
        NSDate *now = [NSDate date];
        if ([now compare:votingDeadlineDate] == NSOrderedAscending) {
            self.superblockPaymentInfo = [NSString stringWithFormat:@"%@ %@, %@ %d",
                                                                    NSLocalizedString(@"Voting deadline", nil),
                                                                    [votingDeadlineDate dc_asInDateString],
                                                                    NSLocalizedString(@"Superblock", nil),
                                                                    budgetInfo.superblock];
        }
        else {
            self.superblockPaymentInfo = [NSString stringWithFormat:@"%@ %d %@",
                                                                    NSLocalizedString(@"Superblock", nil),
                                                                    budgetInfo.superblock,
                                                                    [budgetInfo.paymentDate dc_asInDateString]];
        }
    }
    else {
        self.total = @"...";
        self.alloted = @"...";
        self.superblockPaymentInfo = @"...";
    }
}

- (void)setSegmentIndex:(ProposalsSegmentIndex)segmentIndex {
    if (_segmentIndex == segmentIndex) {
        return;
    }

    _segmentIndex = segmentIndex;

    [self.delegate proposalsHeaderViewModelDidSetSegmentIndex:self];
}

@end

NS_ASSUME_NONNULL_END
