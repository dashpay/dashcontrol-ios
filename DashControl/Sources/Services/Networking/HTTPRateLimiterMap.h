//
//  HTTPRateLimiterMap.h
//
//  Created by Andrew Podkovyrin on 05/01/2018.
//  Copyright © 2018 Andrew Podkovyrin. All rights reserved.
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

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@class HTTPRateLimiter;

@interface HTTPRateLimiterMap : NSObject

- (void)setRateLimiter:(HTTPRateLimiter *)rateLimiter forURL:(NSURL *)URL;
- (nullable HTTPRateLimiter *)rateLimiterForURL:(NSURL *)URL;
- (void)removeRateLimiterForURL:(NSURL *)URL;

@end

NS_ASSUME_NONNULL_END
