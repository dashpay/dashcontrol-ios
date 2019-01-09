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

#import "NewsViewModel.h"

#import "APINews.h"
#import "DCPersistenceStack.h"
#import "HTTPLoaderOperationProtocol.h"

NS_ASSUME_NONNULL_BEGIN

#define KEY_DATE @"date"
#define KEY_TITLE @"title"

@interface NewsViewModel ()

@property (weak, nonatomic) id<HTTPLoaderOperationProtocol> request;

@property (strong, nonatomic) NSFetchedResultsController<DCNewsPostEntity *> *fetchedResultsController;
@property (nullable, strong, nonatomic) NSFetchedResultsController<DCNewsPostEntity *> *searchFetchedResultsController;
@property (strong, nonatomic) NSPredicate *langPredicate;
@property (nullable, strong, nonatomic) NSPredicate *searchPredicate;

@property (assign, nonatomic) NSInteger currentPage;
@property (assign, nonatomic) BOOL loadingNextPage;
@property (assign, nonatomic) BOOL canLoadMore;

@end

@implementation NewsViewModel

- (instancetype)init {
    self = [super init];
    if (self) {
        _langPredicate = [NSPredicate predicateWithFormat:@"langCode == %@", self.api.langCode];
    }
    return self;
}

- (NSFetchedResultsController<DCNewsPostEntity *> *)fetchedResultsController {
    if (!_fetchedResultsController) {
        NSManagedObjectContext *context = self.stack.persistentContainer.viewContext;
        _fetchedResultsController = [[self class] fetchedResultsControllerWithPredicate:self.langPredicate
                                                                                context:context];
    }
    return _fetchedResultsController;
}

- (NSFetchedResultsController<DCNewsPostEntity *> *)searchFetchedResultsController {
    if (!_searchFetchedResultsController) {
        NSManagedObjectContext *context = self.stack.persistentContainer.viewContext;
        _searchFetchedResultsController = [[self class] fetchedResultsControllerWithPredicate:self.searchPredicate
                                                                                      context:context];
    }
    return _searchFetchedResultsController;
}

- (void)reloadWithCompletion:(void (^)(BOOL success))completion {
    self.canLoadMore = YES;
    self.currentPage = 1;
    [self fetchPage:self.currentPage completion:completion];
}

- (void)loadNextPage {
    if (self.loadingNextPage) {
        return;
    }

    self.loadingNextPage = YES;

    self.currentPage += 1;
    [self fetchPage:self.currentPage completion:nil];
}

- (void)searchWithQuery:(NSString *)query {
    NSString *trimmedQuery = [query stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    NSPredicate *predicate = nil;
    if (trimmedQuery.length > 0) {
        NSPredicate *titlePredicate = [NSPredicate predicateWithFormat:@"title CONTAINS[cd] %@", trimmedQuery];
        NSPredicate *urlPredicate = [NSPredicate predicateWithFormat:@"url CONTAINS[cd] %@", trimmedQuery];
        NSPredicate *searchPredicate = [NSCompoundPredicate orPredicateWithSubpredicates:@[ titlePredicate, urlPredicate ]];
        predicate = [NSCompoundPredicate andPredicateWithSubpredicates:@[ self.langPredicate, searchPredicate ]];
    }
    else {
        predicate = self.langPredicate;
    }

    if ([predicate isEqual:self.searchFetchedResultsController.fetchRequest.predicate]) {
        return;
    }

    self.searchPredicate = predicate;

    self.searchFetchedResultsController.delegate = nil;
    self.searchFetchedResultsController = nil;
}

#pragma mark Private

- (void)fetchPage:(NSInteger)page completion:(void (^_Nullable)(BOOL success))completion {
    if (self.request) {
        [self.request cancel];
    }

    weakify;
    self.request = [self.api fetchNewsForPage:page completion:^(BOOL success, BOOL isLastPage) {
        strongify;

        self.canLoadMore = !isLastPage;
        self.loadingNextPage = NO;

        if (completion) {
            completion(success);
        }
    }];
}

+ (NSFetchedResultsController *)fetchedResultsControllerWithPredicate:(NSPredicate *)predicate
                                                              context:(NSManagedObjectContext *)context {
    NSFetchRequest<DCNewsPostEntity *> *fetchRequest = [DCNewsPostEntity fetchRequest];
    fetchRequest.predicate = predicate;
    NSSortDescriptor *dateSortDescriptor = [[NSSortDescriptor alloc] initWithKey:KEY_DATE ascending:NO];
    NSSortDescriptor *titleSortDescriptor = [[NSSortDescriptor alloc] initWithKey:KEY_TITLE ascending:YES];
    fetchRequest.sortDescriptors = @[ dateSortDescriptor, titleSortDescriptor ];

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

@end

NS_ASSUME_NONNULL_END
