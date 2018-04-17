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

#import "PortfolioMasternodeTableViewCellModel.h"

#import "DCMasternodeEntity+CoreDataClass.h"
#import "DCFormattingUtils.h"

NS_ASSUME_NONNULL_BEGIN

@implementation PortfolioMasternodeTableViewCellModel

@synthesize title = _title;
@synthesize subtitle = _subtitle;

- (instancetype)initWithEntity:(DCMasternodeEntity *)entity {
    self = [super init];
    if (self) {
        _title = entity.name ?: entity.address;
        double worthDash = entity.amount / (double)DUFFS;
        _subtitle = [DCFormattingUtils.dashNumberFormatter stringFromNumber:@(worthDash)];
    }
    return self;
}

- (SubtitleTableViewCellModelState)state {
    return SubtitleTableViewCellModelState_Ready;
}

@end

NS_ASSUME_NONNULL_END
