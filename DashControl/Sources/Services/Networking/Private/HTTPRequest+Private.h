//
//  HTTPRequest+Private.h
//
//  Created by Andrew Podkovyrin on 07/02/2018.
//  Copyright © 2018 Dash Foundation. All rights reserved.
//

#import "HTTPRequest.h"

NS_ASSUME_NONNULL_BEGIN

@protocol HTTPCancellationToken;

@interface HTTPRequest (Private)

@property (readonly, strong, nonatomic) NSURLRequest *urlRequest;
@property (assign, nonatomic) BOOL retriedAuthorisation;
@property (weak, nonatomic) id<HTTPCancellationToken> cancellationToken;

@end

NS_ASSUME_NONNULL_END
