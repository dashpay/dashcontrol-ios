//
//  PriceViewController.h
//  DashControl
//
//  Created by Manuel Boyer on 22/08/2017.
//  Copyright © 2017 dashfoundation. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Charts/Charts.h>

@interface PriceViewController : UIViewController <ChartViewDelegate, UITableViewDelegate, UITableViewDataSource,NSFetchedResultsControllerDelegate>

@property (nonatomic, assign) BOOL shouldHideData;

@property (strong, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) IBOutlet UIButton *marketButton;
@property (strong, nonatomic) IBOutlet UIButton *exchangeButton;

- (void)handleOption:(NSString *)key forChartView:(ChartViewBase *)chartView;

- (void)updateChartData;

-(IBAction)chooseInterval:(id)sender;

-(IBAction)chooseTimeFrame:(id)sender;

-(IBAction)chooseMarket:(id)sender;

-(IBAction)chooseExchange:(id)sender;

@end
