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
#import "UIImage+DCAdditions.h"
#import "ProposalDetailBasicInfoView.h"
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

            [self.heightAnchor constraintEqualToConstant:40.0],
        ] enumerateObjectsUsingBlock:^(NSLayoutConstraint *_Nonnull obj, NSUInteger idx, BOOL *_Nonnull stop) {
            obj.active = YES;
        }];
    }
    return self;
}

@end

#pragma mark - Header

@interface ProposalDetailHeaderView ()

@property (strong, nonatomic) IBOutlet UIView *contentView;
@property (strong, nonatomic) IBOutlet ProposalDetailBasicInfoView *basicInfoView;
@property (strong, nonatomic) IBOutlet UIStackView *rowsStackView;
@property (strong, nonatomic) IBOutlet UILabel *voteTitleLabel;
@property (strong, nonatomic) IBOutlet UIButton *yesButton;
@property (strong, nonatomic) IBOutlet UIButton *abstainButton;
@property (strong, nonatomic) IBOutlet UIButton *noButton;

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
    [NSLayoutConstraint activateConstraints:@[
        [self.contentView.topAnchor constraintEqualToAnchor:self.topAnchor],
        [self.contentView.leadingAnchor constraintEqualToAnchor:self.leadingAnchor],
        [self.contentView.bottomAnchor constraintEqualToAnchor:self.bottomAnchor],
        [self.contentView.trailingAnchor constraintEqualToAnchor:self.trailingAnchor],
        [self.contentView.widthAnchor constraintEqualToAnchor:self.widthAnchor],
    ]];

    UIColor *color = [UIColor colorWithRed:141.0 / 255.0 green:201.0 / 255.0 blue:25.0 / 255.0 alpha:1.0];
    [self.yesButton setBackgroundImage:[UIImage dc_imageWithColor:color] forState:UIControlStateNormal];
    color = [UIColor colorWithRed:255.0 / 255.0 green:43.0 / 255.0 blue:104.0 / 255.0 alpha:1.0];
    [self.noButton setBackgroundImage:[UIImage dc_imageWithColor:color] forState:UIControlStateNormal];
    color = [UIColor colorWithRed:231.0 / 255.0 green:188.0 / 255.0 blue:82.0 / 255.0 alpha:1.0];
    [self.abstainButton setBackgroundImage:[UIImage dc_imageWithColor:color] forState:UIControlStateNormal];
    [self.yesButton setTitle:[NSLocalizedString(@"Yes", nil) uppercaseString] forState:UIControlStateNormal];
    [self.noButton setTitle:[NSLocalizedString(@"No", nil) uppercaseString] forState:UIControlStateNormal];
    [self.abstainButton setTitle:[NSLocalizedString(@"Abstain", nil) uppercaseString] forState:UIControlStateNormal];
    self.yesButton.tag = DSGovernanceVoteOutcome_Yes;
    self.noButton.tag = DSGovernanceVoteOutcome_No;
    self.abstainButton.tag = DSGovernanceVoteOutcome_Abstain;

    self.voteTitleLabel.text = NSLocalizedString(@"Cast your vote", nil);

    // KVO

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

    [self mvvm_observe:@"viewModel.voteOutcome" with:^(typeof(self) self, NSNumber * value) {
        self.yesButton.userInteractionEnabled = YES;
        self.noButton.userInteractionEnabled = YES;
        self.abstainButton.userInteractionEnabled = YES;

        if (!self.viewModel.voteAllowed) {
            self.yesButton.enabled = NO;
            self.noButton.enabled = NO;
            self.abstainButton.enabled = NO;

            return;
        }

        switch (self.viewModel.voteOutcome) {
            case DSGovernanceVoteOutcome_None: {
                self.yesButton.enabled = YES;
                self.noButton.enabled = YES;
                self.abstainButton.enabled = YES;
                break;
            }
            case DSGovernanceVoteOutcome_Yes: {
                self.yesButton.enabled = YES;
                self.noButton.enabled = NO;
                self.abstainButton.enabled = NO;
                self.yesButton.userInteractionEnabled = NO;
                break;
            }
            case DSGovernanceVoteOutcome_No: {
                self.yesButton.enabled = NO;
                self.noButton.enabled = YES;
                self.abstainButton.enabled = NO;
                self.noButton.userInteractionEnabled = NO;
                break;
            }
            case DSGovernanceVoteOutcome_Abstain: {
                self.yesButton.enabled = NO;
                self.noButton.enabled = NO;
                self.abstainButton.enabled = YES;
                self.abstainButton.userInteractionEnabled = NO;
                break;
            }
        }

        if (self.viewModel.voteOutcome == DSGovernanceVoteOutcome_None) {
            self.voteTitleLabel.text = NSLocalizedString(@"Cast your vote", nil);
        }
        else {
            self.voteTitleLabel.text = NSLocalizedString(@"Your vote", nil);
        }
    }];
}

- (void)setViewModel:(ProposalDetailHeaderViewModel *)viewModel {
    _viewModel = viewModel;
    self.basicInfoView.viewModel = viewModel;
}

- (IBAction)voteButtonAction:(UIButton *)sender {
    if ([self.viewModel canVote]) {
        DSGovernanceVoteOutcome voteOutcome = (DSGovernanceVoteOutcome)sender.tag;
        [self.viewModel voteOnProposalWithOutcome:voteOutcome];
    }
    else {
        [self.delegate proposalDetailHeaderViewShowAddMasternodeController:self];
    }
}

@end

NS_ASSUME_NONNULL_END
