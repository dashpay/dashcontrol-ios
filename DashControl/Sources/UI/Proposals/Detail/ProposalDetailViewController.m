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

#import "ProposalDetailViewController.h"

#import <SafariServices/SafariServices.h>

#import "DCBudgetProposalEntity+CoreDataClass.h"
#import "UIColor+DCStyle.h"
#import "ProposalCommentsViewController.h"
#import "ProposalDetailCommentsButtonView.h"
#import "ProposalDetailHeaderView.h"
#import "ProposalDetailTableViewCell.h"
#import "ProposalDetailTitleView.h"
#import "ProposalDetailViewModel.h"
#import "ProposalDetailVotesView.h"

static NSString *const PROPOSALDETAIL_CELL_ID = @"ProposalDetailTableViewCell";
static CGFloat const VOTES_VIEW_HEIGHT = 90.0;
static CGFloat const COMMENTS_BUTTON_VIEW_HEIGHT = 135.0;

NS_ASSUME_NONNULL_BEGIN

@interface ProposalDetailViewController () <UITableViewDelegate, UITableViewDataSource, ProposalDetailTableViewCellDelegate, ProposalCommentsViewControllerDelegate>

@property (strong, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) IBOutlet ProposalDetailVotesView *votesView;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *votesViewTopConstraint;
@property (strong, nonatomic) IBOutlet ProposalDetailCommentsButtonView *commentsButtonView;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *commentsButtonViewBottomConstraint;
@property (strong, nonatomic) ProposalDetailHeaderView *headerView;
@property (strong, nonatomic) ProposalDetailTitleView *titleView;
@property (strong, nonatomic) ProposalDetailViewModel *viewModel;
@property (nullable, strong, nonatomic) NSNumber *cellHeight;

@end

@implementation ProposalDetailViewController

+ (instancetype)controllerWithProposal:(DCBudgetProposalEntity *)proposal {
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Proposals" bundle:nil];
    ProposalDetailViewController *viewController = [storyboard instantiateViewControllerWithIdentifier:NSStringFromClass([self class])];
    viewController.viewModel = [[ProposalDetailViewModel alloc] initWithProposal:proposal];
    return viewController;
}

- (void)viewDidLoad {
    [super viewDidLoad];

    self.navigationItem.titleView = self.titleView;

    self.votesView.viewModel = self.viewModel.votesViewModel;

    [self.tableView registerClass:ProposalDetailTableViewCell.class forCellReuseIdentifier:PROPOSALDETAIL_CELL_ID];
    self.tableView.contentInset = UIEdgeInsetsMake(VOTES_VIEW_HEIGHT, 0.0, COMMENTS_BUTTON_VIEW_HEIGHT, 0.0);
    self.tableView.scrollIndicatorInsets = self.tableView.contentInset;
    UIRefreshControl *refreshControl = [[UIRefreshControl alloc] init];
    refreshControl.tintColor = [UIColor dc_barTintColor];
    self.tableView.refreshControl = refreshControl;

    self.commentsButtonView.hidden = YES;
    [self updateCommentsButtonView];

    [self updateHeaderView];

    [self reload];
}

- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
}

#pragma mark Actions

- (IBAction)commentsButtonAction:(id)sender {
    ProposalCommentsViewController *controller = [ProposalCommentsViewController controllerWithProposal:self.viewModel.proposal
                                                                                  detailHeaderViewModel:self.viewModel.headerViewModel];
    controller.delegate = self;
    [self showViewController:controller sender:self];
}

#pragma mark UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    ProposalDetailTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:PROPOSALDETAIL_CELL_ID forIndexPath:indexPath];
    cell.viewModel = self.viewModel.cellViewModel;
    cell.delegate = self;
    return cell;
}

#pragma mark UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (self.cellHeight) {
        return self.cellHeight.doubleValue;
    }
    else {
        return CGRectGetHeight(tableView.bounds);
    }
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    [self.titleView scrollViewDidScroll:scrollView threshold:VOTES_VIEW_HEIGHT];

    CGFloat topOffset = scrollView.contentOffset.y + scrollView.contentInset.top;
    self.votesViewTopConstraint.constant = MIN(-topOffset, 0.0);

    CGFloat bottomOffset = (scrollView.contentSize.height - (CGRectGetHeight(scrollView.frame) + scrollView.contentOffset.y)) + scrollView.contentInset.bottom;
    self.commentsButtonViewBottomConstraint.constant = MIN(-bottomOffset, 0.0);

    if (SYSTEM_VERSION_LESS_THAN(@"11.0")) {
        for (ProposalDetailTableViewCell *cell in self.tableView.visibleCells) {
            if ([cell isKindOfClass:ProposalDetailTableViewCell.class]) {
                [cell performSetNeedLayoutOnWebView];
            }
        }
    }
}

#pragma mark ProposalDetailTableViewCellDelegate

- (void)proposalDetailTableViewCell:(ProposalDetailTableViewCell *)cell didUpdateHeight:(CGFloat)height {
    self.cellHeight = height > 0.0 ? @(height) : nil;
    [UIView setAnimationsEnabled:NO];
    [self.tableView beginUpdates];
    [self.tableView endUpdates];
    [self scrollViewDidScroll:self.tableView];
    self.commentsButtonView.hidden = NO;
    [UIView setAnimationsEnabled:YES];
}

- (void)proposalDetailTableViewCell:(ProposalDetailTableViewCell *)cell openURL:(NSURL *)url {
    SFSafariViewController *safariViewController = [[SFSafariViewController alloc] initWithURL:url];
    safariViewController.preferredBarTintColor = [UIColor dc_barTintColor];
    safariViewController.preferredControlTintColor = [UIColor whiteColor];
    [self showDetailViewController:safariViewController sender:self];
}

#pragma mark ProposalCommentsViewControllerDelegate

- (void)proposalCommentsViewControllerDidAddComment:(ProposalCommentsViewController *)controller {
    [self reload];
}

#pragma mark Private

- (ProposalDetailHeaderView *)headerView {
    if (!_headerView) {
        _headerView = [[ProposalDetailHeaderView alloc] initWithFrame:CGRectZero];
        _headerView.viewModel = self.viewModel.headerViewModel;
    }
    return _headerView;
}

- (ProposalDetailTitleView *)titleView {
    if (!_titleView) {
        _titleView = [[ProposalDetailTitleView alloc] initWithFrame:CGRectZero];
        _titleView.dummyTitle = NSLocalizedString(@"Proposal", nil);
        _titleView.title = self.viewModel.proposal.title;
        [_titleView sizeToFit];
    }
    return _titleView;
}

- (void)reload {
    if (self.tableView.contentOffset.y == 0) {
        self.tableView.contentOffset = CGPointMake(0.0, -self.tableView.refreshControl.frame.size.height);
        [self.tableView.refreshControl beginRefreshing];
    }

    weakify;
    [self.viewModel reloadWithCompletion:^(BOOL success) {
        strongify;

        [self updateHeaderView];
        [self updateCommentsButtonView];
        [self.tableView reloadData];

        [self.tableView.refreshControl endRefreshing];
        if (success) {
            self.tableView.refreshControl = nil;
        }
    }];
}

- (void)updateHeaderView {
    CGSize headerSize = [self.headerView systemLayoutSizeFittingSize:UILayoutFittingCompressedSize];
    self.headerView.frame = CGRectMake(0.0, 0.0, headerSize.width, headerSize.height);
    self.tableView.tableHeaderView = self.headerView;
}

- (void)updateCommentsButtonView {
    self.commentsButtonView.commentsCount = [NSString stringWithFormat:@"%d", self.viewModel.proposal.commentsCount];
}

@end

NS_ASSUME_NONNULL_END
