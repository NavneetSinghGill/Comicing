//
//  FriendPageVC.h
//  CurlDemo
//
//  Created by Vishnu Vardhan PV on 03/02/16.
//  Copyright © 2016 Vishnu Vardhan PV. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ComicBookVC.h"
#import "ComicCommentPeopleVC.h"
#import "TopBarViewController.h"
#import "Friend.h"
#import "ComicsModel.h"
#import "DateLabel.h"

@interface FriendPageVC : UIViewController <UITableViewDelegate, UITableViewDataSource,BookChangeDelegate, commentersDelegate> {
    int TagRecord;
    NSUInteger selectedRow;
    TopBarViewController *topBarView;
    NSUInteger currentPageDownScroll;
    NSUInteger currentPageUpScroll;
    NSUInteger lastPageDownScroll;
    NSUInteger lastPageUpScroll;
    NSString *nowLabel;
    NSString *currentlyShowingTimelinePeriodDownScroll;
    NSString *currentlyShowingTimelinePeriodUpScroll;
    ComicsModel *comicsModelObj;
    UIRefreshControl *refreshControl;
    NSMutableArray *comicsArray;
    NSMutableArray *bubbleLabels;
}

@property(nonatomic,strong)NSMutableDictionary*ComicBookDict;
@property(nonatomic,strong)UIButton* currentButton;
@property (weak, nonatomic) IBOutlet UIView *NameView;
@property (weak, nonatomic) IBOutlet UITableView *tableview;
@property (assign, nonatomic) CATransform3D initialTransformation;
@property (assign, nonatomic) Friend *friendObj;

@property (weak, nonatomic) IBOutlet UIButton *NowButton;
@property (weak, nonatomic) IBOutlet UIButton *SecondButton;
@property (weak, nonatomic) IBOutlet UIButton *ThirdButton;
@property (weak, nonatomic) IBOutlet UIButton *FourthButton;
@property (weak, nonatomic) IBOutlet UIImageView *friendBubble;
@property (weak, nonatomic) IBOutlet UIButton *profilePicButton;
@property (weak, nonatomic) IBOutlet UIImageView *profileImageView;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *totalComicCountLabel;

@end