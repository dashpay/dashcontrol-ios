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

#import "PriceTriggerTextFieldTableViewCell.h"

#import "TextFieldTriggerDetail.h"

NS_ASSUME_NONNULL_BEGIN

@interface PriceTriggerTextFieldTableViewCell () <UITextFieldDelegate>

@property (strong, nonatomic) IBOutlet UILabel *titleLabel;
@property (strong, nonatomic) IBOutlet UITextField *textField;

@end

@implementation PriceTriggerTextFieldTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];

    [self mvvm_observe:@"detail.title" with:^(typeof(self) self, NSString * value) {
        self.titleLabel.text = value;
    }];

    [self mvvm_observe:@"detail.placeholder" with:^(typeof(self) self, NSString * value) {
        NSDictionary *attributes = @{NSForegroundColorAttributeName : [UIColor colorWithWhite:1.0 alpha:0.5]};
        self.textField.attributedPlaceholder = [[NSAttributedString alloc] initWithString:value ?: @"" attributes:attributes];
    }];

    [self mvvm_observe:@"detail.text" with:^(typeof(self) self, NSString * value) {
        self.textField.text = value;
    }];
}

#pragma mark UITextFieldDelegate

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    NSString *decimalSeparator = [NSLocale currentLocale].decimalSeparator;
    NSCharacterSet *decimalSeparatorSet = [NSCharacterSet characterSetWithCharactersInString:decimalSeparator];
    BOOL allowedString = ([string rangeOfCharacterFromSet:[NSCharacterSet decimalDigitCharacterSet]].location != NSNotFound ||
                          [string rangeOfCharacterFromSet:decimalSeparatorSet].location != NSNotFound ||
                          string.length == 0);
    if (!allowedString) {
        return NO;
    }
    
    if ([textField.text rangeOfCharacterFromSet:decimalSeparatorSet].location != NSNotFound &&
        [string rangeOfCharacterFromSet:decimalSeparatorSet].location != NSNotFound) {
        return NO;
    }
    
    textField.text = [textField.text stringByReplacingCharactersInRange:range withString:string];
    self.detail.text = textField.text;

    return NO;
}

- (BOOL)textFieldShouldClear:(UITextField *)textField {
    textField.text = @"";
    self.detail.text = textField.text;

    return NO;
}

@end

NS_ASSUME_NONNULL_END
