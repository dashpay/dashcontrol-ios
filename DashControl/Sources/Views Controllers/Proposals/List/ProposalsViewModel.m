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

#import "ProposalsViewModel.h"

#import "APIBudget.h"
#import "AppDelegate.h"
#import "DCPersistenceStack.h"
#import "HTTPLoaderOperationProtocol.h"

NS_ASSUME_NONNULL_BEGIN

#define KEY_DATEADDED @"dateAdded"
#define KEY_SORTORDER @"sortOrder"

@interface ProposalsViewModel ()

@property (weak, nonatomic) id<HTTPLoaderOperationProtocol> request;

@property (strong, nonatomic) NSFetchedResultsController<DCBudgetProposalEntity *> *fetchedResultsController;
@property (nullable, strong, nonatomic) NSFetchedResultsController<DCBudgetProposalEntity *> *searchFetchedResultsController;
@property (nullable, strong, nonatomic) NSPredicate *searchPredicate;

@end

@implementation ProposalsViewModel

- (NSFetchedResultsController<DCBudgetProposalEntity *> *)fetchedResultsController {
    if (!_fetchedResultsController) {
        NSManagedObjectContext *context = self.stack.persistentContainer.viewContext;
        _fetchedResultsController = [[self class] fetchedResultsControllerWithPredicate:nil
                                                                                context:context
                                                                              cacheName:@"AllProposalsRequestCache"];
    }
    return _fetchedResultsController;
}

- (NSFetchedResultsController<DCBudgetProposalEntity *> *_Nullable)searchFetchedResultsController {
    if (!_searchFetchedResultsController) {
        NSManagedObjectContext *context = self.stack.persistentContainer.viewContext;
        _searchFetchedResultsController = [[self class] fetchedResultsControllerWithPredicate:self.searchPredicate
                                                                                      context:context
                                                                                    cacheName:nil];
    }
    return _searchFetchedResultsController;
}

- (void)reloadWithCompletion:(void (^)(BOOL success))completion {
    if (self.request) {
        [self.request cancel];
    }

    self.request = [self.api fetchActiveProposalsCompletion:completion];
}

- (BOOL)searchWithQuery:(NSString *)query {
    NSString *trimmedQuery = [query stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    NSPredicate *predicate = nil;
    if (trimmedQuery.length > 0) {
        NSPredicate *titlePredicate = [NSPredicate predicateWithFormat:@"title CONTAINS[cd] %@", trimmedQuery];
        NSPredicate *namePredicate = [NSPredicate predicateWithFormat:@"name CONTAINS[cd] %@", trimmedQuery];
        NSPredicate *ownerPredicate = [NSPredicate predicateWithFormat:@"ownerUsername CONTAINS[cd] %@", trimmedQuery];
        predicate = [NSCompoundPredicate orPredicateWithSubpredicates:@[ titlePredicate, namePredicate, ownerPredicate ]];
    }

    if ([predicate isEqual:self.searchFetchedResultsController.fetchRequest.predicate]) {
        return NO;
    }

    self.searchFetchedResultsController.delegate = nil;
    self.searchFetchedResultsController = nil;

    self.searchPredicate = predicate;

    return YES;
}

#pragma mark Private

+ (NSFetchedResultsController *)fetchedResultsControllerWithPredicate:(nullable NSPredicate *)predicate
                                                              context:(NSManagedObjectContext *)context
                                                            cacheName:(nullable NSString *)cacheName {
    NSFetchRequest<DCBudgetProposalEntity *> *fetchRequest = [DCBudgetProposalEntity fetchRequest];
    fetchRequest.predicate = predicate;
    NSSortDescriptor *orderSortDescriptor = [[NSSortDescriptor alloc] initWithKey:KEY_SORTORDER ascending:YES];
    NSSortDescriptor *dateAddedSortDescriptor = [[NSSortDescriptor alloc] initWithKey:KEY_DATEADDED ascending:NO];
    fetchRequest.sortDescriptors = @[ orderSortDescriptor, dateAddedSortDescriptor ];

    NSFetchedResultsController *fetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest
                                                                                               managedObjectContext:context
                                                                                                 sectionNameKeyPath:nil
                                                                                                          cacheName:cacheName];

    NSError *error = nil;
    if (![fetchedResultsController performFetch:&error]) {
        DCDebugLog([self class], error);
    }

    return fetchedResultsController;
}

@end

NS_ASSUME_NONNULL_END
