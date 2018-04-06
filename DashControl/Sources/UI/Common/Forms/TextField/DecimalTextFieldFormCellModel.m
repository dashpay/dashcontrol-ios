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

#import "DecimalTextFieldFormCellModel.h"

NS_ASSUME_NONNULL_BEGIN

@implementation DecimalTextFieldFormCellModel

- (instancetype)initWithTitle:(nullable NSString *)title placeholder:(nullable NSString *)placeholder {
    self = [super initWithTitle:title placeholder:placeholder];
    if (self) {
        self.keyboardType = UIKeyboardTypeDecimalPad;
    }
    return self;
}

- (BOOL)validateReplacementString:(NSString *)string text:(nullable NSString *)text {
    NSString *decimalSeparator = [NSLocale currentLocale].decimalSeparator;
    NSCharacterSet *decimalSeparatorSet = [NSCharacterSet characterSetWithCharactersInString:decimalSeparator];
    BOOL allowedString = ([string rangeOfCharacterFromSet:[NSCharacterSet decimalDigitCharacterSet]].location != NSNotFound ||
                          [string rangeOfCharacterFromSet:decimalSeparatorSet].location != NSNotFound ||
                          string.length == 0);
    if (!allowedString) {
        return NO;
    }

    if ([string rangeOfCharacterFromSet:decimalSeparatorSet].location != NSNotFound &&
        ([text rangeOfCharacterFromSet:[NSCharacterSet decimalDigitCharacterSet]].location == NSNotFound ||
         [text rangeOfCharacterFromSet:decimalSeparatorSet].location != NSNotFound)) {
        return NO;
    }

    return [super validateReplacementString:string text:text];
}

@end

NS_ASSUME_NONNULL_END
