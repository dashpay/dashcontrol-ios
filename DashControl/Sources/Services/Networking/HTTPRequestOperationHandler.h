//
//  HTTPRequestOperationHandler.h
//
//  Created by Andrew Podkovyrin on 07/02/2018.
//  Copyright © 2018 Dash Foundation. All rights reserved.
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
