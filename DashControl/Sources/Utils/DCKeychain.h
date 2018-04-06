//
//  Created by Sam Westrich on 10/26/17.
//  Copyright © 2017 dashfoundation. All rights reserved.
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

#if __cplusplus
extern "C" {
#endif /* __cplusplus */

extern BOOL setKeychainData(NSData *_Nullable data, NSString *key, BOOL authenticated);
extern NSData *_Nullable getKeychainData(NSString *key, NSError *_Nullable *_Nullable error);

extern BOOL setKeychainInt(int64_t i, NSString *key, BOOL authenticated);
extern int64_t getKeychainInt(NSString *key, NSError *_Nullable *_Nullable error);

extern BOOL setKeychainBool(Boolean i, NSString *key, BOOL authenticated);
extern Boolean getKeychainBool(NSString *key, NSError *_Nullable *_Nullable error);

extern BOOL setKeychainString(NSString *_Nullable s, NSString *key, BOOL authenticated);
extern NSString *_Nullable getKeychainString(NSString *key, NSError *_Nullable *_Nullable error);

extern BOOL setKeychainDict(NSDictionary *_Nullable dict, NSString *key, BOOL authenticated);
extern NSDictionary *_Nullable getKeychainDict(NSString *key, NSError *_Nullable *_Nullable error);

#if __cplusplus
}
#endif /* __cplusplus */

NS_ASSUME_NONNULL_END
