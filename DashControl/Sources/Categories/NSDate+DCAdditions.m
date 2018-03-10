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

- (NSInteger)dc_daysToDate:(NSDate *)toDate {
    NSDate *fromDatePointer = nil;
    NSDate *toDatePointer = nil;
    
    NSCalendar *calendar = [NSCalendar currentCalendar];
    [calendar rangeOfUnit:NSCalendarUnitDay startDate:&fromDatePointer interval:NULL forDate:self];
    [calendar rangeOfUnit:NSCalendarUnitDay startDate:&toDatePointer interval:NULL forDate:toDate];
    
    NSDateComponents *difference = [calendar components:NSCalendarUnitDay fromDate:fromDatePointer toDate:toDatePointer options:kNilOptions];
    
    return difference.day;
}

@end

NS_ASSUME_NONNULL_END
