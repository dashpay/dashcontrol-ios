//
//  AppDelegate.h
//  DashControl
//
//  Created by Sam Westrich on 8/3/17.
//  Copyright © 2017 dashfoundation. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@class DCPersistenceStack;
@class APITrigger;
@class DCWalletManager;
@class DSChainManager;
@class DSChain;

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) InjectedClass(DCPersistenceStack) stack;
@property (strong, nonatomic) InjectedClass(APITrigger) apiTrigger;
@property (strong, nonatomic) InjectedClass(DCWalletManager) walletManager;

@property (strong, nonatomic) UIWindow *window;

+ (instancetype)sharedDelegate;

- (void)showAddMasternodeController;

@end

NS_ASSUME_NONNULL_END
