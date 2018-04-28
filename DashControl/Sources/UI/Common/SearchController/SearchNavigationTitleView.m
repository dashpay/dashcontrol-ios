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

#import "SearchNavigationTitleView.h"

#import "UIColor+DCStyle.h"

NS_ASSUME_NONNULL_BEGIN

@interface SearchNavigationTitleView ()

@property (strong, nonatomic) UIButton *searchButton;
@property (nullable, strong, nonatomic) UIView *mainView;
@property (nullable, strong, nonatomic) UIView *searchBarView;

@end

@implementation SearchNavigationTitleView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor dc_barTintColor];

        UIButton *searchButton = [UIButton buttonWithType:UIButtonTypeCustom];
        searchButton.translatesAutoresizingMaskIntoConstraints = NO;
        [searchButton setImage:[UIImage imageNamed:@"searchBarButton"] forState:UIControlStateNormal];
        [searchButton addTarget:self action:@selector(searchButtonAction) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:searchButton];
        _searchButton = searchButton;

        [NSLayoutConstraint activateConstraints:@[
            [searchButton.topAnchor constraintEqualToAnchor:self.topAnchor],
            [searchButton.bottomAnchor constraintEqualToAnchor:self.bottomAnchor],
            [searchButton.trailingAnchor constraintEqualToAnchor:self.trailingAnchor],
            [searchButton.widthAnchor constraintEqualToConstant:32.0],
        ]];
    }
    return self;
}

- (CGSize)intrinsicContentSize {
    return CGSizeMake([UIScreen mainScreen].bounds.size.width, 44.0);
}

- (void)setMainView:(UIView *)mainView {
    [_mainView removeFromSuperview];
    if (mainView) {
        mainView.translatesAutoresizingMaskIntoConstraints = NO;
        [self insertSubview:mainView atIndex:0];
        [NSLayoutConstraint activateConstraints:@[
            [mainView.topAnchor constraintEqualToAnchor:self.topAnchor],
            [mainView.bottomAnchor constraintEqualToAnchor:self.bottomAnchor],
            [mainView.centerXAnchor constraintEqualToAnchor:self.centerXAnchor],
        ]];
    }
    _mainView = mainView;
}

- (void)setSearchBarView:(UIView *)searchBarView {
    [_searchBarView removeFromSuperview];
    if (searchBarView) {
        searchBarView.translatesAutoresizingMaskIntoConstraints = NO;
        searchBarView.alpha = 0.0;
        [self addSubview:searchBarView];
        [NSLayoutConstraint activateConstraints:@[
            [searchBarView.topAnchor constraintEqualToAnchor:self.topAnchor],
            [searchBarView.leadingAnchor constraintEqualToAnchor:self.leadingAnchor],
            [searchBarView.bottomAnchor constraintEqualToAnchor:self.bottomAnchor],
            [searchBarView.trailingAnchor constraintEqualToAnchor:self.trailingAnchor],
        ]];
    }
    _searchBarView = searchBarView;
}

#define ANIMATION_DURATION 0.25

- (void)showMainView {
    [UIView animateWithDuration:ANIMATION_DURATION animations:^{
        self.mainView.alpha = 1.0;
        self.searchBarView.alpha = 0.0;
    }];
}

- (void)showSearchView {
    [UIView animateWithDuration:ANIMATION_DURATION animations:^{
        self.mainView.alpha = 0.0;
        self.searchBarView.alpha = 1.0;
    }];
}

#pragma mark Actions

- (void)searchButtonAction {
    [self.delegate searchNavigationTitleViewSearchButtonAction:self];
}

@end

NS_ASSUME_NONNULL_END
