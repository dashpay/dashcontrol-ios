//
//  ChartTimeFormatter.m
//  DashControl
//
//  Created by Sam Westrich on 8/31/17.
//  Copyright © 2017 dashfoundation. All rights reserved.
//

#import "ChartTimeFormatter.h"

@implementation ChartTimeFormatter

- (NSString * _Nonnull)stringForValue:(double)value axis:(ChartAxisBase * _Nullable)axis {
    
    static NSDateFormatter *dateFormatter = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateStyle:NSDateFormatterMediumStyle];
    });
    return [dateFormatter stringFromDate:[NSDate dateWithTimeIntervalSince1970:value]];
}

+(NSTimeInterval)timeIntervalForChartTimeInterval:(ChartTimeInterval)timeInterval {
    switch (timeInterval) {
        case ChartTimeInterval_5Mins:
            return 300;
        case ChartTimeInterval_15Mins:
            return 900;
        case ChartTimeInterval_30Mins:
            return 1800;
        case ChartTimeInterval_2Hour:
            return 7200;
        case ChartTimeInterval_4Hours:
            return 14400;
        case ChartTimeInterval_1Day:
            return 86400;
    }
}

+(NSTimeInterval)timeIntervalForChartTimeFrame:(ChartTimeFrame)chartTimeFrame {
    switch (chartTimeFrame) {
        case ChartTimeFrame_6H:
            return 21600;
        case ChartTimeFrame_24H:
            return 86400;
        case ChartTimeFrame_2D:
            return 172800;
        case ChartTimeFrame_4D:
            return 345600;
        case ChartTimeFrame_1W:
            return 604800;
        case ChartTimeFrame_1M:
            return 2568400;
    }
}

-(NSInteger)stepsForChartTimeInterval:(ChartTimeInterval)chartTimeInterval timeFrame:(ChartTimeFrame)chartTimeFrame {
    NSTimeInterval timeInterval = [ChartTimeFormatter timeIntervalForChartTimeInterval:chartTimeInterval];
    NSTimeInterval Frame = [ChartTimeFormatter timeIntervalForChartTimeFrame:chartTimeFrame];
    if (Frame < timeInterval) return 1;
    return ceil(Frame/timeInterval);
}

-(void)maxIndexForChartTimeInterval:(NSDate *)date {
    
}

@end
