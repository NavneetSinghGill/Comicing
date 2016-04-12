//
//  TopBarViewController.h
//  CurlDemo
//
//  Created by Vishnu Vardhan PV on 02/02/16.
//  Copyright © 2016 Vishnu Vardhan PV. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void (^ HomeAction) (void);
typedef void (^ ContactAction) (void);
typedef void (^ MeAction) (void);
typedef void (^ ContactAction) (void);
typedef void (^ MeAction) (void);
typedef void (^ SearchAction) (void);
typedef void (^ SearchUser) (NSString* txtSearch);

@interface TopBarViewController : UIViewController

@property (nonatomic, strong) HomeAction homeAction;
@property (nonatomic, strong) ContactAction contactAction;
@property (nonatomic, strong) MeAction meAction;
@property (nonatomic, strong) SearchAction searchAction;
@property (nonatomic, strong) SearchUser searchUser;

-(void)handleSearchControl:(BOOL)isActiveSearch;
@end
