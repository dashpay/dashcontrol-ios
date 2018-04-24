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

#import "DCTableViewController.h"

NS_ASSUME_NONNULL_BEGIN

@interface DCTableViewController ()

@property (readonly, assign, nonatomic) UITableViewStyle tableViewStyle;
@property (assign, nonatomic) BOOL hasReloadData;
@property (strong, nonatomic) UITableView *tableView;

@end

@implementation DCTableViewController

- (instancetype)initWithStyle:(UITableViewStyle)style {
    self = [super initWithNibName:nil bundle:nil];
    if (self) {
        _tableViewStyle = style;
        _clearsSelectionOnViewWillAppear = YES;
    }
    return self;
}

- (instancetype)initWithNibName:(nullable NSString *)nibNameOrNil bundle:(nullable NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        _tableViewStyle = UITableViewStylePlain;
        _clearsSelectionOnViewWillAppear = YES;
    }
    return self;
}

- (nullable instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        _tableViewStyle = UITableViewStylePlain;
        _clearsSelectionOnViewWillAppear = YES;
    }
    return self;
}

- (void)loadView {
    [super loadView];

    self.tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:self.tableViewStyle];
    self.tableView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    [self.view addSubview:self.tableView];
}

- (UITableView *)tableView {
    [self loadViewIfNeeded];
    return _tableView;
}

- (void)viewDidLoad {
    [super viewDidLoad];

    [self.view insertSubview:self.tableView atIndex:0];
}

- (nullable UIRefreshControl *)refreshControl {
    return self.tableView.refreshControl;
}

- (void)setRefreshControl:(nullable UIRefreshControl *)refreshControl {
    self.tableView.refreshControl = refreshControl;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];

    if (!self.hasReloadData) {
        self.hasReloadData = YES;
        [self.tableView reloadData];
    }

    if (self.clearsSelectionOnViewWillAppear) {
        // explanation https://gist.github.com/smileyborg/ec4812c146f575cd006d98d681108ba8
        NSIndexPath *selectedIndexPath = self.tableView.indexPathForSelectedRow;
        if (selectedIndexPath != nil) {
            id<UIViewControllerTransitionCoordinator> coordinator = self.transitionCoordinator;
            if (coordinator != nil) {
                [coordinator animateAlongsideTransition:^(id<UIViewControllerTransitionCoordinatorContext> context) {
                    [self.tableView deselectRowAtIndexPath:selectedIndexPath animated:YES];
                }
                    completion:^(id<UIViewControllerTransitionCoordinatorContext> context) {
                        if (context.cancelled) {
                            [self.tableView selectRowAtIndexPath:selectedIndexPath animated:NO scrollPosition:UITableViewScrollPositionNone];
                        }
                    }];
            }
            else {
                [self.tableView deselectRowAtIndexPath:selectedIndexPath animated:animated];
            }
        }
    }
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];

    [self.tableView flashScrollIndicators];
}

#pragma mark UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    return nil;
}

@end

NS_ASSUME_NONNULL_END
