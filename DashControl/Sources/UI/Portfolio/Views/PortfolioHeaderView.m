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

#import "PortfolioHeaderView.h"

NS_ASSUME_NONNULL_BEGIN

@interface PortfolioHeaderView ()

@property (strong, nonatomic) IBOutlet UIView *contentView;
@property (strong, nonatomic) IBOutlet UILabel *dashTitleLabel;
@property (strong, nonatomic) IBOutlet UILabel *usdTitleLabel;
@property (strong, nonatomic) IBOutlet UILabel *dashLabel;
@property (strong, nonatomic) IBOutlet UILabel *usdLabel;

@end

@implementation PortfolioHeaderView

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
    
    self.dashTitleLabel.text = NSLocalizedString(@"Your DASH", nil);
    self.usdTitleLabel.text = NSLocalizedString(@"Value in USD", nil);
    
    // KVO
    
    [self mvvm_observe:@"viewModel.dashTotal" with:^(typeof(self) self, NSString * value) {
        self.dashLabel.text = value;
    }];
    
    [self mvvm_observe:@"viewModel.dashTotalInUSD" with:^(typeof(self) self, NSString * value) {
        self.usdLabel.text = value;
    }];
}

- (CGSize)intrinsicContentSize {
    return CGSizeMake([UIScreen mainScreen].bounds.size.width, 88.0);
}

@end

NS_ASSUME_NONNULL_END
