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

#import "ButtonTriggerDetail.h"
#import "PriceTriggerButtonTableViewCell.h"
#import "PriceTriggerDetailTableViewCell.h"
#import "PriceTriggerTextFieldTableViewCell.h"
#import "PriceTriggerViewModel.h"
#import "TextFieldTriggerDetail.h"
#import "ValueTriggerDetail.h"

NS_ASSUME_NONNULL_BEGIN

static NSString *const DETAIL_CELL_ID = @"PriceTriggerDetailTableViewCell";
static NSString *const DETAIL_TEXTFIELD_CELL_ID = @"PriceTriggerTextFieldTableViewCell";
static NSString *const DETAIL_BUTTON_CELL_ID = @"PriceTriggerButtonTableViewCell";

@interface PriceTriggerViewController ()

@property (strong, nonatomic) PriceTriggerViewModel *viewModel;

@end

@implementation PriceTriggerViewController

+ (instancetype)controllerWithExchangeMarketPair:(nullable NSObject<ExchangeMarketPair> *)exchangeMarketPair {
    PriceTriggerViewController *viewController = [self controllerFromStoryboard];
    viewController.viewModel = [[PriceTriggerViewModel alloc] initAsNewWithExchangeMarketPair:exchangeMarketPair];
    return viewController;
}

+ (instancetype)controllerWithTrigger:(DCTriggerEntity *)trigger {
    PriceTriggerViewController *viewController = [self controllerFromStoryboard];
    viewController.viewModel = [[PriceTriggerViewModel alloc] initWithTrigger:trigger];
    return viewController;
}

+ (instancetype)controllerFromStoryboard {
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Price" bundle:nil];
    PriceTriggerViewController *viewController = [storyboard instantiateViewControllerWithIdentifier:NSStringFromClass([self class])];
    return viewController;
}

- (void)viewDidLoad {
    [super viewDidLoad];

    self.title = NSLocalizedString(@"Price Alert", nil);
    self.tableView.contentInset = UIEdgeInsetsMake(10.0, 0.0, 0.0, 0.0);

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

#pragma mark UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.viewModel.items.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    BaseTriggerDetail *detail = self.viewModel.items[indexPath.row];

    if ([detail isKindOfClass:ValueTriggerDetail.class]) {
        PriceTriggerDetailTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:DETAIL_CELL_ID forIndexPath:indexPath];
        cell.detail = (ValueTriggerDetail *)detail;
        return cell;
    }
    else if ([detail isKindOfClass:TextFieldTriggerDetail.class]) {
        PriceTriggerTextFieldTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:DETAIL_TEXTFIELD_CELL_ID forIndexPath:indexPath];
        cell.detail = (TextFieldTriggerDetail *)detail;
        return cell;
    }
    else {
        NSAssert([detail isKindOfClass:ButtonTriggerDetail.class], @"unknown detail model");

        PriceTriggerButtonTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:DETAIL_BUTTON_CELL_ID forIndexPath:indexPath];
        cell.detail = (ButtonTriggerDetail *)detail;
        return cell;
    }
}

#pragma mark UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    [self.view endEditing:YES];

    BaseTriggerDetail *detail = self.viewModel.items[indexPath.row];
    if ([detail isKindOfClass:ValueTriggerDetail.class]) {
        [self showValueSelectorForDetail:(ValueTriggerDetail *)detail];
    }
    else if ([detail isKindOfClass:ButtonTriggerDetail.class]) {
        NSInteger index = [self.viewModel indexOfInvalidDetail];
        if (index == NSNotFound) {
            [self saveCurrentTrigger];
        }
        else {
            UITableViewCell *cell = [tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:index inSection:0]];
            CAKeyframeAnimation *shakeAnimation = [CAKeyframeAnimation animationWithKeyPath:@"transform.translation.x"];
            shakeAnimation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear];
            shakeAnimation.duration = 0.5;
            shakeAnimation.values = @[ @(-16), @(16), @(-8), @(8), @(-4), @(4), @(0) ];
            [cell.layer addAnimation:shakeAnimation forKey:@"ShakeAnimation"];
        }
    }
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

- (void)showValueSelectorForDetail:(ValueTriggerDetail *)detail {
    NSArray<id<NamedObject>> *values = [self.viewModel availableValuesForDetail:detail];

    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:detail.title
                                                                             message:nil
                                                                      preferredStyle:UIAlertControllerStyleActionSheet];
    for (id<NamedObject> value in values) {
        [alertController addAction:[UIAlertAction actionWithTitle:value.name
                                                            style:UIAlertActionStyleDefault
                                                          handler:^(UIAlertAction *_Nonnull action) {
                                                              [self.viewModel selectValue:value forDetail:detail];
                                                          }]];
    }
    [self presentViewController:alertController animated:YES completion:nil];
}

- (void)saveCurrentTrigger {
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    weakify;
    [self.viewModel saveCurrentTriggerCompletion:^(NSString *_Nullable errorMessage) {
        strongify;
        [self handleOperationCompletionWithErrorMessage:errorMessage];
    }];
}

- (void)handleOperationCompletionWithErrorMessage:(nullable NSString *)errorMessage {
    [MBProgressHUD hideHUDForView:self.view animated:YES];
    if (errorMessage) {
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Error"
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
