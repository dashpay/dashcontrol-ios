//
//  Created by Andrew Podkovyrin
//  Copyright © 2018 dashfoundation. All rights reserved.
//
//  Licensed under the MIT License (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//  https://opensource.org/licenses/MIT
//
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  See the License for the specific language governing permissions and
//  limitations under the License.
//

#import "Credentials.h"

#import "NSString+Sugar.h"

NS_ASSUME_NONNULL_BEGIN

static NSString * const DEVICE_ID = @"DEVICE_ID";
static NSString * const DEVICE_PASSWORD = @"DEVICE_PASSWORD";
static NSString * const DEVICE_HAS_REGISTERED = @"DEVICE_HAS_REGISTERED";

@implementation Credentials

+ (NSString *)deviceId {
    static NSString *deviceId = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        deviceId = [[NSUserDefaults standardUserDefaults] stringForKey:DEVICE_ID];
        if (!deviceId) {
            deviceId = [[NSUUID UUID] UUIDString];
            [[NSUserDefaults standardUserDefaults] setObject:deviceId forKey:DEVICE_ID];
        }
    });
    return deviceId;
}

+ (NSString *)devicePassword {
    static NSString *devicePassword = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        devicePassword = [[NSUserDefaults standardUserDefaults] stringForKey:DEVICE_PASSWORD];
        if (!devicePassword) {
            devicePassword = [NSString randomStringWithLength:12];
            [[NSUserDefaults standardUserDefaults] setObject:devicePassword forKey:DEVICE_PASSWORD];
        }
    });
    return devicePassword;
}

+ (BOOL)hasRegistered {
    return [[NSUserDefaults standardUserDefaults] boolForKey:DEVICE_HAS_REGISTERED];
}

+ (void)setHasRegistered:(BOOL)hasRegistered {
    [[NSUserDefaults standardUserDefaults] setBool:hasRegistered forKey:DEVICE_HAS_REGISTERED];
}

@end

NS_ASSUME_NONNULL_END
