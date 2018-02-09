//
//  HTTPResponse.m
//
//  Created by Andrew Podkovyrin on 07/02/2018.
//  Copyright © 2018 Dash Foundation. All rights reserved.
//

#import "HTTPResponse.h"

#import "HTTPResponse+Private.h"

NS_ASSUME_NONNULL_BEGIN

NSString *const HTTPResponseErrorDomain = @"dash.httpresponse.error";

static NSString *const HTTPResponseHeaderRetryAfter = @"Retry-After";

@interface HTTPResponse ()

@property (nullable, readonly, strong, nonatomic) NSURLResponse *response;
@property (copy, nonatomic) NSDictionary<NSString *, NSString *> *responseHeaders;
@property (strong, nonatomic) NSError *error;
@property (strong, nonatomic) NSData *body;
@property (assign, nonatomic) NSTimeInterval requestTime;

@end

@implementation HTTPResponse

#pragma mark Private

- (instancetype)initWithRequest:(HTTPRequest *)request response:(nullable NSURLResponse *)response {
    self = [super init];
    if (self) {
        _request = request;
        _response = response;

        if ([response isKindOfClass:[NSHTTPURLResponse class]]) {
            NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)response;
            if (httpResponse.statusCode >= 300 || httpResponse.statusCode <= 101) {
                _error = [NSError errorWithDomain:HTTPResponseErrorDomain
                                             code:httpResponse.statusCode
                                         userInfo:nil];
            }
            _responseHeaders = httpResponse.allHeaderFields;
            _statusCode = httpResponse.statusCode;
        }

        _retryAfter = [self retryAfterForHeaders:_responseHeaders];
    }

    return self;
}

- (BOOL)shouldRetry {
    if ([self.error.domain isEqualToString:HTTPResponseErrorDomain]) {
        switch (self.error.code) {
            case HTTPResponseStatusCode_Invalid:
            case HTTPResponseStatusCode_Continue:
            case HTTPResponseStatusCode_SwitchProtocols:
            case HTTPResponseStatusCode_OK:
            case HTTPResponseStatusCode_Created:
            case HTTPResponseStatusCode_Accepted:
            case HTTPResponseStatusCode_NonAuthoritiveInformation:
            case HTTPResponseStatusCode_NoContent:
            case HTTPResponseStatusCode_ResetContent:
            case HTTPResponseStatusCode_PartialContent:
            case HTTPResponseStatusCode_MovedMultipleChoices:
            case HTTPResponseStatusCode_MovedPermanently:
            case HTTPResponseStatusCode_Found:
            case HTTPResponseStatusCode_SeeOther:
            case HTTPResponseStatusCode_NotModified:
            case HTTPResponseStatusCode_UseProxy:
            case HTTPResponseStatusCode_Unused:
            case HTTPResponseStatusCode_TemporaryRedirect:
            case HTTPResponseStatusCode_BadRequest:
            case HTTPResponseStatusCode_Unauthorised:
            case HTTPResponseStatusCode_PaymentRequired:
            case HTTPResponseStatusCode_Forbidden:
            case HTTPResponseStatusCode_MethodNotAllowed:
            case HTTPResponseStatusCode_NotAcceptable:
            case HTTPResponseStatusCode_ProxyAuthenticationRequired:
            case HTTPResponseStatusCode_Conflict:
            case HTTPResponseStatusCode_Gone:
            case HTTPResponseStatusCode_LengthRequired: // We always include the content-length header
            case HTTPResponseStatusCode_PreconditionFailed:
            case HTTPResponseStatusCode_RequestEntityTooLarge:
            case HTTPResponseStatusCode_RequestURITooLong:
            case HTTPResponseStatusCode_RequestRangeUnsatisifiable:
            case HTTPResponseStatusCode_ExpectationFail:
            case HTTPResponseStatusCode_HTTPVersionNotSupported:
            case HTTPResponseStatusCode_NotImplemented:
                return NO;
            case HTTPResponseStatusCode_NotFound:
            case HTTPResponseStatusCode_RequestTimeout:
            case HTTPResponseStatusCode_UnsupportedMediaTypes:
            case HTTPResponseStatusCode_InternalServerError:
            case HTTPResponseStatusCode_BadGateway:
            case HTTPResponseStatusCode_ServiceUnavailable:
            case HTTPResponseStatusCode_GatewayTimeout:
                return YES;
        }
    }

    if ([self.error.domain isEqualToString:NSURLErrorDomain]) {
        switch (self.error.code) {
            case NSURLErrorCancelled:
            case NSURLErrorUnknown:
            case NSURLErrorBadURL:
            case NSURLErrorUnsupportedURL:
            case NSURLErrorZeroByteResource:
            case NSURLErrorCannotDecodeRawData:
            case NSURLErrorCannotDecodeContentData:
            case NSURLErrorCannotParseResponse:
            case NSURLErrorFileDoesNotExist:
            case NSURLErrorNoPermissionsToReadFile:
            case NSURLErrorDataLengthExceedsMaximum:
            case NSURLErrorRedirectToNonExistentLocation:
            case NSURLErrorBadServerResponse:
            case NSURLErrorUserCancelledAuthentication:
            case NSURLErrorUserAuthenticationRequired:
            case NSURLErrorServerCertificateHasBadDate:
            case NSURLErrorServerCertificateUntrusted:
            case NSURLErrorServerCertificateHasUnknownRoot:
            case NSURLErrorServerCertificateNotYetValid:
            case NSURLErrorClientCertificateRejected:
            case NSURLErrorClientCertificateRequired:
                return NO;
            case NSURLErrorTimedOut:
            case NSURLErrorCannotFindHost:
            case NSURLErrorCannotConnectToHost:
            case NSURLErrorNetworkConnectionLost:
            case NSURLErrorDNSLookupFailed:
            case NSURLErrorHTTPTooManyRedirects:
            case NSURLErrorResourceUnavailable:
            case NSURLErrorNotConnectedToInternet:
            case NSURLErrorSecureConnectionFailed:
            case NSURLErrorCannotLoadFromNetwork:
                return YES;
        }
    }

    return NO;
}

- (nullable NSDate *)retryAfterForHeaders:(NSDictionary<NSString *, NSString *> *)headers {
    static NSDateFormatter *httpDateFormatter;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        httpDateFormatter = [[NSDateFormatter alloc] init];
        [httpDateFormatter setDateFormat:@"EEE, dd MMM yyyy HH:mm:ss zzz"];
    });

    NSTimeInterval retryAfterSeconds = [headers[HTTPResponseHeaderRetryAfter] doubleValue];
    if (retryAfterSeconds != 0.0) {
        return [NSDate dateWithTimeIntervalSinceNow:retryAfterSeconds];
    }

    NSString *retryAfterValue = headers[HTTPResponseHeaderRetryAfter];
    return [httpDateFormatter dateFromString:retryAfterValue];
}

- (NSString *)description {
    return [NSString stringWithFormat:@"<%@: %p URL = \"%@\"; status-code = %ld; headers = %@>", self.class, (void *)self, self.response.URL, (long)self.statusCode, self.responseHeaders];
}

@end

NS_ASSUME_NONNULL_END
