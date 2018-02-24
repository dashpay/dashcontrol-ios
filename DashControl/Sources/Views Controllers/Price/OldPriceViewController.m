//
//  PriceViewController.m
//  DashControl
//
//  Created by Manuel Boyer on 22/08/2017.
//  Copyright © 2017 dashfoundation. All rights reserved.
//

#import "OldPriceViewController.h"

#import "DCCoreDataManager.h"
#import "DCPersistenceStack.h"
#import "DCChartDataEntryEntity+CoreDataProperties.h"
#import "DCChartTimeFormatter.h"
#import "PriceAlertViewController.h"
#import "DCTriggerEntity+CoreDataProperties.h"
#import "DCExchangeEntity+CoreDataProperties.h"
#import "DCMarketEntity+CoreDataProperties.h"

@interface OldPriceViewController ()


@property (nonatomic, strong) IBOutlet CandleStickChartView *chartView;
@property (nonatomic, strong) IBOutlet UIButton *optionsButton;
@property (nonatomic, strong) IBOutlet NSArray *options;
@property (nonatomic, strong) DCMarketEntity * selectedMarket;
@property (nonatomic, strong) DCExchangeEntity * selectedExchange;
@property (nonatomic, assign) ChartTimeInterval timeInterval;
@property (nonatomic, strong) NSDate * startTime;
@property (nonatomic, strong) NSDate * endTime;
@property (nonatomic, strong) NSFetchedResultsController* triggerFetchedResultsController;
@property (nonatomic, strong) NSManagedObjectContext* managedObjectContext;

@end

@implementation OldPriceViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    
    
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
    
    ChartXAxis *xAxis = _chartView.xAxis;
    xAxis.labelPosition = XAxisLabelPositionBottom;
    xAxis.drawGridLinesEnabled = YES;
    
    ChartYAxis *leftAxis = _chartView.leftAxis;
    leftAxis.labelCount = 7;
    leftAxis.drawGridLinesEnabled = YES;
    leftAxis.drawAxisLineEnabled = NO;
    
    ChartYAxis *rightAxis = _chartView.rightAxis;
    rightAxis.enabled = NO;
    
    _chartView.legend.enabled = NO;

    self.tableView.allowsMultipleSelectionDuringEditing = NO;
}

-(void)setSelectedExchange:(DCExchangeEntity *)selectedExchange {
    _selectedExchange = selectedExchange;
    [self.exchangeButton setTitle:selectedExchange.name forState:UIControlStateNormal];
}

-(void)setSelectedMarket:(DCMarketEntity *)selectedMarket {
    _selectedMarket = selectedMarket;
    [self.marketButton setTitle:selectedMarket.name forState:UIControlStateNormal];
}

-(NSManagedObjectContext*)managedObjectContext {
    return self.stack.persistentContainer.viewContext;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)updateChartData
{
    _chartView.data = nil;
    // 
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

-(IBAction)chooseInterval:(id)sender {
    self.timeInterval = [((UISegmentedControl*)sender) selectedSegmentIndex];
    [self updateChartData];
}

-(IBAction)chooseTimeFrame:(id)sender {
    ChartTimeFrame chartTimeFrame = [((UISegmentedControl*)sender) selectedSegmentIndex];
    NSTimeInterval timeFrame = [DCChartTimeFormatter timeIntervalForChartTimeFrame:chartTimeFrame];
    self.startTime = [NSDate dateWithTimeIntervalSinceNow:-timeFrame];
    [self updateChartData];
}

-(IBAction)chooseMarket:(id)sender {
    NSArray * markets = [self.selectedExchange.markets sortedArrayUsingDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:@"name" ascending:TRUE]]];
    if (markets && [markets count]) {
        UIAlertController * alertController = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"Choose Market", @"Price View Screen") message:nil preferredStyle:UIAlertControllerStyleActionSheet];
        for (DCMarketEntity * market in markets) {
            [alertController addAction:[UIAlertAction actionWithTitle:market.name style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                self.selectedMarket = market;
                [self updateChartData];
            }]];
        }
        [alertController addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"Cancel", nil) style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        }]];
        
        [self presentViewController:alertController animated:TRUE completion:nil];
    }
}

-(IBAction)chooseExchange:(id)sender {
    NSError * error = nil;
    NSArray * exchanges = [[DCCoreDataManager sharedInstance] exchangesInContext:nil error:&error];
    UIAlertController * alertController = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"Choose Exchange", @"Price View Screen") message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    for (DCExchangeEntity * exchange in exchanges) {
        [alertController addAction:[UIAlertAction actionWithTitle:exchange.name style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            self.selectedExchange = exchange;
            ((UIButton*)sender).titleLabel.text = exchange.name;
            [self updateChartData];
        }]];
    }
    [alertController addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"Cancel", nil) style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
    }]];
    [self presentViewController:alertController animated:TRUE completion:nil];
}

#pragma mark - ChartViewDelegate

- (void)chartValueSelected:(ChartViewBase * __nonnull)chartView entry:(DCChartDataEntryEntity * __nonnull)entry highlight:(ChartHighlight * __nonnull)highlight
{
    NSLog(@"chartValueSelected");
}

- (void)chartValueNothingSelected:(ChartViewBase * __nonnull)chartView
{
    NSLog(@"chartValueNothingSelected");
}

#pragma mark - Price Alerts Section

#pragma mark - Fetch result controller

- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller {
    // The fetch controller is about to start sending change notifications, so prepare the table view for updates.
    [self.tableView beginUpdates];
}


- (void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type newIndexPath:(NSIndexPath *)newIndexPath {
    
    UITableView *tableView = self.tableView;
    
    switch(type) {
            
        case NSFetchedResultsChangeInsert:
            [tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:newIndexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeDelete:
            [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeUpdate:
            [self configureCell:[tableView cellForRowAtIndexPath:indexPath] atIndexPath:indexPath];
            break;
            
        case NSFetchedResultsChangeMove:
            [tableView moveRowAtIndexPath:indexPath toIndexPath:newIndexPath];
            [self configureCell:[tableView cellForRowAtIndexPath:newIndexPath] atIndexPath:indexPath];
            
            break;
    }
}


- (void)controller:(NSFetchedResultsController *)controller didChangeSection:(id )sectionInfo atIndex:(NSUInteger)sectionIndex forChangeType:(NSFetchedResultsChangeType)type {
    
    switch(type) {
            
        case NSFetchedResultsChangeInsert:
            [self.tableView insertSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeDelete:
            [self.tableView deleteSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeUpdate:
            break;
            
        case NSFetchedResultsChangeMove:
            break;
    }
}


- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller {
    // The fetch controller has sent all current change notifications, so tell the table view to process all updates.
    [self.tableView endUpdates];
}

- (NSFetchedResultsController *)triggerFetchedResultsController {
    
    if (_triggerFetchedResultsController != nil) {
        return _triggerFetchedResultsController;
    }
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"DCTriggerEntity" inManagedObjectContext:self.managedObjectContext];
    [fetchRequest setEntity:entity];
    NSSortDescriptor * sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"value" ascending:TRUE];
    [fetchRequest setSortDescriptors:@[sortDescriptor]];
    [fetchRequest setFetchBatchSize:20];
    NSFetchedResultsController *theFetchedResultsController =
    [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest
                                        managedObjectContext:self.managedObjectContext sectionNameKeyPath:nil
                                                   cacheName:nil];
    self.triggerFetchedResultsController = theFetchedResultsController;
    _triggerFetchedResultsController.delegate = self;
    NSError *error = nil;
    if (![_triggerFetchedResultsController performFetch:&error]) {
        /*
         Replace this implementation with code to handle the error appropriately.
         */
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
    }
    return _triggerFetchedResultsController;
}

#pragma mark - Trigger Table View

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (!section) {
        return [self.triggerFetchedResultsController.fetchedObjects count];
    } else return 1;
}

-(void)configureCell:(UITableViewCell*)cell atIndexPath:(NSIndexPath *)indexPath {
    DCTriggerEntity * triggerEntity = [self.triggerFetchedResultsController objectAtIndexPath:[NSIndexPath indexPathForRow:indexPath.row inSection:0]];
    switch (triggerEntity.type) {
        case DCTriggerBelow:
        {
            cell.textLabel.text = [NSString stringWithFormat:NSLocalizedString(@"Under %@", @"Price View Screen"),@(triggerEntity.value)];
            return;
        }
        case DCTriggerAbove:
        {
            cell.textLabel.text = [NSString stringWithFormat:NSLocalizedString(@"Over %@", @"Price View Screen"),@(triggerEntity.value)];
            return;
        }
    }
    
}

-(UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell;
    if (!indexPath.section) {
        static NSString * priceAlertCellIdentifierString = @"PriceAlertCellIdentifier";
        cell = [tableView dequeueReusableCellWithIdentifier:priceAlertCellIdentifierString];
        [self configureCell:cell atIndexPath:indexPath];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        
        return cell;
    }
    else {
        static NSString * addPriceAlertCellIdentifierString = @"AddPriceAlertCellIdentifier";
        cell = [tableView dequeueReusableCellWithIdentifier:addPriceAlertCellIdentifierString];
        cell.textLabel.text = NSLocalizedString(@"New Price Alert", @"Price Alert Screen");
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        return cell;
    }
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if (!indexPath.section) {
        DCTriggerEntity * triggerEntity = [self.triggerFetchedResultsController objectAtIndexPath:[NSIndexPath indexPathForRow:indexPath.row inSection:0]];
        [self performSegueWithIdentifier:@"PriceAlertSegue" sender:triggerEntity];
    }
    else {
        [self performSegueWithIdentifier:@"PriceAlertSegue" sender:nil];
    }
}

-(NSString*)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    if (!section) {
        return NSLocalizedString(@"PRICE ALERTS", @"Price Alert Screen");
    } else {
        return nil;
    }
}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 40;
}
-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return CGFLOAT_MIN;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return YES if you want the specified item to be editable.
    if (!indexPath.section) {
        return YES;
    }
    return NO;
}

// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        DCTriggerEntity * triggerEntity = [self.triggerFetchedResultsController objectAtIndexPath:[NSIndexPath indexPathForRow:indexPath.row inSection:0]];
        if (!triggerEntity.identifier) {
            [self.managedObjectContext deleteObject:triggerEntity];
            return;
        }
        [[DCBackendManager sharedInstance] deleteTriggerWithId:triggerEntity.identifier completion:^(NSError * _Nullable error,NSUInteger statusCode, id  _Nullable responseObject) {
            if (!error) {
                [self.managedObjectContext deleteObject:triggerEntity];
            }
        }];
    }
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    //we kind of hacked the sender as it contains the trigger to send to the next view
    if ([segue.identifier isEqualToString:@"PriceAlertSegue"]) {
        if ([sender isMemberOfClass:[DCTriggerEntity class]]) {
            ((PriceAlertViewController*)segue.destinationViewController).editingTrigger = sender;
        } else {
            ((PriceAlertViewController*)segue.destinationViewController).selectedMarket = self.selectedMarket;
            ((PriceAlertViewController*)segue.destinationViewController).selectedExchange = self.selectedExchange;
        }
    }
}

@end
