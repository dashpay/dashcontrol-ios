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

#import "ProposalsTopViewModel.h"

#import "DCBudgetInfoEntity+CoreDataClass.h"

NS_ASSUME_NONNULL_BEGIN

@interface ProposalsTopViewModel ()

@property (copy, nonatomic) NSString *total;
@property (copy, nonatomic) NSString *alloted;

@end

@implementation ProposalsTopViewModel

- (instancetype)init {
    self = [super init];
    if (self) {
        _total = @"...";
        _alloted = @"...";
    }
    return self;
}

- (void)updateWithBudgetInfo:(nullable DCBudgetInfoEntity *)budgetInfo {
    if (budgetInfo) {
        self.total = [NSString stringWithFormat:@"%.1f", budgetInfo.totalAmount];
        self.alloted = [NSString stringWithFormat:@"%.1f", budgetInfo.allotedAmount];
    }
    else {
        self.total = @"...";
        self.alloted = @"...";
    }
}

@end

NS_ASSUME_NONNULL_END
