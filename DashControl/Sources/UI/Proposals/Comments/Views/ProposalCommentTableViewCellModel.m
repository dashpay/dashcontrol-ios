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

#import "ProposalCommentTableViewCellModel.h"

#import "DCBudgetProposalCommentEntity+CoreDataClass.h"
#import "NSDate+DCAdditions.h"

NS_ASSUME_NONNULL_BEGIN

@implementation ProposalCommentTableViewCellModel

- (instancetype)initWithCommentEntity:(DCBudgetProposalCommentEntity *)entity
                               parent:(nullable DCBudgetProposalCommentEntity *)parentEntity {
    self = [super init];
    if (self) {
        _username = entity.username;
        _postedByOwner = entity.postedByOwner;
        _repliedToUsername = parentEntity.username;
        _repliedToIsOwner = parentEntity.postedByOwner;
        _date = [entity.date dc_asDateAgoString];
        _comment = entity.content;
        _shouldIndent = (entity.level > 0);
    }
    return self;
}

@end

NS_ASSUME_NONNULL_END
