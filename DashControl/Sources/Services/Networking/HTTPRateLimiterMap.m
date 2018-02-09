//
//  HTTPRateLimiterMap.m
//  DashPriceViewer
//
//  Created by Andrew Podkovyrin on 05/01/2018.
//  Copyright © 2018 Andrew Podkovyrin. All rights reserved.
//

#import "HTTPRateLimiter.h"

#import "HTTPRateLimiterMap.h"

NS_ASSUME_NONNULL_BEGIN

@interface HTTPRateLimiterMap ()

@property (strong, nonatomic) NSMutableDictionary<NSString *, HTTPRateLimiter *> *rateLimitersByKey;

@end

@implementation HTTPRateLimiterMap

- (instancetype)init {
    self = [super init];
    if (self) {
        _rateLimitersByKey = [NSMutableDictionary dictionary];
    }

    return self;
}

- (void)setRateLimiter:(HTTPRateLimiter *)rateLimiter forURL:(NSURL *)URL {
    NSParameterAssert(rateLimiter);
    NSParameterAssert(URL);

    if (!rateLimiter || !URL) {
        return;
    }

    NSString *key = [self keyFromURL:URL];
    @synchronized(self.rateLimitersByKey) {
        self.rateLimitersByKey[key] = rateLimiter;
    }
}

- (nullable HTTPRateLimiter *)rateLimiterForURL:(NSURL *)URL {
    NSParameterAssert(URL);

    if (!URL) {
        return nil;
    }

    NSString *key = [self keyFromURL:URL];
    HTTPRateLimiter *rateLimiter = nil;
    @synchronized(self.rateLimitersByKey) {
        rateLimiter = self.rateLimitersByKey[key];
    }

    return rateLimiter;
}

- (void)removeRateLimiterForURL:(NSURL *)URL {
    NSParameterAssert(URL);

    if (!URL) {
        return;
    }

    NSString *key = [self keyFromURL:URL];
    @synchronized(self.rateLimitersByKey) {
        [self.rateLimitersByKey removeObjectForKey:key];
    }
}

#pragma mark Private

- (NSString *)keyFromURL:(NSURL *)URL {
    if (!URL) {
        return @"";
    }

    NSURLComponents *components = [NSURLComponents componentsWithURL:URL resolvingAgainstBaseURL:NO];
    NSURLComponents *keyComponents = [[NSURLComponents alloc] init];
    keyComponents.scheme = components.scheme;
    keyComponents.host = components.host;
    keyComponents.path = components.path.pathComponents.firstObject;
    NSString *key = keyComponents.URL.absoluteString;

    return key;
}

@end

NS_ASSUME_NONNULL_END
