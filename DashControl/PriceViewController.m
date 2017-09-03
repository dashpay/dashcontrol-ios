//
//  PriceViewController.m
//  DashControl
//
//  Created by Manuel Boyer on 22/08/2017.
//  Copyright © 2017 dashfoundation. All rights reserved.
//

#import "PriceViewController.h"
#import "DCCoreDataManager.h"
#import "ChartDataEntry+CoreDataProperties.h"
#import "ChartTimeFormatter.h"

@interface PriceViewController ()


@property (nonatomic, strong) IBOutlet CandleStickChartView *chartView;
@property (nonatomic, strong) IBOutlet UIButton *optionsButton;
@property (nonatomic, strong) IBOutlet NSArray *options;

@end

@implementation PriceViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.title = @"Candle Stick Chart";
    
    self.options = @[
                     @{@"key": @"toggleValues", @"label": @"Toggle Values"},
                     @{@"key": @"toggleIcons", @"label": @"Toggle Icons"},
                     @{@"key": @"toggleHighlight", @"label": @"Toggle Highlight"},
                     @{@"key": @"animateX", @"label": @"Animate X"},
                     @{@"key": @"animateY", @"label": @"Animate Y"},
                     @{@"key": @"animateXY", @"label": @"Animate XY"},
                     @{@"key": @"saveToGallery", @"label": @"Save to Camera Roll"},
                     @{@"key": @"togglePinchZoom", @"label": @"Toggle PinchZoom"},
                     @{@"key": @"toggleAutoScaleMinMax", @"label": @"Toggle auto scale min/max"},
                     @{@"key": @"toggleShadowColorSameAsCandle", @"label": @"Toggle shadow same color"},
                     @{@"key": @"toggleData", @"label": @"Toggle Data"},
                     ];
    
    _chartView.delegate = self;
    
    _chartView.chartDescription.enabled = NO;
    
    _chartView.maxVisibleCount = 60;
    _chartView.pinchZoomEnabled = NO;
    _chartView.drawGridBackgroundEnabled = NO;
    
    ChartTimeFormatter * chartTimeFormatter = [[ChartTimeFormatter alloc] init];
    
    NSInteger steps = [chartTimeFormatter stepsForChartTimeInterval:ChartTimeInterval_5Mins timeViewLength:ChartTimeViewLength_6H];
    
    ChartXAxis *xAxis = _chartView.xAxis;
    xAxis.labelPosition = XAxisLabelPositionBottom;
    xAxis.drawGridLinesEnabled = NO;
//    xAxis.axisMinimum = 1;
//    xAxis.axisMaximum = steps;
    //[xAxis setValueFormatter:dateFormatter];
    
    ChartYAxis *leftAxis = _chartView.leftAxis;
    leftAxis.labelCount = 7;
    leftAxis.drawGridLinesEnabled = NO;
    leftAxis.drawAxisLineEnabled = NO;
    
    ChartYAxis *rightAxis = _chartView.rightAxis;
    rightAxis.enabled = NO;
    
    _chartView.legend.enabled = NO;
    
    [self updateChartData];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)updateChartData
{
    if (self.shouldHideData)
    {
        _chartView.data = nil;
        return;
    }
//    NSError * error = nil;
//    NSArray * chartData = [[DCCoreDataManager sharedManager] fetchChartDataForExchange:1 forMarket:3 startTime:nil endTime:nil inContext:self.managedObjectContext error:&error] ;
//    if (!error) {
//    NSMutableArray *charDataPoints = [[NSMutableArray alloc] init];
//    
//    for (int i = 0; i < chartData.count; i++)
//    {
//        ChartDataEntry * entry = [chartData objectAtIndex:0];
//        [charDataPoints addObject:[[CandleChartDataEntry alloc] initWithX:i shadowH:entry.high shadowL:entry.low open:entry.open close:entry.close icon: [UIImage imageNamed:@"icon"]]];
//    }
//    
//    CandleChartDataSet *set1 = [[CandleChartDataSet alloc] initWithValues:charDataPoints label:@"Data Set"];
//    set1.axisDependency = AxisDependencyLeft;
//    [set1 setColor:[UIColor colorWithWhite:80/255.f alpha:1.f]];
//    
//    set1.drawIconsEnabled = NO;
//    
//    set1.shadowColor = UIColor.darkGrayColor;
//    set1.shadowWidth = 0.7;
//    set1.decreasingColor = UIColor.redColor;
//    set1.decreasingFilled = YES;
//    set1.increasingColor = [UIColor colorWithRed:122/255.f green:242/255.f blue:84/255.f alpha:1.f];
//    set1.increasingFilled = NO;
//    set1.neutralColor = UIColor.blueColor;
//    
//    CandleChartData *data = [[CandleChartData alloc] initWithDataSet:set1];
    
//    NSMutableArray *yVals1 = [[NSMutableArray alloc] init];
//    
//    for (int i = 0; i < 100; i++)
//    {
//        double mult = (100 + 1);
//        double val = (double) (arc4random_uniform(40)) + mult;
//        double high = (double) (arc4random_uniform(9)) + 8.0;
//        double low = (double) (arc4random_uniform(9)) + 8.0;
//        double open = (double) (arc4random_uniform(6)) + 1.0;
//        double close = (double) (arc4random_uniform(6)) + 1.0;
//        BOOL even = i % 2 == 0;
//        [yVals1 addObject:[[CandleChartDataEntry alloc] initWithX:i shadowH:val + high shadowL:val - low open:even ? val + open : val - open close:even ? val - close : val + close icon: [UIImage imageNamed:@"icon"]]];
//    }
//    
//    CandleChartDataSet *set1 = [[CandleChartDataSet alloc] initWithValues:yVals1 label:@"Data Set"];
//    set1.axisDependency = AxisDependencyLeft;
//    [set1 setColor:[UIColor colorWithWhite:80/255.f alpha:1.f]];
//    
//    set1.drawIconsEnabled = NO;
//    
//    set1.shadowColor = UIColor.darkGrayColor;
//    set1.shadowWidth = 0.7;
//    set1.decreasingColor = UIColor.redColor;
//    set1.decreasingFilled = YES;
//    set1.increasingColor = [UIColor colorWithRed:122/255.f green:242/255.f blue:84/255.f alpha:1.f];
//    set1.increasingFilled = NO;
//    set1.neutralColor = UIColor.blueColor;
//    
//    CandleChartData *data = [[CandleChartData alloc] initWithDataSet:set1];
    
    //_chartView.data = data;
    //}
}

#pragma mark - Common option actions

- (void)handleOption:(NSString *)key forChartView:(ChartViewBase *)chartView
{
    if ([key isEqualToString:@"toggleValues"])
    {
        for (id<IChartDataSet> set in chartView.data.dataSets)
        {
            set.drawValuesEnabled = !set.isDrawValuesEnabled;
        }
        
        [chartView setNeedsDisplay];
    }
    
    if ([key isEqualToString:@"toggleIcons"])
    {
        for (id<IChartDataSet> set in chartView.data.dataSets)
        {
            set.drawIconsEnabled = !set.isDrawIconsEnabled;
        }
        
        [chartView setNeedsDisplay];
    }
    
    if ([key isEqualToString:@"toggleHighlight"])
    {
        chartView.data.highlightEnabled = !chartView.data.isHighlightEnabled;
        [chartView setNeedsDisplay];
    }
    
    if ([key isEqualToString:@"animateX"])
    {
        [chartView animateWithXAxisDuration:3.0];
    }
    
    if ([key isEqualToString:@"animateY"])
    {
        [chartView animateWithYAxisDuration:3.0];
    }
    
    if ([key isEqualToString:@"animateXY"])
    {
        [chartView animateWithXAxisDuration:3.0 yAxisDuration:3.0];
    }
    
    if ([key isEqualToString:@"saveToGallery"])
    {
        UIImageWriteToSavedPhotosAlbum([chartView getChartImageWithTransparent:NO], nil, nil, nil);
    }
    
    if ([key isEqualToString:@"togglePinchZoom"])
    {
        BarLineChartViewBase *barLineChart = (BarLineChartViewBase *)chartView;
        barLineChart.pinchZoomEnabled = !barLineChart.isPinchZoomEnabled;
        
        [chartView setNeedsDisplay];
    }
    
    if ([key isEqualToString:@"toggleAutoScaleMinMax"])
    {
        BarLineChartViewBase *barLineChart = (BarLineChartViewBase *)chartView;
        barLineChart.autoScaleMinMaxEnabled = !barLineChart.isAutoScaleMinMaxEnabled;
        
        [chartView notifyDataSetChanged];
    }
    
    if ([key isEqualToString:@"toggleData"])
    {
        _shouldHideData = !_shouldHideData;
        [self updateChartData];
    }
    
    if ([key isEqualToString:@"toggleBarBorders"])
    {
        for (id<IBarChartDataSet, NSObject> set in chartView.data.dataSets)
        {
            if ([set conformsToProtocol:@protocol(IBarChartDataSet)])
            {
                set.barBorderWidth = set.barBorderWidth == 1.0 ? 0.0 : 1.0;
            }
        }
        
        [chartView setNeedsDisplay];
    }
}


- (void)optionTapped:(NSString *)key
{
    if ([key isEqualToString:@"toggleShadowColorSameAsCandle"])
    {
        for (id<ICandleChartDataSet> set in _chartView.data.dataSets)
        {
            set.shadowColorSameAsCandle = !set.shadowColorSameAsCandle;
        }
        
        [_chartView notifyDataSetChanged];
        return;
    }
    
    [self handleOption:key forChartView:_chartView];
}

#pragma mark - Actions

#pragma mark - ChartViewDelegate

- (void)chartValueSelected:(ChartViewBase * __nonnull)chartView entry:(ChartDataEntry * __nonnull)entry highlight:(ChartHighlight * __nonnull)highlight
{
    NSLog(@"chartValueSelected");
}

- (void)chartValueNothingSelected:(ChartViewBase * __nonnull)chartView
{
    NSLog(@"chartValueNothingSelected");
}

@end
