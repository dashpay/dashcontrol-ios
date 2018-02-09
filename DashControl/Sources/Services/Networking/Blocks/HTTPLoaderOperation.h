//
//  HTTPLoaderOperation.h
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

@interface HTTPLoaderOperation : NSObject <HTTPLoaderOperationProtocol>

- (instancetype)initWithHTTPRequest:(HTTPRequest *)httpRequest httpLoaderFactory:(HTTPLoaderFactory *)httpLoaderFactory NS_DESIGNATED_INITIALIZER;
- (instancetype)init NS_UNAVAILABLE;

- (void)performWithCompletion:(HTTPLoaderRawCompletionBlock)completion;

@end

NS_ASSUME_NONNULL_END
