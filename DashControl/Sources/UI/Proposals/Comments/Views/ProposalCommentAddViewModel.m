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

#import "ProposalCommentAddViewModel.h"

#import "APIBudgetPrivate.h"

NS_ASSUME_NONNULL_BEGIN

@interface ProposalCommentAddViewModel ()

@property (assign, nonatomic) ProposalCommentAddViewModelState state;

@end

@implementation ProposalCommentAddViewModel

- (instancetype)initWithProposalHash:(NSString *)proposalHash replyToCommentId:(NSString *)replyToCommentId {
    self = [self initWithProposalHash:proposalHash];
    if (self) {
        _replyToCommentId = replyToCommentId;
        _type = ProposalCommentAddViewModelType_Reply;
    }
    return self;
}

- (instancetype)initWithProposalHash:(NSString *)proposalHash {
    self = [super init];
    if (self) {
        _proposalHash = proposalHash;
    }
    return self;
}

- (BOOL)isCommentValid {
    NSString *trimmedString = [self.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    return trimmedString.length > 0;
}

- (void)send {
    self.state = ProposalCommentAddViewModelState_Sending;

    NSString *trimmedString = [self.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    weakify;
    [self.api postComment:trimmedString proposalHash:self.proposalHash replyToCommentId:self.replyToCommentId completion:^(BOOL success) {
        strongify;
        if (success) {
            [self reset];

            [self.uiUpdatesObserver proposalCommentAddViewModelDidAddComment:self];
            [self.mainUpdatesObserver proposalCommentAddViewModelDidAddComment:self];
        }
        else {
            self.state = ProposalCommentAddViewModelState_Error;
        }
    }];
}

#pragma mark Private

- (void)reset {
    self.text = nil;
    self.state = ProposalCommentAddViewModelState_None;
}

@end

NS_ASSUME_NONNULL_END
