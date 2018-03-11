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

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) InjectedClass(DCPersistenceStack) stack;

@property (strong, nonatomic) UIWindow *window;

@end

NS_ASSUME_NONNULL_END
