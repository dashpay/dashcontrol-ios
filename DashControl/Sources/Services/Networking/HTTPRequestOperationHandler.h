//
//  HTTPRequestOperationHandler.h
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

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@class HTTPRequest;
@class HTTPResponse;

@protocol HTTPCancellationToken;
@protocol HTTPRequestOperationHandler;

@protocol HTTPRequestOperationHandlerDelegate <NSObject>

- (void)requestOperationHandler:(id<HTTPRequestOperationHandler>)requestOperationHandler performRequest:(HTTPRequest *)request;
- (void)requestOperationHandler:(id<HTTPRequestOperationHandler>)requestOperationHandler cancelRequest:(HTTPRequest *)request;

@optional

- (void)requestOperationHandler:(id<HTTPRequestOperationHandler>)requestOperationHandler authorisedRequest:(HTTPRequest *)request;
- (void)requestOperationHandler:(id<HTTPRequestOperationHandler>)requestOperationHandler failedToAuthoriseRequest:(HTTPRequest *)request error:(NSError *)error;

@end

@protocol HTTPRequestOperationHandler <NSObject>

@property (nullable, readonly, weak, nonatomic) id<HTTPRequestOperationHandlerDelegate> requestOperationHandlerDelegate;

- (void)successfulResponse:(HTTPResponse *)response;
- (void)failedResponse:(HTTPResponse *)response;
- (void)cancelledRequest:(HTTPRequest *)request;
- (void)receivedDataChunk:(NSData *)data forResponse:(HTTPResponse *)response;
- (void)receivedInitialResponse:(HTTPResponse *)response;
- (void)needsNewBodyStream:(void (^)(NSInputStream *))completionHandler forRequest:(HTTPRequest *)request;

@optional

- (BOOL)shouldAuthoriseRequest:(HTTPRequest *)request;
- (void)authoriseRequest:(HTTPRequest *)request;

@end

NS_ASSUME_NONNULL_END
