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

#import "NewsView.h"

#import "NewsLoadMoreTableViewCell.h"
#import "NewsTableViewCell.h"
#import "NewsViewModel.h"

NS_ASSUME_NONNULL_BEGIN

#define KEY_VIEWMODEL_STATE @"viewModel.state"

static NSString *const NEWS_CELL_ID = @"NewsTableViewCell";
static NSString *const NEWS_LOADMORE_CELL_ID = @"NewsLoadMoreTableViewCell";

@interface NewsView () <UITableViewDelegate, UITableViewDataSource>

@property (weak, nullable, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) NSMutableArray<NSIndexPath *> *deletedRowIndexPaths;
@property (strong, nonatomic) NSMutableArray<NSIndexPath *> *insertedRowIndexPaths;
@property (strong, nonatomic) NSMutableArray<NSIndexPath *> *updatedRowIndexPaths;

@property (strong, nonatomic) NSDateFormatter *dateFormatter;
@property (assign, nonatomic) BOOL showingLoadMoreCell;

@end

@implementation NewsView

- (void)awakeFromNib {
    [super awakeFromNib];

    UIRefreshControl *refreshControl = [[UIRefreshControl alloc] init];
    refreshControl.tintColor = [UIColor whiteColor];
    [refreshControl addTarget:self action:@selector(refreshControlAction) forControlEvents:UIControlEventValueChanged];
    self.tableView.refreshControl = refreshControl;

    self.deletedRowIndexPaths = [[NSMutableArray alloc] init];
    self.insertedRowIndexPaths = [[NSMutableArray alloc] init];
    self.updatedRowIndexPaths = [[NSMutableArray alloc] init];

    self.dateFormatter = [[NSDateFormatter alloc] init];
    self.dateFormatter.dateStyle = NSDateFormatterMediumStyle;
    
    [self mvvm_observe:KEY_VIEWMODEL_STATE with:^(typeof(self) self, NSNumber *value){
        switch (self.viewModel.state) {
            case NewsViewModelState_None: {
                break;
            }
            case NewsViewModelState_Loading: {
                if (self.tableView.contentOffset.y == 0) {
                    self.tableView.contentOffset = CGPointMake(0.0, -self.tableView.refreshControl.frame.size.height);
                    [self.tableView.refreshControl beginRefreshing];
                }
                break;
            }
            case NewsViewModelState_Failed: {
                [self.tableView.refreshControl endRefreshing];
                break;
            }
            case NewsViewModelState_Success: {
                [self.tableView.refreshControl endRefreshing];
                break;
            }
        }
    }];
}

#pragma mark UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSUInteger numberOfObjects = [self numberOfObjects];
    self.showingLoadMoreCell = self.viewModel.canLoadMore && (numberOfObjects > 0);

    return (self.showingLoadMoreCell ? numberOfObjects + 1 : numberOfObjects);
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if ([self isLoadMoreIndexPath:indexPath]) {
        NewsLoadMoreTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:NEWS_LOADMORE_CELL_ID forIndexPath:indexPath];
        return cell;
    }
    else {
        NewsTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:NEWS_CELL_ID forIndexPath:indexPath];
        [self configureCell:cell atIndexPath:indexPath];
        return cell;
    }
}

#pragma mark UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    if ([self isLoadMoreIndexPath:indexPath]) {
        NewsLoadMoreTableViewCell *loadMoreCell = (NewsLoadMoreTableViewCell *)cell;
        [loadMoreCell willDisplay];

        [self.viewModel loadNextPage];
    }
}

- (void)tableView:(UITableView *)tableView didEndDisplayingCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    if ([self isLoadMoreIndexPath:indexPath]) {
        NewsLoadMoreTableViewCell *loadMoreCell = (NewsLoadMoreTableViewCell *)cell;
        [loadMoreCell didEndDisplaying];
    }
}

#pragma mark NSFetchedResultsControllerDelegate

- (void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject atIndexPath:(nullable NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type newIndexPath:(nullable NSIndexPath *)newIndexPath {
    switch (type) {
        case NSFetchedResultsChangeInsert: {
            [self.insertedRowIndexPaths addObject:newIndexPath];
            break;
        }
        case NSFetchedResultsChangeDelete: {
            [self.deletedRowIndexPaths addObject:indexPath];
            break;
        }
        case NSFetchedResultsChangeUpdate: {
            [self.updatedRowIndexPaths addObject:indexPath];
            break;
        }
        case NSFetchedResultsChangeMove: {
            [self.insertedRowIndexPaths addObject:newIndexPath];
            [self.deletedRowIndexPaths addObject:indexPath];
            break;
        }
    }
}

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller {
    NSUInteger numberOfObjects = [self numberOfObjects];
    if (numberOfObjects > 0) {
        if (!self.showingLoadMoreCell) {
            [self.insertedRowIndexPaths addObject:[NSIndexPath indexPathForRow:numberOfObjects inSection:0]];
        }
        else if (!self.viewModel.canLoadMore) {
            [self.deletedRowIndexPaths addObject:[NSIndexPath indexPathForRow:numberOfObjects inSection:0]];
        }
    }

    [self.tableView beginUpdates];
    [self.tableView deleteRowsAtIndexPaths:self.deletedRowIndexPaths withRowAnimation:UITableViewRowAnimationFade];
    [self.tableView insertRowsAtIndexPaths:self.insertedRowIndexPaths withRowAnimation:UITableViewRowAnimationFade];
    [self.tableView reloadRowsAtIndexPaths:self.updatedRowIndexPaths withRowAnimation:UITableViewRowAnimationFade];
    [self.tableView endUpdates];

    [self.deletedRowIndexPaths removeAllObjects];
    [self.insertedRowIndexPaths removeAllObjects];
    [self.updatedRowIndexPaths removeAllObjects];
}

#pragma mark Actions

- (void)refreshControlAction {
    [self.viewModel reload];
}

#pragma mark Private

- (void)configureCell:(NewsTableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath {
    DCNewsPostEntity *entity = [self.viewModel.fetchedResultsController objectAtIndexPath:indexPath];

    [cell configureWithTitle:entity.title
                  dateString:[self.dateFormatter stringFromDate:entity.date]
                    imageURL:[NSURL URLWithString:entity.imageURL]];
}

- (BOOL)isLoadMoreIndexPath:(NSIndexPath *)indexPath {
    if (!self.showingLoadMoreCell) {
        return NO;
    }

    return (indexPath.row == [self numberOfObjects]);
}

- (NSUInteger)numberOfObjects {
    id<NSFetchedResultsSectionInfo> sectionInfo = self.viewModel.fetchedResultsController.sections.firstObject;
    NSInteger numberOfObjects = sectionInfo.numberOfObjects;
    return numberOfObjects;
}

@end

NS_ASSUME_NONNULL_END
