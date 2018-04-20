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

#import "DCFormattingUtils.h"

NS_ASSUME_NONNULL_BEGIN

int64_t const DUFFS = 100000000;

@implementation DCFormattingUtils

+ (NSNumberFormatter *)dashNumberFormatter {
    static NSNumberFormatter *_dashNumberFormatter = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _dashNumberFormatter = [[NSNumberFormatter alloc] init];
        _dashNumberFormatter.numberStyle = NSNumberFormatterCurrencyStyle;
        _dashNumberFormatter.generatesDecimalNumbers = YES;
        _dashNumberFormatter.maximumFractionDigits = 8;
        _dashNumberFormatter.minimumFractionDigits = 0;
        _dashNumberFormatter.currencySymbol = @"";

    });
    return _dashNumberFormatter;
}

@end

NS_ASSUME_NONNULL_END
