//
//  HTTPLoaderFactory.h
//
//  Created by Andrew Podkovyrin on 07/02/2018.
//  Copyright © 2018 Dash Foundation. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@class HTTPLoader;
@protocol HTTPLoaderAuthoriser;

@interface HTTPLoaderFactory : NSObject

@property (assign, nonatomic, getter=isOffline) BOOL offline;
@property (nullable, readonly, copy, nonatomic) NSArray<id<HTTPLoaderAuthoriser>> *authorisers;

- (HTTPLoader *)createHTTPLoader;

- (instancetype)init NS_UNAVAILABLE;

@end

NS_ASSUME_NONNULL_END
