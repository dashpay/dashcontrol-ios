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

#import <DashSync/DashSync.h>

#import "Pair.h"

NS_ASSUME_NONNULL_BEGIN

@class DCPersistenceStack;
@class DCBudgetProposalEntity;
@class DSChainPeerManager;
@class DSChain;

@interface ProposalDetailHeaderViewModel : NSObject

@property (strong, nonatomic) InjectedClass(DCPersistenceStack) stack;
@property (strong, nonatomic) InjectedClass(DSChainPeerManager) chainPeerManager;
@property (strong, nonatomic) InjectedClass(DSChain) chain;

@property (readonly, assign, nonatomic) CGFloat completedPercent;
@property (readonly, copy, nonatomic) NSString *title;
@property (readonly, copy, nonatomic) NSString *ownerUsername;

@property (readonly, copy, nonatomic) NSArray<Pair<NSString *> *> *rows;

@property (readonly, assign, nonatomic) BOOL voteAllowed;
@property (readonly, assign, nonatomic) DSGovernanceVoteOutcome voteOutcome;

- (void)updateWithProposal:(DCBudgetProposalEntity *)proposal;
- (void)voteOnProposalWithOutcome:(DSGovernanceVoteOutcome)voteOutcome;
- (BOOL)canVote;

@end

NS_ASSUME_NONNULL_END
