//
//  NSURL+Sugar.h
//  DashControl
//
//  Created by Sam Westrich on 10/27/17.
//  Copyright © 2017 dashfoundation. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSURL (Sugar)

-(NSURL*)URLByAppendingQueryParameters:(NSDictionary*)queryParameters;

@end
