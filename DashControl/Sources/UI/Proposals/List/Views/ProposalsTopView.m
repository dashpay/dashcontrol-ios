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

#import "ProposalsTopView.h"

#import "ProposalsTopViewModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface ProposalsTopView ()

@property (strong, nonatomic) IBOutlet UILabel *totalTitleLabel;
@property (strong, nonatomic) IBOutlet UILabel *allotedTitleLabel;
@property (strong, nonatomic) IBOutlet UILabel *totalLabel;
@property (strong, nonatomic) IBOutlet UILabel *allotedLabel;

@end

@implementation ProposalsTopView

- (void)awakeFromNib {
    [super awakeFromNib];

    self.totalTitleLabel.text = NSLocalizedString(@"Total", nil);
    self.allotedTitleLabel.text = NSLocalizedString(@"Alloted", nil);

    // KVO

    [self mvvm_observe:@"viewModel.total" with:^(typeof(self) self, NSString * value) {
        self.totalLabel.text = value;
    }];

    [self mvvm_observe:@"viewModel.alloted" with:^(typeof(self) self, NSString * value) {
        self.allotedLabel.text = value;
    }];
}

@end

NS_ASSUME_NONNULL_END
