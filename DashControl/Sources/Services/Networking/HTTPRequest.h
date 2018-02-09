//
//  HTTPRequest.h
//
//  Created by Andrew Podkovyrin on 07/02/2018.
//  Copyright © 2018 Dash Foundation. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSInteger, HTTPRequestMethod) {
    HTTPRequestMethod_GET,
    HTTPRequestMethod_POST,
    HTTPRequestMethod_PUT,
    HTTPRequestMethod_DELETE,
    HTTPRequestMethod_UPDATE,
    HTTPRequestMethod_HEAD,
};

typedef NS_ENUM(NSUInteger, HTTPContentType) {
    HTTPContentType_JSON,
    HTTPContentType_UrlEncoded,
};

typedef NS_ENUM(NSInteger, HTTPRequestErrorCode) {
    HTTPRequestErrorCode_Timeout,
    HTTPRequestErrorCode_ChunkedRequestWithoutChunkedDelegate
};

extern NSString *const HTTPRequestErrorDomain;

@interface HTTPRequest : NSObject <NSCopying>

@property (readonly, strong, nonatomic) NSURL *URL;
@property (readonly, assign, nonatomic) HTTPRequestMethod method;
@property (nullable, readonly, strong, nonatomic) NSData *body;
@property (nullable, readonly, strong, nonatomic) NSInputStream *bodyStream;
@property (readonly, copy, nonatomic) NSDictionary<NSString *, NSString *> *headers;
@property (nullable, readonly, copy, nonatomic) NSString *sourceIdentifier;
@property (readonly, assign, nonatomic) int64_t uniqueIdentifier;

@property (assign, nonatomic) BOOL chunks;
@property (assign, nonatomic) NSURLRequestCachePolicy cachePolicy;
@property (assign, nonatomic) BOOL skipNSURLCache;
@property (assign, nonatomic) NSTimeInterval timeout;
@property (assign, nonatomic) NSUInteger maximumRetryCount;
@property (copy, nonatomic) NSDictionary *userInfo;

- (instancetype)initWithURL:(NSURL *)URL
                     method:(HTTPRequestMethod)method
                contentType:(HTTPContentType)contentType
                 parameters:(nullable NSDictionary *)parameters
                       body:(nullable NSData *)body
           sourceIdentifier:(nullable NSString *)sourceIdentifier;
- (instancetype)initWithURL:(NSURL *)URL
                     method:(HTTPRequestMethod)method
                 parameters:(nullable NSDictionary *)parameters
                 bodyStream:(nullable NSInputStream *)bodyStream
           sourceIdentifier:(nullable NSString *)sourceIdentifier;
- (instancetype)init NS_UNAVAILABLE;

- (void)addValue:(NSString *)value forHeader:(NSString *)header;
- (void)removeHeader:(NSString *)header;

@end

NS_ASSUME_NONNULL_END
