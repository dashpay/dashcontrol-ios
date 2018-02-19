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

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@protocol DCSearchBarDelegate;

@interface DCSearchBar : UIView

@property (weak, nonatomic) id<DCSearchBarDelegate> delegate;
@property (nullable, copy, nonatomic) NSString *text;

- (void)showAnimatedCompletion:(void (^_Nullable)(void))completion;
- (void)hideAnimatedCompletion:(void (^_Nullable)(void))completion;

@end

@protocol DCSearchBarDelegate <NSObject>

- (void)searchBar:(DCSearchBar *)searchBar textDidChange:(NSString *)searchText;
- (void)searchBarSearchButtonClicked:(DCSearchBar *)searchBar;
- (void)searchBarCancelButtonClicked:(DCSearchBar *)searchBar;
- (void)searchBarDidBecomeFirstResponder:(DCSearchBar *)searchBar;

@end

NS_ASSUME_NONNULL_END