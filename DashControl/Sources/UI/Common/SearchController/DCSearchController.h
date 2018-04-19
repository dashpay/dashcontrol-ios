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

#import "DCSearchBar.h"

NS_ASSUME_NONNULL_BEGIN

@protocol DCSearchControllerDelegate;
@protocol DCSearchResultsUpdating;

@interface DCSearchController : UIViewController

@property (readonly, strong, nonatomic) UIViewController *searchResultsController;
@property (nullable, weak, nonatomic) UIViewController<DCSearchControllerDelegate> *delegate;
@property (nullable, weak, nonatomic) id<DCSearchResultsUpdating> searchResultsUpdater;

@property (assign, nonatomic) BOOL active;

// don't touch searchBar's delegate :-P
@property (strong, nonatomic) DCSearchBar *searchBar;

@property (readonly, strong, nonatomic) UIView *searchAccessoryView;

- (instancetype)initWithController:(UIViewController *)searchResultsController NS_DESIGNATED_INITIALIZER;

- (instancetype)initWithNibName:(nullable NSString *)nibNameOrNil bundle:(nullable NSBundle *)nibBundleOrNil NS_UNAVAILABLE;
- (nullable instancetype)initWithCoder:(NSCoder *)aDecoder NS_UNAVAILABLE;

@end

@protocol DCSearchControllerDelegate <NSObject>

@optional
- (void)willPresentSearchController:(DCSearchController *)searchController;
- (void)didPresentSearchController:(DCSearchController *)searchController;
- (void)willDismissSearchController:(DCSearchController *)searchController;
- (void)didDismissSearchController:(DCSearchController *)searchController;

@end

@protocol DCSearchResultsUpdating <NSObject>

// Called when the search bar's text has changed or when the search bar becomes first responder.
- (void)updateSearchResultsForSearchController:(DCSearchController *)searchController;

@end

NS_ASSUME_NONNULL_END
