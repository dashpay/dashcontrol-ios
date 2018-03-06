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

#import "BudgetInfoHeaderView.h"

#import "BudgetInfoHeaderViewModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface BudgetInfoHeaderView ()

@property (weak, nonatomic) IBOutlet UIView *contentView;
@property (weak, nonatomic) IBOutlet UILabel *totalTitleLabel;
@property (weak, nonatomic) IBOutlet UILabel *allotedTitleLabel;
@property (weak, nonatomic) IBOutlet UILabel *totalLabel;
@property (weak, nonatomic) IBOutlet UILabel *allotedLabel;
@property (weak, nonatomic) IBOutlet UILabel *superblockPaymentInfoLabel;

@end

@implementation BudgetInfoHeaderView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self commonInit];
    }
    return self;
}

- (nullable instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self commonInit];
    }
    return self;
}

- (void)commonInit {
    [[NSBundle mainBundle] loadNibNamed:NSStringFromClass([self class]) owner:self options:nil];
    [self addSubview:self.contentView];
    self.contentView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.contentView.topAnchor constraintEqualToAnchor:self.topAnchor].active = YES;
    [self.contentView.leadingAnchor constraintEqualToAnchor:self.leadingAnchor].active = YES;
    [self.contentView.bottomAnchor constraintEqualToAnchor:self.bottomAnchor].active = YES;
    [self.contentView.trailingAnchor constraintEqualToAnchor:self.trailingAnchor].active = YES;
    [self.contentView.widthAnchor constraintEqualToAnchor:self.widthAnchor].active = YES;

    self.totalTitleLabel.text = NSLocalizedString(@"Total", nil);
    self.allotedTitleLabel.text = NSLocalizedString(@"Alloted", nil);
}

- (CGSize)intrinsicContentSize {
    return CGSizeMake([UIScreen mainScreen].bounds.size.width, 122.0);
}

- (void)configureWithViewModel:(BudgetInfoHeaderViewModel *)viewModel {
    self.totalLabel.text = viewModel.total;
    self.allotedLabel.text = viewModel.alloted;
    self.superblockPaymentInfoLabel.text = viewModel.superblocksPaymentInfo;
}

@end

NS_ASSUME_NONNULL_END
