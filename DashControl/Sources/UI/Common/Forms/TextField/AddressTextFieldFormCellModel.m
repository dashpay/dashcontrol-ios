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

#import "AddressTextFieldFormCellModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface AddressTextFieldFormCellModel ()

@property (strong, nonatomic) NSCharacterSet *allowedCharacterSet;

@end

@implementation AddressTextFieldFormCellModel

- (NSCharacterSet *)allowedCharacterSet {
    if (!_allowedCharacterSet) {
        _allowedCharacterSet = [NSCharacterSet characterSetWithCharactersInString:@"abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"];
    }
    return _allowedCharacterSet;
}

- (BOOL)validateReplacementString:(NSString *)string text:(nullable NSString *)text {
    if (![super validateReplacementString:string text:text]) {
        return NO;
    }
    
    BOOL allowedString = ([string rangeOfCharacterFromSet:self.allowedCharacterSet].location != NSNotFound ||
                          string.length == 0);
    
    return allowedString;
}

@end

NS_ASSUME_NONNULL_END
