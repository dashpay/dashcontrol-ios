//
//  HTTPLoaderOperation.m
//  DashPriceViewer
//
//  Created by Andrew Podkovyrin on 08/02/2018.
//  Copyright © 2018 Andrew Podkovyrin. All rights reserved.
//

#import "HTTPLoaderOperation.h"

#import "NetworkActivityIndicatorManager.h"
#import "HTTPLoader.h"
#import "HTTPRequest.h"
#import "HTTPCancellationToken.h"
#import "HTTPLoaderFactory.h"
#import "HTTPLoaderDelegate.h"

NS_ASSUME_NONNULL_BEGIN

@interface HTTPLoaderOperation () <HTTPLoaderDelegate>

@property (strong, nonatomic) HTTPLoader *httpLoader;
@property (strong, nonatomic) HTTPRequest *httpRequest;

@property (weak, nonatomic) id<HTTPCancellationToken> cancellationToken;
@property (nullable, copy, nonatomic) HTTPLoaderRawCompletionBlock completion;

@end

@implementation HTTPLoaderOperation

- (instancetype)initWithHTTPRequest:(HTTPRequest *)httpRequest httpLoaderFactory:(HTTPLoaderFactory *)httpLoaderFactory {
    NSParameterAssert(httpRequest);
    NSParameterAssert(httpLoaderFactory);

    self = [super init];
    if (self) {
        _httpRequest = httpRequest;
        _httpLoader = [httpLoaderFactory createHTTPLoader];
        _httpLoader.delegate = self;
    }

    return self;
}

- (void)performWithCompletion:(HTTPLoaderRawCompletionBlock)completion {
    NSParameterAssert(completion);

    //
    // hold cycle reference to the `self` to keep an operation alive until it completed or cancelled
    //
    __block id referenceToSelf = self;
    self.completion = ^(BOOL success, BOOL cancelled, HTTPResponse * _Nullable response) {
        if (completion) {
            completion(success, cancelled, response);
        }

        referenceToSelf = nil;
    };

    self.cancellationToken = [self.httpLoader performRequest:self.httpRequest];
    NSAssert(self.cancellationToken, @"Performing request failed");

    RunOnMainThread(^{
        [NetworkActivityIndicatorManager increaseActivityCounter];
    });
}

#pragma mark HTTPLoaderOperationProtocol

- (void)cancel {
    [self.cancellationToken cancel];

    //
    // nilled out completion block to break the retain cycle
    // @see: performWithCompletion
    //
    self.completion = nil;
}

#pragma mark HTTPLoaderDelegate

- (void)httpLoader:(HTTPLoader *)httpLoader didReceiveSuccessfulResponse:(HTTPResponse *)response {
    RunOnMainThread(^{
        [NetworkActivityIndicatorManager decreaseActivityCounter];
    });

    if (self.completion) {
        self.completion(YES, NO, response);
    }
}

- (void)httpLoader:(HTTPLoader *)httpLoader didReceiveErrorResponse:(HTTPResponse *)response {
    RunOnMainThread(^{
        [NetworkActivityIndicatorManager decreaseActivityCounter];
    });

    if (self.completion) {
        self.completion(NO, NO, response);
    }
}

- (void)httpLoader:(HTTPLoader *)httpLoader didCancelRequest:(HTTPRequest *)request {
    RunOnMainThread(^{
        [NetworkActivityIndicatorManager decreaseActivityCounter];
    });
    
    if (self.completion) {
        self.completion(NO, YES, nil);
    }
}

@end

NS_ASSUME_NONNULL_END
