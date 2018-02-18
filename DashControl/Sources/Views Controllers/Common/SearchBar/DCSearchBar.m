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

#import "DCSearchBar.h"

#import "UIFont+DCStyle.h"

NS_ASSUME_NONNULL_BEGIN

#pragma mark - SearchBar TextField

@interface DCSearchBarTintedTextField : UITextField
@end

@implementation DCSearchBarTintedTextField

- (void)layoutSubviews {
    [super layoutSubviews];

    for (UIView *subview in self.subviews) {
        if ([subview isKindOfClass:[UIButton class]]) {
            UIButton *button = (UIButton *)subview;
            [button setImage:[[button imageForState:UIControlStateNormal] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate]
                    forState:UIControlStateNormal];
            button.tintColor = [UIColor whiteColor];
        }
    }
}

@end

#pragma mark - SearchBar

@interface DCSearchBar () <UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet UIView *contentView;
@property (weak, nonatomic) IBOutlet UITextField *textField;
@property (weak, nonatomic) IBOutlet UIButton *cancelButton;

@end

@implementation DCSearchBar

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

    self.textField.attributedPlaceholder = [[NSAttributedString alloc] initWithString:NSLocalizedString(@"Search", @"Search bar placeholder") attributes:@{
        NSForegroundColorAttributeName : [UIColor colorWithWhite:1.0 alpha:0.5],
        NSFontAttributeName : [UIFont dc_montserratRegularFontOfSize:16.0],
    }];

    [self.cancelButton setTitle:NSLocalizedString(@"Cancel", @"Cancel button") forState:UIControlStateNormal];
}

- (CGSize)intrinsicContentSize {
    return CGSizeMake([UIScreen mainScreen].bounds.size.width, 44.0);
}

- (NSString *_Nullable)text {
    return self.textField.text;
}

- (void)setText:(NSString *_Nullable)text {
    self.textField.text = text;
}

#pragma mark UIResponder

- (BOOL)canBecomeFirstResponder {
    return self.textField.canBecomeFirstResponder;
}

- (BOOL)becomeFirstResponder {
    return [self.textField becomeFirstResponder];
}

- (BOOL)canResignFirstResponder {
    return self.textField.canResignFirstResponder;
}

- (BOOL)resignFirstResponder {
    return [self.textField resignFirstResponder];
}

- (BOOL)isFirstResponder {
    return self.textField.isFirstResponder;
}

#pragma mark Actions

- (IBAction)cancelButtonAction:(id)sender {
    [self.delegate searchBarCancelButtonClicked:self];
}

#pragma mark UITextFieldDelegate

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    textField.text = [textField.text stringByReplacingCharactersInRange:range withString:string];;
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.delegate searchBar:self textDidChange:self.textField.text];
    });

    return NO;
}

- (BOOL)textFieldShouldClear:(UITextField *)textField {
    textField.text = @"";
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.delegate searchBar:self textDidChange:@""];
    });
    
    return NO;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.delegate searchBarSearchButtonClicked:self];
    });

    return YES;
}

@end

NS_ASSUME_NONNULL_END
