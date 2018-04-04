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

#import "WalletAddressViewController.h"

#import <MBProgressHUD/MBProgressHUD.h>

#import "FormTableViewController.h"
#import "QRCodeButton.h"
#import "QRScannerViewController.h"
#import "WalletAddressViewModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface WalletAddressViewController () <FormTableViewControllerDelegate, QRScannerViewControllerDelegate>

@property (strong, nonatomic) WalletAddressViewModel *viewModel;

@end

@implementation WalletAddressViewController

+ (instancetype)controllerWalletAddress:(nullable DCWalletAddressEntity *)walletAddress {
    WalletAddressViewController *controller = [[WalletAddressViewController alloc] initWithNibName:nil bundle:nil];
    controller.viewModel = [[WalletAddressViewModel alloc] initWithWalletAddress:walletAddress];
    return controller;
}

- (void)viewDidLoad {
    [super viewDidLoad];

    self.title = NSLocalizedString(@"Wallet Address", nil);

    FormTableViewController *formController = [[FormTableViewController alloc] initWithStyle:UITableViewStylePlain];
    formController.items = self.viewModel.items;
    formController.delegate = self;

    if (!self.viewModel.deleteAvailable) {
        CGRect frame = CGRectMake(0.0, 0.0, [UIScreen mainScreen].bounds.size.width, 84.0);
        QRCodeButton *qrCodeButton = [[QRCodeButton alloc] initWithFrame:frame];
        [qrCodeButton addTarget:self action:@selector(qrCodeButtonAction) forControlEvents:UIControlEventTouchUpInside];
        formController.tableView.tableFooterView = qrCodeButton;
    }

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
    return nil;
}

- (void)formTableViewController:(FormTableViewController *)controller
                    selectValue:(id<NamedObject>)value
                   forCellModel:(SelectorFormCellModel *)cellModel {
    // NOP
}

- (NSInteger)formTableViewControllerIndexOfInvalidDetail:(FormTableViewController *)controller {
    return [self.viewModel indexOfInvalidDetail];
}

- (void)formTableViewControllerDone:(FormTableViewController *)controller {
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    weakify;
    [self.viewModel saveCurrentWithCompletion:^{
        strongify;
        [MBProgressHUD hideHUDForView:self.view animated:YES];
        [self.navigationController popViewControllerAnimated:YES];
    }];
}

#pragma mark Actions

- (void)deleteButtonAction:(id)sender {
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    weakify;
    [self.viewModel deleteCurrentWithCompletion:^{
        strongify;
        [MBProgressHUD hideHUDForView:self.view animated:YES];
        [self.navigationController popViewControllerAnimated:YES];
    }];
}

- (void)qrCodeButtonAction {
    QRScannerViewController *controller = [[QRScannerViewController alloc] init];
    controller.delegate = self;
    [self presentViewController:controller animated:YES completion:nil];
}

#pragma mark QRScannerViewControllerDelegate

- (void)qrScannerViewControllerDidCancel:(QRScannerViewController *)controller {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)qrScannerViewController:(QRScannerViewController *)controller didScanDASHAddress:(NSString *)address {
    [self.viewModel updateAddress:address];
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end

NS_ASSUME_NONNULL_END
