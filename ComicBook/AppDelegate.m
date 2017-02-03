//
//  AppDelegate.m
//  ComicMakingPage
//
//  Created by ADNAN THATHIYA on 23/12/15.
//  Copyright © 2015 ADNAN THATHIYA. All rights reserved.
//

#import "AppDelegate.h"
#import "AppHelper.h"
#import "AppConstants.h"
#import <Fabric/Fabric.h>
#import <Crashlytics/Crashlytics.h>
#import "FabricAnalytics.h"
#import "InstructionView.h"
#import "Global.h"

@interface AppDelegate ()

@end

@implementation AppDelegate

@synthesize managedObjectContext = _managedObjectContext;
@synthesize managedObjectModel = _managedObjectModel;
@synthesize persistentStoreCoordinator = _persistentStoreCoordinator;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
   
    [Fabric with:@[[Crashlytics class]]];
    [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleLightContent;

    ///**************** Loging FabricAnalytics ******************
    NSString* event_Key = [NSString stringWithFormat:@"AppStart"];
    [[FabricAnalytics sharedFabricAnalytics] logEvent:event_Key Attributes:nil];
    ///**************** End Loging FabricAnalytics ******************
    
    [[GoogleAnalytics sharedGoogleAnalytics] initTracking];
    

    if ([[NSUserDefaults standardUserDefaults] boolForKey:kIsUserRegisterFirstTime] == YES)
    {
        [[NSUserDefaults standardUserDefaults] setBool:NO forKey:kIsUserRegisterFirstTime];
        [[NSUserDefaults standardUserDefaults] synchronize];
        
        [Global global].isUserEnterSecondTime = YES;
    }
    else
    {
        [Global global].isUserEnterSecondTime = NO;
    }
    
    
    
    NSString* Identifier = @"MainViewController";
    
//    UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:@"Main" bundle: nil];
    
    if (![AppHelper isActiveUser])
    {
        self.window = [[UIWindow alloc] initWithFrame:UIScreen.mainScreen.bounds];
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        self.viewController = [storyboard instantiateViewControllerWithIdentifier:Identifier];
        self.navigation = [[UINavigationController alloc]initWithRootViewController:self.viewController];
        [self.navigation.navigationBar setHidden:YES];
        
        self.window.rootViewController = self.navigation;
        storyboard = nil;
        [self.window makeKeyAndVisible];
    }
    else
    {
        //Already register
    }
    self.dataManager = [[DataManager alloc] init];

    [[GoogleAnalytics sharedGoogleAnalytics] logScreenEvent:@"AppStart" Attributes:nil];
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
//    [self updateSettingValue];
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    [self saveContext];
}

#pragma mark Notifications

- (void)application:(UIApplication *)app didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
    NSString* deviceTokenStr = [[[[deviceToken description]
                                stringByReplacingOccurrencesOfString: @"<" withString: @""]
                                stringByReplacingOccurrencesOfString: @">" withString: @""]
                                stringByReplacingOccurrencesOfString: @" " withString: @""];
    
    deviceTokenStr = [deviceTokenStr stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    [AppHelper setDeviceToken:deviceTokenStr];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:RegisterNotification_Sucess object:nil];
}

- (void)application:(UIApplication *)app didFailToRegisterForRemoteNotificationsWithError:(NSError *)err {
    #if (TARGET_OS_SIMULATOR)
        [AppHelper setDeviceToken:@"4f61d75d601aa4729732b62b43d8dc285acc910325b78528ae078fac56f539f2"];
        [[NSNotificationCenter defaultCenter] postNotificationName:RegisterNotification_Sucess object:nil];
    #else
        [[NSNotificationCenter defaultCenter] postNotificationName:RegisterNotification_Failed object:nil];
    #endif
}
- (void)application:(UIApplication *)application didRegisterUserNotificationSettings:(UIUserNotificationSettings *)notificationSettings
{
    if (notificationSettings.types == UIUserNotificationTypeNone) {
        [[NSNotificationCenter defaultCenter] postNotificationName:RegisterNotification_Failed object:nil];
    }
}
-(void)application:(UIApplication *)application didReceiveLocalNotification:(UILocalNotification *)notification{
    
}

-(void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo fetchCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler {
    [self handleNotification:userInfo];
}

- (void)application:(UIApplication *)application handleActionWithIdentifier:(NSString *)identifier forRemoteNotification:(NSDictionary *)userInfo completionHandler:(void (^)())handler {
    [self handleNotification:userInfo];
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo {
    [self handleNotification:userInfo];
}

#pragma mark Methods

-(void)handleNotification:(NSDictionary *)userInfo{
    if ([userInfo objectForKey:@"aps"] &&
        [[userInfo objectForKey:@"aps" ] objectForKey:@"verification_code"]) {
        [[NSNotificationCenter defaultCenter] postNotificationName:RegisterNotification_Receive object:[userInfo objectForKey:@"aps" ]];
    }
}

+ (AppDelegate *)application {
    return [[UIApplication sharedApplication] delegate];
}
//-(void)updateSettingValue{
//    BOOL isLogin = YES;
//    if ([[AppHelper getCurrentLoginId] isEqualToString:@"1"]) {
//        isLogin = NO;
//    }
//    NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
//    // The user wants to cache files aggressively.
//    [defaults setBool:!isLogin forKey:@"enabled_preference"];
//    
//}

#pragma mark - Core Data stack

- (void)saveContext
{
    NSError *error = nil;
    NSManagedObjectContext *managedObjectContext = self.managedObjectContext;
    if (managedObjectContext != nil) {
        if ([managedObjectContext hasChanges] && ![managedObjectContext save:&error]) {
            // Replace this implementation with code to handle the error appropriately.
            // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            abort();
        }
    }
}

// Returns the managed object context for the application.
// If the context doesn't already exist, it is created and bound to the persistent store coordinator for the application.
- (NSManagedObjectContext *)managedObjectContext
{
    if (_managedObjectContext != nil) {
        return _managedObjectContext;
    }
    
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if (coordinator != nil) {
        _managedObjectContext = [[NSManagedObjectContext alloc] init];
        [_managedObjectContext setPersistentStoreCoordinator:coordinator];
    }
    return _managedObjectContext;
}

// Returns the managed object model for the application.
// If the model doesn't already exist, it is created from the application's model.
- (NSManagedObjectModel *)managedObjectModel
{
    if (_managedObjectModel != nil) {
        return _managedObjectModel;
    }
    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"ComicBookData" withExtension:@"momd"];
    _managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    return _managedObjectModel;
}

// Returns the persistent store coordinator for the application.
// If the coordinator doesn't already exist, it is created and the application's store added to it.
- (NSPersistentStoreCoordinator *)persistentStoreCoordinator
{
    if (_persistentStoreCoordinator != nil) {
        return _persistentStoreCoordinator;
    }
    
    NSURL *storeURL = [[self applicationDocumentsDirectory] URLByAppendingPathComponent:@"ComicBookData.sqlite"];
    
    NSError *error = nil;
    _persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];
    if (![_persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:nil error:&error]) {
        /*
         Replace this implementation with code to handle the error appropriately.
         
         abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
         
         Typical reasons for an error here include:
         * The persistent store is not accessible;
         * The schema for the persistent store is incompatible with current managed object model.
         Check the error message to determine what the actual problem was.
         
         
         If the persistent store is not accessible, there is typically something wrong with the file path. Often, a file URL is pointing into the application's resources directory instead of a writeable directory.
         
         If you encounter schema incompatibility errors during development, you can reduce their frequency by:
         * Simply deleting the existing store:
         [[NSFileManager defaultManager] removeItemAtURL:storeURL error:nil]
         
         * Performing automatic lightweight migration by passing the following dictionary as the options parameter:
         @{NSMigratePersistentStoresAutomaticallyOption:@YES, NSInferMappingModelAutomaticallyOption:@YES}
         
         Lightweight migration will only work for a limited set of schema changes; consult "Core Data Model Versioning and Data Migration Programming Guide" for details.
         
         */
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }
    
    return _persistentStoreCoordinator;
}

// Returns the URL to the application's Documents directory.
- (NSURL *)applicationDocumentsDirectory
{
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}
@end
