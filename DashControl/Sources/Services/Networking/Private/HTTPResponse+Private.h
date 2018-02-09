//
//  HTTPResponse+Private.h
//
//  Created by Andrew Podkovyrin on 07/02/2018.
//  Copyright © 2018 Dash Foundation. All rights reserved.
//

#import "HTTPResponse.h"

NS_ASSUME_NONNULL_BEGIN

@class HTTPRequest;

@interface HTTPResponse (Private)

@property (nullable, strong, nonatomic) NSError *error;
@property (nullable, strong, nonatomic) NSData *body;
@property (assign, nonatomic) NSTimeInterval requestTime;

- (instancetype)initWithRequest:(HTTPRequest *)request response:(nullable NSURLResponse *)response;

- (BOOL)shouldRetry;

@end

NS_ASSUME_NONNULL_END
