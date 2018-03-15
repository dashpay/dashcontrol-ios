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

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@class HTTPLoaderManager;
@class DCPersistenceStack;
@class DCBudgetProposalEntity;
@protocol HTTPLoaderOperationProtocol;

extern CGFloat const MASTERNODES_SUFFICIENT_VOTING_PERCENT;

@interface APIBudget : NSObject

@property (strong, nonatomic) InjectedClass(DCPersistenceStack) stack;
@property (strong, nonatomic) InjectedClass(HTTPLoaderManager) httpManager;

@property (class, readonly, nonatomic) NSInteger masternodesCount;

- (void)updateMasternodesCount;
- (id<HTTPLoaderOperationProtocol>)fetchActiveProposalsCompletion:(void (^)(BOOL success))completion;
- (id<HTTPLoaderOperationProtocol>)fetchProposalDetails:(DCBudgetProposalEntity *)entity completion:(void (^)(BOOL success))completion;

@end

NS_ASSUME_NONNULL_END
