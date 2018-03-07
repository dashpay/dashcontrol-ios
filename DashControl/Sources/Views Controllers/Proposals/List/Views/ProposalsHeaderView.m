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

#import "ProposalsHeaderView.h"

#import "ProposalsHeaderViewModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface ProposalsHeaderView ()

@property (weak, nonatomic) IBOutlet UIView *contentView;
@property (weak, nonatomic) IBOutlet UIView *segmentedView;
@property (weak, nonatomic) IBOutlet UIButton *segementedCurrentButton;
@property (weak, nonatomic) IBOutlet UIButton *segementedOngoingButton;
@property (weak, nonatomic) IBOutlet UIButton *segementedPastButton;
@property (weak, nonatomic) IBOutlet UILabel *totalTitleLabel;
@property (weak, nonatomic) IBOutlet UILabel *allotedTitleLabel;
@property (weak, nonatomic) IBOutlet UILabel *totalLabel;
@property (weak, nonatomic) IBOutlet UILabel *allotedLabel;
@property (weak, nonatomic) IBOutlet UILabel *superblockPaymentInfoLabel;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *topInfoViewTopConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *segmentedViewTopConstraint;

@property (assign, nonatomic) BOOL opened;

@end

@implementation ProposalsHeaderView

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
    [self.segementedCurrentButton setTitle:NSLocalizedString(@"Current", @"Current proposals") forState:UIControlStateNormal];
    [self.segementedOngoingButton setTitle:NSLocalizedString(@"Ongoing", @"Ongoing proposals") forState:UIControlStateNormal];
    [self.segementedPastButton setTitle:NSLocalizedString(@"Past", @"Past proposals") forState:UIControlStateNormal];

    [self setOpened:NO animated:NO];

    // KVO

    [self mvvm_observe:@"viewModel.total" with:^(typeof(self) self, NSString * value) {
        self.totalLabel.text = value;
    }];

    [self mvvm_observe:@"viewModel.alloted" with:^(typeof(self) self, NSString * value) {
        self.allotedLabel.text = value;
    }];

    [self mvvm_observe:@"viewModel.superblockPaymentInfo" with:^(typeof(self) self, NSString * value) {
        self.superblockPaymentInfoLabel.text = value;
    }];

    [self mvvm_observe:@"viewModel.segmentIndex" with:^(typeof(self) self, NSNumber * value) {
        ProposalsSegmentIndex segmentIndex = value.unsignedIntegerValue;
        switch (segmentIndex) {
            case ProposalsSegmentIndex_Current: {
                self.segementedCurrentButton.selected = YES;
                self.segementedOngoingButton.selected = NO;
                self.segementedPastButton.selected = NO;
                break;
            }
            case ProposalsSegmentIndex_Ongoing: {
                self.segementedCurrentButton.selected = NO;
                self.segementedOngoingButton.selected = YES;
                self.segementedPastButton.selected = NO;
                break;
            }
            case ProposalsSegmentIndex_Past: {
                self.segementedCurrentButton.selected = NO;
                self.segementedOngoingButton.selected = NO;
                self.segementedPastButton.selected = YES;
                break;
            }
        }
    }];
}

#define SEGMENTEDVIEW_HEIGHT 44.0

- (CGSize)intrinsicContentSize {
    return CGSizeMake([UIScreen mainScreen].bounds.size.width,
                      122.0 + (self.opened ? SEGMENTEDVIEW_HEIGHT : 0.0));
}

- (void)setOpened:(BOOL)opened animated:(BOOL)animated {
    self.opened = opened;

    if (self.opened) {
        self.segmentedView.hidden = NO;
    }
    self.segmentedViewTopConstraint.constant = opened ? 0.0 : -SEGMENTEDVIEW_HEIGHT;
    self.topInfoViewTopConstraint.constant = opened ? SEGMENTEDVIEW_HEIGHT : 0.0;

    CGSize headerSize = [self intrinsicContentSize];
    self.frame = CGRectMake(0.0, 0.0, headerSize.width, headerSize.height);

    [UIView animateWithDuration:animated ? 0.25 : 0.0
        animations:^{
            [self layoutIfNeeded];
        }
        completion:^(BOOL finished) {
            if (!self.opened) {
                self.segmentedView.hidden = YES;
            }
        }];
}

#pragma mark - Private

- (IBAction)segmentedButtonAction:(UIButton *)sender {
    ProposalsSegmentIndex segmentIndex = ProposalsSegmentIndex_Current;
    if (sender == self.segementedOngoingButton) {
        segmentIndex = ProposalsSegmentIndex_Ongoing;
    }
    else if (sender == self.segementedPastButton) {
        segmentIndex = ProposalsSegmentIndex_Past;
    }
    self.viewModel.segmentIndex = segmentIndex;
}

@end

NS_ASSUME_NONNULL_END
