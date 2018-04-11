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

#import <KVO-MVVM/KVOUITableViewCell.h>

NS_ASSUME_NONNULL_BEGIN

@class ProposalDetailTableViewCell;

@protocol ProposalDetailTableViewCellDelegate <NSObject>

- (void)proposalDetailTableViewCell:(ProposalDetailTableViewCell *)cell didUpdateHeight:(CGFloat)height;
- (void)proposalDetailTableViewCell:(ProposalDetailTableViewCell *)cell openURL:(NSURL *)url;

@end

@class ProposalDetailTableViewCellModel;

@interface ProposalDetailTableViewCell : KVOUITableViewCell

@property (weak, nonatomic) id<ProposalDetailTableViewCellDelegate> delegate;
@property (nullable, strong, nonatomic) ProposalDetailTableViewCellModel *viewModel;

/**
 Workaround for iOS 10
 @discussion https://stackoverflow.com/questions/39549103/wkwebview-not-rendering-correctly-in-ios-10
 */
- (void)performSetNeedLayoutOnWebView;

@end

NS_ASSUME_NONNULL_END
