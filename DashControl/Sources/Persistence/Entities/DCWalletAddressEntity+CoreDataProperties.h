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
//

#import "DCWalletAddressEntity+CoreDataClass.h"


NS_ASSUME_NONNULL_BEGIN

@interface DCWalletAddressEntity (CoreDataProperties)

+ (NSFetchRequest<DCWalletAddressEntity *> *)fetchRequest;

@property (nullable, nonatomic, copy) NSString *address;
@property (nonatomic) int64_t amount;
@property (nullable, nonatomic, retain) NSData *extendedKeyHash;
@property (nonatomic) int32_t index;
@property (nonatomic) BOOL internal;
@property (nullable, nonatomic, copy) NSDate *lastUpdatedAmount;
@property (nullable, nonatomic, copy) NSString *name;
@property (nullable, nonatomic, retain) DCWalletAccountEntity *walletAccount;

@end

NS_ASSUME_NONNULL_END
