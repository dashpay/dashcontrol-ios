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

#import "ProposalCommentsViewModel.h"

#import "DCPersistenceStack.h"

NS_ASSUME_NONNULL_BEGIN

#define KEY_SORTORDER @"sortOrder"

@interface ProposalCommentsViewModel ()

@property (strong, nonatomic) DCBudgetProposalEntity *proposal;
@property (strong, nonatomic) NSFetchedResultsController<DCBudgetProposalCommentEntity *> *fetchedResultsController;

@end

@implementation ProposalCommentsViewModel

- (instancetype)initWithProposal:(DCBudgetProposalEntity *)proposal {
    self = [super init];
    if (self) {
        _proposal = proposal;
    }
    return self;
}

- (NSFetchedResultsController<DCBudgetProposalCommentEntity *> *)fetchedResultsController {
    if (!_fetchedResultsController) {
        NSManagedObjectContext *context = self.stack.persistentContainer.viewContext;
        _fetchedResultsController = [[self class] fetchedResultsControllerWithProposal:self.proposal context:context];
    }
    return _fetchedResultsController;
}

+ (NSFetchedResultsController *)fetchedResultsControllerWithProposal:(DCBudgetProposalEntity *)proposal
                                                             context:(NSManagedObjectContext *)context {
    NSFetchRequest<DCBudgetProposalCommentEntity *> *fetchRequest = [DCBudgetProposalCommentEntity fetchRequest];
    fetchRequest.predicate = [NSPredicate predicateWithFormat:@"proposal == %@", proposal];
    NSSortDescriptor *orderSortDescriptor = [[NSSortDescriptor alloc] initWithKey:KEY_SORTORDER ascending:YES];
    fetchRequest.sortDescriptors = @[ orderSortDescriptor ];

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
