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

#import "APIPrice.h"
#import "DCChartTimeFormatter.h"
#import "Pair.h"

@interface APIPrice (Testability)

+ (Pair<Pair<NSDate *> *> *)parametersAndKnownDatesForStart:(nullable NSDate *)start
                                                        end:(nullable NSDate *)end
                                              intervalStart:(nullable NSDate *)intervalStart
                                                intervalEnd:(nullable NSDate *)intervalEnd;

@end

@interface APIPriceTests : XCTestCase

@end

#pragma mark -

@implementation APIPriceTests

- (void)setUp {
    [super setUp];
    
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
    
    
    NSLog(@"");
    
}

- (void)testExample {
    // This is an example of a functional test case.
    // Use XCTAssert and related functions to verify your tests produce the correct results.
    
    NSTimeInterval startTimeInterval = [DCChartTimeFormatter timeIntervalForChartTimeFrame:ChartTimeFrame_1M];
    NSDate *start = [[NSDate date] dateByAddingTimeInterval:-startTimeInterval];
    NSDate *end = nil;
    NSDate *intervalStart = nil;
    NSDate *intervalEnd = nil;
    Pair<Pair<NSDate *> *> *dateData = [APIPrice parametersAndKnownDatesForStart:start
                                                                             end:end
                                                                   intervalStart:intervalStart
                                                                     intervalEnd:intervalEnd];
    NSDate *realStart = dateData.first.first;
    NSDate *realEnd = dateData.first.second;
    NSDate *knownDataStart = dateData.second.first;
    NSDate *knownDataEnd = dateData.second.second;
    
    XCTAssertTrue(realStart == start);
    
}



@end
