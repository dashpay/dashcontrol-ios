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

#import "MasternodeViewModel.h"

#import "DCMasternodeEntity+CoreDataClass.h"
#import "NSManagedObjectContext+DCExtensions.h"
#import "NSString+Dash.h"
#import "AddressTextFieldFormCellModel.h"
#import "ButtonFormCellModel.h"
#import "DCPersistenceStack.h"

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSUInteger, MasternodeType) {
    MasternodeType_Address,
    MasternodeType_AddButton,
};

@interface MasternodeViewModel ()

@property (nullable, strong, nonatomic) DCMasternodeEntity *masternode;
@property (strong, nonatomic) AddressTextFieldFormCellModel *addressDetail;

@end

@implementation MasternodeViewModel

- (instancetype)initWithMasternode:(nullable DCMasternodeEntity *)masternode {
    self = [super init];
    if (self) {
        _masternode = masternode;

        NSMutableArray *items = [NSMutableArray array];
        {
            _addressDetail = [[AddressTextFieldFormCellModel alloc] initWithTitle:NSLocalizedString(@"Address", nil)
                                                                      placeholder:nil];
            _addressDetail.tag = MasternodeType_Address;
            _addressDetail.text = _masternode.address;
            _addressDetail.returnKeyType = UIReturnKeyDone;
            [items addObject:_addressDetail];
        }
        {
            NSString *title = _masternode ? NSLocalizedString(@"SAVE", nil) : NSLocalizedString(@"ADD", nil);
            ButtonFormCellModel *detail = [[ButtonFormCellModel alloc] initWithTitle:title];
            detail.tag = MasternodeType_AddButton;
            [items addObject:detail];
        }
        _items = [items copy];
    }
    return self;
}

- (BOOL)deleteAvailable {
    return (self.masternode != nil);
}

- (NSInteger)indexOfInvalidDetail {
    for (NSInteger index = 0; index < self.items.count - 1; index++) {
        BaseFormCellModel *detail = self.items[index];
        if ([detail isKindOfClass:AddressTextFieldFormCellModel.class]) {
            NSString *text = [(AddressTextFieldFormCellModel *)detail text];
            if (text.length == 0 || ![text isValidDashAddress]) {
                return index;
            }
        }
    }

    return NSNotFound;
}

- (void)saveCurrentWithCompletion:(void (^)(void))completion {
    NSAssert([self indexOfInvalidDetail] == NSNotFound, @"Validate data before saving");

    weakify;
    [self.stack.persistentContainer performBackgroundTask:^(NSManagedObjectContext *_Nonnull context) {
        strongify;

        DCMasternodeEntity *masternode = [[DCMasternodeEntity alloc] initWithContext:context];
        masternode.address = self.addressDetail.text;

        context.mergePolicy = NSMergeByPropertyStoreTrumpMergePolicy;
        [context dc_saveIfNeeded];

        dispatch_async(dispatch_get_main_queue(), ^{
            if (completion) {
                completion();
            }
        });
    }];
}

@end

NS_ASSUME_NONNULL_END
