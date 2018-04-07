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

#import "TextFieldFormTableViewCell.h"

NS_ASSUME_NONNULL_BEGIN

@interface TextFieldFormTableViewCell () <UITextFieldDelegate>

@property (strong, nonatomic) IBOutlet UILabel *titleLabel;
@property (strong, nonatomic) IBOutlet UITextField *textField;

@end

@implementation TextFieldFormTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];

    [self mvvm_observe:@"cellModel.title" with:^(typeof(self) self, NSString * value) {
        self.titleLabel.text = value;
    }];

    [self mvvm_observe:@"cellModel.placeholder" with:^(typeof(self) self, NSString * value) {
        NSDictionary *attributes = @{NSForegroundColorAttributeName : [UIColor colorWithWhite:1.0 alpha:0.5]};
        self.textField.attributedPlaceholder = [[NSAttributedString alloc] initWithString:value ?: @"" attributes:attributes];
    }];

    [self mvvm_observe:@"cellModel.text" with:^(typeof(self) self, NSString * value) {
        self.textField.text = value;
    }];
}

- (void)setCellModel:(nullable TextFieldFormCellModel *)cellModel {
    _cellModel = cellModel;

    self.textField.autocapitalizationType = _cellModel.autocapitalizationType;
    self.textField.autocorrectionType = _cellModel.autocorrectionType;
    self.textField.keyboardType = _cellModel.keyboardType;
    self.textField.returnKeyType = _cellModel.returnKeyType;
    self.textField.enablesReturnKeyAutomatically = _cellModel.enablesReturnKeyAutomatically;
    self.textField.secureTextEntry = _cellModel.secureTextEntry;
}

#pragma mark UITextFieldDelegate

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    BOOL allowed = [self.cellModel validateReplacementString:string text:textField.text];
    if (!allowed) {
        return NO;
    }

    self.cellModel.text = [textField.text stringByReplacingCharactersInRange:range withString:string];

    return NO;
}

- (BOOL)textFieldShouldClear:(UITextField *)textField {
    self.cellModel.text = @"";

    return NO;
}

@end

NS_ASSUME_NONNULL_END
