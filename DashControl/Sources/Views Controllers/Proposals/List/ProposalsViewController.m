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

#import "ProposalsViewController.h"

#import "BaseProposalViewController+Protected.h"
#import "UIColor+DCStyle.h"
#import "DCSearchController.h"
#import "ProposalTableViewCell.h"
#import "ProposalsSearchResultsController.h"
#import "ProposalsViewModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface ProposalsViewController () <DCSearchControllerDelegate, DCSearchResultsUpdating>

@property (strong, nonatomic) ProposalsViewModel *viewModel;

@property (strong, nonatomic) DCSearchController *searchController;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *searchBarButtonItem;

@end

@implementation ProposalsViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.viewModel.fetchedResultsController.delegate = self;
    [self reload];

    ProposalsSearchResultsController *searchResultsController = [[ProposalsSearchResultsController alloc] init];
    searchResultsController.tableView.dataSource = self;
    searchResultsController.tableView.delegate = self;
    self.searchController = [[DCSearchController alloc] initWithController:searchResultsController];
    self.searchController.delegate = self;
    self.searchController.searchResultsUpdater = self;
    self.definesPresentationContext = YES;
}

- (ProposalsViewModel *)viewModel {
    if (!_viewModel) {
        _viewModel = [[ProposalsViewModel alloc] init];
    }
    return _viewModel;
}

#pragma mark Actions

- (IBAction)refreshControlAction:(UIRefreshControl *)sender {
    [self reload];
}

- (IBAction)searchBarButtonItemAction:(UIBarButtonItem *)sender {
    self.navigationItem.rightBarButtonItem = nil;

    DCSearchBar *searchBar = self.searchController.searchBar;
    self.navigationItem.titleView = searchBar;
    [searchBar showAnimatedCompletion:nil];

    self.searchController.active = YES;
    [searchBar becomeFirstResponder];
}

#pragma mark UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSFetchedResultsController *frc = [self fetchedResultsControllerForTableView:tableView];
    id<NSFetchedResultsSectionInfo> sectionInfo = frc.sections.firstObject;
    NSUInteger numberOfObjects = sectionInfo.numberOfObjects;
    return numberOfObjects;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    ProposalTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:PROPOSAL_CELL_ID forIndexPath:indexPath];
    NSFetchedResultsController *frc = [self fetchedResultsControllerForTableView:tableView];
    [self fetchedResultsController:frc configureCell:cell atIndexPath:indexPath];
    return cell;
}

#pragma mark UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];

    // TODO
    //    [self showDetailViewController:detailViewController sender:self];
}

#pragma mark DCSearchControllerDelegate

- (void)willDismissSearchController:(DCSearchController *)searchController {
    self.navigationItem.titleView = nil;
    self.navigationItem.rightBarButtonItem = self.searchBarButtonItem;
}

#pragma mark DCSearchResultsUpdating

- (void)updateSearchResultsForSearchController:(DCSearchController *)searchController {
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(performSearch) object:nil];
    NSTimeInterval const delay = 0.2;
    [self performSelector:@selector(performSearch) withObject:nil afterDelay:delay];
}

#pragma mark Private

- (NSFetchedResultsController *)fetchedResultsControllerForTableView:(UITableView *)tableView {
    return (tableView == self.tableView ? self.viewModel.fetchedResultsController : self.viewModel.searchFetchedResultsController);
}

- (void)performSearch {
    NSString *query = self.searchController.searchBar.text;
    BOOL result = [self.viewModel searchWithQuery:query];
    if (!result) {
        return; // nothing changed
    }

    ProposalsSearchResultsController *searchResultsController = (ProposalsSearchResultsController *)self.searchController.searchResultsController;
    [searchResultsController.tableView reloadData];
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
