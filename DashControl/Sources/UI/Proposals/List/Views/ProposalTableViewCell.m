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

#import "ProposalTableViewCell.h"

#import <MBCircularProgressBar/MBCircularProgressBarView.h>

#import "ProposalTableViewCellModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface ProposalTableViewCell ()

@property (weak, nonatomic) IBOutlet MBCircularProgressBarView *progressBarView;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *dateLabel;
@property (weak, nonatomic) IBOutlet UILabel *amountLabel;
@property (weak, nonatomic) IBOutlet UILabel *repeatIntervalLabel;
@property (weak, nonatomic) IBOutlet UILabel *authorLabel;
@property (weak, nonatomic) IBOutlet UILabel *likesCountLabel;
@property (weak, nonatomic) IBOutlet UILabel *commentsCountLabel;

@end

@implementation ProposalTableViewCell

- (void)setHighlighted:(BOOL)highlighted animated:(BOOL)animated {
    [super setHighlighted:highlighted animated:animated];

    [UIView animateWithDuration:0.25 animations:^{
        self.contentView.alpha = highlighted ? 0.65 : 1.0;
    }];
}

- (void)configureWithViewModel:(ProposalTableViewCellModel *)viewModel {
    self.progressBarView.value = viewModel.completedPercent;
    self.titleLabel.text = viewModel.title;
    self.dateLabel.text = viewModel.remainingPayment;
    self.repeatIntervalLabel.text = viewModel.repeatInterval;
    self.amountLabel.text = viewModel.monthlyAmount;
    self.authorLabel.text = viewModel.ownerUsername;
    self.likesCountLabel.text = viewModel.likes;
    self.commentsCountLabel.text = viewModel.comments;
}

@end

NS_ASSUME_NONNULL_END
