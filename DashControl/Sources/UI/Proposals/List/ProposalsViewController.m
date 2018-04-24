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
#import "ProposalsSegmentSelectorView.h"
#import "ProposalsTopView.h"
#import "ProposalsViewModel.h"

NS_ASSUME_NONNULL_BEGIN

static CGFloat const TOP_VIEW_HEIGHT = 88.0;

@interface ProposalsViewController () <DCSearchControllerDelegate, DCSearchResultsUpdating, ProposalsSegmentSelectorViewDelegate>

@property (strong, nonatomic) ProposalsViewModel *viewModel;

@property (strong, nonatomic) NavigationTitleButton *navigationTitleButton;
@property (strong, nonatomic) ProposalsSegmentSelectorView *segmentSelectorView;
@property (strong, nonatomic) IBOutlet ProposalsTopView *topView;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *topViewTopConstraint;
@property (strong, nonatomic) ProposalsHeaderView *proposalsHeaderView;
@property (strong, nonatomic) DCSearchController *searchController;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *searchBarButtonItem;

@end

@implementation ProposalsViewController

- (void)awakeFromNib {
    [super awakeFromNib];

    self.title = @""; // hides back button title in the detail controller
    self.tabBarItem.title = NSLocalizedString(@"Proposals", nil);
}

- (void)viewDidLoad {
    [super viewDidLoad];

    UIImage *emptyImage = [[UIImage alloc] init];
    self.navigationController.navigationBar.shadowImage = emptyImage;
    [self.navigationController.navigationBar setBackgroundImage:emptyImage forBarMetrics:UIBarMetricsDefault];
    self.navigationItem.titleView = self.navigationTitleButton;

    self.topView.viewModel = self.viewModel.topViewModel;

    self.tableView.contentInset = UIEdgeInsetsMake(TOP_VIEW_HEIGHT, 0.0, 0.0, 0.0);
    self.tableView.scrollIndicatorInsets = self.tableView.contentInset;
    self.tableView.tableHeaderView = self.proposalsHeaderView;
    UIRefreshControl *refreshControl = [[UIRefreshControl alloc] init];
    refreshControl.tintColor = [UIColor colorWithWhite:1.0 alpha:0.6];
    [refreshControl addTarget:self action:@selector(refreshControlAction:) forControlEvents:UIControlEventValueChanged];
    self.refreshControl = refreshControl;

    [self.viewModel updateMasternodesCount];
    [self reload];

    ProposalsSearchResultsController *searchResultsController = [[ProposalsSearchResultsController alloc] init];
    searchResultsController.tableView.dataSource = self;
    searchResultsController.tableView.delegate = self;
    self.searchController = [[DCSearchController alloc] initWithController:searchResultsController];
    self.searchController.delegate = self;
    self.searchController.searchResultsUpdater = self;
    UIView *searchAccessoryView = self.searchController.searchAccessoryView;
    ProposalsSegmentedControl *searchSegmentedControl = [[ProposalsSegmentedControl alloc] initWithFrame:CGRectZero];
    searchSegmentedControl.translatesAutoresizingMaskIntoConstraints = NO;
    searchSegmentedControl.backgroundColor = [UIColor dc_barTintColor];
    [searchSegmentedControl addTarget:self action:@selector(searchSegmentedControlAction:) forControlEvents:UIControlEventValueChanged];
    [searchAccessoryView addSubview:searchSegmentedControl];
    [searchSegmentedControl.topAnchor constraintEqualToAnchor:searchAccessoryView.topAnchor].active = YES;
    [searchSegmentedControl.leadingAnchor constraintEqualToAnchor:searchAccessoryView.leadingAnchor].active = YES;
    [searchSegmentedControl.bottomAnchor constraintEqualToAnchor:searchAccessoryView.bottomAnchor].active = YES;
    [searchSegmentedControl.trailingAnchor constraintEqualToAnchor:searchAccessoryView.trailingAnchor].active = YES;
    [searchSegmentedControl.heightAnchor constraintEqualToConstant:44.0].active = YES;

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

- (void)refreshControlAction:(UIRefreshControl *)sender {
    [self reload];
}

- (IBAction)searchBarButtonItemAction:(UIBarButtonItem *)sender {
    [self.segmentSelectorView setOpen:NO];

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

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if (scrollView != self.tableView) {
        return;
    }
    
    CGFloat offset = scrollView.contentOffset.y + scrollView.contentInset.top;
    self.topViewTopConstraint.constant = MIN(-offset, 0.0);
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

- (ProposalsSegmentSelectorView *)segmentSelectorView {
    if (!_segmentSelectorView) {
        _segmentSelectorView = [[ProposalsSegmentSelectorView alloc] initWithFrame:CGRectZero];
        _segmentSelectorView.translatesAutoresizingMaskIntoConstraints = NO;
        _segmentSelectorView.delegate = self;
        [_segmentSelectorView.segmentedControl addTarget:self action:@selector(segmentSelectorViewAction:) forControlEvents:UIControlEventValueChanged];
        [_segmentSelectorView.segmentedControl addTarget:self action:@selector(segmentSelectorViewCancel:) forControlEvents:UIControlEventTouchCancel];
    }
    return _segmentSelectorView;
}

- (ProposalsHeaderView *)proposalsHeaderView {
    if (!_proposalsHeaderView) {
        _proposalsHeaderView = [[ProposalsHeaderView alloc] initWithFrame:CGRectZero];
        _proposalsHeaderView.viewModel = self.viewModel.headerViewModel;
        [_proposalsHeaderView sizeToFit];
    }
    return _proposalsHeaderView;
}

- (void)navigationTitleButtonAction {
    if (self.segmentSelectorView.window) {
        [self.segmentSelectorView setOpen:NO];
    }
    else {
        UIView *view = self.navigationController.view;
        [view insertSubview:self.segmentSelectorView belowSubview:self.navigationController.navigationBar];
        [self.segmentSelectorView.topAnchor constraintEqualToAnchor:self.navigationController.navigationBar.bottomAnchor].active = YES;
        [self.segmentSelectorView.leadingAnchor constraintEqualToAnchor:view.leadingAnchor].active = YES;
        [self.segmentSelectorView.trailingAnchor constraintEqualToAnchor:view.trailingAnchor].active = YES;
        [self.segmentSelectorView.widthAnchor constraintEqualToAnchor:view.widthAnchor].active = YES;
        if (@available(iOS 11.0, *)) {
            [self.segmentSelectorView.bottomAnchor constraintEqualToAnchor:view.safeAreaLayoutGuide.bottomAnchor].active = YES;
        }
        else {
            [self.segmentSelectorView.bottomAnchor constraintEqualToAnchor:self.navigationController.bottomLayoutGuide.topAnchor].active = YES;
        }
        [self.segmentSelectorView layoutIfNeeded];

        [self.segmentSelectorView setOpen:YES];
        self.navigationTitleButton.opened = YES;
    }
}

- (void)segmentSelectorViewAction:(ProposalsSegmentedControl *)sender {
    [self.viewModel updateSegmentIndex:sender.selectedIndex];
    [self.segmentSelectorView setOpen:NO];
}

- (void)segmentSelectorViewCancel:(ProposalsSegmentedControl *)sender {
    [self.segmentSelectorView setOpen:NO];
}

- (void)searchSegmentedControlAction:(ProposalsSegmentedControl *)sender {
    [self.viewModel updateSearchSegmentIndex:sender.selectedIndex];
}

- (NSFetchedResultsController *)fetchedResultsControllerForTableView:(UITableView *)tableView {
    return (tableView == self.tableView ? self.viewModel.fetchedResultsController : self.viewModel.searchFetchedResultsController);
}

- (void)performSearch {
    NSString *query = self.searchController.searchBar.text;
    [self.viewModel searchWithQuery:query];
}

- (void)reload {
    if (self.tableView.contentOffset.y == -TOP_VIEW_HEIGHT) {
        self.tableView.contentOffset = CGPointMake(0.0, -(self.tableView.refreshControl.frame.size.height + TOP_VIEW_HEIGHT));
        [self.tableView.refreshControl beginRefreshing];
    }

    weakify;
    [self.viewModel reloadWithCompletion:^(BOOL success) {
        strongify;

        [self.tableView.refreshControl endRefreshing];
    }];
}

#pragma mark ProposalsSegmentSelectorViewDelegate

- (void)proposalsSegmentSelectorViewDidClose:(ProposalsSegmentSelectorView *)view {
    [view removeFromSuperview];
    self.navigationTitleButton.opened = NO;
}

@end

NS_ASSUME_NONNULL_END
