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

#import "NewsViewModel.h"
#import "NewsView.h"

NS_ASSUME_NONNULL_BEGIN

@interface NewsViewController ()

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
}

- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end

NS_ASSUME_NONNULL_END
