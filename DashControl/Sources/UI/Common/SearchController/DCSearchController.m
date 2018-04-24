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

#import "DCSearchController.h"

#import "UIColor+DCStyle.h"
#import "UIViewController+DCChildControllers.h"

NS_ASSUME_NONNULL_BEGIN

@interface DCSearchController () <DCSearchBarDelegate>

@property (strong, nonatomic) UIButton *dismissSearchControllerButton;
@property (strong, nonatomic) UIView *searchAccessoryView;

@end

@implementation DCSearchController

- (instancetype)initWithController:(UIViewController *)searchResultsController {
    self = [super initWithNibName:nil bundle:nil];
    if (self) {
        _searchResultsController = searchResultsController;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];

    [self.view addSubview:self.dismissSearchControllerButton];

    [self.view addSubview:self.searchAccessoryView];
    [self.searchAccessoryView.topAnchor constraintEqualToAnchor:self.view.topAnchor].active = YES;
    [self.searchAccessoryView.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor].active = YES;
    [self.searchAccessoryView.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor].active = YES;
    NSLayoutConstraint *heightContraint = [self.searchAccessoryView.heightAnchor constraintEqualToConstant:0.0];
    heightContraint.priority = UILayoutPriorityRequired - 100;
    heightContraint.active = YES;

    UIView *searchView = self.searchResultsController.view;
    [self addChildViewController:self.searchResultsController];
    searchView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:searchView];
    [searchView.topAnchor constraintEqualToAnchor:self.searchAccessoryView.bottomAnchor].active = YES;
    [searchView.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor].active = YES;
    [searchView.bottomAnchor constraintEqualToAnchor:self.view.bottomAnchor].active = YES;
    [searchView.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor].active = YES;
    [self.searchResultsController didMoveToParentViewController:self];
}

- (DCSearchBar *)searchBar {
    if (!_searchBar) {
        _searchBar = [[DCSearchBar alloc] initWithFrame:CGRectMake(0.0, 0.0, [UIScreen mainScreen].bounds.size.width, 44.0)];
        _searchBar.delegate = self;
    }
    return _searchBar;
}

- (UIButton *)dismissSearchControllerButton {
    if (!_dismissSearchControllerButton) {
        _dismissSearchControllerButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _dismissSearchControllerButton.frame = self.view.bounds;
        _dismissSearchControllerButton.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        _dismissSearchControllerButton.backgroundColor = [[UIColor dc_darkBlueColor] colorWithAlphaComponent:0.65];
        [_dismissSearchControllerButton addTarget:self
                                           action:@selector(dismissSearchControllerButtonAction:)
                                 forControlEvents:UIControlEventTouchUpInside];
    }
    return _dismissSearchControllerButton;
}

- (UIView *)searchAccessoryView {
    if (!_searchAccessoryView) {
        _searchAccessoryView = [[UIView alloc] initWithFrame:CGRectZero];
        _searchAccessoryView.translatesAutoresizingMaskIntoConstraints = NO;
    }
    return _searchAccessoryView;
}

- (void)setActive:(BOOL)active {
    if (_active == active) {
        return;
    }

    _active = active;

    if (active) {
        if ([self.delegate respondsToSelector:@selector(willPresentSearchController:)]) {
            [self.delegate willPresentSearchController:self];
        }

        [self updateSearchResultsControllerVisibility];

        [self.delegate dc_displayController:self];

        if ([self.delegate respondsToSelector:@selector(didPresentSearchController:)]) {
            [self.delegate didPresentSearchController:self];
        }
    }
    else {
        if ([self.delegate respondsToSelector:@selector(willDismissSearchController:)]) {
            [self.delegate willDismissSearchController:self];
        }

        [self.delegate dc_hideController:self];

        if ([self.delegate respondsToSelector:@selector(didDismissSearchController:)]) {
            [self.delegate didDismissSearchController:self];
        }
    }
}

#pragma mark DCSearchBarDelegate

- (void)searchBarDidBeginEditing:(DCSearchBar *)searchBar {
    self.active = YES;

    [self.searchResultsUpdater updateSearchResultsForSearchController:self];
}

- (void)searchBar:(DCSearchBar *)searchBar textDidChange:(NSString *)searchText {
    [self updateSearchResultsControllerVisibility];
    [self.searchResultsUpdater updateSearchResultsForSearchController:self];
}

- (void)searchBarSearchButtonClicked:(DCSearchBar *)searchBar {
    [searchBar resignFirstResponder];
}

- (void)searchBarCancelButtonClicked:(DCSearchBar *)searchBar {
    searchBar.text = nil;
    [searchBar resignFirstResponder];

    self.active = NO;

    [self.searchResultsUpdater updateSearchResultsForSearchController:self];
}

- (void)searchBarDidBecomeFirstResponder:(DCSearchBar *)searchBar {
    [self.searchResultsUpdater updateSearchResultsForSearchController:self];
}

#pragma mark Actions

- (void)dismissSearchControllerButtonAction:(UIButton *)sender {
    [self searchBarCancelButtonClicked:self.searchBar];
}

#pragma mark Private

- (void)updateSearchResultsControllerVisibility {
    BOOL visible = (self.searchBar.text.length > 0);
    self.searchResultsController.view.alpha = visible ? 1.0 : 0.0;
}

@end

NS_ASSUME_NONNULL_END
