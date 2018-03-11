//
//  AppDelegate.m
//  DashControl
//
//  Created by Sam Westrich on 8/3/17.
//  Copyright © 2017 dashfoundation. All rights reserved.
//

#import "AppDelegate.h"

#import <UserNotifications/UserNotifications.h>
#import <CoreSpotlight/CoreSpotlight.h>

#import "DCPortfolioManager.h"
#import "DCCoreDataManager.h"
#import "DCWalletManager.h"
#import "DCBackendManager.h"
#import "DCEnvironment.h"
#import "Injections.h"
#import "DCPersistenceStack.h"

#define kRSSFeedViewControllerIndex 0
#define kProposalsViewControllerIndex 2


@interface AppDelegate () <UNUserNotificationCenterDelegate>

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application willFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // place all initialization code here that needs to be called "before" state restoration occurs
    //
    
    // At launch time, the system automatically loads your app’s main storyboard file and
    // loads the initial view controller. For apps that support state restoration, the state
    // restoration machinery restores your interface to its previous state between calls to the
    // application:willFinishLaunchingWithOptions: and application:didFinishLaunchingWithOptions: methods.
    // Use the application:willFinishLaunchingWithOptions: method to show your app window and to determine
    // if state restoration should happen at all. Use the application:didFinishLaunchingWithOptions: method
    // to make any final adjustments to your app’s user interface.
    
    // require the window being visible before state restoration
    [self.window makeKeyAndVisible];
    
    return YES;
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    
    // DI
    [Injections activate];
    
    // CoreData stack
    [self.stack loadStack:^(DCPersistenceStack * _Nonnull stack) {
        [Injections activateCoreDataDependentInjections];
    }];
    
    //Request Device Token For Apple Push Notifications
    [self registerForRemoteNotifications];
    
    //Init the Price Data Manager
    [DCBackendManager sharedInstance];
    
    //Init the Core Data Manager
    [DCCoreDataManager sharedInstance];
    
    [[DCPortfolioManager sharedInstance] updateAmounts];
    
    
    [DCWalletManager sharedInstance];
    
    [self configureAppearance];
    
    return YES;
}


- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
}


- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    [self.stack saveViewContext];
}


- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
}


- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}


- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    [self.stack saveViewContext];
}

#pragma mark - NSUserActivity Search API

- (BOOL)application:(UIApplication *)application continueUserActivity:(NSUserActivity *)activity restorationHandler:(void (^)(NSArray *))restorationHandler
{
    NSString * valueCSSearchableItemActionType = nil;
    BOOL wasHandled = NO;
    
    if ([CSSearchableItemAttributeSet class]) //iOS 9
    {
        valueCSSearchableItemActionType = CSSearchableItemActionType;
    }
    
    if ([activity.activityType isEqual: valueCSSearchableItemActionType])
        //Clicked on spotlight search, item was created via CoreSpotlight API
    {
        NSString * activityIdentifier = [activity.userInfo valueForKey:CSSearchableItemActivityIdentifier];
        
        wasHandled = YES;
        
        // TODO: rewrite core spotlight support
        
        NSArray *identifierComponents = [activityIdentifier componentsSeparatedByString:@"/"];
        if ([identifierComponents.firstObject isEqualToString:@"post"]) {

            
//            activityIdentifier = [activityIdentifier stringByReplacingOccurrencesOfString:@"post/" withString:@""];
//
//            UITabBarController *tabBarController = (UITabBarController *)_window.rootViewController;
//            [tabBarController setSelectedIndex:kRSSFeedViewControllerIndex];
//            UINavigationController *RSSFeedNavigationController = (UINavigationController*)[tabBarController.viewControllers objectAtIndex:kRSSFeedViewControllerIndex];
//            [RSSFeedNavigationController dismissViewControllerAnimated:NO completion:nil];
//            [RSSFeedNavigationController popToRootViewControllerAnimated:NO];
//            RSSFeedListViewController *vc = (RSSFeedListViewController*)[[RSSFeedNavigationController viewControllers] firstObject];
//            [vc simulateNavitationToPostWithGUID:activityIdentifier];
        }
        else if ([identifierComponents.firstObject isEqualToString:@"proposal"]) {
            
//            activityIdentifier = [activityIdentifier stringByReplacingOccurrencesOfString:@"proposal/" withString:@""];
//
//            UITabBarController *tabBarController = (UITabBarController *)_window.rootViewController;
//            [tabBarController setSelectedIndex:kProposalsViewControllerIndex];
//            UINavigationController *proposalsNavigationController = (UINavigationController*)[tabBarController.viewControllers objectAtIndex:kProposalsViewControllerIndex];
//            [proposalsNavigationController dismissViewControllerAnimated:NO completion:nil];
//            [proposalsNavigationController popToRootViewControllerAnimated:NO];
//            OldProposalsViewController *vc = (OldProposalsViewController*)[[proposalsNavigationController viewControllers] firstObject];
//            [vc simulateNavitationToProposalWithHash:activityIdentifier];
        }
        else {
            wasHandled = NO;
        }
        
    } else {
        
        //the app was launched via Handoff protocol
        //or with a Universal Link
    }
    
    return wasHandled;
}

#pragma mark - Notifications

- (void)registerForRemoteNotifications {
    UNUserNotificationCenter *center = [UNUserNotificationCenter currentNotificationCenter];
    center.delegate = self;
    [center requestAuthorizationWithOptions:(UNAuthorizationOptionSound | UNAuthorizationOptionAlert | UNAuthorizationOptionBadge) completionHandler:^(BOOL granted, NSError * _Nullable error){
        if(!error){
            if (granted) {
#if !TARGET_OS_SIMULATOR
                dispatch_async(dispatch_get_main_queue(), ^{
                    [[UIApplication sharedApplication] registerForRemoteNotifications];
                });
#else
                [self application:[UIApplication sharedApplication] didRegisterForRemoteNotificationsWithDeviceToken:[NSData data]];
#endif
            } else {
                //Remind the user, when relevant, that he must allow it from setting app
            }
        }
        else {
            //Push registration FAILED
            NSLog(@"ERROR: %@ - %@", error.localizedFailureReason, error.localizedDescription );
            NSLog(@"SUGGESTIONS: %@ - %@", error.localizedRecoveryOptions, error.localizedRecoverySuggestion );
        }
    }];
}

//Called when a notification is delivered to a foreground app.
-(void)userNotificationCenter:(UNUserNotificationCenter *)center willPresentNotification:(UNNotification *)notification withCompletionHandler:(void (^)(UNNotificationPresentationOptions options))completionHandler{
    NSLog(@"User Info : %@",notification.request.content.userInfo);
    completionHandler(UNAuthorizationOptionSound | UNAuthorizationOptionAlert | UNAuthorizationOptionBadge);
}

//Called to let your app know which action was selected by the user for a given notification.
-(void)userNotificationCenter:(UNUserNotificationCenter *)center didReceiveNotificationResponse:(UNNotificationResponse *)response withCompletionHandler:(void(^)(void))completionHandler{
    NSLog(@"User Info : %@",response.notification.request.content.userInfo);
    completionHandler();
}


- (void)application:(UIApplication*)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken
{
    dispatch_async(dispatch_get_main_queue(), ^{
        [[DCBackendManager sharedInstance] registerDeviceForDeviceToken:deviceToken];
    });
}

-(void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error
{
    NSLog(@"%@ = %@", NSStringFromSelector(_cmd), error);
    NSLog(@"Error = %@",error);
}

-(void) application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo fetchCompletionHandler:(void
                                                                                                                               (^)(UIBackgroundFetchResult))completionHandler
{
    // iOS 10 will handle notifications through other methods
    
    if( SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO( @"10.0" ) )
    {
        NSLog( @"iOS version >= 10. Let NotificationCenter handle this one." );
        // set a member variable to tell the new delegate that this is background
        return;
    }
    NSLog( @"HANDLE PUSH, didReceiveRemoteNotification: %@", userInfo );
    
    // custom code to handle notification content
    
    if( [UIApplication sharedApplication].applicationState == UIApplicationStateInactive )
    {
        NSLog( @"INACTIVE" );
        completionHandler( UIBackgroundFetchResultNewData );
    }
    else if( [UIApplication sharedApplication].applicationState == UIApplicationStateBackground )
    {
        NSLog( @"BACKGROUND" );
        completionHandler( UIBackgroundFetchResultNewData );
    }
    else
    {
        NSLog( @"FOREGROUND" );
        completionHandler( UIBackgroundFetchResultNewData );
    }
}


- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo  
{  
    [self application:application didReceiveRemoteNotification:userInfo fetchCompletionHandler:^(UIBackgroundFetchResult result) {
    }];
}

- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication
         annotation:(id)annotation
{
    if (![url.scheme isEqual:@"dashcontrol"]) {
        UIAlertController * alert = [UIAlertController
                                     alertControllerWithTitle:@"Not a dash URL"
                                     message:url.absoluteString
                                     preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction* okButton = [UIAlertAction
                                   actionWithTitle:NSLocalizedString(@"ok", nil)
                                   style:UIAlertActionStyleCancel
                                   handler:^(UIAlertAction * action) {
                                   }];
        
        [alert addAction:okButton];
        [[[[UIApplication sharedApplication] keyWindow] rootViewController] presentViewController:alert animated:YES completion:nil];
        
        return NO;
    }
    
    NSArray * parameters = [url.host componentsSeparatedByString:@"&"];
    NSMutableDictionary * paramDictionary = [[NSMutableDictionary alloc] init];
    for (NSString * param in parameters) {
        NSArray * paramArray = [param componentsSeparatedByString:@"="];
        if ([paramArray count] == 2) {
            [paramDictionary setObject:[paramArray[1] stringByRemovingPercentEncoding] forKey:paramArray[0]];
        }
    }
    if (paramDictionary[@"callback"]) {
        if ([[paramDictionary[@"callback"] lowercaseString] isEqualToString:@"masterpublickey"]) {
            [[DCWalletManager sharedInstance] importWalletMasterAddressFromSource:@"Dashwallet" withExtended32PublicKey:paramDictionary[@"masterPublicKeyBIP32"] extended44PublicKey:paramDictionary[@"masterPublicKeyBIP44"] completion:^(BOOL success) {
                if (success) {
                
                }
            }];
        }
    }
    return TRUE;
}

#pragma mark - Private

- (void)configureAppearance {
    [[UITabBarItem appearance] setTitleTextAttributes:@{ NSFontAttributeName: [UIFont fontWithName:@"Montserrat-SemiBold" size:10.0] }
                                             forState:UIControlStateNormal];
}

@end
