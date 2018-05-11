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

#import "NSDate+DCAdditions.h"

NS_ASSUME_NONNULL_BEGIN

@implementation NSDate (DCAdditions)

- (NSString *)dc_asInDateString {
    NSDate *earliest = [NSDate date];
    NSDate *latest = self;
    NSString *relativeDateString = [self dc_relativeDateStringEarliest:earliest latest:latest];
    return [NSString stringWithFormat:@"%@ %@", NSLocalizedString(@"in", @"as in 'in 2 hours'"), relativeDateString];
}

- (NSString *)dc_asDateAgoString {
    NSDate *earliest = self;
    NSDate *latest = [NSDate date];
    NSString *relativeDateString = [self dc_relativeDateStringEarliest:earliest latest:latest];
    return [NSString stringWithFormat:@"%@ %@", relativeDateString, NSLocalizedString(@"ago", @"as in '2 months ago'")];
}

#pragma mark Private

- (NSString *)dc_relativeDateStringEarliest:(NSDate *)earliest latest:(NSDate *)latest {
    NSCalendar *calendar = [NSCalendar currentCalendar];

    NSUInteger upToHours = NSCalendarUnitSecond | NSCalendarUnitMinute | NSCalendarUnitHour;
    NSDateComponents *difference = [calendar components:upToHours fromDate:earliest toDate:latest options:kNilOptions];

    if (difference.hour < 24) {
        if (difference.hour >= 1) {
            return [self dc_localizedStringWithFormat:@"%ld hour(s)" value:difference.hour];
        }
        else if (difference.minute >= 1) {
            return [self dc_localizedStringWithFormat:@"%ld minute(s)" value:difference.minute];
        }
        else {
            return [self dc_localizedStringWithFormat:@"%ld second(s)" value:difference.second];
        }
    }
    else {
        NSUInteger bigUnits = NSCalendarUnitTimeZone | NSCalendarUnitDay | NSCalendarUnitWeekOfYear | NSCalendarUnitMonth | NSCalendarUnitYear;

        NSDateComponents *components = [calendar components:bigUnits fromDate:earliest];
        earliest = [calendar dateFromComponents:components];

        components = [calendar components:bigUnits fromDate:latest];
        latest = [calendar dateFromComponents:components];

        difference = [calendar components:bigUnits fromDate:earliest toDate:latest options:kNilOptions];

        if (difference.year >= 1) {
            return [self dc_localizedStringWithFormat:@"%ld year(s)" value:difference.year];
        }
        else if (difference.month >= 1) {
            return [self dc_localizedStringWithFormat:@"%ld month(s)" value:difference.month];
        }
        else if (difference.weekOfYear >= 1) {
            return [self dc_localizedStringWithFormat:@"%ld week(s)" value:difference.weekOfYear];
        }
        else {
            return [self dc_localizedStringWithFormat:@"%ld day(s)" value:difference.day];
        }
    }
}

- (NSString *)dc_localizedStringWithFormat:(NSString *)format value:(NSInteger)value {
    return [NSString localizedStringWithFormat:NSLocalizedString(format, nil), value];
}

@end

NS_ASSUME_NONNULL_END
