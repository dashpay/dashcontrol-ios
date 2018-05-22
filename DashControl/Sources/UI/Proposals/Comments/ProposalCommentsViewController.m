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

#import <UIViewController-KeyboardAdditions/UIViewController+KeyboardAdditions.h>

#import "DCBudgetProposalEntity+CoreDataClass.h"
#import "ProposalCommentAddTableViewCell.h"
#import "ProposalCommentAddViewModel.h"
#import "ProposalCommentTableViewCell.h"
#import "ProposalCommentTableViewCellModel.h"
#import "ProposalCommentsViewModel.h"
#import "ProposalDetailBasicInfoView.h"
#import "ProposalDetailTitleView.h"
#import "QRScannerViewController.h"
#import "TableViewFRCDelegate.h"

NS_ASSUME_NONNULL_BEGIN

NSString *const COMMENT_CELL_ID = @"ProposalCommentTableViewCell";
NSString *const COMMENT_ADD_CELL_ID = @"ProposalCommentAddTableViewCell";

typedef NS_ENUM(NSUInteger, ProposalCommentsSection) {
    ProposalCommentsSection_AddComment = 0,
    ProposalCommentsSection_Comments = 1,
};

@interface ProposalCommentsViewController () <ProposalCommentAddViewParentCellDelegate, QRScannerViewControllerDelegate, ProposalCommentAddViewModelUpdatesObserver>

@property (strong, nonatomic) IBOutlet ProposalDetailBasicInfoView *basicInfoView;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *basicInfoViewTopConstraint;
@property (strong, nonatomic) ProposalDetailTitleView *titleView;

@property (strong, nonatomic) TableViewFRCDelegate *frcDelegate;
@property (strong, nonatomic) ProposalDetailHeaderViewModel *detailHeaderViewModel;
@property (strong, nonatomic) ProposalCommentsViewModel *viewModel;

@property (strong, nonatomic) NSMutableDictionary<NSString *, UITableViewCell *> *heightCalculationCellsByIdentifier;
@property (strong, nonatomic) NSMutableDictionary<NSString *, ProposalCommentAddViewModel *> *commentAddViewModelsByIdentifiers;
@property (strong, nonatomic) ProposalCommentAddViewModel *rootCommentAddViewModel;
@property (nullable, strong, nonatomic) ProposalCommentAddViewModel *commentToSend;

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

    self.commentAddViewModelsByIdentifiers = [NSMutableDictionary dictionary];
    self.heightCalculationCellsByIdentifier = [NSMutableDictionary dictionary];
    self.rootCommentAddViewModel = [[ProposalCommentAddViewModel alloc] initWithProposalHash:self.viewModel.proposal.proposalHash];
    self.rootCommentAddViewModel.visible = YES;

    self.navigationItem.titleView = self.titleView;

    self.view.backgroundColor = [UIColor colorWithRed:243.0 / 255.0 green:243.0 / 255.0 blue:243.0 / 255.0 alpha:1.0];

    self.tableView.backgroundColor = self.view.backgroundColor;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
    self.tableView.separatorInset = UIEdgeInsetsMake(0.0, 24.0, 0.0, 24.0);
    self.tableView.separatorColor = [UIColor colorWithRed:106.0 / 255.0 green:120.0 / 255.0 blue:141.0 / 255.0 alpha:1.0];
    self.tableView.estimatedRowHeight = UITableViewAutomaticDimension;
    self.tableView.allowsSelection = NO;
    self.tableView.keyboardDismissMode = UIScrollViewKeyboardDismissModeOnDrag;
    NSArray<NSString *> *cellIds = @[ COMMENT_CELL_ID, COMMENT_ADD_CELL_ID ];
    for (NSString *cellId in cellIds) {
        UINib *nib = [UINib nibWithNibName:cellId bundle:nil];
        NSParameterAssert(nib);
        [self.tableView registerNib:nib forCellReuseIdentifier:cellId];
    }

    self.basicInfoView.viewModel = self.detailHeaderViewModel;
    CGSize size = [self.basicInfoView systemLayoutSizeFittingSize:UILayoutFittingCompressedSize];
    self.tableView.contentInset = UIEdgeInsetsMake(size.height, 0.0, 0.0, 0.0);
    self.tableView.scrollIndicatorInsets = self.tableView.contentInset;

    // KVO

    [self mvvm_observe:@"viewModel.fetchedResultsController" with:^(typeof(self) self, id value) {
        self.viewModel.fetchedResultsController.delegate = self.frcDelegate;
        [self.tableView reloadData];
    }];
}

- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];

    [self ka_startObservingKeyboardNotifications];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];

    [self ka_stopObservingKeyboardNotifications];
}

#pragma mark UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == ProposalCommentsSection_AddComment) {
        return 1;
    }
    else {
        NSFetchedResultsController *frc = [self fetchedResultsControllerForTableView:tableView];
        id<NSFetchedResultsSectionInfo> sectionInfo = frc.sections.firstObject;
        NSUInteger numberOfObjects = sectionInfo.numberOfObjects;
        return numberOfObjects;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    switch (indexPath.section) {
        case ProposalCommentsSection_AddComment: {
            ProposalCommentAddTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:COMMENT_ADD_CELL_ID forIndexPath:indexPath];
            [self configureCommentAddCell:cell atIndexPath:indexPath];
            return cell;
        }
        case ProposalCommentsSection_Comments: {
            ProposalCommentTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:COMMENT_CELL_ID forIndexPath:indexPath];
            [self configureCommentCell:cell atIndexPath:indexPath];
            return cell;
        }
        default: {
            NSAssert(NO, @"Inconsistent data source");
            return [UITableViewCell new];
        }
    }
}

#pragma mark UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *cellId = nil;
    switch (indexPath.section) {
        case ProposalCommentsSection_AddComment:
            cellId = COMMENT_ADD_CELL_ID;
            break;
        case ProposalCommentsSection_Comments:
            cellId = COMMENT_CELL_ID;
            break;
    }

    UITableViewCell *cell = self.heightCalculationCellsByIdentifier[cellId];
    if (!cell) {
        cell = [[NSBundle mainBundle] loadNibNamed:cellId owner:nil options:nil].firstObject;
        self.heightCalculationCellsByIdentifier[cellId] = cell;
    }

    ProposalCommentAddViewModel *commentAddViewModel = nil;
    switch (indexPath.section) {
        case ProposalCommentsSection_AddComment: {
            commentAddViewModel = self.rootCommentAddViewModel;

            [self configureCommentAddCell:(ProposalCommentAddTableViewCell *)cell atIndexPath:indexPath];

            break;
        }
        case ProposalCommentsSection_Comments: {
            DCBudgetProposalCommentEntity *entity = [self commentAtIndexPath:indexPath];
            commentAddViewModel = [self commentAddViewModelForEntity:entity];

            [self configureCommentCell:(ProposalCommentTableViewCell *)cell atIndexPath:indexPath];

            break;
        }
    }
    id<ProposalCommentAddViewModelUpdatesObserver> originalUpdatesObserver = commentAddViewModel.uiUpdatesObserver;

    [cell setNeedsUpdateConstraints];
    [cell updateConstraintsIfNeeded];
    cell.bounds = CGRectMake(0.0, 0.0, CGRectGetWidth(tableView.bounds), CGRectGetHeight(cell.bounds));
    [cell setNeedsLayout];
    [cell layoutIfNeeded];

    CGFloat height = [cell.contentView systemLayoutSizeFittingSize:UILayoutFittingCompressedSize].height;
    height += 1.0; // an extra point to the height to account for the cell separator

    commentAddViewModel.uiUpdatesObserver = originalUpdatesObserver;

    return ceil(height);
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    [self.titleView scrollViewDidScroll:scrollView threshold:0.0];

    CGFloat topOffset = scrollView.contentOffset.y + scrollView.contentInset.top;
    self.basicInfoViewTopConstraint.constant = MIN(-topOffset, 0.0);
}

#pragma mark ProposalCommentAddViewParentCellDelegate

- (void)proposalCommentAddViewParentCell:(ProposalCommentTableViewCell *)cell didUpdateHeightShouldScrollToCellAnimated:(BOOL)shouldScrollToCellAnimated {
    [UIView setAnimationsEnabled:NO];
    [self.tableView beginUpdates];
    [self.tableView endUpdates];
    [UIView setAnimationsEnabled:YES];

    NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
    if (!indexPath) {
        return;
    }

    dispatch_async(dispatch_get_main_queue(), ^{
        [self.tableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionBottom animated:shouldScrollToCellAnimated];
    });
}

- (void)proposalCommentAddViewParentCellAddCommentAction:(ProposalCommentTableViewCell *)cell {
    if (self.viewModel.authorized) {
        [cell.commentAddViewModel send];
    }
    else {
        self.commentToSend = cell.commentAddViewModel;
        [self showAuthorization];
    }
}

#pragma mark ProposalCommentAddViewModelUpdatesObserver

- (void)proposalCommentAddViewModelDidAddComment:(ProposalCommentAddViewModel *)viewModel {
    [self.delegate proposalCommentsViewControllerDidAddComment:self];
}

#pragma mark Keyboard

- (void)ka_keyboardShowOrHideAnimationWithHeight:(CGFloat)height
                               animationDuration:(NSTimeInterval)animationDuration
                                  animationCurve:(UIViewAnimationCurve)animationCurve {
    UIEdgeInsets contentInset = self.tableView.contentInset;
    contentInset.bottom = height;
    self.tableView.contentInset = contentInset;
}

#pragma mark QRScannerViewControllerDelegate

- (void)qrScannerViewControllerDidCancel:(QRScannerViewController *)controller {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)qrScannerViewController:(QRScannerViewController *)controller didScanString:(NSString *)scannedString {
    [self.viewModel authorizeWithUserAPIKey:scannedString];
    [self dismissViewControllerAnimated:YES completion:nil];

    if (self.commentToSend) {
        [self.commentToSend send];
        self.commentToSend = nil;
    }
}

#pragma mark Private

- (DCBudgetProposalCommentEntity *)commentAtIndexPath:(NSIndexPath *)indexPath {
    NSFetchedResultsController *frc = self.viewModel.fetchedResultsController;
    id<NSFetchedResultsSectionInfo> sectionInfo = frc.sections.firstObject;
    NSArray *objects = sectionInfo.objects;
    DCBudgetProposalCommentEntity *entity = objects[indexPath.row];
    return entity;
}

- (void)configureCommentCell:(ProposalCommentTableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath {
    DCBudgetProposalCommentEntity *entity = [self commentAtIndexPath:indexPath];
    DCBudgetProposalCommentEntity *parent = nil;
    BOOL hasParent = (entity.level > 0);
    NSInteger parentRow = indexPath.row - 1;
    if (hasParent && parentRow >= 0) {
        NSIndexPath *parentIndexPath = [NSIndexPath indexPathForRow:parentRow inSection:indexPath.section];
        parent = [self commentAtIndexPath:parentIndexPath];
    }
    ProposalCommentTableViewCellModel *viewModel = [[ProposalCommentTableViewCellModel alloc] initWithCommentEntity:entity parent:parent];
    ProposalCommentAddViewModel *commentAddViewModel = [self commentAddViewModelForEntity:entity];
    cell.viewModel = viewModel;
    cell.commentAddViewModel = commentAddViewModel;
    cell.delegate = self;
}

- (void)configureCommentAddCell:(ProposalCommentAddTableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath {
    cell.commentAddViewModel = self.rootCommentAddViewModel;
    cell.delegate = self;
}

- (TableViewFRCDelegate *)frcDelegate {
    if (!_frcDelegate) {
        _frcDelegate = [[TableViewFRCDelegate alloc] init];
        _frcDelegate.tableView = self.tableView;
        weakify;
        _frcDelegate.configureCellBlock = ^(NSFetchedResultsController *_Nonnull fetchedResultsController, UITableViewCell *_Nonnull cell, NSIndexPath *_Nonnull indexPath) {
            strongify;
            [self configureCommentCell:(ProposalCommentTableViewCell *)cell atIndexPath:indexPath];
        };
        _frcDelegate.transformationBlock = ^NSIndexPath *_Nonnull(NSIndexPath *_Nonnull indexPath) {
            return [NSIndexPath indexPathForRow:indexPath.row inSection:1];
        };
    }
    return _frcDelegate;
}

- (void)showAuthorization {
    QRScannerViewController *controller = [[QRScannerViewController alloc] initAsDashCentralAuth];
    controller.delegate = self;
    [self presentViewController:controller animated:YES completion:nil];
}

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

- (ProposalCommentAddViewModel *)commentAddViewModelForEntity:(DCBudgetProposalCommentEntity *)entity {
    NSString *identifier = entity.identifier;
    NSParameterAssert(identifier);
    if (!identifier) {
        return nil;
    }
    ProposalCommentAddViewModel *commentAddViewModel = self.commentAddViewModelsByIdentifiers[identifier];
    if (!commentAddViewModel) {
        commentAddViewModel = [[ProposalCommentAddViewModel alloc] initWithProposalHash:self.viewModel.proposal.proposalHash
                                                                       replyToCommentId:identifier];
        commentAddViewModel.mainUpdatesObserver = self;
        self.commentAddViewModelsByIdentifiers[identifier] = commentAddViewModel;
    }
    return commentAddViewModel;
}

@end

NS_ASSUME_NONNULL_END
