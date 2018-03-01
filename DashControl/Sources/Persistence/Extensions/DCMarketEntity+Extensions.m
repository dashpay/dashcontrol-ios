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

#import "DCMarketEntity+Extensions.h"

#import "NSManagedObject+DCExtensions.h"

NS_ASSUME_NONNULL_BEGIN

@implementation DCMarketEntity (Extensions)

+ (nullable DCMarketEntity *)marketForName:(NSString *)name inContext:(NSManagedObjectContext *)context {
    return [self dc_objectWithPredicate:[NSPredicate predicateWithFormat:@"name == %@", name] inContext:context];
}

+ (nullable NSArray<DCMarketEntity *> *)marketsForNames:(NSArray<NSString *> *)names inContext:(NSManagedObjectContext *)context {
    return [self dc_objectsWithPredicate:[NSPredicate predicateWithFormat:@"name IN %@", names] inContext:context];
}

+ (nullable instancetype)marketWithIdentifier:(NSInteger)marketIdentifier inContext:(NSManagedObjectContext *)context {
    return [self dc_objectWithPredicate:[NSPredicate predicateWithFormat:@"identifier == %d", marketIdentifier] inContext:context];
}

+ (NSInteger)autoIncrementIDInContext:(NSManagedObjectContext *)context {
    DCMarketEntity *entity = [DCMarketEntity dc_objectWithPredicate:[NSPredicate predicateWithFormat:@"identifier == max(identifier)"] inContext:context];
    if (entity) {
        return entity.identifier + 1;
    }
    else {
        return 1;
    }
}

@end

NS_ASSUME_NONNULL_END
