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

#import <XCTest/XCTest.h>

#import "TimestampIntervalArray.h"

static TimestampInterval *TI(NSUInteger start, NSUInteger end) {
    return [TimestampInterval start:start end:end];
}

@interface TimestampIntervalTests : XCTestCase

@end

@implementation TimestampIntervalTests

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testTimestampInterval {
    TimestampInterval *interval = [TimestampInterval start:8 end:42];
    XCTAssertTrue(interval.start == 8, @"start is not right");
    XCTAssertTrue(interval.end == 42, @"end is not right");

    XCTAssertTrue([interval intersects:[TimestampInterval start:16 end:84]], @"intersection test failed");
    XCTAssertTrue([interval intersects:[TimestampInterval start:1 end:84]], @"intersection test failed");
    XCTAssertTrue([interval intersects:[TimestampInterval start:20 end:30]], @"intersection test failed");
    XCTAssertFalse([interval intersects:[TimestampInterval start:1 end:5]], @"intersection test failed");
    XCTAssertFalse([interval intersects:[TimestampInterval start:43 end:84]], @"intersection test failed");

    XCTAssertTrue([interval isEqual:interval], @"isEqual failed");
    XCTAssertTrue([interval isEqual:[TimestampInterval start:8 end:42]], @"isEqual failed");
    XCTAssertFalse([interval isEqual:[TimestampInterval start:10 end:42]], @"isEqual failed");

    NSDate *startDate = [NSDate dateWithTimeIntervalSinceNow:1000];
    NSDate *endDate = [NSDate dateWithTimeIntervalSinceNow:2000];
    NSTimeInterval startTimeInterval = [startDate timeIntervalSince1970];
    NSTimeInterval endTimeInterval = [endDate timeIntervalSince1970];
    interval = [TimestampInterval startDate:startDate endDate:endDate];
    XCTAssertTrue(interval.start == (NSUInteger)startTimeInterval, @"start is not right");
    XCTAssertTrue(interval.end == (NSUInteger)endTimeInterval, @"end is not right");

    XCTAssertThrows([TimestampInterval start:42 end:8], @"didn't throw assert for incorrect start/end");
    XCTAssertThrows([TimestampInterval startDate:endDate endDate:startDate], @"didn't throw assert for incorrect startDate/endDate");
}

- (void)testTimestampIntervalArray {
    TimestampIntervalArray *array = [[TimestampIntervalArray alloc] initWithArray:@[
        TI(16, 21),
        TI(2, 5),
        TI(30, 40),
        TI(8, 12),
    ]];

    NSArray *shouldBeSortedArray = @[
        TI(2, 5),
        TI(8, 12),
        TI(16, 21),
        TI(30, 40),
    ];

    XCTAssertTrue([array.sortedIntervals isEqual:shouldBeSortedArray], @"array should be sorted");
    XCTAssertTrue(array.minIntervalStart == 2);
    XCTAssertTrue(array.maxIntervalEnd == 40);

    array = [[TimestampIntervalArray alloc] initWithArray:@[]];
    XCTAssertTrue(array.minIntervalStart == NSNotFound);
    XCTAssertTrue(array.maxIntervalEnd == NSNotFound);
}

- (void)testTimestampIntervalMerging {
    TimestampIntervalArray *array = [[TimestampIntervalArray alloc] initWithArray:@[
        TI(16, 21),
        TI(2, 5),
        TI(30, 40),
        TI(53, 54),
        TI(51, 52),
        TI(8, 12),
        TI(51, 52),
        TI(53, 54),
        TI(20, 40),
    ]];

    NSArray<TimestampInterval *> *merged = [array mergedOverlappingIntervals];
    XCTAssertTrue(merged.count == 4);

    NSArray<TimestampInterval *> *shouldBeMerged = @[
        TI(2, 5),
        TI(8, 12),
        TI(16, 40),
        TI(51, 54),
    ];
    XCTAssertTrue([merged isEqual:shouldBeMerged]);
}

- (void)testTimestampIntervalEmptyGaps {
    // input:
    //
    // [[2, 5], [8, 12], [16, 21], [30, 40]]
    //
    TimestampIntervalArray *array = [[TimestampIntervalArray alloc] initWithArray:@[
        TI(2, 5),
        TI(16, 21),
        TI(8, 12),
        TI(30, 40),
    ]];

    id nilValue = nil;
    XCTAssertThrows([array findEmptyGapsDesiredInterval:nilValue], @"nil desired interval is not allowed");

    TimestampInterval *desired = TI(0, 15);
    NSArray<TimestampInterval *> *emptyGaps = [array findEmptyGapsDesiredInterval:desired];
    NSArray<TimestampInterval *> *shouldBeEmptyGaps = @[ TI(0, 2), TI(5, 8), TI(12, 16) ];
    XCTAssertTrue([emptyGaps isEqual:shouldBeEmptyGaps]);

    desired = TI(6, 14);
    emptyGaps = [array findEmptyGapsDesiredInterval:desired];
    shouldBeEmptyGaps = @[ TI(5, 8), TI(12, 16) ];
    XCTAssertTrue([emptyGaps isEqual:shouldBeEmptyGaps]);

    desired = TI(17, 20);
    emptyGaps = [array findEmptyGapsDesiredInterval:desired];
    shouldBeEmptyGaps = @[];
    XCTAssertTrue([emptyGaps isEqual:shouldBeEmptyGaps]);

    desired = TI(50, 60);
    emptyGaps = [array findEmptyGapsDesiredInterval:desired];
    shouldBeEmptyGaps = @[ TI(40, 60) ];
    XCTAssertTrue([emptyGaps isEqual:shouldBeEmptyGaps]);

    desired = TI(0, 2);
    emptyGaps = [array findEmptyGapsDesiredInterval:desired];
    shouldBeEmptyGaps = @[ TI(0, 2) ];
    XCTAssertTrue([emptyGaps isEqual:shouldBeEmptyGaps]);

    desired = TI(50, 50);
    emptyGaps = [array findEmptyGapsDesiredInterval:desired];
    shouldBeEmptyGaps = @[ TI(40, 50) ];
    XCTAssertTrue([emptyGaps isEqual:shouldBeEmptyGaps]);

    // input:
    //
    // [ [4, 7], [9, 12] ]
    //
    array = [[TimestampIntervalArray alloc] initWithArray:@[ TI(4, 7), TI(9, 12) ]];

    desired = TI(1, 16);
    emptyGaps = [array findEmptyGapsDesiredInterval:desired];
    shouldBeEmptyGaps = @[ TI(1, 4), TI(7, 9), TI(12, 16) ];
    XCTAssertTrue([emptyGaps isEqual:shouldBeEmptyGaps]);

    // input:
    //
    // [ [4, 12] ]
    //
    array = [[TimestampIntervalArray alloc] initWithArray:@[ TI(4, 12) ]];

    desired = TI(1, 16);
    emptyGaps = [array findEmptyGapsDesiredInterval:desired];
    shouldBeEmptyGaps = @[ TI(1, 4), TI(12, 16) ];
    XCTAssertTrue([emptyGaps isEqual:shouldBeEmptyGaps]);

    desired = TI(0, 2);
    emptyGaps = [array findEmptyGapsDesiredInterval:desired];
    shouldBeEmptyGaps = @[ TI(0, 4) ];
    XCTAssertTrue([emptyGaps isEqual:shouldBeEmptyGaps]);

    desired = TI(100, 200);
    emptyGaps = [array findEmptyGapsDesiredInterval:desired];
    shouldBeEmptyGaps = @[ TI(12, 200) ];
    XCTAssertTrue([emptyGaps isEqual:shouldBeEmptyGaps]);

    // input:
    //
    // [ ]
    //
    array = [[TimestampIntervalArray alloc] initWithArray:@[]];
    desired = TI(100, 200);
    emptyGaps = [array findEmptyGapsDesiredInterval:desired];
    shouldBeEmptyGaps = @[ desired ];
    XCTAssertTrue([emptyGaps isEqual:shouldBeEmptyGaps]);
}

- (void)testTimestampIntervalEmptyGapsWithAllowedDistance {
    // input:
    //
    // [ [30, 42], [48, 60] ]
    //
    TimestampIntervalArray *array = [[TimestampIntervalArray alloc] initWithArray:@[
        TI(48, 60),
        TI(30, 42),
    ]];

    TimestampInterval *desired = TI(5, 12);
    NSUInteger allowedDistance = 10;
    NSArray<TimestampInterval *> *emptyGaps = [array findEmptyGapsDesiredInterval:desired maximumAllowedDistanceToJoin:allowedDistance];
    NSArray<TimestampInterval *> *shouldBeEmptyGaps = @[ desired ];
    XCTAssertTrue([emptyGaps isEqual:shouldBeEmptyGaps]);

    desired = TI(100, 150);
    emptyGaps = [array findEmptyGapsDesiredInterval:desired maximumAllowedDistanceToJoin:allowedDistance];
    shouldBeEmptyGaps = @[ desired ];
    XCTAssertTrue([emptyGaps isEqual:shouldBeEmptyGaps]);
    
    desired = TI(80, 90);
    allowedDistance = 100;
    emptyGaps = [array findEmptyGapsDesiredInterval:desired maximumAllowedDistanceToJoin:allowedDistance];
    shouldBeEmptyGaps = @[ TI(60, 90) ];
    XCTAssertTrue([emptyGaps isEqual:shouldBeEmptyGaps]);
    
    desired = TI(4, 16);
    emptyGaps = [array findEmptyGapsDesiredInterval:desired maximumAllowedDistanceToJoin:allowedDistance];
    shouldBeEmptyGaps = @[ TI(4, 30) ];
    XCTAssertTrue([emptyGaps isEqual:shouldBeEmptyGaps]);
}

@end
