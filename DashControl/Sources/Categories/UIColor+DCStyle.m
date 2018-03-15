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

#import "UIColor+DCStyle.h"

NS_ASSUME_NONNULL_BEGIN

@implementation UIColor (DCStyle)

+ (UIColor *)dc_barTintColor {
    return [UIColor colorWithRed:0.0 green:113.0 / 255.0 blue:190.0 / 255.0 alpha:1.0];
}

+ (UIColor *)dc_darkBlueColor {
    return [UIColor colorWithRed:30.0 / 255.0 green:37.0 / 255.0 blue:51.0 / 255.0 alpha:1.0];
}

@end

NS_ASSUME_NONNULL_END
