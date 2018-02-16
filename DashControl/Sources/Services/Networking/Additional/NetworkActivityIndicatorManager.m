//
//  NetworkActivityIndicatorManager.m
//
//  Created by Andrew Podkovyrin
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
        DCDebugLog([self class], @"activity counter < 0, something went wrong");

        return;
    }

    self.counter--;

    if (self.counter == 0) {
        [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    }
}

@end

NS_ASSUME_NONNULL_END
