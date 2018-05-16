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

#import "ProposalCommentTableViewCell.h"

#import "UIColor+DCStyle.h"
#import "UIFont+DCStyle.h"
#import "ProposalCommentAddView.h"
#import "ProposalCommentAddViewModel.h"
#import "ProposalCommentTableViewCellModel.h"

NS_ASSUME_NONNULL_BEGIN

static CGFloat const INREPLYTO_USERNAME_PADDING = 13.0;
static CGFloat const LEADING_PADDING = 24.0;

@interface ProposalCommentTableViewCell () <ProposalCommentAddViewDelegate, ProposalCommentAddViewModelUpdatesObserver>

@property (strong, nonatomic) IBOutlet UILabel *inRelpyToLabel;
@property (strong, nonatomic) IBOutlet UILabel *usernameLabel;
@property (strong, nonatomic) IBOutlet UILabel *dateLabel;
@property (strong, nonatomic) IBOutlet UILabel *commentLabel;
@property (strong, nonatomic) IBOutlet UIButton *replyButton;
@property (strong, nonatomic) IBOutlet ProposalCommentAddView *commentAddView;

@property (strong, nonatomic) IBOutlet NSLayoutConstraint *inReplyToUsernameVerticalConstraint;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *usernameLeadingConstraint;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *dateLeadingConstraint;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *commentLeadingConstraint;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *replyLeadingConstraint;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *commentAddViewHeightConstraint;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *commentAddViewHiddenConstraint;

@end

@implementation ProposalCommentTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];

    self.commentAddView.delegate = self;
}

- (void)setViewModel:(ProposalCommentTableViewCellModel *)viewModel {
    _viewModel = viewModel;

    NSString *proposalOwner = [NSString stringWithFormat:@" (%@)", NSLocalizedString(@"proposal owner", nil)];

    if (viewModel.repliedToUsername) {
        self.inRelpyToLabel.text = [NSString stringWithFormat:@"%@ %@%@",
                                                              NSLocalizedString(@"In reply to", nil),
                                                              viewModel.repliedToUsername,
                                                              viewModel.repliedToIsOwner ? proposalOwner : @""];
        self.inReplyToUsernameVerticalConstraint.constant = INREPLYTO_USERNAME_PADDING;
    }
    else {
        self.inRelpyToLabel.text = nil;
        self.inReplyToUsernameVerticalConstraint.constant = 0.0;
    }

    if (viewModel.postedByOwner) {
        NSAttributedString *usernameAttributed = [[NSAttributedString alloc] initWithString:viewModel.username attributes:@{
            NSForegroundColorAttributeName : [UIColor dc_barTintColor],
            NSFontAttributeName : [UIFont dc_montserratSemiBoldFontOfSize:13.0],
        }];
        NSAttributedString *proposalOwnerAttributed = [[NSAttributedString alloc] initWithString:proposalOwner attributes:@{
            NSForegroundColorAttributeName : [UIColor dc_barTintColor],
            NSFontAttributeName : [UIFont dc_montserratRegularFontOfSize:13.0],
        }];
        NSMutableAttributedString *mutableAttributedString = [[NSMutableAttributedString alloc] init];
        [mutableAttributedString beginEditing];
        [mutableAttributedString appendAttributedString:usernameAttributed];
        [mutableAttributedString appendAttributedString:proposalOwnerAttributed];
        [mutableAttributedString endEditing];
        self.usernameLabel.attributedText = mutableAttributedString;
    }
    else {
        self.usernameLabel.text = viewModel.username;
    }

    self.dateLabel.text = viewModel.date;
    self.commentLabel.text = viewModel.comment;

    NSInteger level = viewModel.shouldIndent ? 2 : 1;
    CGFloat leading = LEADING_PADDING * level;
    self.usernameLeadingConstraint.constant = leading;
    self.dateLeadingConstraint.constant = leading;
    self.commentLeadingConstraint.constant = leading;
    self.replyLeadingConstraint.constant = leading;
}

- (void)layoutSubviews {
    [super layoutSubviews];

    [self.contentView setNeedsLayout];
    [self.contentView layoutIfNeeded];

    self.commentLabel.preferredMaxLayoutWidth = CGRectGetWidth(self.commentLabel.frame);
}

- (void)setCommentAddViewModel:(ProposalCommentAddViewModel *)commentAddViewModel {
    _commentAddViewModel = commentAddViewModel;
    _commentAddViewModel.uiUpdatesObserver = self;

    self.commentAddView.viewModel = commentAddViewModel;
    [self setCommentAddViewVisible:commentAddViewModel.visible];
}

- (IBAction)replyButtonAction:(id)sender {
    if (self.commentAddViewHiddenConstraint.active) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.commentAddView becomeFirstResponder];
        });

        self.commentAddViewModel.visible = YES;

        [self.delegate proposalCommentTableViewCell:self didUpdateHeightShouldScrollToCellAnimated:YES];

        [self setCommentAddViewVisible:self.commentAddViewModel.visible];
    }
    else {
        [self exitAddCommentMode];
    }
}

#pragma mark ProposalCommentAddViewDelegate

- (void)proposalCommentAddViewTextDidChange:(ProposalCommentAddView *)view {
    [self.delegate proposalCommentTableViewCell:self didUpdateHeightShouldScrollToCellAnimated:NO];
}

- (void)proposalCommentAddViewAddButtonAction:(ProposalCommentAddView *)view {
    if ([self.commentAddViewModel isCommentValid]) {
        [self.delegate proposalCommentTableViewCellAddCommentAction:self];
    }
    else {
        [self.commentAddView shakeTextView];
    }
}

#pragma mark ProposalCommentAddViewModelUpdatesObserver

- (void)proposalCommentAddViewModelDidAddComment:(ProposalCommentAddViewModel *)viewModel {
    [self exitAddCommentMode];
}

#pragma mark Private

- (void)setCommentAddViewVisible:(BOOL)visible {
    self.commentAddViewHiddenConstraint.active = !visible;
    self.commentAddViewHeightConstraint.active = visible;

    NSString *buttonTitle = visible ? NSLocalizedString(@"Hide Reply", nil) : NSLocalizedString(@"Reply", nil);
    [self.replyButton setTitle:buttonTitle forState:UIControlStateNormal];
}

- (void)exitAddCommentMode {
    [self.commentAddView resignFirstResponder];

    self.commentAddViewModel.visible = NO;

    [self setCommentAddViewVisible:self.commentAddViewModel.visible];

    [self.delegate proposalCommentTableViewCell:self didUpdateHeightShouldScrollToCellAnimated:YES];
}

@end

NS_ASSUME_NONNULL_END
