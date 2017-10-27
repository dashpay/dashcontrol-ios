//
//  AppDelegate.m
//  DashControl
//
//  Created by Sam Westrich on 8/3/17.
//  Copyright © 2017 dashfoundation. All rights reserved.
//

#import "AppDelegate.h"

#import "RSSFeedListViewController.h"
#import "ProposalsViewController.h"
#import "DCPortfolioManager.h"
#import "DCCoreDataManager.h"
#import "DCWalletManager.h"
#import "DCBackendManager.h"

#define kRSSFeedViewControllerIndex 0
#define kProposalsViewControllerIndex 2

/*
 * Utils: Add this section before your class implementation
 */

/**
 This creates a new query parameters string from the given NSDictionary. For
 example, if the input is @{@"day":@"Tuesday", @"month":@"January"}, the output
 string will be @"day=Tuesday&month=January".
 @param queryParameters The input dictionary.
 @return The created parameters string.
 */
static NSString* NSStringFromQueryParameters(NSDictionary* queryParameters)
{
    NSMutableArray* parts = [NSMutableArray array];
    [queryParameters enumerateKeysAndObjectsUsingBlock:^(id key, id value, BOOL *stop) {
        NSString *part = [NSString stringWithFormat: @"%@=%@",
                          [key stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLHostAllowedCharacterSet]],
                          [value stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLHostAllowedCharacterSet]]
                          ];
        [parts addObject:part];
    }];
    return [parts componentsJoinedByString: @"&"];
}

@interface AppDelegate ()

@property (nonatomic, strong) NSPersistentContainer *persistentContainer;

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application willFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
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
    
    self.persistentContainer.viewContext.mergePolicy = NSMergeByPropertyStoreTrumpMergePolicy;
    self.persistentContainer.viewContext.automaticallyMergesChangesFromParent = TRUE;
    
    //Request Device Token For Apple Push Notifications
    [self registerForRemoteNotifications];
    
    //Init the RSSFeedManager Manager.
    [DCRSSFeedManager sharedManager];
    
    //Init the Price Data Manager
    [DCBackendManager sharedInstance];
    
    //Init the Proposals Manager
    [DCProposalsManager sharedManager];
    
    //Init the Core Data Manager
    [DCCoreDataManager sharedManager];
    
    [[DCPortfolioManager sharedManager] updateAmounts];
    
    return YES;
}


- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
}


- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    [self saveContext];
}


- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
}


- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}


- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    [self saveContext];
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
        
        NSArray *identifierComponents = [activityIdentifier componentsSeparatedByString:@"/"];
        if ([identifierComponents.firstObject isEqualToString:@"post"]) {
            
            activityIdentifier = [activityIdentifier stringByReplacingOccurrencesOfString:@"post/" withString:@""];
            
            UITabBarController *tabBarController = (UITabBarController *)_window.rootViewController;
            [tabBarController setSelectedIndex:kRSSFeedViewControllerIndex];
            UINavigationController *RSSFeedNavigationController = (UINavigationController*)[tabBarController.viewControllers objectAtIndex:kRSSFeedViewControllerIndex];
            [RSSFeedNavigationController dismissViewControllerAnimated:NO completion:nil];
            [RSSFeedNavigationController popToRootViewControllerAnimated:NO];
            RSSFeedListViewController *vc = (RSSFeedListViewController*)[[RSSFeedNavigationController viewControllers] firstObject];
            [vc simulateNavitationToPostWithGUID:activityIdentifier];
        }
        else if ([identifierComponents.firstObject isEqualToString:@"proposal"]) {
            
            activityIdentifier = [activityIdentifier stringByReplacingOccurrencesOfString:@"proposal/" withString:@""];
            
            UITabBarController *tabBarController = (UITabBarController *)_window.rootViewController;
            [tabBarController setSelectedIndex:kProposalsViewControllerIndex];
            UINavigationController *proposalsNavigationController = (UINavigationController*)[tabBarController.viewControllers objectAtIndex:kProposalsViewControllerIndex];
            [proposalsNavigationController dismissViewControllerAnimated:NO completion:nil];
            [proposalsNavigationController popToRootViewControllerAnimated:NO];
            ProposalsViewController *vc = (ProposalsViewController*)[[proposalsNavigationController viewControllers] firstObject];
            [vc simulateNavitationToProposalWithHash:activityIdentifier];
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

#pragma mark - UIStateRestoration

- (BOOL)application:(UIApplication *)application shouldSaveApplicationState:(NSCoder *)coder {
    return YES;
}

- (BOOL)application:(UIApplication *)application shouldRestoreApplicationState:(NSCoder *)coder {
    return YES;
}

#pragma mark - Core Data stack

- (NSPersistentContainer *)persistentContainer {
    // The persistent container for the application. This implementation creates and returns a container, having loaded the store for the application to it.
    @synchronized (self) {
        if (_persistentContainer == nil) {
            _persistentContainer = [[NSPersistentContainer alloc] initWithName:@"DashControl"];
            [_persistentContainer loadPersistentStoresWithCompletionHandler:^(NSPersistentStoreDescription *storeDescription, NSError *error) {
                if (error != nil) {
                    // Replace this implementation with code to handle the error appropriately.
                    // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                    
                    /*
                     Typical reasons for an error here include:
                     * The parent directory does not exist, cannot be created, or disallows writing.
                     * The persistent store is not accessible, due to permissions or data protection when the device is locked.
                     * The device is out of space.
                     * The store could not be migrated to the current model version.
                     Check the error message to determine what the actual problem was.
                     */
                    NSLog(@"Unresolved error %@, %@", error, error.userInfo);
                    abort();
                }
            }];
        }
    }
    
    return _persistentContainer;
}

#pragma mark - Core Data Saving support

- (void)saveContext {
    NSManagedObjectContext *context = self.persistentContainer.viewContext;
    NSError *error = nil;
    if ([context hasChanges] && ![context save:&error]) {
        // Replace this implementation with code to handle the error appropriately.
        // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
        NSLog(@"Unresolved error %@, %@", error, error.userInfo);
        abort();
    }
}

#pragma mark - Notifications

- (void)registerForRemoteNotifications {
    UNUserNotificationCenter *center = [UNUserNotificationCenter currentNotificationCenter];
    center.delegate = self;
    [center requestAuthorizationWithOptions:(UNAuthorizationOptionSound | UNAuthorizationOptionAlert | UNAuthorizationOptionBadge) completionHandler:^(BOOL granted, NSError * _Nullable error){
        if(!error){
            dispatch_async(dispatch_get_main_queue(), ^{
                [[UIApplication sharedApplication] registerForRemoteNotifications];
            });
            if (!granted) {
                //Remind the user, when relevant, that he must allow it from setting app
            }
        }
        else {
            //Push registration FAILED
            NSLog( @"ERROR: %@ - %@", error.localizedFailureReason, error.localizedDescription );
            NSLog( @"SUGGESTIONS: %@ - %@", error.localizedRecoveryOptions, error.localizedRecoverySuggestion );
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
    [[DCBackendManager sharedInstance] registerDeviceForDeviceToken:deviceToken];
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
                
            }];
        }
    }
    return TRUE;
}

@end
