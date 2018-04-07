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

#import "ProposalDetailHeaderView.h"

#import "UIFont+DCStyle.h"
#import "MBCircularProgressBarView.h"
#import "ProposalDetailHeaderViewModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface ProposalDetailHeaderRowView : UIView

@property (readonly, strong, nonatomic) UILabel *titleLabel;
@property (readonly, strong, nonatomic) UILabel *valueLabel;

@end

@implementation ProposalDetailHeaderRowView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor whiteColor];

        UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        titleLabel.translatesAutoresizingMaskIntoConstraints = NO;
        titleLabel.numberOfLines = 2;
        titleLabel.textAlignment = NSTextAlignmentLeft;
        titleLabel.font = [UIFont dc_montserratLightFontOfSize:10.0];
        titleLabel.textColor = [UIColor colorWithWhite:0.3 alpha:1.0];
        [self addSubview:titleLabel];
        _titleLabel = titleLabel;

        UILabel *valueLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        valueLabel.translatesAutoresizingMaskIntoConstraints = NO;
        valueLabel.numberOfLines = 2;
        valueLabel.textAlignment = NSTextAlignmentRight;
        valueLabel.font = [UIFont dc_montserratRegularFontOfSize:14.0];
        valueLabel.textColor = [UIColor colorWithWhite:0.3 alpha:1.0];
        valueLabel.adjustsFontSizeToFitWidth = YES;
        valueLabel.minimumScaleFactor = 0.75;
        [self addSubview:valueLabel];
        _valueLabel = valueLabel;

        UIView *lineView = [[UIView alloc] initWithFrame:CGRectZero];
        lineView.translatesAutoresizingMaskIntoConstraints = NO;
        lineView.backgroundColor = [UIColor colorWithWhite:0.9 alpha:1.0];
        [self addSubview:lineView];

        [titleLabel setContentCompressionResistancePriority:UILayoutPriorityDefaultHigh + 1 forAxis:UILayoutConstraintAxisHorizontal];
        [valueLabel setContentHuggingPriority:UILayoutPriorityDefaultLow + 1 forAxis:UILayoutConstraintAxisHorizontal];
        [@[
            [titleLabel.topAnchor constraintEqualToAnchor:self.topAnchor],
            [titleLabel.leadingAnchor constraintEqualToAnchor:self.leadingAnchor],
            [titleLabel.bottomAnchor constraintEqualToAnchor:self.bottomAnchor],

            [valueLabel.topAnchor constraintEqualToAnchor:self.topAnchor],
            [valueLabel.leadingAnchor constraintEqualToAnchor:titleLabel.trailingAnchor constant:8.0],
            [valueLabel.bottomAnchor constraintEqualToAnchor:self.bottomAnchor],
            [valueLabel.trailingAnchor constraintEqualToAnchor:self.trailingAnchor],

            [lineView.leadingAnchor constraintEqualToAnchor:self.leadingAnchor],
            [lineView.bottomAnchor constraintEqualToAnchor:self.bottomAnchor],
            [lineView.trailingAnchor constraintEqualToAnchor:self.trailingAnchor],
            [lineView.heightAnchor constraintEqualToConstant:1.0],
            
            [self.heightAnchor constraintGreaterThanOrEqualToConstant:40.0],
        ] enumerateObjectsUsingBlock:^(NSLayoutConstraint *_Nonnull obj, NSUInteger idx, BOOL *_Nonnull stop) {
            obj.active = YES;
        }];
    }
    return self;
}

@end

#pragma mark - Header

@interface ProposalDetailHeaderView ()

@property (weak, nonatomic) IBOutlet UIView *contentView;

@property (weak, nonatomic) IBOutlet UILabel *yesVotesTitleLabel;
@property (weak, nonatomic) IBOutlet UILabel *yesVotesLabel;
@property (weak, nonatomic) IBOutlet UILabel *noVotesTitleLabel;
@property (weak, nonatomic) IBOutlet UILabel *noVotesLabel;
@property (weak, nonatomic) IBOutlet UILabel *abstainTitleLabel;
@property (weak, nonatomic) IBOutlet UILabel *abstainLabel;

@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *ownerUsernameLabel;
@property (weak, nonatomic) IBOutlet MBCircularProgressBarView *progressBarView;

@property (weak, nonatomic) IBOutlet UIStackView *rowsStackView;

@end

@implementation ProposalDetailHeaderView

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

    self.yesVotesLabel.text = NSLocalizedString(@"Yes", @"Yes votes count title");
    self.noVotesLabel.text = NSLocalizedString(@"No", @"No votes count title");
    self.abstainLabel.text = NSLocalizedString(@"Abstain", @"Abstain votes count title");

    // KVO

    [self mvvm_observe:@"viewModel.completedPercent" with:^(typeof(self) self, NSNumber * value) {
        self.progressBarView.value = self.viewModel.completedPercent;
    }];

    [self mvvm_observe:@"viewModel.title" with:^(typeof(self) self, NSString * value) {
        self.titleLabel.text = value;
    }];

    [self mvvm_observe:@"viewModel.ownerUsername" with:^(typeof(self) self, NSString * value) {
        self.ownerUsernameLabel.text = value;
    }];

    [self mvvm_observe:@"viewModel.yesVotes" with:^(typeof(self) self, NSString * value) {
        self.yesVotesLabel.text = value;
    }];

    [self mvvm_observe:@"viewModel.noVotes" with:^(typeof(self) self, NSString * value) {
        self.noVotesLabel.text = value;
    }];

    [self mvvm_observe:@"viewModel.abstainVotes" with:^(typeof(self) self, NSString * value) {
        self.abstainLabel.text = value;
    }];

    [self mvvm_observe:@"viewModel.rows" with:^(typeof(self) self, NSArray<Pair<NSString *> *> * value) {
        for (UIView *subview in self.rowsStackView.subviews) {
            [subview removeFromSuperview];
        }

        for (Pair<NSString *> *pair in value) {
            ProposalDetailHeaderRowView *view = [[ProposalDetailHeaderRowView alloc] initWithFrame:CGRectZero];
            view.translatesAutoresizingMaskIntoConstraints = NO;
            view.titleLabel.text = pair.first;
            view.valueLabel.text = pair.second;
            [self.rowsStackView addArrangedSubview:view];
        }
    }];
}

@end

NS_ASSUME_NONNULL_END
