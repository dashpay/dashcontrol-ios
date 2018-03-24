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

#import "PriceTriggerTableViewCellModel.h"

#import "DCMarketEntity+Extensions.h"
#import "DCTriggerEntity+CoreDataClass.h"
#import "DCTrigger.h"

NS_ASSUME_NONNULL_BEGIN

@implementation PriceTriggerTableViewCellModel

- (instancetype)initWithTrigger:(DCTriggerEntity *)trigger {
    self = [super init];
    if (self) {
        NSString *title = [NSString stringWithFormat:@"%@, ", trigger.market.name];
        switch (trigger.type) {
            case DCTriggerBelow: {
                title = [title stringByAppendingFormat:NSLocalizedString(@"Under %@", nil), @(trigger.value)];
                break;
            }
            case DCTriggerAbove: {
                title = [title stringByAppendingFormat:NSLocalizedString(@"Over %@", nil), @(trigger.value)];
                break;
            }
        }
        _title = title;
    }
    return self;
}

@end

NS_ASSUME_NONNULL_END
