//
//  HTTPCancellationTokenImpl.m
//
//  Created by Andrew Podkovyrin on 07/02/2018.
//  Copyright © 2018 Dash Foundation. All rights reserved.
//

#import "HTTPCancellationTokenImpl.h"

NS_ASSUME_NONNULL_BEGIN

@interface HTTPCancellationTokenImpl ()

@property (assign, nonatomic, getter=isCancelled) BOOL cancelled;

@end

@implementation HTTPCancellationTokenImpl

- (instancetype)initWithDelegate:(id<HTTPCancellationTokenDelegate>)delegate cancelObject:(nullable id)cancelObject {
    self = [super init];
    if (self) {
        _delegate = delegate;
        _objectToCancel = cancelObject;
    }

    return self;
}

#pragma mark HTTPCancellationToken

@synthesize cancelled = _cancelled;
@synthesize delegate = _delegate;
@synthesize objectToCancel = _objectToCancel;

- (void)cancel {
    if (self.cancelled) {
        return;
    }

    [self.delegate cancellationTokenDidCancel:self];

    self.cancelled = YES;
}

@end

NS_ASSUME_NONNULL_END
