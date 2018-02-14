//
//  NSString+Sugar.h
//  DashControl
//
//  Created by Sam Westrich on 10/27/17.
//  Copyright © 2017 dashfoundation. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (Sugar)

+(NSString *)pathExtensionFromQueryParameters:(NSDictionary*)queryParameters;

+(NSString *)randomStringWithLength:(uint32_t)length;

@end
