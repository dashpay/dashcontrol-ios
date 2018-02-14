//
//  HTTPLoaderAuthoriser.h
//
//  Created by Andrew Podkovyrin on 07/02/2018.
//  Copyright © 2018 Dash Foundation. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@class HTTPRequest;

@protocol HTTPLoaderAuthoriser;

@protocol HTTPLoaderAuthoriserDelegate <NSObject>

- (void)httpLoaderAuthoriser:(id<HTTPLoaderAuthoriser>)httpLoaderAuthoriser authorisedRequest:(HTTPRequest *)request;
- (void)httpLoaderAuthoriser:(id<HTTPLoaderAuthoriser>)httpLoaderAuthoriser didFailToAuthoriseRequest:(HTTPRequest *)request withError:(NSError *)error;

@end

@protocol HTTPLoaderAuthoriser <NSObject, NSCopying>

@property (readonly, copy, nonatomic) NSString *identifier;
@property (nullable, weak, nonatomic) id<HTTPLoaderAuthoriserDelegate> delegate;

- (BOOL)requestRequiresAuthorisation:(HTTPRequest *)request;
- (void)authoriseRequest:(HTTPRequest *)request;
- (void)requestFailedAuthorisation:(HTTPRequest *)request;
- (void)refresh;

@end

NS_ASSUME_NONNULL_END
