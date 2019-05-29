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

#import "APIBaseAuthorized.h"

#import "Credentials.h"
#import "DSNetworking.h"

NS_ASSUME_NONNULL_BEGIN

#define USE_PRODUCTION 1

#ifdef USE_PRODUCTION
static NSString *const API_BASE_URL = @"https://dashpay.info/api/v0/";
#else
static NSString *const API_BASE_URL = @"https://dev.dashpay.info/api/v0/";
#endif

@implementation APIBaseAuthorized

- (NSString *)baseURLString {
    return API_BASE_URL;
}

- (id<HTTPLoaderOperationProtocol>)sendAuthorizedRequest:(HTTPRequest *)request completion:(HTTPLoaderCompletionBlock)completion {
    NSString *username = [Credentials deviceId];
    NSString *password = [Credentials devicePassword];
    NSData *basicAuthCredentials = [[NSString stringWithFormat:@"%@:%@", username, password] dataUsingEncoding:NSUTF8StringEncoding];
    NSString *base64AuthCredentials = [basicAuthCredentials base64EncodedStringWithOptions:kNilOptions];
    [request addValue:[NSString stringWithFormat:@"Basic %@", base64AuthCredentials] forHeader:@"Authorization"];
    return [self.httpManager sendRequest:request completion:completion];
}

@end

NS_ASSUME_NONNULL_END
