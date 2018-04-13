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
#import "NavigationTitleButton.h"
#import "ProposalDetailViewController.h"
#import "ProposalTableViewCell.h"
#import "ProposalsHeaderView.h"
#import "ProposalsHeaderViewModel.h"
#import "ProposalsSearchResultsController.h"
#import "ProposalsViewModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface ProposalsViewController () <DCSearchControllerDelegate, DCSearchResultsUpdating>

@property (strong, nonatomic) ProposalsViewModel *viewModel;

@property (strong, nonatomic) NavigationTitleButton *navigationTitleButton;
@property (strong, nonatomic) ProposalsHeaderView *proposalsHeaderView;
@property (strong, nonatomic) DCSearchController *searchController;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *searchBarButtonItem;

@end

@implementation ProposalsViewController

- (void)awakeFromNib {
    [super awakeFromNib];

    self.title = NSLocalizedString(@"Proposals", nil);
    self.tabBarItem.title = self.title;
}

- (void)viewDidLoad {
    [super viewDidLoad];

    UIImage *emptyImage = [[UIImage alloc] init];
    self.navigationController.navigationBar.shadowImage = emptyImage;
    [self.navigationController.navigationBar setBackgroundImage:emptyImage forBarMetrics:UIBarMetricsDefault];
    self.navigationItem.titleView = self.navigationTitleButton;

    // blue bg view above the tableView
    CGRect frame = [UIScreen mainScreen].bounds;
    frame.origin.y = -frame.size.height;
    UIView *topBackgroundView = [[UIView alloc] initWithFrame:frame];
    topBackgroundView.backgroundColor = [UIColor dc_barTintColor];
    [self.tableView insertSubview:topBackgroundView atIndex:0];

    self.tableView.tableHeaderView = self.proposalsHeaderView;

    [self.viewModel updateMasternodesCount];
    [self reload];

    ProposalsSearchResultsController *searchResultsController = [[ProposalsSearchResultsController alloc] init];
    searchResultsController.tableView.dataSource = self;
    searchResultsController.tableView.delegate = self;
    self.searchController = [[DCSearchController alloc] initWithController:searchResultsController];
    self.searchController.delegate = self;
    self.searchController.searchResultsUpdater = self;
    self.definesPresentationContext = YES;

    // KVO

    [self mvvm_observe:@"viewModel.fetchedResultsController" with:^(typeof(self) self, id value) {
        self.viewModel.fetchedResultsController.delegate = self;
        [self.tableView reloadData];
    }];

    [self mvvm_observe:@"viewModel.searchFetchedResultsController" with:^(typeof(self) self, id value) {
        ProposalsSearchResultsController *searchResultsController = (ProposalsSearchResultsController *)self.searchController.searchResultsController;
        [searchResultsController.tableView reloadData];
        self.viewModel.searchFetchedResultsController.delegate = searchResultsController;
    }];
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

#define TABLEVIEW_TOPBOTTOM_PADDING 6.0

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    if (tableView == self.tableView) {
        return CGFLOAT_MIN;
    }
    
    if (section == 0) {
        return TABLEVIEW_TOPBOTTOM_PADDING;
    }
    else {
        return CGFLOAT_MIN;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return TABLEVIEW_TOPBOTTOM_PADDING;
}

- (nullable UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    if (tableView == self.tableView) {
        return nil;
    }
    
    if (section == 0) {
        return [[UIView alloc] initWithFrame:CGRectZero];
    }
    else {
        return nil;
    }
}

- (nullable UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    return [[UIView alloc] initWithFrame:CGRectZero];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];

    DCSearchBar *searchBar = self.searchController.searchBar;
    [searchBar resignFirstResponder];
    
    NSFetchedResultsController *frc = [self fetchedResultsControllerForTableView:tableView];
    DCBudgetProposalEntity *entity = [frc objectAtIndexPath:indexPath];
    ProposalDetailViewController *detailViewController = [ProposalDetailViewController controllerWithProposal:entity];
    [self showViewController:detailViewController sender:self];
}

#pragma mark DCSearchControllerDelegate

- (void)willDismissSearchController:(DCSearchController *)searchController {
    self.navigationItem.titleView = self.navigationTitleButton;
    self.navigationItem.rightBarButtonItem = self.searchBarButtonItem;
}

#pragma mark DCSearchResultsUpdating

- (void)updateSearchResultsForSearchController:(DCSearchController *)searchController {
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(performSearch) object:nil];
    NSTimeInterval const delay = 0.2;
    [self performSelector:@selector(performSearch) withObject:nil afterDelay:delay];
}

#pragma mark Private

- (NavigationTitleButton *)navigationTitleButton {
    if (!_navigationTitleButton) {
        _navigationTitleButton = [[NavigationTitleButton alloc] initWithFrame:CGRectZero];
        _navigationTitleButton.title = NSLocalizedString(@"Proposals", nil);
        CGSize size = [_navigationTitleButton sizeThatFits:CGSizeZero];
        _navigationTitleButton.frame = CGRectMake(0.0, 0.0, size.width, size.height);
        [_navigationTitleButton addTarget:self action:@selector(navigationTitleButtonAction) forControlEvents:UIControlEventTouchUpInside];
    }
    return _navigationTitleButton;
}

- (void)navigationTitleButtonAction {
    self.navigationTitleButton.opened = !self.navigationTitleButton.opened;

    if (self.navigationTitleButton.opened) {
        [self.tableView setContentOffset:CGPointZero animated:YES];
    }
    [self.proposalsHeaderView setOpened:self.navigationTitleButton.opened animated:YES];
    self.tableView.tableHeaderView = self.proposalsHeaderView;
}

- (ProposalsHeaderView *)proposalsHeaderView {
    if (!_proposalsHeaderView) {
        _proposalsHeaderView = [[ProposalsHeaderView alloc] initWithFrame:CGRectZero];
        _proposalsHeaderView.viewModel = self.viewModel.headerViewModel;
    }
    return _proposalsHeaderView;
}

- (NSFetchedResultsController *)fetchedResultsControllerForTableView:(UITableView *)tableView {
    return (tableView == self.tableView ? self.viewModel.fetchedResultsController : self.viewModel.searchFetchedResultsController);
}

- (void)performSearch {
    NSString *query = self.searchController.searchBar.text;
    [self.viewModel searchWithQuery:query];
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
