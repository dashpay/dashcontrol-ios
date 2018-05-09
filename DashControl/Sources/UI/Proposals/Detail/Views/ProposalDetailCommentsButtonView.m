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

#import "ProposalDetailCommentsButtonView.h"

NS_ASSUME_NONNULL_BEGIN

#pragma mark - Footer Button

@interface ProposalDetailCommentsButton : UIControl

@property (strong, nonatomic) IBOutlet UILabel *titleLabel;
@property (strong, nonatomic) IBOutlet UIImageView *disclosureImageView;

@end

@implementation ProposalDetailCommentsButton

- (void)awakeFromNib {
    [super awakeFromNib];

    self.titleLabel.text = NSLocalizedString(@"Submit your comments and exchange your ideas on this proposal", nil);
}

- (void)setHighlighted:(BOOL)highlighted {
    [super setHighlighted:highlighted];

    [UIView animateWithDuration:0.25 animations:^{
        CGFloat alpha = highlighted ? 0.65 : 1.0;
        self.titleLabel.alpha = alpha;
        self.disclosureImageView.alpha = alpha;
    }];
}

@end

#pragma mark - Footer

@interface ProposalDetailCommentsButtonView ()

@property (strong, nonatomic) IBOutlet UILabel *joinDiscussionLabel;
@property (strong, nonatomic) IBOutlet UILabel *commentsCountLabel;

@end

@implementation ProposalDetailCommentsButtonView

- (void)awakeFromNib {
    [super awakeFromNib];

    self.joinDiscussionLabel.text = NSLocalizedString(@"Join the discussion!", nil);
}

- (void)setCommentsCount:(nullable NSString *)commentsCount {
    self.commentsCountLabel.text = commentsCount;
}

- (nullable NSString *)commentsCount {
    return self.commentsCountLabel.text;
}

@end

NS_ASSUME_NONNULL_END
