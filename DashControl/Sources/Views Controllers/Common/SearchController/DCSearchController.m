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

NS_ASSUME_NONNULL_BEGIN

@interface DCSearchController () <DCSearchBarDelegate>

@end

@implementation DCSearchController

- (instancetype)initWithController:(UIViewController *)searchResultsController {
    self = [super initWithNibName:nil bundle:nil];
    if (self) {
        _searchResultsController = searchResultsController;
        
        self.modalTransitionStyle  = UIModalTransitionStyleCrossDissolve;
        self.modalPresentationStyle = UIModalPresentationOverCurrentContext;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self addChildViewController:self.searchResultsController];
    self.searchResultsController.view.frame = self.view.bounds;
    self.searchResultsController.view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [self.view addSubview:self.searchResultsController.view];
    [self.searchResultsController didMoveToParentViewController:self];
}

- (DCSearchBar *)searchBar {
    if (!_searchBar) {
        _searchBar = [[DCSearchBar alloc] initWithFrame:CGRectMake(0.0, 0.0, [UIScreen mainScreen].bounds.size.width, 44.0)];
        _searchBar.delegate = self;
    }
    return _searchBar;
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
        [self.delegate presentViewController:self animated:YES completion:^{
            if ([self.delegate respondsToSelector:@selector(didPresentSearchController:)]) {
                [self.delegate didPresentSearchController:self];
            }
        }];
    }
    else {
        if ([self.delegate respondsToSelector:@selector(willDismissSearchController:)]) {
            [self.delegate willDismissSearchController:self];
        }
        [self.delegate dismissViewControllerAnimated:YES completion:^{
            if ([self.delegate respondsToSelector:@selector(didDismissSearchController:)]) {
                [self.delegate didDismissSearchController:self];
            }
        }];
    }
}

#pragma mark DCSearchBarDelegate

- (void)searchBarDidBeginEditing:(DCSearchBar *)searchBar {
    self.active = YES;
    
    [self.searchResultsUpdater updateSearchResultsForSearchController:self];
}

- (void)searchBar:(DCSearchBar *)searchBar textDidChange:(NSString *)searchText {
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

@end

NS_ASSUME_NONNULL_END
