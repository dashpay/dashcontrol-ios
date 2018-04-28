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

#import <UIViewController-KeyboardAdditions/UIViewController+KeyboardAdditions.h>

#import "UIColor+DCStyle.h"
#import "UIViewController+DCChildControllers.h"

NS_ASSUME_NONNULL_BEGIN

@interface DCSearchController () <DCSearchBarDelegate>

@property (strong, nonatomic) UIButton *dismissSearchControllerButton;
@property (strong, nonatomic) UIView *searchAccessoryView;
@property (assign, nonatomic) BOOL didPresentSearchControllerNotified;

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
        self.didPresentSearchControllerNotified = NO;
        [self hideSearchControllerViews];

        [self ka_startObservingKeyboardNotifications];

        if ([self.delegate respondsToSelector:@selector(willPresentSearchController:)]) {
            [self.delegate willPresentSearchController:self];
        }

        [self.delegate dc_displayController:self];

        [self.searchBar becomeFirstResponder];
    }
    else {
        BOOL keyboardWasActive = self.searchBar.isFirstResponder;

        if ([self.delegate respondsToSelector:@selector(willDismissSearchController:)]) {
            [self.delegate willDismissSearchController:self];
        }

        if (!keyboardWasActive) {
            [UIView animateWithDuration:0.25 animations:^{
                [self hideSearchControllerViews];
            }
                completion:^(BOOL finished) {
                    [self completeSearchControllerDismiss];
                }];
        }
    }
}

#pragma mark Keyboard

- (void)ka_keyboardShowOrHideAnimationWithHeight:(CGFloat)height
                               animationDuration:(NSTimeInterval)animationDuration
                                  animationCurve:(UIViewAnimationCurve)animationCurve {
    if (self.active) {
        if (height > 0.0 || self.searchBar.isFirstResponder) {
            self.dismissSearchControllerButton.alpha = 1.0;
        }
    }
    else {
        [self hideSearchControllerViews];
    }
}

- (void)ka_keyboardShowOrHideAnimationDidFinishedWithHeight:(CGFloat)height {
    if (self.active) {
        if (height > 0) {
            if (!self.didPresentSearchControllerNotified) {
                self.didPresentSearchControllerNotified = YES;

                if ([self.delegate respondsToSelector:@selector(didPresentSearchController:)]) {
                    [self.delegate didPresentSearchController:self];
                }
            }
        }
        else {
            // keyboard just hide
        }
    }
    else {
        if (height == 0) {
            [self completeSearchControllerDismiss];
        }
        else {
            NSAssert(NO, @"Inconsistent state: search controller inactive but keyboard was shown");
        }
    }
}

#pragma mark DCSearchBarDelegate

- (void)searchBarDidBeginEditing:(DCSearchBar *)searchBar {
    self.active = YES;

    [self.searchResultsUpdater updateSearchResultsForSearchController:self];
}

- (void)searchBar:(DCSearchBar *)searchBar textDidChange:(NSString *)searchText {
    CGFloat alpha = (self.searchBar.text.length > 0) ? 1.0 : 0.0;
    self.searchResultsController.view.alpha = alpha;
    self.searchAccessoryView.alpha = alpha;

    [self.searchResultsUpdater updateSearchResultsForSearchController:self];
}

- (void)searchBarSearchButtonClicked:(DCSearchBar *)searchBar {
    [searchBar resignFirstResponder];
}

- (void)searchBarCancelButtonClicked:(DCSearchBar *)searchBar {
    searchBar.text = nil;

    self.active = NO;

    [searchBar resignFirstResponder];

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

- (void)hideSearchControllerViews {
    self.dismissSearchControllerButton.alpha = 0.0;
    self.searchAccessoryView.alpha = 0.0;
    self.searchResultsController.view.alpha = 0.0;
}

- (void)completeSearchControllerDismiss {
    [self.delegate dc_hideController:self];

    if ([self.delegate respondsToSelector:@selector(didDismissSearchController:)]) {
        [self.delegate didDismissSearchController:self];
    }

    [self ka_stopObservingKeyboardNotifications];
}

@end

NS_ASSUME_NONNULL_END
