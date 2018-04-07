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

#import "DCWalletEntity+Extensions.h"

#import "NSManagedObject+DCExtensions.h"

NS_ASSUME_NONNULL_BEGIN

@implementation DCWalletEntity (Extensions)

+ (nullable DCWalletEntity *)walletHavingOneOfAccounts:(NSArray<DCWalletAccountEntity *> *)accounts
                                        withIdentifier:(NSString *)identifier
                                             inContext:(NSManagedObjectContext *)context {
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"ANY accounts IN %@ AND identifier == %@", accounts, identifier];
    return [self dc_objectWithPredicate:predicate inContext:context];
}

+ (nullable NSArray<DCWalletEntity *> *)walletsWithIndentifier:(NSString *)identifier inContext:(NSManagedObjectContext *)context {
    return [self dc_objectWithPredicate:[NSPredicate predicateWithFormat:@"identifier == [c] %@", identifier] inContext:context];
}

@end

NS_ASSUME_NONNULL_END
