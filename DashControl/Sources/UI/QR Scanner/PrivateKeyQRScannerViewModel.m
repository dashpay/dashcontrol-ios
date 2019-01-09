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

#import "PrivateKeyQRScannerViewModel.h"

#import "NSString+Dash.h"

NS_ASSUME_NONNULL_BEGIN

NSString *const PrivateKeyQRScannerViewModelErrorDomain = @"PrivateKeyQRScannerViewModelErrorDomain";

@implementation PrivateKeyQRScannerViewModel

- (BOOL)validateQRCodeObjectValue:(NSString *_Nullable)stringValue error:(NSError *__autoreleasing _Nullable *_Nullable)error {
    NSString *addr = [stringValue stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    BOOL valid = [addr isValidDashPrivateKeyOnChain:self.chain];
    if (!valid && error) {
        *error = [NSError errorWithDomain:PrivateKeyQRScannerViewModelErrorDomain
                                     code:1
                                 userInfo:@{
                                     NSLocalizedDescriptionKey : NSLocalizedString(@"Invalid private key", nil),
                                 }];
    }

    return valid;
}

@end

NS_ASSUME_NONNULL_END
