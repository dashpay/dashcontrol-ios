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

#import "QRScannerViewController.h"

#import <DashSync/DashSync.h>

#import "AddressQRScannerViewModel.h"
#import "DashCentralAuthQRScannerViewModel.h"
#import "PrivateKeyQRScannerViewModel.h"
#import "QRScannerView.h"

NS_ASSUME_NONNULL_BEGIN

@interface QRScannerViewController () <QRScannerViewDelegate>

@property (strong, nonatomic) QRScannerView *view;
@property (strong, nonatomic) QRScannerViewModel *viewModel;

@end

@implementation QRScannerViewController

@dynamic view;

- (instancetype)initAsAddressScanner {
    self = [super initWithNibName:nil bundle:nil];
    if (self) {
        AddressQRScannerViewModel *viewModel = [[AddressQRScannerViewModel alloc] init];
        _viewModel = viewModel;
    }
    return self;
}

- (instancetype)initAsDashCentralAuth {
    self = [super initWithNibName:nil bundle:nil];
    if (self) {
        _viewModel = [[DashCentralAuthQRScannerViewModel alloc] init];
    }
    return self;
}

- (instancetype)initAsPrivateKeyScanner {
    self = [super init];
    if (self) {
        PrivateKeyQRScannerViewModel *viewModel = [[PrivateKeyQRScannerViewModel alloc] init];
        _viewModel = viewModel;
    }
    return self;
}

- (void)loadView {
    self.view = [[QRScannerView alloc] initWithFrame:[UIScreen mainScreen].bounds];
    self.view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
}

- (void)viewDidLoad {
    [super viewDidLoad];

    self.view.viewModel = self.viewModel;
    self.view.delegate = self;
}

- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];

    if (self.viewModel.isCameraDeniedOrRestricted) {
        NSString *displayName = [NSBundle mainBundle].infoDictionary[@"CFBundleDisplayName"];
        NSString *titleString = [NSString stringWithFormat:NSLocalizedString(@"%@ is not allowed to access the camera", nil),
                                                           displayName];
        NSString *messageString = [NSString stringWithFormat:NSLocalizedString(@"\nallow camera access in\n"
                                                                                "Settings->Privacy->Camera->%@",
                                                                               nil),
                                                             displayName];
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:titleString
                                                                                 message:messageString
                                                                          preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *okAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"ok", nil)
                                                           style:UIAlertActionStyleCancel
                                                         handler:nil];
        [alertController addAction:okAction];

        UIAlertAction *settingsAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"Settings", nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction *_Nonnull action) {
            NSURL *url = [NSURL URLWithString:UIApplicationOpenSettingsURLString];
            if (url && [[UIApplication sharedApplication] canOpenURL:url]) {
                [[UIApplication sharedApplication] openURL:url options:@{} completionHandler:nil];
            }
        }];
        [alertController addAction:settingsAction];

        [self presentViewController:alertController animated:YES completion:nil];
    }
    else {
        [self.viewModel startPreview];
    }
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];

    [self.viewModel stopPreview];
}

#pragma mark QRScannerViewDelegate

- (void)qrScannerViewDidCancel:(QRScannerView *)view {
    [self.delegate qrScannerViewControllerDidCancel:self];
}

- (void)qrScannerView:(QRScannerView *)view didScanString:(NSString *)scannedString {
    [self.delegate qrScannerViewController:self didScanString:scannedString];
}

@end

NS_ASSUME_NONNULL_END
