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

#import "UIFont+DCStyle.h"

NS_ASSUME_NONNULL_BEGIN

@implementation UIFont (DCStyle)

+ (UIFont *)dc_montserratRegularFontOfSize:(CGFloat)size {
    return [UIFont fontWithName:@"Montserrat-Regular" size:size];
}

+ (UIFont *)dc_montserratLightFontOfSize:(CGFloat)size {
    return [UIFont fontWithName:@"Montserrat-Light" size:size];
}

+ (UIFont *)dc_montserratSemiBoldFontOfSize:(CGFloat)size {
    return [UIFont fontWithName:@"Montserrat-SemiBold" size:size];
}

@end

NS_ASSUME_NONNULL_END
