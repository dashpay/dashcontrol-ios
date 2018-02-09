//
//  HTTPLoader+Private.h
//
//  Created by Andrew Podkovyrin on 07/02/2018.
//  Copyright © 2018 Dash Foundation. All rights reserved.
//

#import "HTTPLoader.h"

#import "HTTPRequestOperationHandler.h"

NS_ASSUME_NONNULL_BEGIN

@interface HTTPLoader (Private) <HTTPRequestOperationHandler>

- (instancetype)initWithRequestOperationHandlerDelegate:(id<HTTPRequestOperationHandlerDelegate>)requestOperationHandlerDelegate;

@end

NS_ASSUME_NONNULL_END
