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

#import "PriceViewController.h"

NS_ASSUME_NONNULL_BEGIN

static CGFloat const CHART_HEIGHT_MULTIPLIER = 0.635;

@interface PriceViewController ()

@property (weak, nonatomic) IBOutlet UIView *chartContainerView;

@end

@implementation PriceViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    CGSize size = [UIScreen mainScreen].bounds.size;
    self.chartContainerView.frame = CGRectMake(0.0, 0.0, size.width, size.height * CHART_HEIGHT_MULTIPLIER);
}

- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
}

@end

NS_ASSUME_NONNULL_END
