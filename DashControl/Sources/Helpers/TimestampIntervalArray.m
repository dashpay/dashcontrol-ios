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

#import "TimestampIntervalArray.h"

NS_ASSUME_NONNULL_BEGIN

#pragma mark - Element

@implementation TimestampInterval

+ (instancetype)startDate:(NSDate *)startDate endDate:(NSDate *)endDate {
    return [[[self class] alloc] initWithStartDate:startDate endDate:endDate];
}

+ (instancetype)start:(NSUInteger)start end:(NSUInteger)end {
    return [[[self class] alloc] initWithStart:start end:end];
}

- (instancetype)initWithStartDate:(NSDate *)startDate endDate:(NSDate *)endDate {
    NSParameterAssert(startDate);
    NSParameterAssert(endDate);
    NSAssert([startDate compare:endDate] != NSOrderedDescending, @"TimestampInterval: startDate should be earlier than endDate (or the same)");

    return [self initWithStart:(NSUInteger)startDate.timeIntervalSince1970
                           end:(NSUInteger)endDate.timeIntervalSince1970];
}

- (instancetype)initWithStart:(NSUInteger)start end:(NSUInteger)end {
    NSAssert(start <= end, @"TimestampInterval: start should be less than or equal end");

    self = [super init];
    if (self) {
        _start = start;
        _end = end;
    }
    return self;
}

- (BOOL)intersects:(TimestampInterval *)interval {
    return (self.start <= interval.end && interval.start <= self.end);
}

- (BOOL)isEqualToInterval:(TimestampInterval *)interval {
    if (!interval) {
        return NO;
    }

    BOOL haveEqualStarts = (self.start == interval.start);
    if (!haveEqualStarts) {
        return NO;
    }

    BOOL haveEqualEnds = (self.end == interval.end);
    if (!haveEqualEnds) {
        return NO;
    }

    return YES;
}

- (BOOL)isEqual:(id)object {
    if (self == object) {
        return YES;
    }

    if (![object isKindOfClass:[self class]]) {
        return NO;
    }

    return [self isEqualToInterval:object];
}

- (NSUInteger)hash {
    return @(self.start).hash ^ @(self.end).hash;
}

- (NSString *)description {
    if (self.start > NSTimeIntervalSince1970) { // looks like date
        return [NSString stringWithFormat:@"[ %@ -- %@ ]",
                                          [NSDateFormatter localizedStringFromDate:[NSDate dateWithTimeIntervalSince1970:self.start]
                                                                         dateStyle:NSDateFormatterShortStyle
                                                                         timeStyle:NSDateFormatterShortStyle],
                                          [NSDateFormatter localizedStringFromDate:[NSDate dateWithTimeIntervalSince1970:self.end]
                                                                         dateStyle:NSDateFormatterShortStyle
                                                                         timeStyle:NSDateFormatterShortStyle]];
    }
    else {
        return [NSString stringWithFormat:@"[ %lu -- %lu ]", self.start, self.end];
    }
}

@end

#pragma mark - Array

@interface TimestampIntervalArray ()

@property (copy, nonatomic) NSArray<TimestampInterval *> *mergedOverlappingIntervals;

@end

@implementation TimestampIntervalArray

- (instancetype)initWithArray:(NSArray<TimestampInterval *> *)array {
    self = [super init];
    if (self) {
        NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"start" ascending:YES];
        _sortedIntervals = [array sortedArrayUsingDescriptors:@[ sortDescriptor ]];
    }
    return self;
}

- (NSUInteger)minIntervalStart {
    if (self.sortedIntervals.count > 0) {
        return self.sortedIntervals.firstObject.start;
    }
    else {
        return NSNotFound;
    }
}

- (NSUInteger)maxIntervalEnd {
    if (self.sortedIntervals.count > 0) {
        return self.sortedIntervals.lastObject.end;
    }
    else {
        return NSNotFound;
    }
}

- (NSArray<TimestampInterval *> *)mergedOverlappingIntervals {
    if (!_mergedOverlappingIntervals) {
        _mergedOverlappingIntervals = [[self class] arrayByMergingOverlappingIntervalsInSortedArray:self.sortedIntervals];
    }
    return _mergedOverlappingIntervals;
}

- (NSArray<TimestampInterval *> *)findEmptyGapsDesiredInterval:(TimestampInterval *)desired {
    return [self findEmptyGapsDesiredInterval:desired maximumAllowedDistanceToJoin:NSNotFound];
}

- (NSArray<TimestampInterval *> *)findEmptyGapsDesiredInterval:(TimestampInterval *)desired
                                  maximumAllowedDistanceToJoin:(NSUInteger)allowedDistance {
    NSParameterAssert(desired);
    if (!desired) {
        return @[];
    }

    if (allowedDistance != NSNotFound && self.sortedIntervals.count > 0 &&
        ((desired.end < self.minIntervalStart && self.minIntervalStart - desired.end > allowedDistance) ||
         (desired.start > self.maxIntervalEnd && desired.start - self.maxIntervalEnd > allowedDistance))) {
        return @[ desired ];
    }

    return [[self class] findEmptyGapsInSortedAndMergedArray:self.mergedOverlappingIntervals
                                             desiredInterval:desired];
}

#pragma mark Private

+ (NSArray<TimestampInterval *> *)findEmptyGapsInSortedAndMergedArray:(NSArray<TimestampInterval *> *)array
                                                      desiredInterval:(TimestampInterval *)desired {
    if (array.count == 0) {
        return @[ desired ];
    }

    NSMutableArray<TimestampInterval *> *result = [NSMutableArray array];

    if (array.count == 1) {
        TimestampInterval *single = array.firstObject;

        if (desired.start < single.start) {
            TimestampInterval *interval = [TimestampInterval start:desired.start
                                                               end:single.start];
            if ([interval intersects:desired]) {
                [result addObject:interval];
            }
        }

        if (single.end < desired.end) {
            TimestampInterval *interval = [TimestampInterval start:single.end
                                                               end:desired.end];
            if ([interval intersects:desired]) {
                [result addObject:interval];
            }
        }
    }
    else {
        for (NSUInteger i = 1; i < array.count; i++) {
            if (i == 1 && desired.start < array[i - 1].start) {
                TimestampInterval *interval = [TimestampInterval start:desired.start
                                                                   end:array[i - 1].start];
                if ([interval intersects:desired]) {
                    [result addObject:interval];
                }
            }

            TimestampInterval *interval = [TimestampInterval start:array[i - 1].end
                                                               end:array[i].start];
            if ([interval intersects:desired]) {
                [result addObject:interval];
            }

            if (i == array.count - 1 && array[array.count - 1].end < desired.end) {
                TimestampInterval *interval = [TimestampInterval start:array[array.count - 1].end
                                                                   end:desired.end];
                if ([interval intersects:desired]) {
                    [result addObject:interval];
                }
            }
        }
    }

    return [result copy];
}

+ (NSArray<TimestampInterval *> *)arrayByMergingOverlappingIntervalsInSortedArray:(NSArray<TimestampInterval *> *)array {
    if (array.count <= 1) {
        return array;
    }

    NSMutableArray<TimestampInterval *> *result = [NSMutableArray array];

    [result addObject:array.firstObject];

    for (NSUInteger i = 1; i < array.count; i++) {
        TimestampInterval *top = result.lastObject;

        /*
         in a classic implementation of this algorithm ("Merge Overlapping Intervals")
         it doesn't merge neighboring intervals: [1, 2], [2, 4]
         our modification allows such merging:
         
         `if (top.end < array[i].start) {` changed to
         `if (top.end + 1 < array[i].start) {`
         
         i.e.: [1, 2], [2, 4] will become [1, 4]
         */

        if (top.end + 1 < array[i].start) {
            [result addObject:array[i]];
        }
        else if (top.end < array[i].end) {
            TimestampInterval *interval = [TimestampInterval start:top.start end:array[i].end];
            [result removeLastObject];
            [result addObject:interval];
        }
    }

    return [result copy];
}

@end

NS_ASSUME_NONNULL_END
