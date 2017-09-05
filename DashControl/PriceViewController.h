//
//  PriceViewController.h
//  DashControl
//
//  Created by Manuel Boyer on 22/08/2017.
//  Copyright © 2017 dashfoundation. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Charts/Charts.h>

@interface PriceViewController : UIViewController <ChartViewDelegate>

@property (nonatomic, strong) NSManagedObjectContext* managedObjectContext;
@property (nonatomic, assign) BOOL shouldHideData;

- (void)handleOption:(NSString *)key forChartView:(ChartViewBase *)chartView;

- (void)updateChartData;

-(IBAction)chooseInterval:(id)sender;

-(IBAction)chooseTimeFrame:(id)sender;

@end
