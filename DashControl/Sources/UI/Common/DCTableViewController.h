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

#import <KVO-MVVM/KVOUIViewController.h>

NS_ASSUME_NONNULL_BEGIN

@interface DCTableViewController : KVOUIViewController <UITableViewDelegate, UITableViewDataSource>

- (instancetype)initWithStyle:(UITableViewStyle)style;

@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, assign) BOOL clearsSelectionOnViewWillAppear; // defaults to YES

@property (nonatomic, strong, nullable) UIRefreshControl *refreshControl;

@end

NS_ASSUME_NONNULL_END
