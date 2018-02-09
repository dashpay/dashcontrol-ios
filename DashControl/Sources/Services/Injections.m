//
//  Injections.m
//  DashPriceViewer
//
//  Created by Andrew Podkovyrin on 05/01/2018.
//  Copyright © 2018 Andrew Podkovyrin. All rights reserved.
//

#import <DeluxeInjection/DeluxeInjection.h>

#import "Networking.h"

#import "Injections.h"

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
            httpService.allCertificatesAllowed = YES;
        });
        
        static HTTPLoaderFactory *loaderFactory;
        static dispatch_once_t loaderFactoryOnceToken;
        dispatch_once(&loaderFactoryOnceToken, ^{
            loaderFactory = [httpService createHTTPLoaderFactoryWithAuthorisers:nil];
        });
        
        [[[lets inject] byPropertyClass:[HTTPService class]] getterValue:httpService];
        [[[lets inject] byPropertyClass:[HTTPLoaderManager class]] getterValue:[[HTTPLoaderManager alloc] initWithFactory:loaderFactory]];
    }];
}

@end

NS_ASSUME_NONNULL_END
