//
//  HTTPLoader.h
//
//  Created by Andrew Podkovyrin on 07/02/2018.
//  Copyright © 2018 Dash Foundation. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@protocol HTTPCancellationToken;
@protocol HTTPLoaderDelegate;
@class HTTPRequest;

@interface HTTPLoader : NSObject

@property (nullable, weak, nonatomic) id<HTTPLoaderDelegate> delegate;
@property (strong, nonatomic) dispatch_queue_t delegateQueue;
@property (readonly, copy, nonatomic) NSArray<HTTPRequest *> *currentRequests;

- (nullable id<HTTPCancellationToken>)performRequest:(HTTPRequest *)request;

- (void)cancelAllLoads;

- (instancetype)init NS_UNAVAILABLE;

@end

NS_ASSUME_NONNULL_END
