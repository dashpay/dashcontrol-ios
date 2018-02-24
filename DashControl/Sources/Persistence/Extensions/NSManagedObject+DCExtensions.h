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

#import <CoreData/CoreData.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSManagedObject (DCExtensions)

+ (nullable NSArray *)dc_objectsInContext:(NSManagedObjectContext *)context;
+ (NSUInteger)dc_countOfObjectsInContext:(NSManagedObjectContext *)context;

+ (nullable instancetype)dc_objectWithPredicate:(nullable NSPredicate *)predicate inContext:(NSManagedObjectContext *)context;
+ (nullable NSArray *)dc_objectsWithPredicate:(nullable NSPredicate *)predicate inContext:(NSManagedObjectContext *)context;
+ (NSUInteger)dc_countOfObjectsWithPredicate:(nullable NSPredicate *)predicate inContext:(NSManagedObjectContext *)context;

@end

NS_ASSUME_NONNULL_END
