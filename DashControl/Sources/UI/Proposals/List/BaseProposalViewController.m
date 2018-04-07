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

#import "BaseProposalViewController+Protected.h"

#import "DCBudgetProposalEntity+CoreDataClass.h"
#import "UIColor+DCStyle.h"
#import "ProposalTableViewCell.h"
#import "ProposalTableViewCellModel.h"

NS_ASSUME_NONNULL_BEGIN

NSString *const PROPOSAL_CELL_ID = @"ProposalTableViewCell";

@implementation BaseProposalViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.view.backgroundColor = [UIColor dc_darkBlueColor];

    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView.rowHeight = 104.0;
    [self.tableView registerNib:[UINib nibWithNibName:@"ProposalTableViewCell" bundle:nil] forCellReuseIdentifier:PROPOSAL_CELL_ID];
}

- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
}

- (void)fetchedResultsController:(NSFetchedResultsController<DCBudgetProposalEntity *> *)fetchedResultsController
                   configureCell:(ProposalTableViewCell *)cell
                     atIndexPath:(NSIndexPath *)indexPath {
    DCBudgetProposalEntity *entity = [fetchedResultsController objectAtIndexPath:indexPath];
    ProposalTableViewCellModel *viewModel = [[ProposalTableViewCellModel alloc] initWithProposal:entity];
    [cell configureWithViewModel:viewModel];
}

@end

NS_ASSUME_NONNULL_END
