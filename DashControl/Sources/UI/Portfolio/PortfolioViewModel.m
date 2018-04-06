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

#import "DCPersistenceStack.h"

NS_ASSUME_NONNULL_BEGIN

static NSString *const DASHWALLET_REQUEST_PUBKEY_URL = @"dashwallet://request=masterPublicKey&account=0&sender=dashcontrol";
static NSString *const DASHWALLET_APPSTORE_URL = @"https://itunes.apple.com/app/apple-store/id1206647026?mt=8";

@implementation PortfolioViewModel

@synthesize walletFetchedResultsController = _walletFetchedResultsController;
@synthesize walletAddressFetchedResultsController = _walletAddressFetchedResultsController;
@synthesize masternodeFetchedResultsController = _masternodeFetchedResultsController;
@synthesize dashWalletRequestURL = _dashWalletRequestURL;
@synthesize dashWalletAppStoreURL = _dashWalletAppStoreURL;

- (NSFetchedResultsController<DCWalletEntity *> *)walletFetchedResultsController {
    if (!_walletFetchedResultsController) {
        NSFetchRequest *fetchRequest = [DCWalletEntity fetchRequest];
        NSManagedObjectContext *context = self.stack.persistentContainer.viewContext;
        _walletFetchedResultsController = [self.class fetchedResultsControllerWithFetchRequest:fetchRequest
                                                                                       sortKey:@"name"
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
                                                                                              sortKey:@"address"
                                                                                              context:context];
    }
    return _walletAddressFetchedResultsController;
}

- (NSFetchedResultsController<DCMasternodeEntity *> *)masternodeFetchedResultsController {
    if (!_masternodeFetchedResultsController) {
        NSFetchRequest *fetchRequest = [DCMasternodeEntity fetchRequest];
        NSManagedObjectContext *context = self.stack.persistentContainer.viewContext;
        _masternodeFetchedResultsController = [self.class fetchedResultsControllerWithFetchRequest:fetchRequest
                                                                                           sortKey:@"address"
                                                                                           context:context];
    }
    return _masternodeFetchedResultsController;
}

- (NSURL *)dashWalletRequestURL {
    if (!_dashWalletRequestURL) {
        _dashWalletRequestURL = [NSURL URLWithString:DASHWALLET_REQUEST_PUBKEY_URL];
    }
    return _dashWalletRequestURL;
}

- (NSURL *)dashWalletAppStoreURL {
    if (!_dashWalletAppStoreURL) {
        _dashWalletAppStoreURL = [NSURL URLWithString:DASHWALLET_APPSTORE_URL];
    }
    return _dashWalletAppStoreURL;
}

#pragma mark Private

+ (NSFetchedResultsController *)fetchedResultsControllerWithFetchRequest:(NSFetchRequest *)fetchRequest
                                                                 sortKey:(NSString *)sortKey
                                                                 context:(NSManagedObjectContext *)context {
    fetchRequest.sortDescriptors = @[
        [[NSSortDescriptor alloc] initWithKey:sortKey ascending:YES],
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

@end

NS_ASSUME_NONNULL_END
