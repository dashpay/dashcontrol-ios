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

#import "PriceViewController.h"

#import <CoreData/CoreData.h>

#import "AddItemTableViewCell.h"
#import "ChartViewModel.h"
#import "ItemTableViewCell.h"
#import "PriceTriggerTableViewCellModel.h"
#import "PriceTriggerViewController.h"
#import "PriceViewModel.h"
#import "TableViewFetchedResultsControllerDelegate.h"

NS_ASSUME_NONNULL_BEGIN

static NSString *const ADD_CELL_ID = @"AddItemTableViewCell";
static NSString *const CELL_ID = @"ItemTableViewCell";

@interface PriceViewController () <UITableViewDataSource, NSFetchedResultsControllerDelegate>

@property (strong, nonatomic) PriceViewModel *viewModel;
@property (strong, nonatomic) TableViewFetchedResultsControllerDelegate *fetchedResultsControllerDelegate;

@property (strong, nonatomic) IBOutlet UITableView *tableView;

@end

@implementation PriceViewController

- (PriceViewModel *)viewModel {
    if (!_viewModel) {
        _viewModel = [[PriceViewModel alloc] init];
    }
    return _viewModel;
}

- (void)viewDidLoad {
    [super viewDidLoad];

    self.title = NSLocalizedString(@"Price", nil);

    [self.tableView registerNib:[UINib nibWithNibName:@"AddItemTableViewCell" bundle:nil] forCellReuseIdentifier:ADD_CELL_ID];
    [self.tableView registerNib:[UINib nibWithNibName:@"ItemTableViewCell" bundle:nil] forCellReuseIdentifier:CELL_ID];
    UIRefreshControl *refreshControl = [[UIRefreshControl alloc] init];
    refreshControl.tintColor = [UIColor whiteColor];
    [refreshControl addTarget:self action:@selector(refreshControlAction:) forControlEvents:UIControlEventValueChanged];
    self.tableView.refreshControl = refreshControl;
    
    [self reload];

    // KVO

    [self mvvm_observe:@"viewModel.fetchedResultsController" with:^(typeof(self) self, id value) {
        self.viewModel.fetchedResultsController.delegate = self.fetchedResultsControllerDelegate;
        [self.tableView reloadData];
    }];
}

- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];

    // explanation https://gist.github.com/smileyborg/ec4812c146f575cd006d98d681108ba8
    NSIndexPath *selectedIndexPath = self.tableView.indexPathForSelectedRow;
    if (selectedIndexPath != nil) {
        id<UIViewControllerTransitionCoordinator> coordinator = self.transitionCoordinator;
        if (coordinator != nil) {
            [coordinator animateAlongsideTransition:^(id<UIViewControllerTransitionCoordinatorContext> context) {
                [self.tableView deselectRowAtIndexPath:selectedIndexPath animated:YES];
            }
                completion:^(id<UIViewControllerTransitionCoordinatorContext> context) {
                    if (context.cancelled) {
                        [self.tableView selectRowAtIndexPath:selectedIndexPath animated:NO scrollPosition:UITableViewScrollPositionNone];
                    }
                }];
        }
        else {
            [self.tableView deselectRowAtIndexPath:selectedIndexPath animated:animated];
        }
    }
}

#pragma mark UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == 0) {
        return 1;
    }
    else {
        NSFetchedResultsController *frc = self.viewModel.fetchedResultsController;
        id<NSFetchedResultsSectionInfo> sectionInfo = frc.sections.firstObject;
        NSUInteger numberOfObjects = sectionInfo.numberOfObjects;
        return numberOfObjects;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0) {
        AddItemTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:ADD_CELL_ID forIndexPath:indexPath];
        cell.titleText = NSLocalizedString(@"Price alerts", nil);
        return cell;
    }
    else {
        ItemTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CELL_ID forIndexPath:indexPath];
        [self configureTriggerCell:cell atIndexPath:indexPath];
        return cell;
    }
}

#pragma mark UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0) {
        PriceTriggerViewController *detailViewController =
            [PriceTriggerViewController controllerWithExchangeMarketPair:self.chartViewModel.exchangeMarketPair];
        [self showViewController:detailViewController sender:self];
    }
    else {
        DCTriggerEntity *trigger = [self triggerEntityAtIndexPath:indexPath];
        PriceTriggerViewController *detailViewController = [PriceTriggerViewController controllerWithTrigger:trigger];
        [self showViewController:detailViewController sender:self];
    }
}

#pragma mark Actions

- (void)refreshControlAction:(UIRefreshControl *)sender {
    [self reload];
}

#pragma mark Private

- (TableViewFetchedResultsControllerDelegate *)fetchedResultsControllerDelegate {
    if (!_fetchedResultsControllerDelegate) {
        _fetchedResultsControllerDelegate = [[TableViewFetchedResultsControllerDelegate alloc] init];
        _fetchedResultsControllerDelegate.tableView = self.tableView;
        _fetchedResultsControllerDelegate.transformationBlock = ^NSIndexPath *_Nonnull(NSIndexPath *_Nonnull indexPath) {
            return [NSIndexPath indexPathForRow:indexPath.row inSection:1];
        };
    }
    return _fetchedResultsControllerDelegate;
}

- (void)configureTriggerCell:(ItemTableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath {
    DCTriggerEntity *trigger = [self triggerEntityAtIndexPath:indexPath];
    PriceTriggerTableViewCellModel *viewModel = [[PriceTriggerTableViewCellModel alloc] initWithTrigger:trigger];
    [cell configureWithViewModel:viewModel];
}

- (DCTriggerEntity *)triggerEntityAtIndexPath:(NSIndexPath *)indexPath {
    NSFetchedResultsController *frc = self.viewModel.fetchedResultsController;
    id<NSFetchedResultsSectionInfo> sectionInfo = frc.sections.firstObject;
    NSArray *objects = sectionInfo.objects;
    DCTriggerEntity *entity = objects[indexPath.row];
    return entity;
}

- (void)reload {
    if (self.tableView.contentOffset.y == 0) {
        self.tableView.contentOffset = CGPointMake(0.0, -self.tableView.refreshControl.frame.size.height);
        [self.tableView.refreshControl beginRefreshing];
    }

    weakify;
    [self.viewModel reloadWithCompletion:^(BOOL success) {
        strongify;

        [self.tableView.refreshControl endRefreshing];
    }];
}

@end

NS_ASSUME_NONNULL_END
