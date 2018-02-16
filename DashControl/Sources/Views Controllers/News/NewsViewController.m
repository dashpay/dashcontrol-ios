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

#import "NewsViewController.h"

#import <SafariServices/SafariServices.h>

#import "NewsView.h"
#import "NewsViewModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface NewsViewController () <NewsViewDelegate, SFSafariViewControllerDelegate>

@property (strong, nonatomic) NewsViewModel *viewModel;
@property (strong, nonatomic) NewsView *view;

@end

@implementation NewsViewController

@dynamic view;

- (void)viewDidLoad {
    [super viewDidLoad];

    self.viewModel = [[NewsViewModel alloc] init];
    self.view.viewModel = self.viewModel;

    self.viewModel.fetchedResultsController.delegate = self.view;
    [self.viewModel performFetch];
    [self.viewModel reload];

    self.view.delegate = self;
}

- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
}

#pragma mark NewsViewDelegate

- (void)newsView:(NewsView *)view didSelectNewsPost:(DCNewsPostEntity *)entity {
    NSURL *url = [NSURL URLWithString:entity.url];
    if (!url) {
        return;
    }
    SFSafariViewController *safariViewController = [[SFSafariViewController alloc] initWithURL:url];
    safariViewController.delegate = self;
    safariViewController.preferredBarTintColor = [UIColor colorWithRed:0.0 green:102.0 / 255.0 blue:218.0 / 255.0 alpha:1.0];
    safariViewController.preferredControlTintColor = [UIColor whiteColor];
    [self presentViewController:safariViewController animated:YES completion:nil];
}

#pragma mark SFSafariViewControllerDelegate

- (void)safariViewControllerDidFinish:(SFSafariViewController *)controller {
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end

NS_ASSUME_NONNULL_END
