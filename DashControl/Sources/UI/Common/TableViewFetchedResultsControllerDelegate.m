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

#import "TableViewFetchedResultsControllerDelegate.h"

NS_ASSUME_NONNULL_BEGIN

@implementation TableViewFetchedResultsControllerDelegate

- (void)fetchedResultsController:(NSFetchedResultsController *)fetchedResultsController
                   configureCell:(UITableViewCell *)cell
                     atIndexPath:(NSIndexPath *)indexPath {
    NSParameterAssert(self.configureCellBlock);
    if (self.configureCellBlock) {
        self.configureCellBlock(fetchedResultsController, cell, indexPath);
    }
}

#pragma mark NSFetchedResultsControllerDelegate

- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller {
    NSParameterAssert(self.tableView);
    [self.tableView beginUpdates];
}

- (void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject atIndexPath:(nullable NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type newIndexPath:(nullable NSIndexPath *)newIndexPath {
    UITableView *tableView = self.tableView;

    switch (type) {
        case NSFetchedResultsChangeInsert: {
            NSIndexPath *resultNewIndexPath = self.transformationBlock ? self.transformationBlock(newIndexPath) : newIndexPath;
            [tableView insertRowsAtIndexPaths:@[ resultNewIndexPath ] withRowAnimation:UITableViewRowAnimationFade];
            break;
        }
        case NSFetchedResultsChangeDelete: {
            NSIndexPath *resultIndexPath = self.transformationBlock ? self.transformationBlock(indexPath) : indexPath;
            [tableView deleteRowsAtIndexPaths:@[ resultIndexPath ] withRowAnimation:UITableViewRowAnimationFade];
            break;
        }
        case NSFetchedResultsChangeMove: {
            NSIndexPath *resultIndexPath = self.transformationBlock ? self.transformationBlock(indexPath) : indexPath;
            NSIndexPath *resultNewIndexPath = self.transformationBlock ? self.transformationBlock(newIndexPath) : newIndexPath;
            [tableView deleteRowsAtIndexPaths:@[ resultIndexPath ] withRowAnimation:UITableViewRowAnimationFade];
            [tableView insertRowsAtIndexPaths:@[ resultNewIndexPath ] withRowAnimation:UITableViewRowAnimationFade];
            break;
        }
        case NSFetchedResultsChangeUpdate: {
            [self fetchedResultsController:controller
                             configureCell:[tableView cellForRowAtIndexPath:indexPath]
                               atIndexPath:indexPath];
            break;
        }
    }
}

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller {
    [self.tableView endUpdates];
}

@end

NS_ASSUME_NONNULL_END
