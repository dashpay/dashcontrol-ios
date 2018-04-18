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

#import "ProposalsSegmentedControl.h"

#import "UIFont+DCStyle.h"

NS_ASSUME_NONNULL_BEGIN

static UIButton *SegmentButton(NSString *title) {
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.translatesAutoresizingMaskIntoConstraints = NO;
    button.titleLabel.font = [UIFont dc_montserratLightFontOfSize:11.0];
    button.adjustsImageWhenHighlighted = NO;
    [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [button setTitle:title forState:UIControlStateNormal];
    [button setBackgroundImage:[UIImage imageNamed:@"lightBlueButtonBg"] forState:UIControlStateNormal];
    UIImage *selectedImage = [UIImage imageNamed:@"lightBlueButtonSelectedBg"];
    [button setBackgroundImage:selectedImage forState:UIControlStateSelected];
    [button setBackgroundImage:selectedImage forState:UIControlStateHighlighted];
    [button.heightAnchor constraintEqualToConstant:23.0].active = YES;
    return button;
}

@interface ProposalsSegmentedControl ()

@property (copy, nonatomic) NSArray<UIButton *> *buttons;
@property (strong, nonatomic) UIStackView *stackView;

@end

@implementation ProposalsSegmentedControl

- (nullable instancetype)initWithCoder:(NSCoder *)coder {
    self = [super initWithCoder:coder];
    if (self) {
        [self setupView];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self setupView];
    }
    return self;
}

- (void)setSelectedIndex:(ProposalsSegmentIndex)selectedIndex {
    _selectedIndex = selectedIndex;

    UIButton *selectedButton = self.buttons[selectedIndex];
    selectedButton.selected = YES;
    for (UIButton *button in self.buttons) {
        if (button != selectedButton) {
            button.selected = NO;
        }
    }
}

#define PADDING 24.0

- (void)setupView {
    NSMutableArray<UIButton *> *buttons = [NSMutableArray array];
    NSArray<NSString *> *titles = @[
        NSLocalizedString(@"Current", @"Current proposals"),
        NSLocalizedString(@"Ongoing", @"Ongoing proposals"),
        NSLocalizedString(@"Past", @"Past proposals"),
    ];
    for (NSString *title in titles) {
        UIButton *button = SegmentButton(title);
        button.tag = [titles indexOfObject:title];
        [button addTarget:self action:@selector(segmentButtonAction:) forControlEvents:UIControlEventTouchUpInside];
        [buttons addObject:button];
    }
    self.buttons = buttons;

    UIStackView *stackView = [[UIStackView alloc] initWithArrangedSubviews:self.buttons];
    stackView.translatesAutoresizingMaskIntoConstraints = NO;
    stackView.axis = UILayoutConstraintAxisHorizontal;
    stackView.alignment = UIStackViewAlignmentFill;
    stackView.distribution = UIStackViewDistributionFillEqually;
    stackView.spacing = 8.0;
    [self addSubview:stackView];
    [stackView.leadingAnchor constraintEqualToAnchor:self.leadingAnchor constant:PADDING].active = YES;
    [stackView.trailingAnchor constraintEqualToAnchor:self.trailingAnchor constant:-PADDING].active = YES;
    [stackView.centerYAnchor constraintEqualToAnchor:self.centerYAnchor].active = YES;

    self.selectedIndex = 0;
}

- (void)segmentButtonAction:(UIButton *)sender {
    NSUInteger selectedIndex = [self.buttons indexOfObject:sender];
    NSParameterAssert(selectedIndex != NSNotFound);
    if (self.selectedIndex == selectedIndex) {
        [self sendActionsForControlEvents:UIControlEventTouchCancel];
        
        return;
    }

    self.selectedIndex = selectedIndex;

    [self sendActionsForControlEvents:UIControlEventValueChanged];
}

@end

NS_ASSUME_NONNULL_END
