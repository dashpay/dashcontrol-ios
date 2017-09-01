//
//  ChartTimeFormatter.h
//  DashControl
//
//  Created by Sam Westrich on 8/31/17.
//  Copyright © 2017 dashfoundation. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Charts/Charts.h>

typedef NS_ENUM(NSInteger, ChartTimeInterval) {
    ChartTimeInterval_5Mins = 0,
    ChartTimeInterval_15Mins = 1,
    ChartTimeInterval_30Mins = 2,
    ChartTimeInterval_2Hour = 3,
    ChartTimeInterval_4Hours = 4,
    ChartTimeInterval_1Day = 5
};

typedef NS_ENUM(NSInteger, ChartTimeViewLength) {
    ChartTimeViewLength_6H = 0,
    ChartTimeViewLength_24H = 1,
    ChartTimeViewLength_2D = 2,
    ChartTimeViewLength_4D = 3,
    ChartTimeViewLength_1W = 4,
    ChartTimeViewLength_1M = 5
};


@interface ChartTimeFormatter : NSObject <IChartAxisValueFormatter>

-(NSInteger)stepsForChartTimeInterval:(ChartTimeInterval)timeInterval timeViewLength:(ChartTimeViewLength)viewLength;

@end
