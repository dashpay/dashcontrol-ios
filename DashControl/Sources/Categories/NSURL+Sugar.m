//
//  NSURL+Sugar.m
//  DashControl
//
//  Created by Sam Westrich on 10/27/17.
//  Copyright © 2017 dashfoundation. All rights reserved.
//

#import "NSURL+Sugar.h"
#import "NSString+Sugar.h"

@implementation NSURL (Sugar)

-(NSURL*)URLByAppendingQueryParameters:(NSDictionary*)queryParameters
{
    NSString* URLString = [NSString stringWithFormat:@"%@?%@",[self absoluteString],[NSString pathExtensionFromQueryParameters:queryParameters]];
    return [NSURL URLWithString:URLString];
}

@end
