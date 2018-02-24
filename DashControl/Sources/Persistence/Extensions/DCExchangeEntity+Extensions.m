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

#import "DCExchangeEntity+Extensions.h"

#import "NSManagedObject+DCExtensions.h"

NS_ASSUME_NONNULL_BEGIN

@implementation DCExchangeEntity (Extensions)

+ (nullable NSArray<DCExchangeEntity *> *)exchangesForNames:(NSArray<NSString *> *)names inContext:(NSManagedObjectContext *)context {
    return [self dc_objectsWithPredicate:[NSPredicate predicateWithFormat:@"name IN %@", names] inContext:context];
}

+ (nullable instancetype)exchangeWithIdentifier:(NSInteger)exchangeIdentifier inContext:(NSManagedObjectContext *)context {
    return [self dc_objectWithPredicate:[NSPredicate predicateWithFormat:@"identifier == %d", exchangeIdentifier] inContext:context];
}

+ (NSInteger)autoIncrementIDInContext:(NSManagedObjectContext *)context {
    DCExchangeEntity *entity = [DCExchangeEntity dc_objectWithPredicate:[NSPredicate predicateWithFormat:@"identifier == MAX(identifier)"] inContext:context];
    if (entity) {
        return entity.identifier + 1;
    }
    else {
        return 1;
    }
}

@end

NS_ASSUME_NONNULL_END
