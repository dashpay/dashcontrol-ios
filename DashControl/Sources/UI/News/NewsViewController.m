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

#import "NewsViewController.h"

#import <SafariServices/SafariServices.h>

#import "BaseNewsTableViewController+Protected.h"
#import "UIColor+DCStyle.h"
#import "DCSearchController.h"
#import "NewsLoadMoreTableViewCell.h"
#import "NewsSearchResultsController.h"
#import "NewsTableViewCell.h"
#import "NewsViewModel.h"

NS_ASSUME_NONNULL_BEGIN

static NSString *const NEWS_FIRST_CELL_ID = @"NewsFirstTableViewCell";
static NSString *const NEWS_LOADMORE_CELL_ID = @"NewsLoadMoreTableViewCell";

@interface NewsViewController () <DCSearchControllerDelegate, DCSearchResultsUpdating>

@property (strong, nonatomic) NewsViewModel *viewModel;

@property (strong, nonatomic) DCSearchController *searchController;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *searchBarButtonItem;

@property (assign, nonatomic) BOOL showingLoadMoreCell;

@end

@implementation NewsViewController

- (void)awakeFromNib {
    [super awakeFromNib];

    self.title = NSLocalizedString(@"News", nil);
    self.tabBarItem.title = self.title;
}

- (void)viewDidLoad {
    [super viewDidLoad];

    [self reload];

    NewsSearchResultsController *searchResultsController = [[NewsSearchResultsController alloc] init];
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
        NewsSearchResultsController *searchResultsController = (NewsSearchResultsController *)self.searchController.searchResultsController;
        [searchResultsController.tableView reloadData];
        self.viewModel.searchFetchedResultsController.delegate = searchResultsController;
    }];
}

- (NewsViewModel *)viewModel {
    if (!_viewModel) {
        _viewModel = [[NewsViewModel alloc] init];
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

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSFetchedResultsController *frc = [self fetchedResultsControllerForTableView:tableView];
    id<NSFetchedResultsSectionInfo> sectionInfo = frc.sections.firstObject;
    NSUInteger numberOfObjects = sectionInfo.numberOfObjects;

    if (section == 0) {
        return numberOfObjects;
    }
    else {
        if (tableView == self.tableView) {
            self.showingLoadMoreCell = self.viewModel.canLoadMore && (numberOfObjects > 0);
            return (self.showingLoadMoreCell ? 1 : 0);
        }
        else {
            return 0;
        }
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell * (^newsCellForIdentifier)(NSString *identifier) = ^UITableViewCell *(NSString *identifier) {
        NewsTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier forIndexPath:indexPath];
        NSFetchedResultsController *frc = [self fetchedResultsControllerForTableView:tableView];
        [self fetchedResultsController:frc configureCell:cell atIndexPath:indexPath];
        return cell;
    };

    if (tableView == self.tableView) {
        if ([self isLoadMoreIndexPath:indexPath]) {
            NewsLoadMoreTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:NEWS_LOADMORE_CELL_ID forIndexPath:indexPath];
            return cell;
        }
        else {
            NSString *identifier = (indexPath.row == 0 ? NEWS_FIRST_CELL_ID : NEWS_CELL_ID);
            return newsCellForIdentifier(identifier);
        }
    }
    else {
        return newsCellForIdentifier(NEWS_CELL_ID);
    }
}

#pragma mark UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    CGFloat const defaultHeight = 104.0;
    if (tableView == self.tableView) {
        if ([self isLoadMoreIndexPath:indexPath]) {
            return defaultHeight;
        }
        else {
            return (indexPath.row == 0 ? 198.0 : defaultHeight);
        }
    }
    else {
        return defaultHeight;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];

    if (tableView == self.tableView && [self isLoadMoreIndexPath:indexPath]) {
        return;
    }

    NSFetchedResultsController *frc = [self fetchedResultsControllerForTableView:tableView];
    DCNewsPostEntity *entity = [frc objectAtIndexPath:indexPath];
    NSURL *url = [NSURL URLWithString:entity.url];
    if (!url) {
        return;
    }
    SFSafariViewController *safariViewController = [[SFSafariViewController alloc] initWithURL:url];
    safariViewController.preferredBarTintColor = [UIColor dc_barTintColor];
    safariViewController.preferredControlTintColor = [UIColor whiteColor];
    [self showDetailViewController:safariViewController sender:self];
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (tableView != self.tableView) {
        return;
    }

    if ([self isLoadMoreIndexPath:indexPath] && [cell isKindOfClass:[NewsLoadMoreTableViewCell class]]) {
        NewsLoadMoreTableViewCell *loadMoreCell = (NewsLoadMoreTableViewCell *)cell;
        [loadMoreCell willDisplay];

        [self.viewModel loadNextPage];
    }
}

- (void)tableView:(UITableView *)tableView didEndDisplayingCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (tableView != self.tableView) {
        return;
    }

    if ([self isLoadMoreIndexPath:indexPath] && [cell isKindOfClass:[NewsLoadMoreTableViewCell class]]) {
        NewsLoadMoreTableViewCell *loadMoreCell = (NewsLoadMoreTableViewCell *)cell;
        [loadMoreCell didEndDisplaying];
    }
}

#pragma mark NSFetchedResultsControllerDelegate

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller {
    NSUInteger numberOfObjects = [self numberOfObjectsInMainFetchedResultsController];
    if (numberOfObjects > 0) {
        if (!self.showingLoadMoreCell) {
            [self.tableView insertRowsAtIndexPaths:@[ [NSIndexPath indexPathForRow:0 inSection:1] ] withRowAnimation:UITableViewRowAnimationFade];
        }
        else if (!self.viewModel.canLoadMore) {
            [self.tableView deleteRowsAtIndexPaths:@[ [NSIndexPath indexPathForRow:0 inSection:1] ] withRowAnimation:UITableViewRowAnimationFade];
        }
    }

    [super controllerDidChangeContent:controller];
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
    [self.viewModel searchWithQuery:query];
}

- (BOOL)isLoadMoreIndexPath:(NSIndexPath *)indexPath {
    if (!self.showingLoadMoreCell) {
        return NO;
    }

    return (indexPath.section == 1);
}

- (NSUInteger)numberOfObjectsInMainFetchedResultsController {
    NSFetchedResultsController *frc = self.viewModel.fetchedResultsController;
    id<NSFetchedResultsSectionInfo> sectionInfo = frc.sections.firstObject;
    NSUInteger numberOfObjects = sectionInfo.numberOfObjects;
    return numberOfObjects;
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
