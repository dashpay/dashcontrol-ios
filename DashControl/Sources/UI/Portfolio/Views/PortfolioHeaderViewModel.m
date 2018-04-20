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

#import "PortfolioHeaderViewModel.h"

#import "DCMasternodeEntity+CoreDataClass.h"
#import "DCWalletAddressEntity+CoreDataClass.h"
#import "NSManagedObject+DCExtensions.h"
#import "APIPortfolio.h"
#import "DCFormattingUtils.h"
#import "DCPersistenceStack.h"
#import "Networking.h"

NS_ASSUME_NONNULL_BEGIN

@interface PortfolioHeaderViewModel ()

@property (weak, nonatomic) id<HTTPLoaderOperationProtocol> priceRequest;
@property (weak, nonatomic) id<HTTPLoaderOperationProtocol> addressesRequest;
@property (strong, nonatomic) NSNumberFormatter *usdNumberFormatter;
@property (nullable, strong, nonatomic) NSNumber *lastDashTotal;
@property (nullable, strong, nonatomic) NSNumber *lastDashUsdPrice;
@property (nullable, copy, nonatomic) NSString *dashTotal;
@property (nullable, copy, nonatomic) NSString *dashTotalInUSD;

@end

@implementation PortfolioHeaderViewModel

- (instancetype)init {
    self = [super init];
    if (self) {
        _usdNumberFormatter = [[NSNumberFormatter alloc] init];
        _usdNumberFormatter.numberStyle = NSNumberFormatterCurrencyStyle;
        _usdNumberFormatter.maximumFractionDigits = 2;
        _usdNumberFormatter.minimumFractionDigits = 0;
        _usdNumberFormatter.currencySymbol = @"$";
    }
    return self;
}

- (void)reloadWithCompletion:(void (^)(void))completion {
    weakify;
    [self totalWorthWithCompletion:^{
        strongify;

        [self fetchPriceWithCompletion:completion];
    }];
}

- (void)updateDashTotalWorth {
    [self totalWorthWithCompletion:nil];
}

#pragma mark Private

- (void)updateTotalValues {
    if (self.lastDashTotal) {
        double worthDash = self.lastDashTotal.longLongValue / (double)DUFFS;
        self.dashTotal = [DCFormattingUtils.dashNumberFormatter stringFromNumber:@(worthDash)];
        if (self.lastDashUsdPrice) {
            CGFloat totalUSD = worthDash * self.lastDashUsdPrice.doubleValue;
            self.dashTotalInUSD = [self.usdNumberFormatter stringFromNumber:@(totalUSD)];
        }
        else {
            self.dashTotalInUSD = @"?";
        }
    }
    else {
        self.dashTotal = @"?";
        self.dashTotalInUSD = @"?";
    }
}

- (void)totalWorthWithCompletion:(void (^_Nullable)(void))completion {
    [self.stack.persistentContainer performBackgroundTask:^(NSManagedObjectContext *_Nonnull context) {
        NSMutableArray<NSString *> *addresses = [NSMutableArray array];
        NSArray<DCWalletAddressEntity *> *walletAddresses = [DCWalletAddressEntity dc_objectsInContext:context];
        for (DCWalletAddressEntity *entity in walletAddresses) {
            [addresses addObject:entity.address];
        }
        NSArray<DCMasternodeEntity *> *masternodes = [DCMasternodeEntity dc_objectsInContext:context];
        for (DCMasternodeEntity *entity in masternodes) {
            [addresses addObject:entity.address];
        }

        dispatch_async(dispatch_get_main_queue(), ^{
            if (self.addressesRequest) {
                [self.addressesRequest cancel];
            }

            weakify;
            self.addressesRequest = [self.apiPortfolio balanceSumInAddresses:addresses completion:^(NSNumber *_Nullable balance) {
                strongify;

                self.lastDashTotal = balance;
                [self updateTotalValues];

                if (completion) {
                    completion();
                }
            }];
        });
    }];
}

- (void)fetchPriceWithCompletion:(void (^)(void))completion {
    if (self.priceRequest) {
        [self.priceRequest cancel];
    }

    weakify;
    self.priceRequest = [self.apiPortfolio dashUSDPrice:^(NSNumber *_Nullable price) {
        strongify;

        NSAssert([NSThread isMainThread], nil);

        if (price) {
            self.lastDashUsdPrice = price;
        }
        [self updateTotalValues];

        if (completion) {
            completion();
        }
    }];
}

@end

NS_ASSUME_NONNULL_END
