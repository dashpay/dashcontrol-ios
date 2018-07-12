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

#import "NSManagedObject+DCExtensions.h"
#import "APIBudget.h"
#import "DCPersistenceStack.h"
#import "HTTPLoaderOperationProtocol.h"
#import "ProposalsHeaderViewModel.h"
#import "ProposalsTopViewModel.h"

NS_ASSUME_NONNULL_BEGIN

#define KEY_DATEADDED @"dateAdded"
#define KEY_SORTORDER @"sortOrder"

@interface ProposalsViewModel ()

@property (weak, nonatomic) id<HTTPLoaderOperationProtocol> activeProposalsRequest;
@property (weak, nonatomic) id<HTTPLoaderOperationProtocol> pastProposalsRequest;

@property (assign, nonatomic) ProposalsSegmentIndex segmentIndex;
@property (nullable, strong, nonatomic) NSFetchedResultsController<DCBudgetProposalEntity *> *fetchedResultsController;
@property (nullable, strong, nonatomic) NSFetchedResultsController<DCBudgetProposalEntity *> *searchFetchedResultsController;
@property (nullable, strong, nonatomic) NSPredicate *segmentPredicate;
@property (nullable, strong, nonatomic) NSPredicate *searchSegmentPredicate;
@property (nullable, strong, nonatomic) NSPredicate *searchPredicate;

@end

@implementation ProposalsViewModel

@synthesize topViewModel = _topViewModel;
@synthesize headerViewModel = _headerViewModel;

- (instancetype)init {
    self = [super init];
    if (self) {
        _segmentIndex = ProposalsSegmentIndex_Current;
        NSPredicate *segmentPredicate = [self.class segmentPredicateForSegmentIndex:_segmentIndex];
        _segmentPredicate = segmentPredicate;
        _searchSegmentPredicate = segmentPredicate;
    }
    return self;
}

- (ProposalsTopViewModel *)topViewModel {
    if (!_topViewModel) {
        _topViewModel = [[ProposalsTopViewModel alloc] init];
    }
    return _topViewModel;
}

- (ProposalsHeaderViewModel *)headerViewModel {
    if (!_headerViewModel) {
        _headerViewModel = [[ProposalsHeaderViewModel alloc] init];
    }
    return _headerViewModel;
}

- (NSFetchedResultsController<DCBudgetProposalEntity *> *)fetchedResultsController {
    if (!_fetchedResultsController) {
        NSManagedObjectContext *context = self.stack.persistentContainer.viewContext;
        _fetchedResultsController = [[self class] fetchedResultsControllerWithPredicate:self.segmentPredicate
                                                                                context:context];
    }
    return _fetchedResultsController;
}

- (NSFetchedResultsController<DCBudgetProposalEntity *> *)searchFetchedResultsController {
    if (!_searchFetchedResultsController) {
        NSManagedObjectContext *context = self.stack.persistentContainer.viewContext;
        NSPredicate *resultPredicate = nil;
        if (self.searchSegmentPredicate && self.searchPredicate) {
            resultPredicate = [NSCompoundPredicate andPredicateWithSubpredicates:@[ self.searchSegmentPredicate, self.searchPredicate ]];
        }
        else if (self.searchSegmentPredicate) {
            resultPredicate = self.searchSegmentPredicate;
        }
        else if (self.searchPredicate) {
            resultPredicate = self.searchPredicate;
        }
        _searchFetchedResultsController = [[self class] fetchedResultsControllerWithPredicate:resultPredicate
                                                                                      context:context];
    }
    return _searchFetchedResultsController;
}

- (void)updateMasternodesCount {
    [self.api updateMasternodesCount];
}

- (void)reloadOnlyCurrentSegment:(BOOL)reloadOnlyCurrent completion:(void (^)(BOOL success))completion {
    if (reloadOnlyCurrent) {
        switch (self.segmentIndex) {
            case ProposalsSegmentIndex_Current:
            case ProposalsSegmentIndex_Ongoing: {
                [self reloadActiveProposalsWithCompletion:completion];
                break;
            }
            case ProposalsSegmentIndex_Past: {
                [self reloadPastProposalsWithCompletion:completion];
                break;
            }
        }
    }
    else {
        [self reloadAllProposalsWithCompletion:completion];
    }
}

- (void)reloadAllProposalsWithCompletion:(void (^)(BOOL success))completion {
    __block BOOL activeProposalsSuccess = NO;
    __block BOOL pastProposalsSuccess = NO;
    dispatch_group_t allRequestsGroup = dispatch_group_create();
    
    dispatch_group_enter(allRequestsGroup);
    [self reloadActiveProposalsWithCompletion:^(BOOL success) {
        activeProposalsSuccess = success;
        dispatch_group_leave(allRequestsGroup);
    }];
    
    dispatch_group_enter(allRequestsGroup);
    [self reloadPastProposalsWithCompletion:^(BOOL success) {
        pastProposalsSuccess = success;
        dispatch_group_leave(allRequestsGroup);
    }];
    
    dispatch_group_notify(allRequestsGroup, dispatch_get_main_queue(), ^{
        if (completion) {
            completion(activeProposalsSuccess && pastProposalsSuccess);
        }
    });
}

- (void)reloadActiveProposalsWithCompletion:(void (^)(BOOL success))completion {
    if (self.activeProposalsRequest) {
        [self.activeProposalsRequest cancel];
    }

    weakify;
    self.activeProposalsRequest = [self.api fetchActiveProposalsCompletion:^(BOOL success) {
        strongify;

        NSAssert([NSThread isMainThread], nil);

        NSManagedObjectContext *viewContext = self.stack.persistentContainer.viewContext;
        DCBudgetInfoEntity *budgetInfoEntity = [DCBudgetInfoEntity dc_objectWithPredicate:nil inContext:viewContext];
        [self.topViewModel updateWithBudgetInfo:budgetInfoEntity];
        [self.headerViewModel updateWithBudgetInfo:budgetInfoEntity];

        if (completion) {
            completion(success);
        }
    }];
}

- (void)reloadPastProposalsWithCompletion:(void (^)(BOOL success))completion {
    if (self.pastProposalsRequest) {
        [self.pastProposalsRequest cancel];
    }

    weakify;
    self.pastProposalsRequest = [self.api fetchPastProposalsCompletion:^(BOOL success) {
        strongify;

        NSAssert([NSThread isMainThread], nil);

        if (completion) {
            completion(success);
        }
    }];
}

- (void)searchWithQuery:(NSString *)query {
    NSString *trimmedQuery = [query stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    NSPredicate *predicate = nil;
    if (trimmedQuery.length > 0) {
        NSPredicate *titlePredicate = [NSPredicate predicateWithFormat:@"title CONTAINS[cd] %@", trimmedQuery];
        NSPredicate *namePredicate = [NSPredicate predicateWithFormat:@"name CONTAINS[cd] %@", trimmedQuery];
        NSPredicate *ownerPredicate = [NSPredicate predicateWithFormat:@"ownerUsername CONTAINS[cd] %@", trimmedQuery];
        predicate = [NSCompoundPredicate orPredicateWithSubpredicates:@[ titlePredicate, namePredicate, ownerPredicate ]];
    }

    if ([predicate isEqual:self.searchFetchedResultsController.fetchRequest.predicate]) {
        return;
    }

    self.searchPredicate = predicate;

    self.searchFetchedResultsController.delegate = nil;
    self.searchFetchedResultsController = nil;
}

- (void)updateSegmentIndex:(ProposalsSegmentIndex)segmentIndex {
    self.segmentIndex = segmentIndex;
    NSPredicate *segmentPredicate = [self.class segmentPredicateForSegmentIndex:segmentIndex];
    if ([segmentPredicate isEqual:self.segmentPredicate]) {
        return;
    }
    self.segmentPredicate = segmentPredicate;

    self.fetchedResultsController.delegate = nil;
    self.fetchedResultsController = nil;
}

- (void)updateSearchSegmentIndex:(ProposalsSegmentIndex)segmentIndex {
    NSPredicate *segmentPredicate = [self.class segmentPredicateForSegmentIndex:segmentIndex];
    if ([segmentPredicate isEqual:self.searchSegmentPredicate]) {
        return;
    }
    self.searchSegmentPredicate = segmentPredicate;

    self.searchFetchedResultsController.delegate = nil;
    self.searchFetchedResultsController = nil;
}

#pragma mark Private

+ (nullable NSPredicate *)segmentPredicateForSegmentIndex:(ProposalsSegmentIndex)segmentIndex {
    NSPredicate *segmentPredicate = nil;
    switch (segmentIndex) {
        case ProposalsSegmentIndex_Current: {
            segmentPredicate = [NSPredicate predicateWithFormat:@"dateEnd > %@", [NSDate date]];
            break;
        }
        case ProposalsSegmentIndex_Ongoing: {
            segmentPredicate = [NSPredicate predicateWithFormat:@"dateEnd > %@ AND remainingPaymentCount > 0 AND willBeFunded == YES AND inNextBudget == YES", [NSDate date]];
            break;
        }
        case ProposalsSegmentIndex_Past: {
            segmentPredicate = [NSPredicate predicateWithFormat:@"dateEnd < %@", [NSDate date]];
            break;
        }
    }

    return segmentPredicate;
}

+ (NSFetchedResultsController *)fetchedResultsControllerWithPredicate:(nullable NSPredicate *)predicate
                                                              context:(NSManagedObjectContext *)context {
    NSFetchRequest<DCBudgetProposalEntity *> *fetchRequest = [DCBudgetProposalEntity fetchRequest];
    fetchRequest.predicate = predicate;
    NSSortDescriptor *orderSortDescriptor = [[NSSortDescriptor alloc] initWithKey:KEY_SORTORDER ascending:NO];
    NSSortDescriptor *dateAddedSortDescriptor = [[NSSortDescriptor alloc] initWithKey:KEY_DATEADDED ascending:NO];
    fetchRequest.sortDescriptors = @[ orderSortDescriptor, dateAddedSortDescriptor ];

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
