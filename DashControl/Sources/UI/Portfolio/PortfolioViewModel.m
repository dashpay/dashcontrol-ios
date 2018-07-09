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

#import "PortfolioViewModel.h"

#import "AppDelegate.h"
#import "DCPersistenceStack.h"
#import "UITestingHelper.h"

NS_ASSUME_NONNULL_BEGIN

static NSString *const DASHWALLET_URL = @"dashwallet://";
static NSString *const DASHWALLET_REQUEST_PUBKEY_URL = @"dashwallet://request=masterPublicKey&account=0&sender=dashcontrol";
static NSInteger const DASHWALLET_APPSTORE_ID = 1206647026;

@implementation PortfolioViewModel

@synthesize walletFetchedResultsController = _walletFetchedResultsController;
@synthesize walletAddressFetchedResultsController = _walletAddressFetchedResultsController;
@synthesize masternodeFetchedResultsController = _masternodeFetchedResultsController;
@synthesize dashWalletRequestURL = _dashWalletRequestURL;
@synthesize dashWalletURL = _dashWalletURL;

- (instancetype)init {
    self = [super init];
    if (self) {
        if ([UITestingHelper isUITest]) {
            NSManagedObjectContext *context = self.stack.persistentContainer.viewContext;
            DCWalletAddressEntity *wallet = [[DCWalletAddressEntity alloc] initWithContext:context];
            wallet.name = @"My Main Wallet";
            wallet.address = @"xxx";
            [context save:nil];
        }
    }
    return self;
}

- (NSFetchedResultsController<DCWalletEntity *> *)walletFetchedResultsController {
    if (!_walletFetchedResultsController) {
        NSFetchRequest *fetchRequest = [DCWalletEntity fetchRequest];
        NSManagedObjectContext *context = self.stack.persistentContainer.viewContext;
        _walletFetchedResultsController = [self.class fetchedResultsControllerWithFetchRequest:fetchRequest
                                                                                      sortKeys:@[ @"name" ]
                                                                                       context:context];
    }
    return _walletFetchedResultsController;
}

- (NSFetchedResultsController<DCWalletAddressEntity *> *)walletAddressFetchedResultsController {
    if (!_walletAddressFetchedResultsController) {
        NSFetchRequest *fetchRequest = [DCWalletAddressEntity fetchRequest];
        fetchRequest.predicate = [NSPredicate predicateWithFormat:@"walletAccount = nil"];
        NSManagedObjectContext *context = self.stack.persistentContainer.viewContext;
        _walletAddressFetchedResultsController = [self.class fetchedResultsControllerWithFetchRequest:fetchRequest
                                                                                             sortKeys:@[ @"name", @"address" ]
                                                                                              context:context];
    }
    return _walletAddressFetchedResultsController;
}

- (NSFetchedResultsController<DSMasternodeBroadcastEntity *> *)masternodeFetchedResultsController {
    if (!_masternodeFetchedResultsController) {
        NSFetchRequest *fetchRequest = [DSMasternodeBroadcastEntity fetchRequest];
        NSManagedObjectContext *context = [DSMasternodeBroadcastEntity context];

        DSChain *chain = [AppDelegate sharedDelegate].chain;

        NSPredicate *predicate = [NSCompoundPredicate andPredicateWithSubpredicates:@[
            [NSPredicate predicateWithFormat:@"masternodeBroadcastHash.chain == %@", chain.chainEntity],
            [NSPredicate predicateWithFormat:@"claimed == %@", @YES],
        ]];
        fetchRequest.predicate = predicate;
        
        _masternodeFetchedResultsController = [self.class fetchedResultsControllerWithFetchRequest:fetchRequest
                                                                                          sortKeys:@[ @"address" ]
                                                                                           context:context];
    }
    return _masternodeFetchedResultsController;
}

- (NSURL *)dashWalletURL {
    if (!_dashWalletURL) {
        _dashWalletURL = [NSURL URLWithString:DASHWALLET_URL];
    }
    return _dashWalletURL;
}

- (NSURL *)dashWalletRequestURL {
    if (!_dashWalletRequestURL) {
        _dashWalletRequestURL = [NSURL URLWithString:DASHWALLET_REQUEST_PUBKEY_URL];
    }
    return _dashWalletRequestURL;
}

- (NSInteger)dashWalletAppStoreID {
    return DASHWALLET_APPSTORE_ID;
}

#pragma mark Private

+ (NSFetchedResultsController *)fetchedResultsControllerWithFetchRequest:(NSFetchRequest *)fetchRequest
                                                                sortKeys:(NSArray<NSString *> *)sortKeys
                                                                 context:(NSManagedObjectContext *)context {
    NSMutableArray<NSSortDescriptor *> *sortDescriptors = [NSMutableArray array];
    for (NSString *sortKey in sortKeys) {
        [sortDescriptors addObject:[[NSSortDescriptor alloc] initWithKey:sortKey ascending:YES]];
    }
    fetchRequest.sortDescriptors = sortDescriptors;

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
