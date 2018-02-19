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

#import "BaseNewsTableViewController+Protected.h"

#import "DCNewsPostEntity+CoreDataClass.h"
#import "NewsTableViewCell.h"
#import "UIColor+DCStyle.h"

NS_ASSUME_NONNULL_BEGIN

NSString *const NEWS_CELL_ID = @"NewsTableViewCell";

@implementation BaseNewsTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.view.backgroundColor = [UIColor dc_darkBlueColor];
    
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.tableView registerNib:[UINib nibWithNibName:@"NewsTableViewCell" bundle:nil] forCellReuseIdentifier:NEWS_CELL_ID];
}

- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
}

- (void)fetchedResultsController:(NSFetchedResultsController<DCNewsPostEntity *> *)fetchedResultsController
                   configureCell:(NewsTableViewCell *)cell
                     atIndexPath:(NSIndexPath *)indexPath {
    DCNewsPostEntity *entity = [fetchedResultsController objectAtIndexPath:indexPath];
    [cell configureWithTitle:entity.title
                  dateString:[self.dateFormatter stringFromDate:entity.date]
                    imageURL:[NSURL URLWithString:entity.imageURL]];
}

- (NSDateFormatter *)dateFormatter {
    if (!_dateFormatter) {
        _dateFormatter = [[NSDateFormatter alloc] init];
        _dateFormatter.dateStyle = NSDateFormatterMediumStyle;
    }
    return _dateFormatter;
}

- (NSMutableArray<NSIndexPath *> *)deletedRowIndexPaths {
    if (!_deletedRowIndexPaths) {
        _deletedRowIndexPaths = [NSMutableArray array];
    }
    return _deletedRowIndexPaths;
}

- (NSMutableArray<NSIndexPath *> *)insertedRowIndexPaths {
    if (!_insertedRowIndexPaths) {
        _insertedRowIndexPaths = [NSMutableArray array];
    }
    return _insertedRowIndexPaths;
}

- (NSMutableArray<NSIndexPath *> *)updatedRowIndexPaths {
    if (!_updatedRowIndexPaths) {
        _updatedRowIndexPaths = [NSMutableArray array];
    }
    return _updatedRowIndexPaths;
}

#pragma mark UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSAssert(NO, @"Should be done in successor");
    
    return [[UITableViewCell alloc] init];
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
    [self.tableView beginUpdates];
    [self.tableView deleteRowsAtIndexPaths:self.deletedRowIndexPaths withRowAnimation:UITableViewRowAnimationFade];
    [self.tableView insertRowsAtIndexPaths:self.insertedRowIndexPaths withRowAnimation:UITableViewRowAnimationFade];
    [self.tableView reloadRowsAtIndexPaths:self.updatedRowIndexPaths withRowAnimation:UITableViewRowAnimationFade];
    [self.tableView endUpdates];
    
    [self.deletedRowIndexPaths removeAllObjects];
    [self.insertedRowIndexPaths removeAllObjects];
    [self.updatedRowIndexPaths removeAllObjects];
}

@end

NS_ASSUME_NONNULL_END
