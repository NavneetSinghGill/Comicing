//
//  PrivateConversationViewController.m
//  ComicApp
//
//  Created by ADNAN THATHIYA on 12/11/15.
//  Copyright (c) 2015 ADNAN THATHIYA. All rights reserved.
//

#define IS_IPHONE (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)
#define SCREEN_WIDTH ([[UIScreen mainScreen] bounds].size.width)
#define SCREEN_HEIGHT ([[UIScreen mainScreen] bounds].size.height)
#define SCREEN_MAX_LENGTH (MAX(SCREEN_WIDTH, SCREEN_HEIGHT))
#define SCREEN_MIN_LENGTH (MIN(SCREEN_WIDTH, SCREEN_HEIGHT))
#define IS_IPHONE_5 (IS_IPHONE && SCREEN_MAX_LENGTH == 568.0)
#define IS_IPHONE_6 (IS_IPHONE && SCREEN_MAX_LENGTH == 667.0)
#define IS_IPHONE_6P (IS_IPHONE && SCREEN_MAX_LENGTH == 736.0)

#import "PrivateConversationViewController.h"
#import "CMCComicCell.h"
#import "BFPaperButton.h"
#import "ComicBookVC.h"
#import "MeCell.h"
#import "UIScrollView+SVPullToRefresh.h"
#import "Constants.h"
#import "UIScrollView+SVInfiniteScrolling.h"
#import "TopBarViewController.h"
#import "CameraViewController.h"
#import "ContactsViewController.h"
#import "MePageVC.h"
#import "MeAPIManager.h"
#import "ComicsModel.h"
#import "ComicBook.h"
#import "Slides.h"
#import "PrivateConversationCell.h"
#import "UIImageView+WebCache.h"
#import "PrivateConversationAPIManager.h"
#import "AppHelper.h"
#import "UIButton+WebCache.h"

@interface PrivateConversationViewController () {
    int TagRecord;
    TopBarViewController *topBarView;
    NSArray *comicsArray;
}

@property (weak, nonatomic) IBOutlet UITableView *tblvComics;
@property (weak, nonatomic) IBOutlet UIView *viewTransperant;
@property (weak, nonatomic) IBOutlet UIButton *btnMe;
@property (weak, nonatomic) IBOutlet UIButton *btnFriend;
@property (weak, nonatomic) IBOutlet UIView *viewPen;
@property (weak, nonatomic) IBOutlet UIImageView *imgvPinkDots;

@property (strong, nonatomic) NSMutableArray *comics;
@property CGRect saveTableViewFrame;

@end

@implementation PrivateConversationViewController

@synthesize saveTableViewFrame, viewTransperant, tblvComics, comics;
@synthesize btnMe,btnFriend, viewPen, imgvPinkDots,ComicBookDict;

#pragma mark - UIViewController
- (void)viewDidLoad
{
    [super viewDidLoad];
    [self animation];
    [self prepareView];
    [self addTopBarView];
    [self callAPIToGetTheComics];
}

#pragma mark - UIView Methods
- (void)prepareView
{
    if(IS_IPHONE_5)
    {
        btnMe.frame = CGRectMake(CGRectGetMinX(btnMe.frame),
                                 CGRectGetMinY(btnMe.frame),
                                 CGRectGetWidth(btnMe.frame),
                                 CGRectGetHeight(btnMe.frame));
        
        btnFriend.frame = CGRectMake(CGRectGetMinX(btnFriend.frame),
                                     CGRectGetMinY(btnFriend.frame),
                                     CGRectGetWidth(btnFriend.frame),
                                     CGRectGetHeight(btnFriend.frame));
    }
    else if(IS_IPHONE_6)
    {
        btnMe.frame = CGRectMake(CGRectGetMinX(btnMe.frame),
                                 CGRectGetMinY(btnMe.frame),
                                 58,
                                 58);
        
        btnFriend.frame = CGRectMake(CGRectGetMinX(btnFriend.frame),
                                     CGRectGetMinY(btnFriend.frame),
                                     49,
                                     49);
    }
    else if(IS_IPHONE_6P)
    {
        btnMe.frame = CGRectMake(CGRectGetMinX(btnMe.frame),
                                 CGRectGetMinY(btnMe.frame),
                                 61,
                                 61);
        
        btnFriend.frame = CGRectMake(CGRectGetMinX(btnFriend.frame),
                                     CGRectGetMinY(btnFriend.frame),
                                     52,
                                     52);
    }
    
    
    TagRecord=0;
    ComicBookDict=[NSMutableDictionary new];
    comics = [[NSMutableArray alloc] init];
    
    saveTableViewFrame = tblvComics.frame;
    
    tblvComics.pullToRefreshView.arrowColor = [UIColor whiteColor];
    tblvComics.pullToRefreshView.textColor = [UIColor whiteColor];
    tblvComics.pullToRefreshView.activityIndicatorViewColor = [UIColor whiteColor];
    
    [self.btnMe sd_setImageWithURL:[NSURL URLWithString:[[AppHelper initAppHelper] getCurrentUser].profile_pic] forState:UIControlStateNormal];
    [self.btnFriend sd_setImageWithURL:[NSURL URLWithString:self.friendObj.profilePic] forState:UIControlStateNormal];
    

    // [self setupPenAnimation];
    
    //    [self loadMoreData];
}

- (void)animation
{
    btnMe.transform = CGAffineTransformMakeScale(0, 0);
    btnFriend.transform = CGAffineTransformMakeScale(0, 0);
    viewPen.transform = CGAffineTransformMakeScale(0, 0);
    imgvPinkDots.alpha = 0;
    
    [UIView animateWithDuration:1 animations:^
     {
         btnMe.transform = CGAffineTransformMakeScale(1, 1);
         btnFriend.transform = CGAffineTransformMakeScale(1, 1);
         viewPen.transform = CGAffineTransformMakeScale(1, 1);
     }
                     completion:^(BOOL finished)
     {
         [UIView animateWithDuration:0.5 animations:^
          {
              imgvPinkDots.alpha = 1;
          }];
     }];
    
}

- (void)addTopBarView {
    topBarView = [self.storyboard instantiateViewControllerWithIdentifier:TOP_BAR_VIEW];
    [topBarView.view setFrame:CGRectMake(0, 0, self.view.frame.size.width, 50)];
    [self addChildViewController:topBarView];
    [self.view addSubview:topBarView.view];
    [topBarView didMoveToParentViewController:self];
    
    __block typeof(self) weakSelf = self;
    topBarView.homeAction = ^(void) {
//        CameraViewController *cameraView = [weakSelf.storyboard instantiateViewControllerWithIdentifier:CAMERA_VIEW];
//        [weakSelf presentViewController:cameraView animated:YES completion:nil];
        [self dismissViewControllerAnimated:YES completion:nil];
    };
    topBarView.contactAction = ^(void) {
//        ContactsViewController *contactsView = [weakSelf.storyboard instantiateViewControllerWithIdentifier:CONTACTS_VIEW];
//        [weakSelf presentViewController:contactsView animated:YES completion:nil];
        [AppHelper closeMainPageviewController:self];
    };
    topBarView.meAction = ^(void) {
//        [weakSelf performSegueWithIdentifier:ME_VIEW_SEGUE sender:nil];
        MePageVC *meView = [weakSelf.storyboard instantiateViewControllerWithIdentifier:ME_VIEW_SEGUE];
//        [weakSelf presentViewController:meView animated:YES completion:nil];
        [weakSelf.navigationController pushViewController:meView animated:YES];
    };
}

#pragma mark - dummy Data
- (NSMutableArray *)makeDummyComics
{
    NSMutableArray *dummyComics = [[NSMutableArray alloc] init];
    
    //    NSDictionary *comicUser1 = @{UKeyID : @13,
    //                                 UKeyImage: @"u1.jpg",
    //                                 UKeyName : @"John"};
    //    NSDictionary *comicUser2 = @{UKeyID : @13,
    //                                 UKeyImage: @"u2.png",
    //                                 UKeyName : @"Merry"};
    //    NSDictionary *comicUser3 = @{UKeyID : @13,
    //                                 UKeyImage: @"u3.jpg",
    //                                 UKeyName : @"Adam"};
    //    NSDictionary *comicUser4 = @{UKeyID : @13,
    //                                 UKeyImage: @"u4.jpg",
    //                                 UKeyName : @"Mark"};
    //    NSDictionary *comicUser5 = @{UKeyID : @13,
    //                                 UKeyImage: @"u5.jpg",
    //                                 UKeyName : @"Jessica"};
    //    NSDictionary *comicUser6 = @{UKeyID : @13,
    //                                 UKeyImage: @"u6.jpg",
    //                                 UKeyName : @"Johnsan"};
    //    NSDictionary *comicUser7 = @{UKeyID : @13,
    //                                 UKeyImage: @"u7.jpg",
    //                                 UKeyName : @"Justin"};
    //    NSDictionary *comicUser8 = @{UKeyID : @13,
    //                                 UKeyImage: @"u8.jpg",
    //                                 UKeyName : @"Peterson"};
    //    NSDictionary *comicUser9 = @{UKeyID : @13,
    //                                 UKeyImage: @"u9.jpg",
    //                                 UKeyName : @"Fedrick"};
    //    NSDictionary *comicUser10 = @{UKeyID : @13,
    //                                  UKeyImage: @"u10.jpg",
    //                                  UKeyName : @"Rebbeca"};
    //
    //    NSDictionary *comicUser11 = @{UKeyID : @13,
    //                                  UKeyImage: @"u3.jpg",
    //                                  UKeyName : @"Adam"};
    //    NSDictionary *comicUser12 = @{UKeyID : @13,
    //                                  UKeyImage: @"u4.jpg",
    //                                  UKeyName : @"Mark"};
    //    NSDictionary *comicUser13 = @{UKeyID : @13,
    //                                  UKeyImage: @"u5.jpg",
    //                                  UKeyName : @"Jessica"};
    //    NSDictionary *comicUser14 = @{UKeyID : @13,
    //                                  UKeyImage: @"u6.jpg",
    //                                  UKeyName : @"Johnsan"};
    //    NSDictionary *comicUser15 = @{UKeyID : @13,
    //                                  UKeyImage: @"u7.jpg",
    //                                  UKeyName : @"Justin"};
    //    NSDictionary *comicUser16 = @{UKeyID : @13,
    //                                  UKeyImage: @"u8.jpg",
    //                                  UKeyName : @"Peterson"};
    //    NSDictionary *comicUser17 = @{UKeyID : @13,
    //                                  UKeyImage: @"u9.jpg",
    //                                  UKeyName : @"Fedrick"};
    //
    //    NSDictionary *comicUser18 = @{UKeyID : @13,
    //                                  UKeyImage: @"u4.jpg",
    //                                  UKeyName : @"Mark"};
    //    NSDictionary *comicUser19 = @{UKeyID : @13,
    //                                  UKeyImage: @"u5.jpg",
    //                                  UKeyName : @"Jessica"};
    //    NSDictionary *comicUser20 = @{UKeyID : @13,
    //                                  UKeyImage: @"u6.jpg",
    //                                  UKeyName : @"Johnsan"};
    //
    //
    //    CMCComic *comic1 = [[CMCComic alloc] initWithDictionary:@{CKeyID : @1,
    //                                                              CKeyName : @"",
    //                                                              CKeyImage : @"the book.png",
    //                                                              CKeyTime : @"2.15 pm",
    //                                                              CKeyDate : @"OCT 10, 2015",
    //                                                              UKeyDetail : comicUser1}];
    //
    //    CMCComic *comic2 = [[CMCComic alloc] initWithDictionary:@{CKeyID : @1,
    //                                                              CKeyName : @"",
    //                                                              CKeyImage : @"comic2.jpg",
    //                                                              CKeyTime : @"1.45 am",
    //                                                              CKeyDate : @"JAN 15, 2015",
    //                                                              UKeyDetail : comicUser2}];
    //
    //    CMCComic *comic3 = [[CMCComic alloc] initWithDictionary:@{CKeyID : @1,
    //                                                              CKeyName : @"",
    //                                                              CKeyImage : @"comic3.jpg",
    //                                                              CKeyTime : @"3.30 pm",
    //                                                              CKeyDate : @"FEB 21, 2015",
    //                                                              UKeyDetail : comicUser3}];
    //
    //    CMCComic *comic4 = [[CMCComic alloc] initWithDictionary:@{CKeyID : @1,
    //                                                              CKeyName : @"",
    //                                                              CKeyImage : @"comic4.jpg",
    //                                                              CKeyTime : @"1.30 pm",
    //                                                              CKeyDate : @"MAY 28, 2015",
    //                                                              UKeyDetail : comicUser4}];
    //
    //    CMCComic *comic5 = [[CMCComic alloc] initWithDictionary:@{CKeyID : @1,
    //                                                              CKeyName : @"",
    //                                                              CKeyImage : @"comic5.jpg",
    //                                                              CKeyTime : @"10 am",
    //                                                              CKeyDate : @"MAR 25, 2015",
    //                                                              UKeyDetail : comicUser5}];
    //
    //    CMCComic *comic6 = [[CMCComic alloc] initWithDictionary:@{CKeyID : @1,
    //                                                              CKeyName : @"",
    //                                                              CKeyImage : @"comic6.jpg",
    //                                                              CKeyTime : @"2.20 pm",
    //                                                              CKeyDate : @"JUN 21, 2015",
    //                                                              UKeyDetail : comicUser6}];
    //
    //    CMCComic *comic7 = [[CMCComic alloc] initWithDictionary:@{CKeyID : @1,
    //                                                              CKeyName : @"",
    //                                                              CKeyImage : @"comic7.jpg",
    //                                                              CKeyTime : @"10 am",
    //                                                              CKeyDate : @"MAR 25, 2015",
    //                                                              UKeyDetail : comicUser7}];
    //
    //    CMCComic *comic8 = [[CMCComic alloc] initWithDictionary:@{CKeyID : @1,
    //                                                              CKeyName : @"",
    //                                                              CKeyImage : @"comic8.jpg",
    //                                                              CKeyTime : @"1.30 pm",
    //                                                              CKeyDate : @"MAY 28, 2015",
    //                                                              UKeyDetail : comicUser8}];
    //
    //    CMCComic *comic9 = [[CMCComic alloc] initWithDictionary:@{CKeyID : @1,
    //                                                              CKeyName : @"",
    //                                                              CKeyImage : @"comic9.jpg",
    //                                                              CKeyTime : @"3.30 pm",
    //                                                              CKeyDate : @"FEB 21, 2015",
    //                                                              UKeyDetail : comicUser9}];
    //
    //    CMCComic *comic10 = [[CMCComic alloc] initWithDictionary:@{CKeyID : @1,
    //                                                               CKeyName : @"",
    //                                                               CKeyImage : @"comic10.jpg",
    //                                                               CKeyTime : @"1.30 pm",
    //                                                               CKeyDate : @"MAY 28, 2015",
    //                                                               UKeyDetail : comicUser10}];
    //
    //    CMCComic *comic11 = [[CMCComic alloc] initWithDictionary:@{CKeyID : @1,
    //                                                               CKeyName : @"",
    //                                                               CKeyImage : @"comic11.jpg",
    //                                                               CKeyTime : @"2.20 pm",
    //                                                               CKeyDate : @"JUN 21, 2015",
    //                                                               UKeyDetail : comicUser11}];
    //
    //    CMCComic *comic12 = [[CMCComic alloc] initWithDictionary:@{CKeyID : @1,
    //                                                               CKeyName : @"",
    //                                                               CKeyImage : @"comic12.jpg",
    //                                                               CKeyTime : @"1.45 am",
    //                                                               CKeyDate : @"JAN 15, 2015",
    //                                                               UKeyDetail : comicUser12}];
    //
    //    CMCComic *comic13 = [[CMCComic alloc] initWithDictionary:@{CKeyID : @1,
    //                                                               CKeyName : @"",
    //                                                               CKeyImage : @"comic13.jpg",
    //                                                               CKeyTime : @"3.30 pm",
    //                                                               CKeyDate : @"FEB 21, 2015",
    //                                                               UKeyDetail : comicUser13}];
    //
    //    CMCComic *comic14 = [[CMCComic alloc] initWithDictionary:@{CKeyID : @1,
    //                                                               CKeyName : @"",
    //                                                               CKeyImage : @"comic14.jpg",
    //                                                               CKeyTime : @"1.30 pm",
    //                                                               CKeyDate : @"MAY 28, 2015",
    //                                                               UKeyDetail : comicUser14}];
    //
    //    CMCComic *comic15 = [[CMCComic alloc] initWithDictionary:@{CKeyID : @1,
    //                                                               CKeyName : @"",
    //                                                               CKeyImage : @"comic15.jpg",
    //                                                               CKeyTime : @"3.30 pm",
    //                                                               CKeyDate : @"FEB 21, 2015",
    //                                                               UKeyDetail : comicUser15}];
    //
    //    CMCComic *comic16 = [[CMCComic alloc] initWithDictionary:@{CKeyID : @1,
    //                                                               CKeyName : @"",
    //                                                               CKeyImage : @"comic16.jpg",
    //                                                               CKeyTime : @"1.30 pm",
    //                                                               CKeyDate : @"MAY 28, 2015",
    //                                                               UKeyDetail : comicUser16}];
    //
    //    CMCComic *comic17 = [[CMCComic alloc] initWithDictionary:@{CKeyID : @1,
    //                                                               CKeyName : @"",
    //                                                               CKeyImage : @"comic17.jpg",
    //                                                               CKeyTime : @"2.20 pm",
    //                                                               CKeyDate : @"JUN 21, 2015",
    //                                                               UKeyDetail : comicUser17}];
    //
    //    CMCComic *comic18 = [[CMCComic alloc] initWithDictionary:@{CKeyID : @1,
    //                                                               CKeyName : @"",
    //                                                               CKeyImage : @"comic18.jpg",
    //                                                               CKeyTime : @"1.45 am",
    //                                                               CKeyDate : @"JAN 15, 2015",
    //                                                               UKeyDetail : comicUser18}];
    //
    //    CMCComic *comic19 = [[CMCComic alloc] initWithDictionary:@{CKeyID : @1,
    //                                                               CKeyName : @"",
    //                                                               CKeyImage : @"comic19.jpg",
    //                                                               CKeyTime : @"1.30 pm",
    //                                                               CKeyDate : @"MAY 28, 2015",
    //                                                               UKeyDetail : comicUser19}];
    //
    //    CMCComic *comic20 = [[CMCComic alloc] initWithDictionary:@{CKeyID : @1,
    //                                                               CKeyName : @"",
    //                                                               CKeyImage : @"comic9.jpg",
    //                                                               CKeyTime : @"1.45 am",
    //                                                               CKeyDate : @"JAN 15, 2015",
    //                                                               UKeyDetail : comicUser20}];
    //
    //
    //    [dummyComics addObject:comic1];
    //    [dummyComics addObject:comic2];
    //    [dummyComics addObject:comic3];
    //    [dummyComics addObject:comic4];
    //    [dummyComics addObject:comic5];
    //    [dummyComics addObject:comic6];
    //    [dummyComics addObject:comic7];
    //    [dummyComics addObject:comic8];
    //    [dummyComics addObject:comic9];
    //    [dummyComics addObject:comic10];
    //    [dummyComics addObject:comic11];
    //    [dummyComics addObject:comic12];
    //    [dummyComics addObject:comic13];
    //    [dummyComics addObject:comic14];
    //    [dummyComics addObject:comic15];
    //    [dummyComics addObject:comic16];
    //    [dummyComics addObject:comic17];
    //    [dummyComics addObject:comic18];
    //    [dummyComics addObject:comic19];
    //    [dummyComics addObject:comic20];
    
    return dummyComics;
}


#pragma mark - Helper Methods
- (void)refreshData
{
    [tblvComics.pullToRefreshView stopAnimating];
}

- (void)loadMoreData
{
    [comics addObjectsFromArray:[self makeDummyComics]];
    
    [tblvComics.infiniteScrollingView stopAnimating];
    
    [tblvComics reloadData];
}

#pragma mark - UITableViewDataSource & UITableViewDelegate
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    CGFloat height = CGRectGetHeight(viewTransperant.frame);
    return height;
}

- (UIView *) tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, tableView.bounds.size.width, CGRectGetHeight(viewTransperant.frame))];
    [headerView setBackgroundColor:[UIColor clearColor]];
    return headerView;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return comicsArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *simpleTableIdentifier = @"Cell";
    
    __block PrivateConversationCell* cell= (PrivateConversationCell*)[tableView dequeueReusableCellWithIdentifier:simpleTableIdentifier];
    
    cell = nil;
    
    if (cell == nil)
    {
        NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"PrivateConversationCell" owner:self options:nil];
        
        cell = [nib objectAtIndex:0];
        
        //        CMCComic *comicInfo = comics[indexPath.row];
        
        
        if(nil!=[ComicBookDict objectForKey:[NSString stringWithFormat:@"%ld",(long)indexPath.row]])
        {
            [ComicBookDict removeObjectForKey:[NSString stringWithFormat:@"%ld",(long)indexPath.row]];
        }
        
        ComicBookVC *comic=[self.storyboard instantiateViewControllerWithIdentifier:@"ComicBookVC"];
        comic.delegate=self;
        comic.Tag=(int)indexPath.row;
        
        comic.view.frame = CGRectMake(0, 0, CGRectGetWidth(cell.viewComicBook.frame), CGRectGetHeight(cell.viewComicBook.frame));
        
        //        [cell.btnUser setBackgroundImage:comicInfo.creator.imgProfile forState:UIControlStateNormal];
        //        [cell.btnUser setBackgroundImage:comicInfo.creator.imgProfile forState:UIControlStateHighlighted];
        
        ComicBook *comicBook = [comicsArray objectAtIndex:indexPath.row];
        [cell.userProfilePic sd_setImageWithURL:[NSURL URLWithString:comicBook.userDetail.profilePic]];
        
        NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
        [dateFormat setDateFormat:@"yyyy-mm-dd hh:mm:ss"];
        NSDate *dateFromStr = [dateFormat dateFromString:comicBook.createdDate];
        [dateFormat setDateFormat:@"MMM dd, yyyy"];
        NSString *dateStr = [dateFormat stringFromDate:dateFromStr];
        [dateFormat setDateFormat:@"hh.mm a"];
        NSString *timeStr = [dateFormat stringFromDate:dateFromStr];
        
        cell.lblDate.text = dateStr;
        cell.lblTime.text = timeStr;
        
        
        [cell.viewComicBook addSubview:comic.view];
        
//        [comic setImages: [self setupImages:indexPath]];
        [comic setSlidesArray:comicBook.slides];
        [comic setupBook];
        [self addChildViewController:comic];
        
        [ComicBookDict setObject:comic forKey:[NSString stringWithFormat:@"%ld",(long)indexPath.row]];
    }
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    int height=0;
    if(IS_IPHONE_5)
    {
        height=209;
    }
    else if(IS_IPHONE_6)
    {
        height= 239;
    }
    else if(IS_IPHONE_6P)
    {
        height= 269;
    }
    
    return tableView.bounds.size.height-height;
}

-(void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    cell.contentView.layer.shadowColor = [[UIColor blackColor] CGColor];
    cell.contentView.layer.shadowOffset = CGSizeMake(10, 10);
    cell.contentView.alpha = 0;
    cell.contentView.layer.transform = CATransform3DMakeScale(0.5, 0.5, 0.5);
    cell.contentView.layer.anchorPoint = CGPointMake(0.5, 0.5);
    
    [UIView animateWithDuration:1 animations:^
     {
         cell.contentView.layer.shadowOffset = CGSizeMake(0, 0);
         cell.contentView.alpha = 1;
         cell.contentView.layer.transform = CATransform3DIdentity;
     }];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    CGFloat offset = scrollView.contentOffset.y; // here you will get the offset value
    CGFloat value = offset / tblvComics.frame.size.height;
    
    NSLog(@"value = %f",value);
    
    if(value > 0 && value < 1)
    {
        self.viewTransperant.alpha = 1-value/4;
    }
}

#pragma mark - BookChangeDelegate Methods
-(void)bookChanged:(int)Tag
{
    if(TagRecord!=Tag)
    {
        ComicBookVC*comic=(ComicBookVC*)[ComicBookDict objectForKey:[NSString stringWithFormat:@"%d",TagRecord]];
        [comic ResetBook];
    }
    
    TagRecord=Tag;
}

#pragma mark - Events Methods
- (IBAction)btnMeTouchDown:(id)sender
{
    [UIView animateWithDuration:0.1 animations:^
     {
         btnMe.layer.transform = CATransform3DMakeScale(0.9, 0.9, 1.0);
     }];
}

- (IBAction)btnMeTouchUpInside:(id)sender
{
    [self restoreTransformWithBounceForView:btnMe];
}

- (IBAction)btnMeTouchUpOutside:(id)sender
{
    [self restoreTransformWithBounceForView:btnMe];
}

- (IBAction)btnFriendTouchDown:(id)sender
{
    [UIView animateWithDuration:0.1 animations:^
     {
         btnFriend.layer.transform = CATransform3DMakeScale(0.9, 0.9, 1.0);
     }];
}

- (IBAction)btnFriendTouchUpInside:(id)sender
{
    [self restoreTransformWithBounceForView:btnFriend];
}

- (IBAction)btnFriendTouchUpOutside:(id)sender
{
    [self restoreTransformWithBounceForView:btnFriend];
}

- (void)restoreTransformWithBounceForView:(UIView*)view
{
    [UIView animateWithDuration:1
                          delay:0
         usingSpringWithDamping:0.2
          initialSpringVelocity:0.3
                        options:UIViewAnimationOptionTransitionCurlDown
                     animations:^
     {
         view.layer.transform = CATransform3DIdentity;
     }
                     completion:nil];
}

- (IBAction)btnPenTouchDown:(id)sender
{
    [UIView animateWithDuration:0.1 animations:^
     {
         viewPen.layer.transform = CATransform3DMakeScale(0.9, 0.9, 1.0);
     }];
}

- (IBAction)btnPenTouchUpInside:(id)sender
{
    [self restoreTransformWithBounceForView:viewPen];
}

- (IBAction)btnPenTouchUpOutside:(id)sender
{
    [self restoreTransformWithBounceForView:viewPen];
}

- (IBAction)tappedBackButton:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - helper methods

-(NSArray*)setupImages:(NSIndexPath*)indexPath
{
    /*
     NSMutableArray *images=[NSMutableArray new];
     
     if(indexPath.row%2)
     {
     for(int i=1;i<9;i++)
     {
     [  images addObject:   [UIImage imageNamed:[NSString stringWithFormat:@"d%d",i]]];
     }
     }
     else
     {
     for(int i=8;i>0;i--)
     {
     [  images addObject:   [UIImage imageNamed:[NSString stringWithFormat:@"d%d",i]]];
     }
     }
     
     if(4>=images.count)
     {
     if(indexPath.row%2)
     {
     [images insertObject: [UIImage imageNamed:@"cover" ] atIndex:0];
     }
     else
     {
     [images insertObject: [UIImage imageNamed:@"cover1" ] atIndex:0];
     }
     
     [images insertObject: [UIImage imageNamed:@"plain" ] atIndex:1];
     
     }
     else
     {
     if(indexPath.row%2)
     {
     [images insertObject: [UIImage imageNamed:@"cover" ] atIndex:0];
     }
     else
     {
     [images insertObject: [UIImage imageNamed:@"cover1" ] atIndex:0];
     }
     
     
     [images insertObject: [UIImage imageNamed:@"plain" ] atIndex:1];
     
     [images insertObject: [UIImage imageNamed:@"plain" ] atIndex:2];
     
     }
     return images;
     */
    
    NSMutableArray *slideImagesArray = [[NSMutableArray alloc] init];
    ComicBook *comicBook = [comicsArray objectAtIndex:indexPath.row];
    [slideImagesArray addObject:comicBook.coverImage];
    
    for(Slides *slides in comicBook.slides) {
        [slideImagesArray addObject:slides.slideImage];
    }
    return slideImagesArray;
}

- (void)callAPIToGetTheComics {
    [PrivateConversationAPIManager getPrivateConversationWithFriendId:self.friendObj.friendId
                                                        currentUserId:[AppHelper getCurrentLoginId]
                                                         SuccessBlock:^(id object) {
                                                             NSLog(@"%@", object);
                                                             NSError *error;
                                                             ComicsModel *comicsModel = [MTLJSONAdapter modelOfClass:ComicsModel.class fromJSONDictionary:[object valueForKey:@"data"] error:&error];
                                                             NSLog(@"%@", comicsModel);
                                                             comicsArray = comicsModel.books;
                                                             [self.tblvComics reloadData];
                                                         } andFail:^(NSError *errorMessage) {
                                                             NSLog(@"%@", errorMessage);
                                                         }];
}

@end