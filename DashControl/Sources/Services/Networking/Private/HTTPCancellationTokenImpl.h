//
//  HTTPCancellationTokenImpl.h
//
//  Created by Andrew Podkovyrin on 07/02/2018.
//  Copyright © 2018 Dash Foundation. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "HTTPCancellationToken.h"

NS_ASSUME_NONNULL_BEGIN

@interface HTTPCancellationTokenImpl : NSObject <HTTPCancellationToken>

- (instancetype)initWithDelegate:(id<HTTPCancellationTokenDelegate>)delegate cancelObject:(nullable id)cancelObject NS_DESIGNATED_INITIALIZER;
- (instancetype)init NS_UNAVAILABLE;

@end

NS_ASSUME_NONNULL_END
