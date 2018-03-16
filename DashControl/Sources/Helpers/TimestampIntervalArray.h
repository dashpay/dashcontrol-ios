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

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

#pragma mark - Element

/**
 NSUInteger's precision is enough
 */
@interface TimestampInterval : NSObject

@property (readonly, assign, nonatomic) NSUInteger start;
@property (readonly, assign, nonatomic) NSUInteger end;

+ (instancetype)startDate:(NSDate *)startDate endDate:(NSDate *)endDate;
+ (instancetype)start:(NSUInteger)start end:(NSUInteger)end;

- (instancetype)initWithStartDate:(NSDate *)startDate endDate:(NSDate *)endDate;
- (instancetype)initWithStart:(NSUInteger)start end:(NSUInteger)end NS_DESIGNATED_INITIALIZER;

- (instancetype)init NS_UNAVAILABLE;

- (BOOL)intersects:(TimestampInterval *)interval;

@end

#pragma mark - Array

@interface TimestampIntervalArray : NSObject

@property (readonly, copy, nonatomic) NSArray<TimestampInterval *> *sortedIntervals;
/**
 returns `NSNotFound` if input is empty
 */
@property (readonly, assign, nonatomic) NSUInteger minIntervalStart;
/**
 returns `NSNotFound` if input is empty
 */
@property (readonly, assign, nonatomic) NSUInteger maxIntervalEnd;
/**
 calculates lazy
 */
@property (readonly, copy, nonatomic) NSArray<TimestampInterval *> *mergedOverlappingIntervals;

- (instancetype)initWithArray:(NSArray<TimestampInterval *> *)array;

- (NSArray<TimestampInterval *> *)findEmptyGapsDesiredInterval:(TimestampInterval *)desired;
- (NSArray<TimestampInterval *> *)findEmptyGapsDesiredInterval:(TimestampInterval *)desired
                                  maximumAllowedDistanceToJoin:(NSUInteger)allowedDistance;

@end

NS_ASSUME_NONNULL_END
