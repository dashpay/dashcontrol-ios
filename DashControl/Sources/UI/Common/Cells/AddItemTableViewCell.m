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

#import "AddItemTableViewCell.h"

NS_ASSUME_NONNULL_BEGIN

@interface AddItemTableViewCell ()

@property (strong, nonatomic) IBOutlet UILabel *titleLabel;
@property (strong, nonatomic) IBOutlet UILabel *addLabel;

@end

@implementation AddItemTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    
    self.addLabel.text = NSLocalizedString(@"ADD", nil);
}

- (void)setHighlighted:(BOOL)highlighted animated:(BOOL)animated {
    [super setHighlighted:highlighted animated:animated];
    
    [UIView animateWithDuration:0.25 animations:^{
        self.contentView.alpha = highlighted ? 0.65 : 1.0;
    }];
}

- (nullable NSString *)titleText {
    return self.titleLabel.text;
}

- (void)setTitleText:(nullable NSString *)titleText {
    self.titleLabel.text = titleText;
}

@end

NS_ASSUME_NONNULL_END
