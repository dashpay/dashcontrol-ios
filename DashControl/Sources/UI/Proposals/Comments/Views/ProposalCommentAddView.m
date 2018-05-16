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

#import "ProposalCommentAddView.h"

#import "UIColor+DCStyle.h"
#import "UIView+DCAnimations.h"
#import "ProposalCommentAddViewModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface ProposalCommentAddView () <UITextViewDelegate>

@property (strong, nonatomic) IBOutlet UIView *contentView;
@property (strong, nonatomic) IBOutlet UITextView *textView;
@property (strong, nonatomic) IBOutlet UIButton *addButton;
@property (strong, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicatorView;

@end

@implementation ProposalCommentAddView

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

    self.textView.delegate = self;
    self.textView.layer.borderWidth = 1.0;

    // KVO

    [self mvvm_observe:@"viewModel.state" with:^(typeof(self) self, NSNumber * value) {
        switch (self.viewModel.state) {
            case ProposalCommentAddViewModelStateNone: {
                [self setViewLoading:NO];
                [self updateFirstResponderState:self.isFirstResponder];
                break;
            }
            case ProposalCommentAddViewModelStateSending: {
                [self setViewLoading:YES];
                [self updateFirstResponderState:self.isFirstResponder];
                break;
            }
            case ProposalCommentAddViewModelStateError: {
                [self setViewLoading:NO];
                UIColor *redColor = [UIColor colorWithRed:255.0 / 255.0 green:37.0 / 255.0 blue:101.0 / 255.0 alpha:1.0];
                self.textView.layer.borderColor = redColor.CGColor;
                break;
            }
        }
    }];

    [self mvvm_observe:@"viewModel.visible" with:^(typeof(self) self, NSNumber * value) {
        BOOL hidden = !self.viewModel.visible;
        self.addButton.hidden = hidden;
        self.textView.hidden = hidden;
        self.activityIndicatorView.hidden = hidden;
    }];

    [self mvvm_observe:@"viewModel.text" with:^(typeof(self) self, NSString * value) {
        self.textView.text = value;
    }];
}

- (void)shakeTextView {
    [self.textView dc_shakeView];
}

#pragma mark Actions

- (IBAction)addButtonAction:(id)sender {
    [self.delegate proposalCommentAddViewAddButtonAction:self];
}

#pragma mark UIResponder

- (BOOL)canBecomeFirstResponder {
    return self.textView.canBecomeFirstResponder;
}

- (BOOL)becomeFirstResponder {
    BOOL result = [self.textView becomeFirstResponder];
    [self updateFirstResponderState:result];
    return result;
}

- (BOOL)canResignFirstResponder {
    return self.textView.canResignFirstResponder;
}

- (BOOL)resignFirstResponder {
    BOOL result = [self.textView resignFirstResponder];
    [self updateFirstResponderState:result];
    return result;
}

- (BOOL)isFirstResponder {
    return self.textView.isFirstResponder;
}

#pragma mark UITextViewDelegate

- (void)textViewDidBeginEditing:(UITextView *)textView {
    [self updateFirstResponderState:YES];
}

- (void)textViewDidEndEditing:(UITextView *)textView {
    [self updateFirstResponderState:NO];
}

- (void)textViewDidChange:(UITextView *)textView {
    self.viewModel.text = textView.text;
    [self.delegate proposalCommentAddViewTextDidChange:self];
}

#pragma mark Private

- (void)updateFirstResponderState:(BOOL)active {
    UIColor *color = active ? [UIColor dc_barTintColor] : [UIColor colorWithRed:211.0 / 255.0 green:214.0 / 255.0 blue:219.0 / 255.0 alpha:1.0];
    self.textView.layer.borderColor = color.CGColor;
}

- (void)setViewLoading:(BOOL)loading {
    if (loading) {
        self.textView.editable = NO; // resigns first responder
        self.addButton.userInteractionEnabled = NO;
        [self.addButton setTitle:nil forState:UIControlStateNormal];
        self.activityIndicatorView.alpha = 1.0;
        [self.activityIndicatorView startAnimating];
    }
    else {
        self.textView.editable = YES;
        self.addButton.userInteractionEnabled = YES;
        [self resetAddButtonTitle];
        self.activityIndicatorView.alpha = 0.0;
        [self.activityIndicatorView stopAnimating];
    }
}

- (void)resetAddButtonTitle {
    NSString *buttonTitle = nil;
    switch (self.viewModel.type) {
        case ProposalCommentAddViewModelTypeComment: {
            buttonTitle = NSLocalizedString(@"Add Comment", nil);
            break;
        }
        case ProposalCommentAddViewModelTypeReply: {
            buttonTitle = NSLocalizedString(@"Add Reply", nil);
            break;
        }
    }
    [self.addButton setTitle:buttonTitle.uppercaseString forState:UIControlStateNormal];
}

@end

NS_ASSUME_NONNULL_END
