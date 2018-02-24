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

#import "NSManagedObject+DCExtensions.h"

NS_ASSUME_NONNULL_BEGIN

@implementation NSManagedObject (DCExtensions)

+ (nullable NSArray *)dc_objectsInContext:(NSManagedObjectContext *)context {
    return [self dc_objectsWithPredicate:nil inContext:context];
}

+ (NSUInteger)dc_countOfObjectsInContext:(NSManagedObjectContext *)context {
    return [self dc_countOfObjectsWithPredicate:nil inContext:context];
}

+ (nullable instancetype)dc_objectWithPredicate:(nullable NSPredicate *)predicate inContext:(NSManagedObjectContext *)context {
    NSParameterAssert(context);

    NSFetchRequest *fetchRequest = [self dc_fetchRequestForPredicate:predicate];
    fetchRequest.fetchLimit = 1;

    NSError *error = nil;
    NSManagedObject *object = [context executeFetchRequest:fetchRequest error:&error].firstObject;
    if (error) {
        DCDebugLog([self class], @"Execute fetch request error: %@", error);
    }

    return object;
}

+ (nullable NSArray *)dc_objectsWithPredicate:(nullable NSPredicate *)predicate inContext:(NSManagedObjectContext *)context {
    NSParameterAssert(context);

    NSFetchRequest *fetchRequest = [self dc_fetchRequestForPredicate:predicate];

    NSError *error = nil;
    NSArray *objects = [context executeFetchRequest:fetchRequest error:&error];
    if (error) {
        DCDebugLog([self class], @"Execute fetch request error: %@", error);
    }

    return objects;
}

+ (NSUInteger)dc_countOfObjectsWithPredicate:(nullable NSPredicate *)predicate inContext:(NSManagedObjectContext *)context {
    NSParameterAssert(context);

    NSFetchRequest *fetchRequest = [self dc_fetchRequestForPredicate:predicate];

    NSError *error = nil;
    NSUInteger count = [context countForFetchRequest:fetchRequest error:&error];
    if (error) {
        DCDebugLog([self class], @"Execute fetch request error: %@", error);
    }

    return count;
}

#pragma mark - Private

+ (NSFetchRequest *)dc_fetchRequestForPredicate:(nullable NSPredicate *)predicate {
    NSEntityDescription *entity = [self entity];
    NSString *entityName = entity.name;
    NSParameterAssert(entityName); // CoreData model doesn't correctly configured
    NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:entityName];
    if (predicate) {
        fetchRequest.predicate = predicate;
    }
    return fetchRequest;
}

@end

NS_ASSUME_NONNULL_END
