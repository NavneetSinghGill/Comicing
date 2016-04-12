//
//  SendPageViewController.h
//  ComicApp
//
//  Created by Ramesh on 27/11/15.
//  Copyright © 2015 Ramesh. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FriendsListView.h"
#import "ComicImageListView.h"
#import "GroupsSection.h"
#import "HeaderView.h"
#import "ShareHelper.h"
#import "ComicShareView.h"
#import "UIImage+resize.h"

@interface SendPageViewController : UIViewController<ComicNetworkingDelegate,GroupDelegate,FriendListDelegate>
{
    NSMutableArray* shareGroupsArray;
    NSMutableArray* shareFriendsArray;
    NSMutableArray* imageArray;
}

@property (weak, nonatomic) IBOutlet HeaderView *headerView;
@property (weak, nonatomic) IBOutlet FriendsListView *friendsListView;
@property (weak, nonatomic) IBOutlet ComicImageListView *comicImageList;
@property (weak, nonatomic) IBOutlet UILabel *lblGroup;
@property (weak, nonatomic) IBOutlet GroupsSection *groupsView;
@property (weak, nonatomic) IBOutlet UILabel *lblFriends;

//@property (weak, nonatomic) NSString HeaderView *headerView;

@property (strong, nonatomic) IBOutlet ComicShareView *comicShareViewView;

- (IBAction)backButtonClick:(id)sender;

- (IBAction)btnEveryOnceClick:(id)sender;
- (IBAction)btnShareComic:(id)sender;

@end
