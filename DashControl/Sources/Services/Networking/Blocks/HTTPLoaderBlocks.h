//
//  HTTPLoaderBlocks.h
//  DashPriceViewer
//
//  Created by Andrew Podkovyrin on 08/02/2018.
//  Copyright © 2018 Andrew Podkovyrin. All rights reserved.
//

#ifndef HTTPLoaderBlocks_h
#define HTTPLoaderBlocks_h

NS_ASSUME_NONNULL_BEGIN

@class HTTPResponse;

typedef void (^HTTPLoaderCompletionBlock)(id _Nullable parsedData, NSDictionary *_Nullable responseHeaders, NSInteger statusCode, NSError *_Nullable error);
typedef void (^HTTPLoaderRawCompletionBlock)(BOOL success, BOOL cancelled, HTTPResponse * _Nullable response);

NS_ASSUME_NONNULL_END

#endif /* HTTPLoaderBlocks_h */
