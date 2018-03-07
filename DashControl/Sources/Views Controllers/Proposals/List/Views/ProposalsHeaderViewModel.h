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

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@class DCBudgetInfoEntity;

typedef NS_ENUM(NSUInteger, ProposalsSegmentIndex) {
    ProposalsSegmentIndex_Current,
    ProposalsSegmentIndex_Ongoing,
    ProposalsSegmentIndex_Past,
};

@interface ProposalsHeaderViewModel : NSObject

@property (readonly, copy, nonatomic) NSString *total;
@property (readonly, copy, nonatomic) NSString *alloted;
@property (readonly, copy, nonatomic) NSString *superblockPaymentInfo;

@property (assign, nonatomic) ProposalsSegmentIndex segmentIndex;

- (void)updateWithBudgetInfo:(nullable DCBudgetInfoEntity *)budgetInfo;

@end

NS_ASSUME_NONNULL_END
