//
//  DCEnvironment.h
//  DashControl
//
//  Created by Sam Westrich on 10/26/17.
//  Copyright © 2017 dashfoundation. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DCEnvironment : NSObject

@property (nonatomic,copy,readonly,nonnull) NSString * deviceId;
@property (nonatomic,copy,readonly,nonnull) NSString * devicePassword;

+ (id _Nonnull )sharedInstance;

@end
