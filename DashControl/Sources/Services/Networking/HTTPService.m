//
//  HTTPService.m
//
//  Created by Andrew Podkovyrin on 07/02/2018.
//
//  Copyright (c) 2015-2018 Spotify AB.
//
//  Licensed to the Apache Software Foundation (ASF) under one
//  or more contributor license agreements.  See the NOTICE file
//  distributed with this work for additional information
//  regarding copyright ownership.  The ASF licenses this file
//  to you under the Apache License, Version 2.0 (the
//  "License"); you may not use this file except in compliance
//  with the License.  You may obtain a copy of the License at
//
//  http://www.apache.org/licenses/LICENSE-2.0
//
//  Unless required by applicable law or agreed to in writing,
//  software distributed under the License is distributed on an
//  "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
//  KIND, either express or implied.  See the License for the
//  specific language governing permissions and limitations
//  under the License.
//

#import "HTTPService.h"

#import "HTTPCancellationToken.h"
#import "HTTPRateLimiterMap.h"

#import "HTTPLoaderFactory+Private.h"
#import "HTTPRequest+Private.h"
#import "HTTPResponse+Private.h"
#import "HTTPRequestOperation.h"
#import "HTTPRequestOperationHandler.h"

NS_ASSUME_NONNULL_BEGIN

@interface HTTPService () <HTTPRequestOperationHandlerDelegate, NSURLSessionDataDelegate, NSURLSessionTaskDelegate>

@property (strong, nonatomic) NSURLSession *session;
@property (strong, nonatomic) NSOperationQueue *sessionQueue;
@property (strong, nonatomic) NSMutableArray<HTTPRequestOperation *> *operations;

@end

@implementation HTTPService

- (instancetype)initWithConfiguration:(NSURLSessionConfiguration *)configuration {
    const NSUInteger HTTPServiceMaxConcurrentOperations = 32;

    self = [super init];
    if (self) {
        _rateLimiterMap = [[HTTPRateLimiterMap alloc] init];
        _sessionQueue = [[NSOperationQueue alloc] init];
        _sessionQueue.maxConcurrentOperationCount = HTTPServiceMaxConcurrentOperations;
        _sessionQueue.name = NSStringFromClass(self.class);
        _session = [NSURLSession sessionWithConfiguration:configuration delegate:self delegateQueue:_sessionQueue];
        _operations = [[NSMutableArray alloc] init];
    }

    return self;
}

- (void)dealloc {
    [self cancelAllLoads];
}

- (HTTPLoaderFactory *)createHTTPLoaderFactoryWithAuthorisers:(nullable NSArray<id<HTTPLoaderAuthoriser>> *)authorisers {
    return [[HTTPLoaderFactory alloc] initWithRequestOperationHandlerDelegate:self authorisers:authorisers];
}

#pragma mark HTTPRequestOperationHandlerDelegate

- (void)requestOperationHandler:(id<HTTPRequestOperationHandler>)requestOperationHandler performRequest:(HTTPRequest *)request {
    if ([requestOperationHandler respondsToSelector:@selector(shouldAuthoriseRequest:)]) {
        if ([requestOperationHandler shouldAuthoriseRequest:request]) {
            if ([requestOperationHandler respondsToSelector:@selector(authoriseRequest:)]) {
                [requestOperationHandler authoriseRequest:request];
                return;
            }
        }
    }

    [self performRequest:request requestOperationHandler:requestOperationHandler];
}

- (void)requestOperationHandler:(id<HTTPRequestOperationHandler>)requestOperationHandler cancelRequest:(HTTPRequest *)request {
    NSArray *operations = nil;
    @synchronized(self.operations) {
        operations = [self.operations copy];
    }
    for (HTTPRequestOperation *operation in operations) {
        if ([operation.request isEqual:request]) {
            [operation.task cancel];
            break;
        }
    }
}

- (void)requestOperationHandler:(id<HTTPRequestOperationHandler>)requestOperationHandler authorisedRequest:(HTTPRequest *)request {
    [self performRequest:request requestOperationHandler:requestOperationHandler];
}

- (void)requestOperationHandler:(id<HTTPRequestOperationHandler>)requestOperationHandler failedToAuthoriseRequest:(HTTPRequest *)request error:(NSError *)error {
    HTTPResponse *response = [[HTTPResponse alloc] initWithRequest:request response:nil];
    response.error = error;
    [requestOperationHandler failedResponse:response];
}

#pragma mark NSURLSessionDataDelegate

- (void)URLSession:(NSURLSession *)session
          dataTask:(NSURLSessionDataTask *)dataTask
    didReceiveResponse:(NSURLResponse *)response
     completionHandler:(void (^)(NSURLSessionResponseDisposition disposition))completionHandler {
    HTTPRequestOperation *operation = [self handlerForTask:dataTask];
    if (completionHandler) {
        completionHandler([operation receiveResponse:response]);
    }
}

- (void)URLSession:(NSURLSession *)session
          dataTask:(NSURLSessionDataTask *)dataTask
    didReceiveData:(NSData *)data {
    HTTPRequestOperation *operation = [self handlerForTask:dataTask];
    [operation receiveData:data];
}

- (void)URLSession:(NSURLSession *)session
          dataTask:(NSURLSessionDataTask *)dataTask
 willCacheResponse:(NSCachedURLResponse *)proposedResponse
 completionHandler:(void (^)(NSCachedURLResponse *cachedResponse))completionHandler {
    if (!completionHandler) {
        return;
    }
    HTTPRequestOperation *operation = [self handlerForTask:dataTask];
    completionHandler(operation.request.skipNSURLCache ? nil : proposedResponse);
}

- (void)URLSession:(NSURLSession *)session
                   task:(NSURLSessionTask *)task
    didReceiveChallenge:(NSURLAuthenticationChallenge *)challenge
      completionHandler:(void (^)(NSURLSessionAuthChallengeDisposition disposition, NSURLCredential *__nullable credential))completionHandler {
    if (!completionHandler) {
        return;
    }

    NSURLSessionAuthChallengeDisposition disposition = NSURLSessionAuthChallengePerformDefaultHandling;
    NSURLCredential *credential = nil;

    if (self.allCertificatesAllowed) {
        disposition = NSURLSessionAuthChallengeUseCredential;
        SecTrustRef trust = challenge.protectionSpace.serverTrust;
        credential = [NSURLCredential credentialForTrust:trust];
    }

    completionHandler(disposition, credential);
}

#pragma mark NSURLSessionTaskDelegate

- (void)URLSession:(NSURLSession *)session
                    task:(NSURLSessionTask *)task
    didCompleteWithError:(nullable NSError *)error {
    HTTPRequestOperation *operation = [self handlerForTask:task];
    if (operation == nil) {
        return;
    }
    operation.task = [self.session dataTaskWithRequest:operation.request.urlRequest];
    HTTPResponse *response = [operation completeWithError:error];
    if (response == nil && !operation.cancelled) {
        return;
    }

    @synchronized(self.operations) {
        [self.operations removeObject:operation];
    }
}

- (void)URLSession:(NSURLSession *)session
              task:(NSURLSessionTask *)task
 needNewBodyStream:(void (^)(NSInputStream *_Nullable))completionHandler {
    HTTPRequestOperation *operation = [self handlerForTask:task];
    [operation provideNewBodyStreamWithCompletion:completionHandler];
}

#pragma mark Private

- (nullable HTTPRequestOperation *)handlerForTask:(NSURLSessionTask *)task {
    NSArray *operations = nil;
    @synchronized(self.operations) {
        operations = [self.operations copy];
    }
    for (HTTPRequestOperation *operation in operations) {
        if ([operation.task isEqual:task]) {
            return operation;
        }
    }
    return nil;
}

- (void)performRequest:(HTTPRequest *)request requestOperationHandler:(id<HTTPRequestOperationHandler>)requestOperationHandler {
    if (request.cancellationToken.cancelled) {
        return;
    }

    if (request.URL.host == nil) {
        return;
    }

    NSURLRequest *urlRequest = request.urlRequest;
    HTTPRateLimiter *rateLimiter = [self.rateLimiterMap rateLimiterForURL:request.URL];
    NSURLSessionTask *task = [self.session dataTaskWithRequest:urlRequest];
    HTTPRequestOperation *operation = [[HTTPRequestOperation alloc] initWithTask:task
                                                                         request:request
                                                         requestOperationHandler:requestOperationHandler
                                                                     rateLimiter:rateLimiter];
    @synchronized(self.operations) {
        [self.operations addObject:operation];
    }
    [operation start];
}

- (void)cancelAllLoads {
    NSArray *operations = nil;
    @synchronized(self.operations) {
        operations = [self.operations copy];
    }
    for (HTTPRequestOperation *operation in operations) {
        [operation.task cancel];
    }
}

@end

NS_ASSUME_NONNULL_END
