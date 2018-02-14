//
//  NetworkActivityIndicatorManager.m
//  DashPriceViewer
//
//  Created by Andrew Podkovyrin on 05/01/2018.
//  Copyright © 2018 Andrew Podkovyrin. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "NetworkActivityIndicatorManager.h"

NS_ASSUME_NONNULL_BEGIN

@interface NetworkActivityIndicatorManager ()

@property (assign, nonatomic) NSUInteger counter;

@end

@implementation NetworkActivityIndicatorManager

+ (void)increaseActivityCounter {
    NSAssert([NSThread isMainThread], nil);
    [[[self class] sharedInstance] increaseActivityCounter];
}

+ (void)decreaseActivityCounter {
    NSAssert([NSThread isMainThread], nil);
    [[[self class] sharedInstance] decreaseActivityCounter];
}

#pragma mark Private

+ (instancetype)sharedInstance {
    static id _sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedInstance = [[self alloc] init];
    });
    return _sharedInstance;
}

- (void)increaseActivityCounter {
    self.counter++;

    if (self.counter > 0) {
        [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    }
}

- (void)decreaseActivityCounter {
    if (self.counter == 0) {
#ifdef DEBUG
        NSLog(@"%@: activity counter < 0, something went wrong", NSStringFromClass([self class]));
#endif

        return;
    }

    self.counter--;

    if (self.counter == 0) {
        [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    }
}

@end

NS_ASSUME_NONNULL_END
