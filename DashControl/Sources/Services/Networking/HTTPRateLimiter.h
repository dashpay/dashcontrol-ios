//
//  HTTPRateLimiter.h
//  DashPriceViewer
//
//  Created by Andrew Podkovyrin on 03/01/2018.
//  Copyright © 2018 Andrew Podkovyrin. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface HTTPRateLimiter : NSObject

@property (readonly, assign, nonatomic) NSTimeInterval window;
@property (readonly, assign, nonatomic) NSUInteger delayAfter;
@property (readonly, assign, nonatomic) NSTimeInterval delay;
@property (readonly, assign, nonatomic) NSUInteger maximum;

- (instancetype)initWithWindow:(NSTimeInterval)window
                    delayAfter:(NSUInteger)delayAfter
                         delay:(NSTimeInterval)delay
                       maximum:(NSUInteger)maximum NS_DESIGNATED_INITIALIZER;
- (instancetype)init NS_UNAVAILABLE;

- (NSTimeInterval)earliestTimeUntilRequestCanBeExecuted;
- (void)executedRequest;

@end

NS_ASSUME_NONNULL_END
