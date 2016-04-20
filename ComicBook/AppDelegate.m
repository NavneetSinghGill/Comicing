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

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    
    NSString* Identifier = @"MainViewController";
    
    UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:@"Main"
                                                             bundle: nil];
    
    if (![AppHelper isActiveUser]) {
        self.window = [[UIWindow alloc] initWithFrame:UIScreen.mainScreen.bounds];
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        self.viewController = [storyboard instantiateViewControllerWithIdentifier:Identifier];
        self.navigation = [[UINavigationController alloc]initWithRootViewController:self.viewController];
        [self.navigation.navigationBar setHidden:YES];
        
        self.window.rootViewController = self.navigation;
        storyboard = nil;
        [self.window makeKeyAndVisible];
    }
    self.dataManager = [[DataManager alloc] init];
    [self updateSettingValue];
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
    [self updateSettingValue];
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
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
-(void)updateSettingValue{
    BOOL isLogin = YES;
    if ([[AppHelper getCurrentLoginId] isEqualToString:@"1"]) {
        isLogin = NO;
    }
    NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
    // The user wants to cache files aggressively.
    [defaults setBool:!isLogin forKey:@"enabled_preference"];
    
}

@end
