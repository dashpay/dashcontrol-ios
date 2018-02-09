//
//  HTTPLoaderDelegate.h
//
//  Created by Andrew Podkovyrin on 07/02/2018.
//  Copyright © 2018 Dash Foundation. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@class HTTPLoader;
@class HTTPResponse;
@class HTTPRequest;

@protocol HTTPLoaderDelegate <NSObject>

- (void)httpLoader:(HTTPLoader *)httpLoader didReceiveSuccessfulResponse:(HTTPResponse *)response;
- (void)httpLoader:(HTTPLoader *)httpLoader didReceiveErrorResponse:(HTTPResponse *)response;

@optional

- (void)httpLoader:(HTTPLoader *)httpLoader didCancelRequest:(HTTPRequest *)request;
- (BOOL)httpLoaderShouldSupportChunks:(HTTPLoader *)httpLoader;
- (void)httpLoader:(HTTPLoader *)httpLoader didReceiveDataChunk:(NSData *)data forResponse:(HTTPResponse *)response;
- (void)httpLoader:(HTTPLoader *)httpLoader didReceiveInitialResponse:(HTTPResponse *)response;
- (void)httpLoader:(HTTPLoader *)httpLoader needsNewBodyStream:(void (^)(NSInputStream *))completionHandler forRequest:(HTTPRequest *)request;

@end

NS_ASSUME_NONNULL_END
