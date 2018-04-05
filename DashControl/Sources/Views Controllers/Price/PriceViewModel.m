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

#import "PriceViewModel.h"

#import "APITrigger.h"
#import "DCEnvironment.h"
#import "DCPersistenceStack.h"
#import "HTTPLoaderOperationProtocol.h"

NS_ASSUME_NONNULL_BEGIN

#define KEY_VALUE @"value"
#define KEY_MARKETNAMED @"marketNamed"

@interface PriceViewModel ()

@property (nullable, strong, nonatomic) NSFetchedResultsController<DCTriggerEntity *> *fetchedResultsController;

@property (weak, nonatomic) id<HTTPLoaderOperationProtocol> request;

@end

@implementation PriceViewModel

- (NSFetchedResultsController<DCTriggerEntity *> *)fetchedResultsController {
    if (!_fetchedResultsController) {
        NSManagedObjectContext *context = self.stack.persistentContainer.viewContext;
        _fetchedResultsController = [[self class] fetchedResultsControllerInContext:context];
    }
    return _fetchedResultsController;
}

- (void)reloadWithCompletion:(void (^)(BOOL success))completion {
    if (self.request) {
        [self.request cancel];
    }
    
    if (![self deviceRegistered]) {
        weakify;
        self.request = [self.apiTrigger registerWithCompletion:^(BOOL success) {
            strongify;
            if (success) {
                [self performTriggersFetchCompletion:completion];
            }
        }];
    }
    else {
        [self performTriggersFetchCompletion:completion];
    }
}

#pragma mark Private

+ (NSFetchedResultsController *)fetchedResultsControllerInContext:(NSManagedObjectContext *)context {
    NSFetchRequest<DCTriggerEntity *> *fetchRequest = [DCTriggerEntity fetchRequest];
    fetchRequest.sortDescriptors = @[
        [[NSSortDescriptor alloc] initWithKey:KEY_MARKETNAMED ascending:YES],
        [[NSSortDescriptor alloc] initWithKey:KEY_VALUE ascending:YES],
    ];

    NSFetchedResultsController *fetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest
                                                                                               managedObjectContext:context
                                                                                                 sectionNameKeyPath:nil
                                                                                                          cacheName:nil];

    NSError *error = nil;
    if (![fetchedResultsController performFetch:&error]) {
        DCDebugLog([self class], error);
    }

    return fetchedResultsController;
}

- (BOOL)deviceRegistered {
    NSError *error = nil;
    BOOL hasRegistered = [[DCEnvironment sharedInstance] hasRegisteredWithError:&error];
    if (!error && hasRegistered) {
        return YES;
    }

    return NO;
}

- (void)performTriggersFetchCompletion:(void (^)(BOOL success))completion {
    self.request = [self.apiTrigger getTriggersCompletion:^(BOOL success) {
        NSAssert([NSThread isMainThread], nil);
        
        if (completion) {
            completion(success);
        }
    }];
}

@end

NS_ASSUME_NONNULL_END
