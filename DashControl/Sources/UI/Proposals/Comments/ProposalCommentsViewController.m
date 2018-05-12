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

#import "ProposalCommentsViewController.h"

#import "DCBudgetProposalEntity+CoreDataClass.h"
#import "ProposalCommentTableViewCell.h"
#import "ProposalCommentTableViewCellModel.h"
#import "ProposalCommentsViewModel.h"
#import "ProposalDetailBasicInfoView.h"
#import "ProposalDetailTitleView.h"

NS_ASSUME_NONNULL_BEGIN

NSString *const COMMENT_CELL_ID = @"ProposalCommentTableViewCell";

@interface ProposalCommentsViewController ()

@property (strong, nonatomic) IBOutlet ProposalDetailBasicInfoView *basicInfoView;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *basicInfoViewTopConstraint;
@property (strong, nonatomic) ProposalDetailTitleView *titleView;

@property (strong, nonatomic) ProposalDetailHeaderViewModel *detailHeaderViewModel;
@property (strong, nonatomic) ProposalCommentsViewModel *viewModel;

@end

@implementation ProposalCommentsViewController

+ (instancetype)controllerWithProposal:(DCBudgetProposalEntity *)proposal
                 detailHeaderViewModel:(ProposalDetailHeaderViewModel *)detailHeaderViewModel {
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Proposals" bundle:nil];
    ProposalCommentsViewController *viewController = [storyboard instantiateViewControllerWithIdentifier:NSStringFromClass([self class])];
    viewController.detailHeaderViewModel = detailHeaderViewModel;
    viewController.viewModel = [[ProposalCommentsViewModel alloc] initWithProposal:proposal];
    return viewController;
}

- (void)viewDidLoad {
    [super viewDidLoad];

    self.navigationItem.titleView = self.titleView;

    self.view.backgroundColor = [UIColor colorWithRed:243.0 / 255.0 green:243.0 / 255.0 blue:243.0 / 255.0 alpha:1.0];

    self.tableView.backgroundColor = self.view.backgroundColor;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
    self.tableView.separatorInset = UIEdgeInsetsMake(0.0, 24.0, 0.0, 24.0);
    self.tableView.separatorColor = [UIColor colorWithRed:106.0 / 255.0 green:120.0 / 255.0 blue:141.0 / 255.0 alpha:1.0];
    self.tableView.rowHeight = UITableViewAutomaticDimension;
    self.tableView.estimatedRowHeight = 158.0;
    self.tableView.allowsSelection = NO;
    [self.tableView registerNib:[UINib nibWithNibName:COMMENT_CELL_ID bundle:nil] forCellReuseIdentifier:COMMENT_CELL_ID];

    self.basicInfoView.viewModel = self.detailHeaderViewModel;
    CGSize size = [self.basicInfoView systemLayoutSizeFittingSize:UILayoutFittingCompressedSize];
    self.tableView.contentInset = UIEdgeInsetsMake(size.height, 0.0, 0.0, 0.0);
    self.tableView.scrollIndicatorInsets = self.tableView.contentInset;
}

- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
}

- (void)fetchedResultsController:(NSFetchedResultsController<DCBudgetProposalCommentEntity *> *)fetchedResultsController
                   configureCell:(ProposalCommentTableViewCell *)cell
                     atIndexPath:(NSIndexPath *)indexPath {
    DCBudgetProposalCommentEntity *entity = [fetchedResultsController objectAtIndexPath:indexPath];
    DCBudgetProposalCommentEntity *parent = nil;
    BOOL hasParent = (entity.level > 0);
    NSInteger parentRow = indexPath.row - 1;
    if (hasParent && parentRow >= 0) {
        NSIndexPath *parentIndexPath = [NSIndexPath indexPathForRow:parentRow inSection:indexPath.section];
        parent = [fetchedResultsController objectAtIndexPath:parentIndexPath];
    }
    ProposalCommentTableViewCellModel *viewModel = [[ProposalCommentTableViewCellModel alloc] initWithCommentEntity:entity parent:parent];
    [cell configureWithViewModel:viewModel];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSFetchedResultsController *frc = [self fetchedResultsControllerForTableView:tableView];
    id<NSFetchedResultsSectionInfo> sectionInfo = frc.sections.firstObject;
    NSUInteger numberOfObjects = sectionInfo.numberOfObjects;
    return numberOfObjects;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    ProposalCommentTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:COMMENT_CELL_ID forIndexPath:indexPath];
    NSFetchedResultsController *frc = [self fetchedResultsControllerForTableView:tableView];
    [self fetchedResultsController:frc configureCell:cell atIndexPath:indexPath];
    return cell;
}

#pragma mark UITableViewDelegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    [self.titleView scrollViewDidScroll:scrollView threshold:0.0];

    CGFloat topOffset = scrollView.contentOffset.y + scrollView.contentInset.top;
    self.basicInfoViewTopConstraint.constant = MIN(-topOffset, 0.0);
}

#pragma mark Private

- (ProposalDetailTitleView *)titleView {
    if (!_titleView) {
        _titleView = [[ProposalDetailTitleView alloc] initWithFrame:CGRectZero];
        _titleView.dummyTitle = NSLocalizedString(@"Discussion", nil);
        _titleView.title = self.viewModel.proposal.title;
        [_titleView sizeToFit];
    }
    return _titleView;
}

- (NSFetchedResultsController *)fetchedResultsControllerForTableView:(UITableView *)tableView {
    return self.viewModel.fetchedResultsController;
}

@end

NS_ASSUME_NONNULL_END
