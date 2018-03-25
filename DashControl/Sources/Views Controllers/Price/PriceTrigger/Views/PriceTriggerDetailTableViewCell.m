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

#import "PriceTriggerDetailTableViewCell.h"

NS_ASSUME_NONNULL_BEGIN

@interface PriceTriggerDetailTableViewCell ()

@property (strong, nonatomic) IBOutlet UILabel *titleLabel;
@property (strong, nonatomic) IBOutlet UILabel *detailLabel;


@end

@implementation PriceTriggerDetailTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    
    [self mvvm_observe:@"detail.title" with:^(typeof(self) self, NSString *value){
        self.titleLabel.text = value;
    }];
    
    [self mvvm_observe:@"detail.detail" with:^(typeof(self) self, NSString *value){
        self.detailLabel.text = value;
    }];
}

- (void)setHighlighted:(BOOL)highlighted animated:(BOOL)animated {
    [super setHighlighted:highlighted animated:animated];
    
    [UIView animateWithDuration:0.25 animations:^{
        self.contentView.alpha = highlighted ? 0.65 : 1.0;
    }];
}

@end

NS_ASSUME_NONNULL_END
