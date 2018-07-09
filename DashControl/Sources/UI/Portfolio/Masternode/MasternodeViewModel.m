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

#import <arpa/inet.h>
#import <DashSync/DashSync.h>

#import "NSManagedObjectContext+DCExtensions.h"
#import "NSManagedObject+DCExtensions.h"
#import "NSString+Dash.h"
#import "APIPortfolio.h"
#import "PrivateKeyTextFieldFormCellModel.h"
#import "ButtonFormCellModel.h"
#import "DCFormattingUtils.h"
#import "DCPersistenceStack.h"
#import "SwitcherFormCellModel.h"
#import "IPAddressTextFieldFormCellModel.h"

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSUInteger, MasternodeType) {
    MasternodeType_IPAddress,
    MasternodeType_PrivateKey,
    MasternodeType_AddButton,
};

@interface MasternodeViewModel ()

@property (strong, nonatomic) IPAddressTextFieldFormCellModel *ipAddressKeyDetail;
@property (strong, nonatomic) PrivateKeyTextFieldFormCellModel *privateKeyDetail;

@property (nullable, strong, nonatomic) DSMasternodeBroadcastEntity *masternodeBroadcast;

@end

@implementation MasternodeViewModel

- (instancetype)initWithMasternode:(nullable DSMasternodeBroadcastEntity *)masternode {
    self = [super init];
    if (self) {
        _masternodeBroadcast = masternode;

        NSMutableArray *items = [NSMutableArray array];
        {
            _ipAddressKeyDetail = [[IPAddressTextFieldFormCellModel alloc] initWithTitle:NSLocalizedString(@"IP Address", nil)
                                                                             placeholder:NSLocalizedString(@"Masternode IP", nil)];
            _ipAddressKeyDetail.tag = MasternodeType_IPAddress;
            _ipAddressKeyDetail.returnKeyType = UIReturnKeyNext;
            if (masternode) {
                char s[INET6_ADDRSTRLEN];
                uint32_t ipAddress = masternode.address;
                _ipAddressKeyDetail.text = [NSString stringWithFormat:@"%s", inet_ntop(AF_INET, &ipAddress, s, sizeof(s))];
            }
            [items addObject:_ipAddressKeyDetail];
        }
        {
            _privateKeyDetail = [[PrivateKeyTextFieldFormCellModel alloc] initWithTitle:NSLocalizedString(@"Private key", nil)
                                                                      placeholder:NSLocalizedString(@"Masternode private key", nil)];
            _privateKeyDetail.tag = MasternodeType_PrivateKey;
            _privateKeyDetail.text = masternode ? @"***" : nil;
            _privateKeyDetail.returnKeyType = UIReturnKeyNext;
            _privateKeyDetail.secureTextEntry = YES;
            [items addObject:_privateKeyDetail];
        }
        if (!masternode) {
            NSString *title = NSLocalizedString(@"ADD", nil);
            ButtonFormCellModel *detail = [[ButtonFormCellModel alloc] initWithTitle:title];
            detail.tag = MasternodeType_AddButton;
            [items addObject:detail];
        }
        _items = [items copy];
        
        // KVO
        
        [self mvvm_observe:@"ipAddressKeyDetail.text" with:^(typeof(self) self, NSString *value){
            if (!value || value.length == 0) {
                self.masternodeBroadcast = nil;
                return;
            }
            
            NSPredicate *predicate = [self.class masternodeBroadcastPredicateForString:value chain:self.chain];
            if (!predicate) {
                self.masternodeBroadcast = nil;
                return;
            }
            
            NSManagedObjectContext *context = [DSMasternodeBroadcastEntity context];
            NSArray <DSMasternodeBroadcastEntity *> *mnbs = [DSMasternodeBroadcastEntity dc_objectsWithPredicate:predicate
                                                                                                       inContext:context requestConfigureBlock:^(NSFetchRequest * _Nonnull fetchRequest) {
                                                                                                           fetchRequest.fetchLimit = 2;
                                                                                                       }];
            if (mnbs.count == 1) {
                self.masternodeBroadcast = mnbs.firstObject;
                
                char s[INET6_ADDRSTRLEN];
                uint32_t ipAddress = self.masternodeBroadcast.address;
                self.ipAddressKeyDetail.text = [NSString stringWithFormat:@"%s", inet_ntop(AF_INET, &ipAddress, s, sizeof(s))];
            }
        }];
    }
    return self;
}

- (BOOL)deleteAvailable {
    return (self.masternodeBroadcast != nil);
}

- (void)updateAddress:(NSString *)address {
//    self.addressDetail.text = address;
}

- (void)deleteCurrentWithCompletion:(void (^)(void))completion {
    NSParameterAssert(self.masternodeBroadcast);

    NSManagedObjectContext * context = [DSMasternodeBroadcastEntity context];
    [context performBlockAndWait:^{
        self.masternodeBroadcast.claimed = NO;
        [DSMasternodeBroadcastEntity saveContext];
        
        if (completion) {
            completion();
        }
    }];
}

- (NSInteger)indexOfInvalidDetail {
    for (NSInteger index = 0; index < self.items.count - 1; index++) {
        BaseFormCellModel *detail = self.items[index];
        if ([detail isKindOfClass:AddressTextFieldFormCellModel.class]) {
            NSString *text = [(AddressTextFieldFormCellModel *)detail text];
            if (text.length == 0) {
                return index;
            }
        }
    }

    return NSNotFound;
}

- (void)registerMasternodeCompletion:(void (^)(NSString *_Nullable errorMessage, NSInteger indexOfInvalidDetail))completion {
    if (!self.masternodeBroadcast) {
        if (completion) {
            completion(NSLocalizedString(@"Select your masternode", nil), MasternodeType_IPAddress);
        }
        
        return;
    }
    
    if (![self.privateKeyDetail.text isValidDashPrivateKeyOnChain:self.chain]) {
        if (completion) {
            completion(NSLocalizedString(@"Invalid private key", nil), MasternodeType_PrivateKey);
        }

        return;
    }
    
    DSMasternodeBroadcast *mnb = [self.masternodeBroadcast masternodeBroadcast];
    DSKey *key = [DSKey keyWithPrivateKey:self.privateKeyDetail.text onChain:self.chain];
    if (![key.publicKey isEqualToData:mnb.publicKey]) {
        if (completion) {
            completion(NSLocalizedString(@"Mismatched Key. This private key is valid but does not correspond to this masternode.", nil), MasternodeType_PrivateKey);
        }
        
        return;
    }
    
    [self.chain registerVotingKey:self.privateKeyDetail.text.base58ToData forMasternodeBroadcast:mnb];
    
    if (completion) {
        completion(nil, NSNotFound);
    }
}

+ (nullable NSPredicate *)masternodeBroadcastPredicateForString:(NSString *)searchString chain:(DSChain *)chain {
    if ([searchString isEqualToString:@"0"] || [searchString longLongValue]) {
        NSArray *ipArray = [searchString componentsSeparatedByString:@"."];
        NSMutableArray *partPredicates = [NSMutableArray array];
        NSPredicate *chainPredicate = [NSPredicate predicateWithFormat:@"masternodeBroadcastHash.chain == %@", chain.chainEntity];
        [partPredicates addObject:chainPredicate];
        for (int i = 0; i < MIN(ipArray.count, 4); i++) {
            if ([ipArray[i] isEqualToString:@""])
                break;
            NSPredicate *currentPartPredicate = [NSPredicate predicateWithFormat:@"(((address >> %@) & 255) == %@)", @(i * 8), @([ipArray[i] integerValue])];
            [partPredicates addObject:currentPartPredicate];
        }
        
        return [NSCompoundPredicate andPredicateWithSubpredicates:partPredicates];
    }

    return nil;
}

@end

NS_ASSUME_NONNULL_END
