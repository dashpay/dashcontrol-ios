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

#import "APIBaseAuthorized.h"

NS_ASSUME_NONNULL_BEGIN

@class DCPersistenceStack;
@class DCTrigger;

@interface APITrigger : APIBaseAuthorized

@property (strong, nonatomic) InjectedClass(DCPersistenceStack) stack;

- (void)performRegisterWithDeviceToken:(NSString *)deviceToken;
- (nullable id<HTTPLoaderOperationProtocol>)registerWithCompletion:(void (^_Nullable)(BOOL success))completion;

- (id<HTTPLoaderOperationProtocol>)getTriggersCompletion:(void (^)(BOOL success))completion;
- (id<HTTPLoaderOperationProtocol>)postTrigger:(DCTrigger *)trigger completion:(void (^)(NSError *_Nullable error))completion;
- (id<HTTPLoaderOperationProtocol>)deleteTriggerWithId:(u_int64_t)triggerId completion:(void (^_Nullable)(NSError *_Nullable error))completion;

@end

NS_ASSUME_NONNULL_END
