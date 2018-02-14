//
//  HTTPRateLimiterMap.h
//  DashPriceViewer
//
//  Created by Andrew Podkovyrin on 05/01/2018.
//  Copyright © 2018 Andrew Podkovyrin. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@class HTTPRateLimiter;

@interface HTTPRateLimiterMap : NSObject

- (void)setRateLimiter:(HTTPRateLimiter *)rateLimiter forURL:(NSURL *)URL;
- (nullable HTTPRateLimiter *)rateLimiterForURL:(NSURL *)URL;
- (void)removeRateLimiterForURL:(NSURL *)URL;

@end

NS_ASSUME_NONNULL_END
