//
//  HTTPService.h
//
//  Created by Andrew Podkovyrin on 07/02/2018.
//  Copyright © 2018 Dash Foundation. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@class HTTPLoaderFactory;
@class HTTPRateLimiterMap;
@protocol HTTPLoaderAuthoriser;

@interface HTTPService : NSObject

@property (assign, nonatomic, getter=areAllCertificatesAllowed) BOOL allCertificatesAllowed;
@property (readonly, strong, nonatomic) HTTPRateLimiterMap *rateLimiterMap;

- (instancetype)initWithConfiguration:(NSURLSessionConfiguration *)configuration NS_DESIGNATED_INITIALIZER;
- (instancetype)init NS_UNAVAILABLE;

- (HTTPLoaderFactory *)createHTTPLoaderFactoryWithAuthorisers:(nullable NSArray<id<HTTPLoaderAuthoriser>> *)authorisers;

@end

NS_ASSUME_NONNULL_END
