//
//  HTTPLoaderFactory+Private.h
//
//  Created by Andrew Podkovyrin on 07/02/2018.
//  Copyright © 2018 Dash Foundation. All rights reserved.
//

#import "HTTPLoaderFactory.h"

#import "HTTPRequestOperationHandler.h"

NS_ASSUME_NONNULL_BEGIN

@protocol HTTPRequestOperationHandlerDelegate;
@protocol HTTPLoaderAuthoriser;

@interface HTTPLoaderFactory (Private) <HTTPRequestOperationHandler>

- (instancetype)initWithRequestOperationHandlerDelegate:(nullable id<HTTPRequestOperationHandlerDelegate>)requestOperationHandlerDelegate
                                            authorisers:(nullable NSArray<id<HTTPLoaderAuthoriser>> *)authorisers;

@end

NS_ASSUME_NONNULL_END
