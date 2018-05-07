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
#import "APIPortfolio.h"
#import "AddressTextFieldFormCellModel.h"
#import "ButtonFormCellModel.h"
#import "DCFormattingUtils.h"
#import "DCPersistenceStack.h"
#import "SwitcherFormCellModel.h"

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSUInteger, MasternodeType) {
    MasternodeType_Address,
    MasternodeType_Name,
    MasternodeType_AddButton,
};

@interface MasternodeViewModel ()

@property (nullable, strong, nonatomic) DCMasternodeEntity *masternode;
@property (strong, nonatomic) AddressTextFieldFormCellModel *addressDetail;
@property (strong, nonatomic) TextFieldFormCellModel *nameDetail;

@end

@implementation MasternodeViewModel

- (instancetype)initWithMasternode:(nullable DCMasternodeEntity *)masternode {
    self = [super init];
    if (self) {
        _masternode = masternode;

        NSMutableArray *items = [NSMutableArray array];
        {
            _addressDetail = [[AddressTextFieldFormCellModel alloc] initWithTitle:NSLocalizedString(@"Address", nil)
                                                                      placeholder:NSLocalizedString(@"Wallet Address", nil)];
            _addressDetail.tag = MasternodeType_Address;
            _addressDetail.text = _masternode.address;
            _addressDetail.returnKeyType = UIReturnKeyNext;
            [items addObject:_addressDetail];
        }
        {
            _nameDetail = [[TextFieldFormCellModel alloc] initWithTitle:NSLocalizedString(@"Name", nil)
                                                            placeholder:NSLocalizedString(@"Masternode name (optional)", nil)];
            _nameDetail.tag = MasternodeType_Name;
            _nameDetail.text = _masternode.name;
            _nameDetail.returnKeyType = UIReturnKeyDone;
            [items addObject:_nameDetail];
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

- (void)updateAddress:(NSString *)address {
    self.addressDetail.text = address;
}

- (void)deleteCurrentWithCompletion:(void (^)(void))completion {
    NSParameterAssert(self.masternode);

    NSManagedObjectID *objectID = self.masternode.objectID;
    weakify;
    [self.stack.persistentContainer performBackgroundTask:^(NSManagedObjectContext *_Nonnull context) {
        strongify;

        NSManagedObject *object = [context objectWithID:objectID];
        [context deleteObject:object];

        context.mergePolicy = NSMergeByPropertyStoreTrumpMergePolicy;
        [context dc_saveIfNeeded];

        dispatch_async(dispatch_get_main_queue(), ^{
            if (completion) {
                completion();
            }
        });
    }];
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

- (void)checkBalanceAtAddressCompletion:(void (^)(NSString *_Nullable errorMessage, NSNumber *_Nullable balance, NSInteger indexOfInvalidDetail))completion {
    weakify;
    [self.apiPortfolio balanceSumInAddresses:@[ self.addressDetail.text ] completion:^(NSNumber *_Nullable balance) {
        strongify;

        if (completion) {
            if (!balance) {
                completion(NSLocalizedString(@"Can't check the address contains 1000 Dash", nil), nil, NSNotFound);
            }
            else if (balance.unsignedLongLongValue < 1000 * DUFFS) {
                NSInteger index = [self.items indexOfObject:self.addressDetail];
                completion(NSLocalizedString(@"Not a valid masternode address. This address does not contain the required 1000 Dash", nil), balance, index);
            }
            else {
                completion(nil, balance, NSNotFound);
            }
        }
    }];
}

- (void)saveCurrentWithBalance:(NSNumber *)balance completion:(void (^)(void))completion {
    NSAssert([self indexOfInvalidDetail] == NSNotFound, @"Validate data before saving");

    NSManagedObjectID * _Nullable objectID = self.masternode.objectID;
    
    weakify;
    [self.stack.persistentContainer performBackgroundTask:^(NSManagedObjectContext *_Nonnull context) {
        strongify;

        DCMasternodeEntity *masternode = nil;
        if (objectID) {
            masternode = [context objectWithID:objectID];
        }
        else {
            masternode = [[DCMasternodeEntity alloc] initWithContext:context];
        }
        masternode.address = self.addressDetail.text;
        masternode.amount = balance.longLongValue;
        NSString *trimmedName = [self.nameDetail.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
        masternode.name = trimmedName.length > 0 ? trimmedName : nil;

        context.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy;
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
