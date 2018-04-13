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

#import "PriceTriggerViewController.h"

#import <MBProgressHUD/MBProgressHUD.h>

#import "FormTableViewController.h"
#import "PriceTriggerViewModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface PriceTriggerViewController () <FormTableViewControllerDelegate>

@property (strong, nonatomic) PriceTriggerViewModel *viewModel;

@end

@implementation PriceTriggerViewController

+ (instancetype)controllerWithExchangeMarketPair:(nullable NSObject<ExchangeMarketPair> *)exchangeMarketPair {
    PriceTriggerViewController *viewController = [[PriceTriggerViewController alloc] initWithNibName:nil bundle:nil];
    viewController.viewModel = [[PriceTriggerViewModel alloc] initAsNewWithExchangeMarketPair:exchangeMarketPair];
    return viewController;
}

+ (instancetype)controllerWithTrigger:(DCTriggerEntity *)trigger {
    PriceTriggerViewController *viewController = [[PriceTriggerViewController alloc] initWithNibName:nil bundle:nil];
    viewController.viewModel = [[PriceTriggerViewModel alloc] initWithTrigger:trigger];
    return viewController;
}

- (void)viewDidLoad {
    [super viewDidLoad];

    self.title = NSLocalizedString(@"Price Alert", nil);

    FormTableViewController *formController = [[FormTableViewController alloc] initWithStyle:UITableViewStylePlain];
    formController.items = self.viewModel.items;
    formController.delegate = self;

    [self addChildViewController:formController];
    formController.view.frame = self.view.bounds;
    formController.view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [self.view addSubview:formController.view];
    [formController didMoveToParentViewController:self];

    if (self.viewModel.deleteAvailable) {
        UIBarButtonItem *deleteButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemTrash
                                                                                      target:self
                                                                                      action:@selector(deleteButtonAction:)];
        self.navigationItem.rightBarButtonItem = deleteButton;
    }
}

- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
}

#pragma mark FormTableViewControllerDelegate

- (nullable NSArray<id<NamedObject>> *)formTableViewController:(FormTableViewController *)controller
                                   availableValuesForCellModel:(SelectorFormCellModel *)cellModel {
    return [self.viewModel availableValuesForDetail:cellModel];
}

- (void)formTableViewController:(FormTableViewController *)controller
                    selectValue:(id<NamedObject>)value
                   forCellModel:(SelectorFormCellModel *)cellModel {
    [self.viewModel selectValue:value forDetail:cellModel];
}

- (NSInteger)formTableViewControllerIndexOfInvalidDetail:(FormTableViewController *)controller {
    return [self.viewModel indexOfInvalidDetail];
}

- (void)formTableViewControllerDone:(FormTableViewController *)controller {
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    weakify;
    [self.viewModel saveCurrentTriggerCompletion:^(NSString *_Nullable errorMessage) {
        strongify;
        [self handleOperationCompletionWithErrorMessage:errorMessage];
    }];
}

#pragma mark Actions

- (void)deleteButtonAction:(id)sender {
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    weakify;
    [self.viewModel deleteTriggerCompletion:^(NSString *_Nullable errorMessage) {
        strongify;
        [self handleOperationCompletionWithErrorMessage:errorMessage];
    }];
}

#pragma mark Private

- (void)handleOperationCompletionWithErrorMessage:(nullable NSString *)errorMessage {
    [MBProgressHUD hideHUDForView:self.view animated:YES];
    if (errorMessage) {
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"Error", nil)
                                                                                 message:errorMessage
                                                                          preferredStyle:UIAlertControllerStyleAlert];
        [alertController addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"ok", @"ok")
                                                            style:UIAlertActionStyleDefault
                                                          handler:nil]];
        [self presentViewController:alertController animated:YES completion:nil];
    }
    else {
        [self.navigationController popViewControllerAnimated:YES];
    }
}

@end

NS_ASSUME_NONNULL_END
