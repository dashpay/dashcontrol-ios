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

#import "DCMarketEntity+CoreDataClass.h"

NS_ASSUME_NONNULL_BEGIN

@interface DCMarketEntity (Extensions)

+ (nullable NSArray <DCMarketEntity *> *)marketsForNames:(NSArray <NSString *> *)names inContext:(NSManagedObjectContext *)context;
+ (nullable instancetype)marketWithIdentifier:(NSInteger)marketIdentifier inContext:(NSManagedObjectContext *)context;
+ (NSInteger)autoIncrementIDInContext:(NSManagedObjectContext *)context;

@end

NS_ASSUME_NONNULL_END
