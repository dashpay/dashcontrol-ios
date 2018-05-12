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

#import "ProposalDetailBasicInfoView.h"

#import <MBCircularProgressBar/MBCircularProgressBarView.h>

#import "ProposalDetailHeaderViewModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface ProposalDetailBasicInfoView ()

@property (strong, nonatomic) IBOutlet UIView *contentView;

@property (strong, nonatomic) IBOutlet UILabel *titleLabel;
@property (strong, nonatomic) IBOutlet UILabel *ownerUsernameLabel;
@property (strong, nonatomic) IBOutlet MBCircularProgressBarView *progressBarView;

@end

@implementation ProposalDetailBasicInfoView

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
}

@end

NS_ASSUME_NONNULL_END
