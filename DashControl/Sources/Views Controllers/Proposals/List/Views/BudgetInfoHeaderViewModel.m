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

#import "BudgetInfoHeaderViewModel.h"

#import "DCBudgetInfoEntity+CoreDataClass.h"

NS_ASSUME_NONNULL_BEGIN

@implementation BudgetInfoHeaderViewModel

- (instancetype)initWithBudgetInfo:(nullable DCBudgetInfoEntity *)budgetInfo {
    self = [super init];
    if (self) {
        if (budgetInfo) {
            _total = [NSString stringWithFormat:@"%.1f", budgetInfo.totalAmount];
            _alloted = [NSString stringWithFormat:@"%.1f", budgetInfo.allotedAmount];

            NSString *superblockString = [NSString stringWithFormat:@"%@ %d", NSLocalizedString(@"Superblock", nil), budgetInfo.superblock];
            NSString *resultString = nil;
            if (budgetInfo.paymentDate) {
                NSInteger numberOfDays = [[self class] daysBetweenDate:[NSDate date] andDate:budgetInfo.paymentDate];
                NSString *inXDaysString = [NSString stringWithFormat:NSLocalizedString(@"in %d Days", @"Proposals View"), numberOfDays];
                NSString *formattedDateString = [NSDateFormatter localizedStringFromDate:budgetInfo.paymentDate
                                                                               dateStyle:NSDateFormatterLongStyle
                                                                               timeStyle:NSDateFormatterNoStyle];
                NSString *dateString = [NSString stringWithFormat:@"%@, %@", inXDaysString, formattedDateString];

                resultString = [NSString stringWithFormat:@"%@ %@", superblockString, dateString];
            }
            else {
                resultString = superblockString;
            }
            _superblocksPaymentInfo = resultString;
        }
        else {
            _total = @"...";
            _alloted = @"...";
            _superblocksPaymentInfo = @"...";
        }
    }
    return self;
}

#pragma mark - Private

+ (NSInteger)daysBetweenDate:(NSDate *)fromDateTime andDate:(NSDate *)toDateTime {
    NSDate *fromDate = nil;
    NSDate *toDate = nil;

    NSCalendar *calendar = [NSCalendar currentCalendar];
    [calendar rangeOfUnit:NSCalendarUnitDay startDate:&fromDate interval:NULL forDate:fromDateTime];
    [calendar rangeOfUnit:NSCalendarUnitDay startDate:&toDate interval:NULL forDate:toDateTime];

    NSDateComponents *difference = [calendar components:NSCalendarUnitDay fromDate:fromDate toDate:toDate options:kNilOptions];

    return difference.day;
}

@end

NS_ASSUME_NONNULL_END
