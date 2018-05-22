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

#import "ProposalCommentAddTableViewCell.h"

#import "ProposalCommentAddView.h"
#import "ProposalCommentAddViewModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface ProposalCommentAddTableViewCell () <ProposalCommentAddViewDelegate, ProposalCommentAddViewModelUpdatesObserver>

@property (strong, nonatomic) IBOutlet ProposalCommentAddView *commentAddView;

@end

@implementation ProposalCommentAddTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];

    self.commentAddView.delegate = self;
}

- (void)setCommentAddViewModel:(ProposalCommentAddViewModel *)commentAddViewModel {
    _commentAddViewModel = commentAddViewModel;
    _commentAddViewModel.uiUpdatesObserver = self;

    self.commentAddView.viewModel = commentAddViewModel;
}

#pragma mark ProposalCommentAddViewDelegate

- (void)proposalCommentAddViewTextDidChange:(ProposalCommentAddView *)view {
    [self.delegate proposalCommentAddViewParentCell:self didUpdateHeightShouldScrollToCellAnimated:NO];
}

- (void)proposalCommentAddViewAddButtonAction:(ProposalCommentAddView *)view {
    if ([self.commentAddViewModel isCommentValid]) {
        [self.delegate proposalCommentAddViewParentCellAddCommentAction:self];
    }
    else {
        [self.commentAddView shakeTextView];
    }
}

#pragma mark ProposalCommentAddViewModelUpdatesObserver

- (void)proposalCommentAddViewModelDidAddComment:(ProposalCommentAddViewModel *)viewModel {
    [self exitAddCommentMode];
}

#pragma mark Private

- (void)exitAddCommentMode {
    [self.commentAddView resignFirstResponder];

    [self.delegate proposalCommentAddViewParentCell:self didUpdateHeightShouldScrollToCellAnimated:YES];
}

@end

NS_ASSUME_NONNULL_END
