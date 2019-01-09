//
//  DCWalletManager.h
//  DashControl
//
//  Created by Sam Westrich on 10/23/17.
//  Copyright © 2017 dashfoundation. All rights reserved.
//

#import <CoreData/CoreData.h>

NS_ASSUME_NONNULL_BEGIN

@class DCPersistenceStack;
@class APIPortfolio;
@class DSChain;

@interface DCWalletManager : NSObject

@property (strong, nonatomic) InjectedClass(DCPersistenceStack) stack;
@property (strong, nonatomic) InjectedClass(APIPortfolio) api;
@property (strong, nonatomic) InjectedClass(DSChain) chain;

- (void)importWalletMasterAddressFromSource:(NSString *)source
                    withExtended32PublicKey:(NSString *_Nullable)extended32PublicKey
                        extended44PublicKey:(NSString *_Nullable)extended44PublicKey;

@end

NS_ASSUME_NONNULL_END
