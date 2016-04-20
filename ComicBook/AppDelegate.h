//
//  AppDelegate.h
//  ComicMakingPage
//
//  Created by ADNAN THATHIYA on 23/12/15.
//  Copyright © 2015 ADNAN THATHIYA. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MainViewController.h"
#import "DataManager.h"

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (strong, nonatomic) MainViewController *viewController;
@property (strong, nonatomic) UINavigationController *navigation;
@property (strong, nonatomic) DataManager *dataManager;

+ (AppDelegate *)application;

@end

