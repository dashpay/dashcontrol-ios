//
//  RunOnMain.h
//
//  Created by Andrew Podkovyrin on 06/12/2017.
//  Copyright © 2017. All rights reserved.
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

extern void RunOnMainThread(dispatch_block_t block);

#if __cplusplus
}
#endif /* __cplusplus */

NS_ASSUME_NONNULL_END
