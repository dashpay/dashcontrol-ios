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

@class APIBudgetPrivate;
@class ProposalCommentAddViewModel;

typedef NS_ENUM(NSUInteger, ProposalCommentAddViewModelType) {
    ProposalCommentAddViewModelTypeComment,
    ProposalCommentAddViewModelTypeReply,
};

typedef NS_ENUM(NSUInteger, ProposalCommentAddViewModelState) {
    ProposalCommentAddViewModelStateNone,
    ProposalCommentAddViewModelStateSending,
    ProposalCommentAddViewModelStateError,
};

@protocol ProposalCommentAddViewModelUpdatesObserver <NSObject>

- (void)proposalCommentAddViewModelDidAddComment:(ProposalCommentAddViewModel *)viewModel;

@end

@interface ProposalCommentAddViewModel : NSObject

@property (strong, nonatomic) InjectedClass(APIBudgetPrivate) api;

@property (readonly, assign, nonatomic) ProposalCommentAddViewModelType type;
@property (readonly, assign, nonatomic) ProposalCommentAddViewModelState state;
@property (readonly, copy, nonatomic) NSString *proposalHash;
@property (nullable, readonly, copy, nonatomic) NSString *replyToCommentId;
@property (assign, nonatomic) BOOL visible;
@property (nullable, copy, nonatomic) NSString *text;

@property (nullable, weak, nonatomic) id<ProposalCommentAddViewModelUpdatesObserver> mainUpdatesObserver;
@property (nullable, weak, nonatomic) id<ProposalCommentAddViewModelUpdatesObserver> uiUpdatesObserver;

- (instancetype)initWithProposalHash:(NSString *)proposalHash replyToCommentId:(NSString *)replyToCommentId;
- (instancetype)initWithProposalHash:(NSString *)proposalHash;
- (instancetype)init NS_UNAVAILABLE;

- (BOOL)isCommentValid;
- (void)send;

@end

NS_ASSUME_NONNULL_END
