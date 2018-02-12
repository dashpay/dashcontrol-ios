//
//  HTTPLoaderManager.h
//  DashPriceViewer
//
//  Created by Andrew Podkovyrin on 08/02/2018.
//  Copyright © 2018 Andrew Podkovyrin. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "HTTPLoaderBlocks.h"
#import "HTTPLoaderOperationProtocol.h"

NS_ASSUME_NONNULL_BEGIN

@class HTTPRequest;
@class HTTPLoaderFactory;

@interface HTTPLoaderManager : NSObject

- (instancetype)initWithFactory:(HTTPLoaderFactory *)factory NS_DESIGNATED_INITIALIZER;
- (instancetype)init NS_UNAVAILABLE;

- (id<HTTPLoaderOperationProtocol>)sendRequest:(HTTPRequest *)httpRequest completion:(HTTPLoaderCompletionBlock)completion;
- (id<HTTPLoaderOperationProtocol>)sendRequest:(HTTPRequest *)httpRequest rawCompletion:(HTTPLoaderRawCompletionBlock)rawCompletion;

@end

NS_ASSUME_NONNULL_END
