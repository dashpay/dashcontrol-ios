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

#import "ProposalDetailHeaderViewModel.h"

#import "DCBudgetProposalEntity+CoreDataClass.h"
#import "NSDate+DCAdditions.h"
#import "APIBudget.h"

NS_ASSUME_NONNULL_BEGIN

@interface ProposalDetailHeaderViewModel ()

@property (assign, nonatomic) CGFloat completedPercent;
@property (copy, nonatomic) NSString *title;
@property (copy, nonatomic) NSString *ownerUsername;

@property (copy, nonatomic) NSString *yesVotes;
@property (copy, nonatomic) NSString *noVotes;
@property (copy, nonatomic) NSString *abstainVotes;

@property (copy, nonatomic) NSArray<Pair *> *rows;

@end

@implementation ProposalDetailHeaderViewModel

- (void)updateWithProposal:(DCBudgetProposalEntity *)proposal {
    NSInteger masternodesCount = APIBudget.masternodesCount;
    CGFloat percent = masternodesCount > 0 ? MIN(MAX((proposal.yesVotesCount - proposal.noVotesCount) / (masternodesCount * MASTERNODES_SUFFICIENT_VOTING_PERCENT), 0.0), 1.0) : 0.0;
    self.completedPercent = percent * 100.0;
    self.title = proposal.title;
    if (proposal.ownerUsername.length > 0) {
        self.ownerUsername = [NSString stringWithFormat:@"%@ %@", NSLocalizedString(@"Owner", nil), proposal.ownerUsername];
    }
    else {
        self.ownerUsername = @"";
    }

    self.yesVotes = [NSString stringWithFormat:@"%d", proposal.yesVotesCount];
    self.noVotes = [NSString stringWithFormat:@"%d", proposal.noVotesCount];
    self.abstainVotes = [NSString stringWithFormat:@"%d", proposal.abstainVotesCount];

    NSMutableArray<Pair *> *rows = [NSMutableArray array];

    NSString *amountString = [NSString stringWithFormat:@"%d DASH", proposal.monthlyAmount];
    NSString *completedPayments = NSLocalizedString(@"Completed\npayments", nil);
    NSString *noPayments = NSLocalizedString(@"no payments occurred yet", nil);
    NSString *remainingMonths = [NSString localizedStringWithFormat:NSLocalizedString(@"%d month(s) remaining", nil), proposal.remainingPaymentCount];
    if (proposal.totalPaymentCount == 1) {
        [rows addObject:[Pair first:NSLocalizedString(@"One-time\npayment", nil) second:amountString]];

        NSString *completedPaymentsValue = [NSString stringWithFormat:@"%@\n(%@)", noPayments, remainingMonths];
        [rows addObject:[Pair first:completedPayments second:completedPaymentsValue]];
    }
    else {
        [rows addObject:[Pair first:NSLocalizedString(@"Monthly\namount", nil) second:amountString]];

        NSInteger completedCount = proposal.totalPaymentCount - proposal.remainingPaymentCount;
        NSString *completedPaymentsFirstPart = nil;
        if (completedCount == 0) {
            completedPaymentsFirstPart = noPayments;
        }
        else {
            NSInteger spentAmount = completedCount * proposal.monthlyAmount;
            completedPaymentsFirstPart = [NSString stringWithFormat:NSLocalizedString(@"%d totaling in %d DASH", nil), completedCount, spentAmount];
        }
        NSString *completedPaymentsValue = [NSString stringWithFormat:@"%@\n(%@)", completedPaymentsFirstPart, remainingMonths];
        [rows addObject:[Pair first:completedPayments second:completedPaymentsValue]];
    }

    // TODO startDate ?
    NSString *paymentStartEnd = [NSString stringWithFormat:@"%@\n%@",
                                                           [NSDateFormatter localizedStringFromDate:proposal.dateAdded
                                                                                          dateStyle:NSDateFormatterShortStyle
                                                                                          timeStyle:NSDateFormatterNoStyle],
                                                           [NSDateFormatter localizedStringFromDate:proposal.dateEnd
                                                                                          dateStyle:NSDateFormatterShortStyle
                                                                                          timeStyle:NSDateFormatterNoStyle]];
    [rows addObject:[Pair first:NSLocalizedString(@"Payment\nadded / end", nil) second:paymentStartEnd]];

    if (!proposal.willBeFunded && proposal.votingDeadline) {
        NSDate *votingDeadline = proposal.votingDeadline;
        NSInteger numberOfDays = [[NSDate date] dc_daysToDate:votingDeadline];
        NSString *inXDaysString = [NSString localizedStringWithFormat:NSLocalizedString(@"in %ld day(s)", nil), numberOfDays];
        [rows addObject:[Pair first:NSLocalizedString(@"Final voting\ndeadline", nil) second:inXDaysString]];
    }

    NSString *funded = proposal.willBeFunded
                           ? NSLocalizedString(@"Yes", @"Will be funded - yes")
                           : [NSString localizedStringWithFormat:NSLocalizedString(@"No. This proposal needs additional %d Yes vote(s) to become funded", nil), proposal.remainingYesVotesUntilFunding];
    [rows addObject:[Pair first:NSLocalizedString(@"Will be\nfunded", nil) second:funded]];

    self.rows = rows;
}

@end

NS_ASSUME_NONNULL_END
