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
#import "ProposalCommentTableViewCellModel.h"

NS_ASSUME_NONNULL_BEGIN

static CGFloat const INREPLYTO_USERNAME_PADDING = 13.0;
static CGFloat const LEADING_PADDING = 24.0;

@interface ProposalCommentTableViewCell ()

@property (strong, nonatomic) IBOutlet UILabel *inRelpyToLabel;
@property (strong, nonatomic) IBOutlet UILabel *usernameLabel;
@property (strong, nonatomic) IBOutlet UILabel *dateLabel;
@property (strong, nonatomic) IBOutlet UILabel *commentLabel;
@property (strong, nonatomic) IBOutlet UIButton *replyButton;

@property (strong, nonatomic) IBOutlet NSLayoutConstraint *inReplyToUsernameVerticalConstraint;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *usernameLeadingConstraint;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *dateLeadingConstraint;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *commentLeadingConstraint;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *replyLeadingConstraint;

@end

@implementation ProposalCommentTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    
    [self.replyButton setTitle:NSLocalizedString(@"Reply", nil) forState:UIControlStateNormal];
}

- (void)configureWithViewModel:(ProposalCommentTableViewCellModel *)viewModel {
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

@end

NS_ASSUME_NONNULL_END
