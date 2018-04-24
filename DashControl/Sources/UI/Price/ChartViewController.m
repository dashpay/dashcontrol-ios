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

#import "ChartViewController.h"

@import Charts;

#import "DCExchangeEntity+CoreDataClass.h"
#import "DCMarketEntity+CoreDataClass.h"
#import "UIFont+DCStyle.h"
#import "ChartViewDataSource.h"
#import "ChartViewModel.h"
#import "DCChartTimeFormatter.h"
#import "DCSegmentedControl.h"

NS_ASSUME_NONNULL_BEGIN

@interface ChartViewController () <IChartAxisValueFormatter, ChartViewDataSourceUpdatesDelegate>

@property (weak, nonatomic) IBOutlet CombinedChartView *chartView;
@property (weak, nonatomic) IBOutlet DCSegmentedControl *timeFrameSegmentedControl;
@property (weak, nonatomic) IBOutlet DCSegmentedControl *intervalSegmentedControl;
@property (weak, nonatomic) IBOutlet UIButton *marketButton;
@property (weak, nonatomic) IBOutlet UIButton *exchangeButton;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicatorView;

@end

@implementation ChartViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    [self.viewModel prefetchInitialChartData];

    [self setupView];

    [self setupKVO];
}

#pragma mark - Actions

- (IBAction)exchangeButtonAction:(id)sender {
    NSArray *exchanges = [self.viewModel.exchangeMarketPair availableExchanges];
    if (exchanges.count == 0) {
        return;
    }

    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"Choose Exchange", @"Price Screen")
                                                                             message:nil
                                                                      preferredStyle:UIAlertControllerStyleActionSheet];
    for (DCExchangeEntity *exchange in exchanges) {
        [alertController addAction:[UIAlertAction actionWithTitle:exchange.name style:UIAlertActionStyleDefault handler:^(UIAlertAction *_Nonnull action) {
                             [self.viewModel selectExchange:exchange];
                         }]];
    }
    [alertController addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"Cancel", nil) style:UIAlertActionStyleCancel handler:nil]];
    [self presentViewController:alertController animated:YES completion:nil];
}

- (IBAction)marketButtonAction:(id)sender {
    NSArray *markets = [self.viewModel.exchangeMarketPair availableMarkets];
    if (markets.count == 0) {
        return;
    }

    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"Choose Market", @"Price Screen")
                                                                             message:nil
                                                                      preferredStyle:UIAlertControllerStyleActionSheet];
    for (DCMarketEntity *market in markets) {
        [alertController addAction:[UIAlertAction actionWithTitle:market.name style:UIAlertActionStyleDefault handler:^(UIAlertAction *_Nonnull action) {
                             [self.viewModel selectMarket:market];
                         }]];
    }
    [alertController addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"Cancel", nil) style:UIAlertActionStyleCancel handler:nil]];
    [self presentViewController:alertController animated:YES completion:nil];
}

- (IBAction)timeFrameValueChangedAction:(DCSegmentedControl *)sender {
    [self.viewModel selectTimeFrame:sender.selectedIndex];
}

- (IBAction)intervalValueChangedAction:(DCSegmentedControl *)sender {
    [self.viewModel selectTimeInterval:sender.selectedIndex];
}

#pragma mark - Private

- (void)setupKVO {
    [self mvvm_observe:@"viewModel.exchangeMarketPair.exchange" with:^(typeof(self) self, DCExchangeEntity * value) {
        [self.exchangeButton setTitle:value.name ?: @"..." forState:UIControlStateNormal];
    }];

    [self mvvm_observe:@"viewModel.exchangeMarketPair.market" with:^(typeof(self) self, DCMarketEntity * value) {
        [self.marketButton setTitle:value.name ?: @"..." forState:UIControlStateNormal];
    }];

    [self mvvm_observe:@"viewModel.timeFrame" with:^(typeof(self) self, NSNumber * value) {
        self.timeFrameSegmentedControl.selectedIndex = value.unsignedIntegerValue;
    }];

    [self mvvm_observe:@"viewModel.chartDataSource" with:^(typeof(self) self, ChartViewDataSource * value) {
        value.updatesDelegate = self;
    }];

    [self mvvm_observe:@"viewModel.state" with:^(typeof(self) self, NSNumber * value) {
        switch (self.viewModel.state) {
            case ChartViewModelState_None: {
                break;
            }
            case ChartViewModelState_Loading: {
                self.chartView.hidden = YES;
                self.exchangeButton.hidden = YES;
                self.marketButton.hidden = YES;
                self.timeFrameSegmentedControl.hidden = YES;
                self.intervalSegmentedControl.hidden = YES;
                [self.activityIndicatorView startAnimating];

                break;
            }
            case ChartViewModelState_Done: {
                self.chartView.hidden = NO;
                self.exchangeButton.hidden = NO;
                self.marketButton.hidden = NO;
                self.timeFrameSegmentedControl.hidden = NO;
                self.intervalSegmentedControl.hidden = NO;
                [self.activityIndicatorView stopAnimating];

                break;
            }
        }
    }];
}

- (void)setupView {
    self.exchangeButton.titleLabel.numberOfLines = 1;
    self.exchangeButton.titleLabel.adjustsFontSizeToFitWidth = YES;
    self.exchangeButton.titleLabel.baselineAdjustment = UIBaselineAdjustmentAlignCenters;
    self.marketButton.titleLabel.numberOfLines = 1;
    self.marketButton.titleLabel.adjustsFontSizeToFitWidth = YES;
    self.marketButton.titleLabel.baselineAdjustment = UIBaselineAdjustmentAlignCenters;

    self.timeFrameSegmentedControl.items = @[
        NSLocalizedString(@"6H", @"6 hours"),
        NSLocalizedString(@"24H", @"24 hours"),
        NSLocalizedString(@"2D", @"2 days"),
        NSLocalizedString(@"4D", @"4 days"),
        NSLocalizedString(@"1W", @"1 week"),
        NSLocalizedString(@"1M", @"1 month"),
        NSLocalizedString(@"6M", @"6 months"),
    ];
    self.intervalSegmentedControl.items = @[
        NSLocalizedString(@"5M", @"5 minutes"),
        NSLocalizedString(@"15M", @"15 minutes"),
        NSLocalizedString(@"30M", @"30 minutes"),
        NSLocalizedString(@"2H", @"2 hours"),
        NSLocalizedString(@"4H", @"4 hours"),
        NSLocalizedString(@"1D", @"1 day"),
    ];

    self.chartView.chartDescription.enabled = NO;
    self.chartView.drawGridBackgroundEnabled = NO;
    self.chartView.drawBarShadowEnabled = NO;
    self.chartView.highlightFullBarEnabled = NO;
    self.chartView.drawOrder = @[
        @(CombinedChartDrawOrderBar),
        @(CombinedChartDrawOrderCandle),
    ];
    self.chartView.pinchZoomEnabled = NO;
    self.chartView.legend.enabled = NO;
    self.chartView.noDataTextColor = [UIColor colorWithWhite:1.0 alpha:0.6];
    self.chartView.noDataFont = [UIFont dc_montserratRegularFontOfSize:12.0];

    ChartYAxis *rightAxis = self.chartView.rightAxis;
    rightAxis.drawGridLinesEnabled = NO;
    rightAxis.labelTextColor = [UIColor colorWithWhite:1.0 alpha:0.6];
    rightAxis.axisMinimum = 0.0;

    ChartYAxis *leftAxis = self.chartView.leftAxis;
    leftAxis.drawGridLinesEnabled = NO;
    leftAxis.labelTextColor = [UIColor colorWithWhite:1.0 alpha:0.6];
    leftAxis.axisMinimum = 0.0;

    ChartXAxis *xAxis = self.chartView.xAxis;
    xAxis.drawGridLinesEnabled = NO;
    xAxis.labelTextColor = [UIColor colorWithWhite:1.0 alpha:0.6];
    xAxis.labelFont = [UIFont systemFontOfSize:9.0];
    xAxis.axisMinimum = 0.0;
    xAxis.labelPosition = XAxisLabelPositionBottom;
    xAxis.granularityEnabled = YES;
    xAxis.valueFormatter = self;
}

#pragma mark - ChartViewDataSourceUpdatesDelegate

- (void)chartViewDataSourceDidFetch:(ChartViewDataSource *)dataSource {
    self.chartView.data = dataSource.chartData;
    if (dataSource.chartData) {
        ChartYAxis *leftAxis = self.chartView.leftAxis;
        leftAxis.axisMinimum = dataSource.leftAxisMinimum;
        leftAxis.axisMaximum = dataSource.leftAxisMaximum;

        ChartXAxis *xAxis = self.chartView.xAxis;
        id<IChartDataSet> dataSet = dataSource.chartData.candleData.dataSets.firstObject;
        const NSInteger numberOfAxisLabels = 6;
        NSInteger granularity = dataSet.entryCount / numberOfAxisLabels;
        xAxis.granularity = granularity;
    }
    [self.chartView fitScreen];
}

#pragma mark - IChartAxisValueFormatter

- (NSString *)stringForValue:(double)value axis:(nullable ChartAxisBase *)axis {
    NSInteger index = (NSUInteger)value;
    id<IChartDataSet> dataSet = self.viewModel.chartDataSource.chartData.candleData.dataSets.firstObject;
    if (dataSet.entryCount <= index) {
        return @"";
    }
    NSDate *date = [dataSet entryForIndex:index].data;
    if (!date) {
        return @"";
    }

    static NSDateFormatter *dateFormatter = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setLocalizedDateFormatFromTemplate:@"MMM d"];
        dateFormatter.locale = [NSLocale autoupdatingCurrentLocale];
    });
    NSString *dateString = [dateFormatter stringFromDate:date];
    NSString *timeString = [NSDateFormatter localizedStringFromDate:date
                                                          dateStyle:NSDateFormatterNoStyle
                                                          timeStyle:NSDateFormatterShortStyle];
    NSString *resultString = [NSString stringWithFormat:@"%@\n%@", dateString, timeString];
    return resultString;
}

@end

NS_ASSUME_NONNULL_END
