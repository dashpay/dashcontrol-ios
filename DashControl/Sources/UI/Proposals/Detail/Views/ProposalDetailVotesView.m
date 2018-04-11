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

#import "ProposalDetailVotesView.h"

#import "ProposalDetailVotesViewModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface ProposalDetailVotesView ()

@property (strong, nonatomic) IBOutlet UILabel *yesVotesTitleLabel;
@property (strong, nonatomic) IBOutlet UILabel *yesVotesLabel;
@property (strong, nonatomic) IBOutlet UILabel *noVotesTitleLabel;
@property (strong, nonatomic) IBOutlet UILabel *noVotesLabel;
@property (strong, nonatomic) IBOutlet UILabel *abstainTitleLabel;
@property (strong, nonatomic) IBOutlet UILabel *abstainLabel;

@end

@implementation ProposalDetailVotesView

- (void)awakeFromNib {
    [super awakeFromNib];

    self.yesVotesLabel.text = NSLocalizedString(@"Yes", @"Yes votes count title");
    self.noVotesLabel.text = NSLocalizedString(@"No", @"No votes count title");
    self.abstainLabel.text = NSLocalizedString(@"Abstain", @"Abstain votes count title");

    // KVO

    [self mvvm_observe:@"viewModel.yesVotes" with:^(typeof(self) self, NSString * value) {
        self.yesVotesLabel.text = value;
    }];

    [self mvvm_observe:@"viewModel.noVotes" with:^(typeof(self) self, NSString * value) {
        self.noVotesLabel.text = value;
    }];

    [self mvvm_observe:@"viewModel.abstainVotes" with:^(typeof(self) self, NSString * value) {
        self.abstainLabel.text = value;
    }];
}

@end

NS_ASSUME_NONNULL_END
