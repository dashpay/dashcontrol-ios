//
//  HTTPRequestOperation.h
//
//  Created by Andrew Podkovyrin on 07/02/2018.
//  Copyright © 2018 Dash Foundation. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@class HTTPRequest;
@class HTTPRateLimiter;
@class HTTPResponse;
@protocol HTTPRequestOperationHandler;

@interface HTTPRequestOperation : NSObject

@property (atomic, strong) NSURLSessionTask *task;
@property (strong, nonatomic) HTTPRequest *request;
@property (readonly, assign, nonatomic, getter=isCancelled) BOOL cancelled;

- (instancetype)initWithTask:(NSURLSessionTask *)task
                     request:(HTTPRequest *)request
     requestOperationHandler:(id<HTTPRequestOperationHandler>)requestOperationHandler
                 rateLimiter:(nullable HTTPRateLimiter *)rateLimiter NS_DESIGNATED_INITIALIZER;

- (NSURLSessionResponseDisposition)receiveResponse:(NSURLResponse *)response;
- (void)receiveData:(NSData *)data;
- (nullable HTTPResponse *)completeWithError:(nullable NSError *)error;
- (BOOL)mayRedirect;
- (void)start;
- (void)provideNewBodyStreamWithCompletion:(void (^)(NSInputStream *_Nonnull))completionHandler;

- (instancetype)init NS_UNAVAILABLE;

@end

NS_ASSUME_NONNULL_END
