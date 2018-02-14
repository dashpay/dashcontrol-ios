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
#import "AppDelegate.h"
#import "HTTPLoaderOperationProtocol.h"

NS_ASSUME_NONNULL_BEGIN

#define KEY_DATE @"date"
#define KEY_TITLE @"title"

@interface NewsViewModel ()

@property (assign, nonatomic) NewsViewModelState state;
@property (strong, nonatomic) NSFetchedResultsController<DCNewsPostEntity *> *fetchedResultsController;
@property (weak, nonatomic) id<HTTPLoaderOperationProtocol> request;

@property (assign, nonatomic) NSInteger currentPage;
@property (assign, nonatomic) BOOL fetchingNextPage;
@property (assign, nonatomic) BOOL canLoadMore;

@end

@implementation NewsViewModel

- (instancetype)init {
    self = [super init];
    if (self) {
        NSFetchRequest<DCNewsPostEntity *> *fetchRequest = [DCNewsPostEntity fetchRequest];
        NSPredicate *langPredicate = [NSPredicate predicateWithFormat:@"langCode == %@", self.api.langCode];
        fetchRequest.predicate = langPredicate;
        NSSortDescriptor *dateSortDescriptor = [[NSSortDescriptor alloc] initWithKey:KEY_DATE ascending:NO];
        NSSortDescriptor *titleSortDescriptor = [[NSSortDescriptor alloc] initWithKey:KEY_TITLE ascending:YES];
        fetchRequest.sortDescriptors = @[ dateSortDescriptor, titleSortDescriptor ];

        NSPersistentContainer *container = [(AppDelegate *)[UIApplication sharedApplication].delegate persistentContainer];
        NSManagedObjectContext *context = container.viewContext;

        _fetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest
                                                                        managedObjectContext:context
                                                                          sectionNameKeyPath:nil
                                                                                   cacheName:nil];
    }
    return self;
}

- (void)reload {
    NSParameterAssert(self.fetchedResultsController.delegate);

    NSError *error = nil;
    if (![self.fetchedResultsController performFetch:&error]) {
        NSLog(@"%@: %@", NSStringFromClass([self class]), error);
    }

    self.canLoadMore = YES;
    self.currentPage = 1;
    [self fetchPage:self.currentPage];
}

- (void)fetchNextPage {
    if (self.fetchingNextPage) {
        return;
    }

    self.fetchingNextPage = YES;

    self.currentPage += 1;
    [self fetchPage:self.currentPage];
}

#pragma mark Private

- (void)fetchPage:(NSInteger)page {
    if (self.request) {
        [self.request cancel];
    }

    __weak typeof(self) weakSelf = self;
    self.request = [self.api fetchNewsForPage:page completion:^(BOOL success, BOOL isLastPage) {
        __strong typeof(weakSelf) strongSelf = weakSelf;
        if (!strongSelf) {
            return;
        }

        strongSelf.canLoadMore = !isLastPage;
        strongSelf.fetchingNextPage = NO;
    }];
}

@end

NS_ASSUME_NONNULL_END
