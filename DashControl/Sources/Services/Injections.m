//
//  Injections.m
//
//  Created by Andrew Podkovyrin on 05/01/2018.
//  Copyright © 2018 Andrew Podkovyrin. All rights reserved.
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

#import "Injections.h"

#import <DeluxeInjection/DeluxeInjection.h>

#import "Networking.h"
#import "APINews.h"

NS_ASSUME_NONNULL_BEGIN

@implementation Injections

+ (void)activate {
    [DeluxeInjection imperative:^(DIImperative *lets) {
        // Networking stack
        
        static HTTPService *httpService;
        static dispatch_once_t serviceOnceToken;
        dispatch_once(&serviceOnceToken, ^{
            NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
            httpService = [[HTTPService alloc] initWithConfiguration:configuration];
        });
        
        static HTTPLoaderFactory *loaderFactory;
        static dispatch_once_t loaderFactoryOnceToken;
        dispatch_once(&loaderFactoryOnceToken, ^{
            loaderFactory = [httpService createHTTPLoaderFactoryWithAuthorisers:nil];
        });
        
        [[[lets inject] byPropertyClass:[HTTPService class]] getterValue:httpService];
        [[[lets inject] byPropertyClass:[HTTPLoaderManager class]] getterValue:[[HTTPLoaderManager alloc] initWithFactory:loaderFactory]];
        
        
        // Lazy API injections:
        
        [[[lets inject] byPropertyClass:[APINews class]] getterValueLazyByClass:[APINews class]];
    }];
}

@end

NS_ASSUME_NONNULL_END
