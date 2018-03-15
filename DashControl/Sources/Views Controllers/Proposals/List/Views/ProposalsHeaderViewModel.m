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

        NSString *superblockString = [NSString localizedStringWithFormat:NSLocalizedString(@"%d Superblock(s)", nil), budgetInfo.superblock];
        NSString *resultString = nil;
        if (budgetInfo.paymentDate) {
            NSInteger numberOfDays = [[NSDate date] dc_daysToDate:budgetInfo.paymentDate];
            NSString *inXDaysString = [NSString localizedStringWithFormat:NSLocalizedString(@"in %ld day(s)", nil), numberOfDays];
            NSString *formattedDateString = [NSDateFormatter localizedStringFromDate:budgetInfo.paymentDate
                                                                           dateStyle:NSDateFormatterLongStyle
                                                                           timeStyle:NSDateFormatterNoStyle];
            NSString *dateString = [NSString stringWithFormat:@"%@, %@", inXDaysString, formattedDateString];

            resultString = [NSString stringWithFormat:@"%@ %@", superblockString, dateString];
        }
        else {
            resultString = superblockString;
        }
        self.superblockPaymentInfo = resultString;
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
