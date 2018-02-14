//
//  Created by Andrew Podkovyrin on 18/03/16.
//  Copyright © 2016. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface HTTPURLRequestBuilder : NSObject

+ (nullable NSData *)jsonDataFromParameters:(nullable NSDictionary *)parameters;
+ (NSString *)queryStringFromParameters:(nullable NSDictionary *)parameters;
+ (NSString *)percentEscapedStringFromString:(NSString *)string;

- (instancetype)init NS_UNAVAILABLE;

@end

NS_ASSUME_NONNULL_END
