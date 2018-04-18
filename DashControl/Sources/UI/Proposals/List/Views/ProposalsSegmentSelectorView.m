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

#import "ProposalsSegmentSelectorView.h"

NS_ASSUME_NONNULL_BEGIN

#define SEGMENTED_HEIGHT 88.0

@interface ProposalsSegmentSelectorView ()

@property (strong, nonatomic) IBOutlet UIView *contentView;
@property (strong, nonatomic) IBOutlet UIView *backgroundView;
@property (strong, nonatomic) IBOutlet ProposalsSegmentedControl *segmentedControl;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *segmentedTopConstraint;

@end

@implementation ProposalsSegmentSelectorView

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
    
    UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapGestureRecognizerAction)];
    [self.backgroundView addGestureRecognizer:tapGestureRecognizer];
    
    // initial state
    self.segmentedTopConstraint.constant = -SEGMENTED_HEIGHT;
    self.backgroundView.alpha = 0.0;
}

- (void)setOpen:(BOOL)open {
    if (open == NO && !self.window) {
        return;
    }
    
    self.segmentedTopConstraint.constant = open ? 0.0 : -SEGMENTED_HEIGHT;
    
    [UIView animateWithDuration:0.25 delay:0.0 options:UIViewAnimationOptionBeginFromCurrentState animations:^{
        [self layoutIfNeeded];
        self.backgroundView.alpha = open ? 1.0 : 0.0;
    } completion:^(BOOL finished) {
        if (!open && finished) {
            [self.delegate proposalsSegmentSelectorViewDidClose:self];
        }
    }];
}

- (void)tapGestureRecognizerAction {
    [self setOpen:NO];
}

@end

NS_ASSUME_NONNULL_END
