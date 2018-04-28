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
#import "UIColor+DCStyle.h"
#import "NewsTableViewCell.h"

NS_ASSUME_NONNULL_BEGIN

NSString *const NEWS_CELL_ID = @"NewsTableViewCell";

@implementation BaseNewsTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.view.backgroundColor = [UIColor dc_darkBlueColor];

    self.tableView.backgroundColor = self.view.backgroundColor;
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

@end

NS_ASSUME_NONNULL_END
