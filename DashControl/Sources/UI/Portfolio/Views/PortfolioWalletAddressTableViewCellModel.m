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

#import "PortfolioWalletAddressTableViewCellModel.h"

#import "DCWalletAddressEntity+CoreDataClass.h"
#import "NSManagedObject+DCExtensions.h"
#import "NSManagedObjectContext+DCExtensions.h"
#import "APIPortfolio.h"
#import "DCFormattingUtils.h"
#import "DCPersistenceStack.h"
#import "Networking.h"
#import "UITestingHelper.h"

NS_ASSUME_NONNULL_BEGIN

static NSTimeInterval const UPDATE_INTERVAL = 30.0; // 30 sec

@interface PortfolioWalletAddressTableViewCellModel ()

@property (nullable, copy, nonatomic) NSString *subtitle;
@property (assign, nonatomic) SubtitleTableViewCellModelState state;
@property (strong, nonatomic) DCWalletAddressEntity *entity;
@property (weak, nonatomic) id<HTTPLoaderOperationProtocol> request;

@end

@implementation PortfolioWalletAddressTableViewCellModel

@synthesize title = _title;

- (instancetype)initWithEntity:(DCWalletAddressEntity *)entity {
    self = [super init];
    if (self) {
        _entity = entity;
        _title = entity.name ?: entity.address;

        BOOL needsUpdate = !_entity.lastUpdatedAmount || (-[_entity.lastUpdatedAmount timeIntervalSinceNow] >= UPDATE_INTERVAL);
        if (!needsUpdate) {
            _state = SubtitleTableViewCellModelState_Ready;
            double worthDash = _entity.amount / (double)DUFFS;
            _subtitle = [DCFormattingUtils.dashNumberFormatter stringFromNumber:@(worthDash)];
        }
        else {
            [self update];
        }
    }
    return self;
}

- (void)update {
    NSParameterAssert([NSThread isMainThread]);

    self.state = SubtitleTableViewCellModelState_Loading;

    NSString *address = self.entity.address;
    NSParameterAssert(address);

    weakify;
    self.request = [self.apiPortfolio balanceSumInAddresses:@[ address ] completion:^(NSNumber *_Nullable balance) {
        strongify;

        NSParameterAssert([NSThread isMainThread]);

        if ([UITestingHelper isUITest]) {
            balance = @(42 * DUFFS);
        }

        if (balance) {
            NSManagedObjectID *objectID = self.entity.objectID;
            weakify;
            [self.stack.persistentContainer performBackgroundTask:^(NSManagedObjectContext *_Nonnull context) {
                strongify;

                DCWalletAddressEntity *entity = [context objectWithID:objectID];
                entity.amount = balance.longLongValue;
                entity.lastUpdatedAmount = [NSDate date];

                context.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy;
                [context dc_saveIfNeeded];

                dispatch_async(dispatch_get_main_queue(), ^{
                    self.state = SubtitleTableViewCellModelState_Ready;
                });
            }];
        }
        else {
            self.subtitle = @"?";
            self.state = SubtitleTableViewCellModelState_Ready;
        }
    }];
}

@end

NS_ASSUME_NONNULL_END
