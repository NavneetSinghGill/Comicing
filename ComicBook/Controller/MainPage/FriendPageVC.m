//
//  FriendPageVC.m
//  CurlDemo
//
//  Created by Vishnu Vardhan PV on 03/02/16.
//  Copyright © 2016 Vishnu Vardhan PV. All rights reserved.
//

#import "FriendPageVC.h"
#import "MePageVC.h"
#import "MeCell.h"
#import "FriendCell.h"
#import "MeAPIManager.h"
#import "ComicsModel.h"
#import "ComicBook.h"
#import "Slides.h"
#import "MePageDetailsVC.h"
#import "CameraViewController.h"
#import "ContactsViewController.h"
#import "Constants.h"
#import "UIImageView+WebCache.h"
#import "FriendsAPIManager.h"
#import "Utilities.h"
#import "TopSearchVC.h"
#import "AppHelper.h"
#import "AppDelegate.h"

#define IS_IPHONE (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)
#define SCREEN_WIDTH ([[UIScreen mainScreen] bounds].size.width)
#define SCREEN_HEIGHT ([[UIScreen mainScreen] bounds].size.height)
#define SCREEN_MAX_LENGTH (MAX(SCREEN_WIDTH, SCREEN_HEIGHT))
#define SCREEN_MIN_LENGTH (MIN(SCREEN_WIDTH, SCREEN_HEIGHT))
#define IS_IPHONE_5 (IS_IPHONE && SCREEN_MAX_LENGTH == 568.0)
#define IS_IPHONE_6 (IS_IPHONE && SCREEN_MAX_LENGTH == 667.0)
#define IS_IPHONE_6P (IS_IPHONE && SCREEN_MAX_LENGTH == 736.0)


@implementation FriendPageVC

@synthesize ComicBookDict;

- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    [[GoogleAnalytics sharedGoogleAnalytics] logScreenEvent:@"FriendPage" Attributes:nil];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(.05 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        self.currentButton=self.NowButton;
        [UIView beginAnimations:@"ScaleButton" context:NULL];
        [UIView setAnimationDuration: 0.5f];
        self.currentButton.transform = CGAffineTransformMakeScale(1.25,1.25);
        CGRect rect= self.currentButton.frame;
        rect.origin.x=0;
        self.currentButton.frame=rect;
        [UIView commitAnimations];
    });
    [self addTopBarView];
    ComicBookDict=[NSMutableDictionary new];
    TagRecord=0;
    // Do any additional setup after loading the view.
    CGFloat rotationAngleDegrees = -15;
    CGFloat rotationAngleRadians = rotationAngleDegrees * (M_PI/180);
    CGPoint offsetPositioning = CGPointMake(-20, -20);
    
    CATransform3D transform = CATransform3DIdentity;
    transform = CATransform3DRotate(transform, rotationAngleRadians, 0.0, 0.0, 1.0);
    transform = CATransform3DTranslate(transform, offsetPositioning.x, offsetPositioning.y, 0.0);
    _initialTransformation = transform;
    
    self.friendBubble.alpha = 0;
    self.profilePicButton.layer.cornerRadius = CGRectGetHeight(self.profilePicButton.frame) / 2;
    //    self.profilePicButton.backgroundColor = [UIColor grayColor];
    self.profileImageView.layer.cornerRadius = CGRectGetHeight(self.profileImageView.frame) / 2;
    self.profileImageView.clipsToBounds = YES;
    [self.profileImageView sd_setImageWithURL:[NSURL URLWithString:[AppDelegate application].dataManager.friendObject.profilePic]];
    [self.nameLabel setText:[NSString stringWithFormat:@"%@ %@", [AppDelegate application].dataManager.friendObject.firstName, [AppDelegate application].dataManager.friendObject.lastName]];
    
    [self addUIRefreshControl];
    currentPageDownScroll = 0;
    currentPageUpScroll = 0;
    [self callAPIToGetTheComicsWithPageNumber:currentPageDownScroll + 1  andTimelinePeriod:@"" andDirection:@"" shouldClearAllData:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 80;
}
- (UIView *) tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, tableView.bounds.size.width, 80)];
    [headerView setBackgroundColor:[UIColor clearColor]];
    return headerView;
}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    int height=0;
    if(IS_IPHONE_5)
    {
        height=169;
    }
    else if(IS_IPHONE_6)
    {
        height= 199;
    }
    else if(IS_IPHONE_6P)
    {
        height= 229;
    }
    
    
    return tableView.bounds.size.height-height;
    
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return comicsArray.count;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *simpleTableIdentifier = @"Cell";
    __block FriendCell * cell= (FriendCell*)[tableView dequeueReusableCellWithIdentifier:simpleTableIdentifier];
    cell = nil;
    if (cell == nil) {
        NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"FreindCellxib" owner:self options:nil];
        cell = [nib objectAtIndex:0];
        
        if(nil!=[ComicBookDict objectForKey:[NSString stringWithFormat:@"%ld",(long)indexPath.row]])
        {
            [ComicBookDict removeObjectForKey:[NSString stringWithFormat:@"%ld",(long)indexPath.row]];
        }
        
        ComicBookVC *comic=[self.storyboard instantiateViewControllerWithIdentifier:@"ComicBookVC"];
        comic.delegate=self;
        comic.Tag=(int)indexPath.row;
        
        comic.view.frame = CGRectMake(0, 0, CGRectGetWidth(cell.viewComicBook.frame), CGRectGetHeight(cell.viewComicBook.frame));
        
        [cell.viewComicBook addSubview:comic.view];
        [self addChildViewController:comic];
        [comic setImages: [self setupImages:indexPath]];
        [comic setupBook];
        [ComicBookDict setObject:comic forKey:[NSString stringWithFormat:@"%ld",(long)indexPath.row]];
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    if(indexPath.row == comicsArray.count - 1 && currentPageDownScroll < lastPageDownScroll) {
        // downscroll with same period
        [self callAPIToGetTheComicsWithPageNumber:currentPageDownScroll + 1  andTimelinePeriod:currentlyShowingTimelinePeriodDownScroll andDirection:DIRECTION_DOWN shouldClearAllData:NO];
    } else if(indexPath.row == comicsArray.count - 1 && currentPageDownScroll == lastPageDownScroll) {
        // downscroll with next period
        if([self getTheNextPeriod:currentlyShowingTimelinePeriodDownScroll] != nil) {
            currentPageDownScroll = 0;
            [self callAPIToGetTheComicsWithPageNumber:currentPageDownScroll + 1  andTimelinePeriod:[self getTheNextPeriod:currentlyShowingTimelinePeriodDownScroll] andDirection:DIRECTION_DOWN shouldClearAllData:NO];
        }
    }
    
    cell.contentView.layer.shadowColor = [[UIColor blackColor] CGColor];
    cell.contentView.layer.shadowOffset = CGSizeMake(10, 10);
    cell.contentView.alpha = 0;
    cell.contentView.layer.transform = CATransform3DMakeScale(0.5, 0.5, 0.5);
    cell.contentView.layer.anchorPoint = CGPointMake(0.5, 0.5);
    
    [UIView animateWithDuration:1 animations:^{
        cell.contentView.layer.shadowOffset = CGSizeMake(0, 0);
        cell.contentView.alpha = 1;
        cell.contentView.layer.transform = CATransform3DIdentity;
        
    }];
}

-(void)bookChanged:(int)Tag {
    if(TagRecord!=Tag)
    {
        ComicBookVC*comic=(ComicBookVC*)[ComicBookDict objectForKey:[NSString stringWithFormat:@"%d",TagRecord]];
        [comic ResetBook];
    }
    TagRecord=Tag;
}

- (void)addUIRefreshControl {
    refreshControl = [[UIRefreshControl alloc] init];
    refreshControl.tintColor = [UIColor whiteColor];
    [self.tableview addSubview:refreshControl];
    [refreshControl addTarget:self
                       action:@selector(refreshTable)
             forControlEvents:UIControlEventValueChanged];
}

- (void)refreshTable {
    [refreshControl endRefreshing];
    if(currentPageUpScroll == 0 || currentPageUpScroll == lastPageUpScroll) {
        currentPageUpScroll = 0;
        // upscroll with previous period
        if([self getThePreviousPeriod:currentlyShowingTimelinePeriodUpScroll] != nil) {
            [self callAPIToGetTheComicsWithPageNumber:currentPageUpScroll + 1 andTimelinePeriod:[self getThePreviousPeriod:currentlyShowingTimelinePeriodUpScroll] andDirection:DIRECTION_UP shouldClearAllData:NO];
        }
    } else if(currentPageUpScroll < lastPageUpScroll) {
        // upscroll with same period
        [self callAPIToGetTheComicsWithPageNumber:currentPageUpScroll + 1 andTimelinePeriod:currentlyShowingTimelinePeriodUpScroll andDirection:DIRECTION_UP shouldClearAllData:NO];
    }
}

-(NSArray*)setupImages:(NSIndexPath*)indexPath {
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

- (void)addTopBarView {
    topBarView = [self.storyboard instantiateViewControllerWithIdentifier:TOP_BAR_VIEW];
    [topBarView.view setFrame:CGRectMake(0, 0, self.view.frame.size.width, 50)];
    [self addChildViewController:topBarView];
    [self.view addSubview:topBarView.view];
    [topBarView didMoveToParentViewController:self];
    
    __block typeof(self) weakSelf = self;
    topBarView.homeAction = ^(void) {
        currentPageDownScroll = 0;
        currentPageUpScroll = 0;
        [weakSelf callAPIToGetTheComicsWithPageNumber:currentPageDownScroll + 1  andTimelinePeriod:@"" andDirection:@"" shouldClearAllData:YES];
    };
    topBarView.contactAction = ^(void) {
//        ContactsViewController *contactsView = [weakSelf.storyboard instantiateViewControllerWithIdentifier:CONTACTS_VIEW];
//        [weakSelf presentViewController:contactsView animated:YES completion:nil];
        [AppHelper closeMainPageviewController:self];
    };
    topBarView.meAction = ^(void) {
        MePageVC *meView = [weakSelf.storyboard instantiateViewControllerWithIdentifier:ME_VIEW_SEGUE];
//        [weakSelf presentViewController:meView animated:YES completion:nil];
        [weakSelf.navigationController pushViewController:meView animated:YES];
    };
    topBarView.searchAction = ^(void) {
        TopSearchVC *topSearchView = [weakSelf.storyboard instantiateViewControllerWithIdentifier:TOP_SEARCH_VIEW];
        [topSearchView displayContentController:self];
        //        [weakSelf presentViewController:topSearchView animated:YES completion:nil];
    };
}

-(void)addCommentPeople:(UIView*)peopleContainer {
    dispatch_async(dispatch_get_main_queue(), ^{
        ComicCommentPeopleVC*people=[self.storyboard instantiateViewControllerWithIdentifier:@"ComicCommentPeopleVC"];
        people.delegate=self;
        people.row = peopleContainer.tag;
        ComicBook *comicBook = [comicsArray objectAtIndex:peopleContainer.tag];
        people.CommentPeopleArray = comicBook.comments;
        [peopleContainer addSubview:people.view];
        [self addChildViewController:people];
        [people.view setTranslatesAutoresizingMaskIntoConstraints:NO];
        [self setBoundary:0 :0 toView:peopleContainer addView:people.view];
    });
}

-(void)commentersPressedAtRow:(NSUInteger)row {
    selectedRow = row;
    [self performSegueWithIdentifier:@"MePageDetailsVC" sender:self];
}
- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    CGFloat offset = scrollView.contentOffset.y; // here you will get the offset value
    CGFloat value = offset / self.tableview.frame.size.height;
    
    if(value>0&&value<2.8)
    {
        
        self.NameView.alpha=1-value/4;
    }
}

-(void) setBoundary :(float) x :(float) y toView:(UIView*)parent addView:(UIView*)child
{
    
    [parent addConstraint:[NSLayoutConstraint constraintWithItem:child
                                                       attribute:NSLayoutAttributeWidth
                                                       relatedBy:NSLayoutRelationEqual
                                                          toItem:parent
                                                       attribute:NSLayoutAttributeWidth
                                                      multiplier:1.0
                                                        constant:0]];
    
    // Height constraint, half of parent view height
    [parent addConstraint:[NSLayoutConstraint constraintWithItem:child
                                                       attribute:NSLayoutAttributeHeight
                                                       relatedBy:NSLayoutRelationEqual
                                                          toItem:parent
                                                       attribute:NSLayoutAttributeHeight
                                                      multiplier:1
                                                        constant:0]];
    
    
    [parent addConstraint:[NSLayoutConstraint constraintWithItem:child
                                                       attribute:NSLayoutAttributeLeading                                                       relatedBy:NSLayoutRelationEqual
                                                          toItem:parent
                                                       attribute:NSLayoutAttributeLeading
                                                      multiplier:1.0
                                                        constant:0]];
    
    
    [parent addConstraint:[NSLayoutConstraint constraintWithItem:child
                                                       attribute:NSLayoutAttributeTop
                                                       relatedBy:NSLayoutRelationEqual
                                                          toItem:parent
                                                       attribute:NSLayoutAttributeTop
                                                      multiplier:1.0
                                                        constant:0]];
    [parent layoutIfNeeded];
    
}

-(IBAction)TimeLineAction:(UIButton*)sender {
    if(sender.tag < bubbleLabels.count) {
        [self addTimelineButtonAnimation:sender];
        DateLabel *dateLabel = [bubbleLabels objectAtIndex:sender.tag];
        NSString *period = dateLabel.code;
        if(period.length != 0) {
            [self makeTimelinePopulateWithPeriod:period];
        }
    }
    //    if(sender.tag == 0) {
    //        [self makeTimelinePopulateWithPeriod:NOW];
    //    } else if(sender.tag == 1) {
    //        [self makeTimelinePopulateWithPeriod:ONE_WEEK];
    //    } else if(sender.tag == 2) {
    //        [self makeTimelinePopulateWithPeriod:ONE_MONTH];
    //    } else if(sender.tag == 3) {
    //        [self makeTimelinePopulateWithPeriod:THREE_MONTHS];
    //    }
}

- (void)makeTimelinePopulateWithPeriod:(NSString *)period {
    //    if([nowLabel isEqualToString:period]) {
    //        [self makeTableViewScrollToIndexPath:0];
    //    } else {
    //        if([self haveComicForThePeriod:period]) {
    //            [self makeTableViewScrollToIndexPath:[self getFirstIndexOfComicForThePeriod:period]];
    //        } else {
    currentPageUpScroll = 0;
    // call api to get comics
    [self callAPIToGetTheComicsWithPageNumber:1 andTimelinePeriod:period andDirection:DIRECTION_DOWN shouldClearAllData:YES];
    //        }
    //    }
}

- (void)makeTableViewScrollToIndexPath:(NSUInteger)index {
    NSIndexPath *indexpath = [NSIndexPath indexPathForRow:index inSection:0];
    [self.tableview scrollToRowAtIndexPath:indexpath atScrollPosition:UITableViewScrollPositionTop animated:YES];
}

- (void)addTimelineButtonAnimation:(UIButton *)sender {
    [UIView beginAnimations:@"ScaleButton" context:NULL];
    [UIView setAnimationDuration: 0.5f];
    self.currentButton.transform = CGAffineTransformMakeScale(1,1);
    CGRect rect= self.currentButton.frame;
    rect.origin.x=0;
    self.currentButton.frame=rect;
    [UIView commitAnimations];
    self.currentButton=sender;
    [UIView beginAnimations:@"ScaleButton" context:NULL];
    [UIView setAnimationDuration: 0.5f];
    self.currentButton.transform = CGAffineTransformMakeScale(1.25,1.25);
    CGRect rect1= self.currentButton.frame;
    rect1.origin.x=0;
    self.currentButton.frame=rect1;
    [UIView commitAnimations];
}

- (void)hideFriendBubble
{
    [UIView animateWithDuration:0.5 animations:^
     {
         self.friendBubble.alpha = 0;
         self.profileImageView.userInteractionEnabled = YES;
     }];
}

- (IBAction)tappedUserPic:(id)sender {
    if([Utilities isReachable]) {
        if ([[AppDelegate application].dataManager.friendObject.status intValue] == 0) {
            // friend API
            [self callFriendUnfriendAPIWithStatus:@"1"];
            self.profileImageView.backgroundColor = [UIColor grayColor];
            self.profileImageView.userInteractionEnabled = NO;
            
            self.friendBubble.image = [UIImage imageNamed:@"friendBubble.png"];
            
            [UIView animateWithDuration:0.3 animations:^
             {
                 self.profileImageView.transform = CGAffineTransformMakeScale(0.7, 0.7);
             }
                             completion:^(BOOL finished)
             {
                 [UIView animateWithDuration:0.3 animations:^
                  {
                      self.profileImageView.transform = CGAffineTransformIdentity;
                  }
                                  completion:^(BOOL finished)
                  {
                      [UIView animateWithDuration:0.5 animations:^
                       {
                           self.friendBubble.alpha = 1;
                       }
                                       completion:^(BOOL finished)
                       {
                           NSTimeInterval delay1 = 2; //in seconds
                           [self performSelector:@selector(hideFriendBubble) withObject:nil afterDelay:delay1];
                       }];
                  }];
             }];
        } else {
            // unfriend API
            [self callFriendUnfriendAPIWithStatus:@"0"];
            self.profileImageView.backgroundColor = [UIColor colorWithRed:0.21 green:0.69 blue:0.93 alpha:1];
            self.profileImageView.userInteractionEnabled = NO;
            
            self.friendBubble.image = [UIImage imageNamed:@"unFriendBubble.png"];
            
            [UIView animateWithDuration:0.3 animations:^
             {
                 self.profileImageView.transform = CGAffineTransformMakeScale(0.7, 0.7);
             }
                             completion:^(BOOL finished)
             {
                 [UIView animateWithDuration:0.3 animations:^
                  {
                      self.profileImageView.transform = CGAffineTransformIdentity;
                  }
                                  completion:^(BOOL finished)
                  {
                      [UIView animateWithDuration:0.5 animations:^
                       {
                           self.friendBubble.alpha = 1;
                       }
                                       completion:^(BOOL finished)
                       {
                           NSTimeInterval delay1 = 2; //in seconds
                           [self performSelector:@selector(hideFriendBubble) withObject:nil afterDelay:delay1];
                       }];
                  }];
             }];
        }
    }
}

- (IBAction)tappedBackButton:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)callAPIToGetTheComicsWithPageNumber:(NSUInteger)page andTimelinePeriod:(NSString *)period andDirection:(NSString *)direction shouldClearAllData:(BOOL)clearData {
    [MeAPIManager getTimelineWithPageNumber:page
                             timelinePeriod:period
                                  direction:direction
                              currentUserId:[AppDelegate application].dataManager.friendObject.userId
                               SuccessBlock:^(id object) {
                                   NSLog(@"%@", object);
                                   NSError *error;
                                   comicsModelObj = [MTLJSONAdapter modelOfClass:ComicsModel.class fromJSONDictionary:[object valueForKey:@"data"] error:&error];
                                   NSLog(@"%@", comicsModelObj);
                                   if(currentPageDownScroll == 0 && period.length == 0) {
                                       nowLabel = [self getTheDefaultPeriod:comicsModelObj];
                                       [self configureBubbleLabelsArray:comicsModelObj];
                                       comicsArray = [[NSMutableArray alloc] init];
                                       currentlyShowingTimelinePeriodDownScroll = nil;
                                       
                                       NSString *period = [self getTheDefaultPeriod:comicsModelObj];
                                       currentlyShowingTimelinePeriodUpScroll = period;
                                   }
                                   if(clearData) {
                                       [comicsArray removeAllObjects];
                                       lastPageDownScroll = [comicsModelObj.pagination.last integerValue];
                                       currentPageDownScroll = [comicsModelObj.pagination.current integerValue];
                                       [comicsArray addObjectsFromArray:comicsModelObj.books];
                                       
                                       NSString *period = [self getTheDefaultPeriod:comicsModelObj];
                                       currentlyShowingTimelinePeriodUpScroll = period;
                                       currentlyShowingTimelinePeriodDownScroll = period;
                                   } else if([direction isEqualToString:DIRECTION_UP]) {
                                       NSMutableArray *tempArray = [[NSMutableArray alloc] init];
                                       [tempArray addObjectsFromArray:comicsModelObj.books];
                                       
                                       NSRange range;
                                       range.length = tempArray.count;
                                       range.location = 0;
                                       NSIndexSet *indexSet = [NSIndexSet indexSetWithIndexesInRange:range];
                                       [comicsArray insertObjects:tempArray atIndexes:indexSet];
                                       
                                       lastPageUpScroll = [comicsModelObj.pagination.last integerValue];
                                       currentPageUpScroll = [comicsModelObj.pagination.current integerValue];
                                       
                                       NSString *period = [self getTheDefaultPeriod:comicsModelObj];
                                       currentlyShowingTimelinePeriodUpScroll = period;
                                   } else {
                                       lastPageDownScroll = [comicsModelObj.pagination.last integerValue];
                                       currentPageDownScroll = [comicsModelObj.pagination.current integerValue];
                                       
                                       NSString *period = [self getTheDefaultPeriod:comicsModelObj];
                                       currentlyShowingTimelinePeriodDownScroll = period;
                                       
                                       [comicsArray addObjectsFromArray:comicsModelObj.books];
                                   }
                                   [self.tableview reloadData];
                               } andFail:^(NSError *errorMessage) {
                                   NSLog(@"%@", errorMessage);
                               }];
}

- (NSString *)getTheDefaultPeriod:(ComicsModel *)comicsModel {
    NSString *predStr = @"active == 1";
    NSPredicate *pred = [NSPredicate predicateWithFormat:predStr];
    NSArray *result = [comicsModel.dateLabels filteredArrayUsingPredicate:pred];
    if(result.count > 0) {
        DateLabel *dateLabel = result[0];
        return dateLabel.code;
    }
    return nil;
}

- (NSString *)getTheNextPeriod:(NSString *)currentPeriod {
    NSString *predStr = [NSString stringWithFormat:@"code == \"%@\"", currentPeriod];
    NSPredicate *pred = [NSPredicate predicateWithFormat:predStr];
    NSArray *result = [comicsModelObj.dateLabels filteredArrayUsingPredicate:pred];
    if(result.count > 0) {
        DateLabel *dateLabel = result[0];
        NSUInteger indexOfObj = [comicsModelObj.dateLabels indexOfObject:dateLabel];
        if(indexOfObj+1 < comicsModelObj.dateLabels.count) {
            DateLabel *dateLabelObj = comicsModelObj.dateLabels[indexOfObj+1];
            return dateLabelObj.code;
        }
    }
    return nil;
}

- (NSString *)getThePreviousPeriod:(NSString *)currentPeriod {
    NSString *predStr = [NSString stringWithFormat:@"code == \"%@\"", currentPeriod];
    NSPredicate *pred = [NSPredicate predicateWithFormat:predStr];
    NSArray *result = [comicsModelObj.dateLabels filteredArrayUsingPredicate:pred];
    if(result.count > 0) {
        DateLabel *dateLabel = result[0];
        NSUInteger indexOfObj = [comicsModelObj.dateLabels indexOfObject:dateLabel];
        if(indexOfObj != 0) {
            DateLabel *dateLabelObj = comicsModelObj.dateLabels[indexOfObj-1];
            return dateLabelObj.code;
        }
    }
    return nil;
}

- (void)setBubbleLabels {
    [self.FourthButton setHidden:TRUE];
    [self.ThirdButton setHidden:TRUE];
    [self.SecondButton setHidden:TRUE];
    [self.NowButton setHidden:TRUE];
    
    if(bubbleLabels.count > 3) {
        DateLabel *dateLabel = bubbleLabels[3];
        [self.FourthButton.titleLabel setTextAlignment: NSTextAlignmentCenter];
        [self.FourthButton setTitle:[Utilities getDateStringForParam:dateLabel.code] forState:UIControlStateNormal];
        [self.FourthButton setHidden:FALSE];
    }
    if(bubbleLabels.count > 2) {
        DateLabel *dateLabel = bubbleLabels[2];
        [self.ThirdButton.titleLabel setTextAlignment: NSTextAlignmentCenter];
        [self.ThirdButton setTitle:[Utilities getDateStringForParam:dateLabel.code] forState:UIControlStateNormal];
        [self.ThirdButton setHidden:FALSE];
    }
    if(bubbleLabels.count > 1) {
        DateLabel *dateLabel = bubbleLabels[1];
        [self.SecondButton.titleLabel setTextAlignment: NSTextAlignmentCenter];
        [self.SecondButton setTitle:[Utilities getDateStringForParam:dateLabel.code] forState:UIControlStateNormal];
        [self.SecondButton setHidden:FALSE];
    }
    if(bubbleLabels.count > 0) {
        DateLabel *dateLabel = bubbleLabels[0];
        [self.NowButton.titleLabel setTextAlignment: NSTextAlignmentCenter];
        [self.NowButton setTitle:[Utilities getDateStringForParam:dateLabel.code] forState:UIControlStateNormal];
        [self.NowButton setHidden:FALSE];
    }
}

- (void)configureBubbleLabelsArray:(ComicsModel *)comicsModel {
    if(comicsModel.dateLabels.count > 0) {
        bubbleLabels = [[NSMutableArray alloc] init];
        if(comicsModel.dateLabels.count < 2) {
            [bubbleLabels addObject:comicsModel.dateLabels[0]];
        } else if(comicsModel.dateLabels.count < 3) {
            [bubbleLabels addObject:comicsModel.dateLabels[0]];
            
            DateLabel *dateLabel1 = comicsModel.dateLabels[0];
            DateLabel *dateLabel2 = comicsModel.dateLabels[1];
            if(![[Utilities getDateStringForParam:dateLabel1.code] isEqualToString:[Utilities getDateStringForParam:dateLabel2.code]]) {
                [bubbleLabels addObject:comicsModel.dateLabels[1]];
            }
            
            
        } else if(comicsModel.dateLabels.count <= 4) {
            [bubbleLabels addObject:comicsModel.dateLabels[0]];
            
            DateLabel *dateLabel1 = comicsModel.dateLabels[0];
            DateLabel *dateLabel2 = comicsModel.dateLabels[1];
            if(![[Utilities getDateStringForParam:dateLabel1.code] isEqualToString:[Utilities getDateStringForParam:dateLabel2.code]]) {
                [bubbleLabels addObject:comicsModel.dateLabels[1]];
            }
            
            DateLabel *dateLabel3 = comicsModel.dateLabels[1];
            DateLabel *dateLabel4 = comicsModel.dateLabels[2];
            if(![[Utilities getDateStringForParam:dateLabel3.code] isEqualToString:[Utilities getDateStringForParam:dateLabel4.code]]) {
                [bubbleLabels addObject:comicsModel.dateLabels[2]];
            }
            if(comicsModel.dateLabels.count == 4) {
                [bubbleLabels addObject:comicsModel.dateLabels[3]];
            }
        }
        [self setBubbleLabels];
    }
}

- (void)callFriendUnfriendAPIWithStatus:(NSString *)status {
    [FriendsAPIManager makeFirendOrUnfriendForUserId:[AppDelegate application].dataManager.friendObject.userId
                                          WithStatus:status
                                    withSuccessBlock:^(id object) {
                                        NSLog(@"%@", object);
                                        // logic to set the status from API.
                                        NSMutableArray *friends = [[MTLJSONAdapter modelsOfClass:[Friend class] fromJSONArray:[object valueForKey:@"data"] error:nil] mutableCopy];
                                        NSPredicate *pred = [NSPredicate predicateWithFormat:[NSString stringWithFormat:@"friendId == \"%@\"", [AppDelegate application].dataManager.friendObject.userId]];
                                        NSArray *result = [friends filteredArrayUsingPredicate:pred];
                                        if(result.count > 0) {
                                            Friend *friend = [result firstObject];
                                            [AppDelegate application].dataManager.friendObject.status = friend.status;
                                        }
                                    } andFail:^(NSError *errorMessage) {
                                        NSLog(@"%@", errorMessage);
                                    }];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if([segue.identifier isEqualToString:@"MePageDetailsVC"]) {
        MePageDetailsVC *mePageDetails = [segue destinationViewController];
        mePageDetails.comicBook = [comicsArray objectAtIndex:selectedRow];
    }
}

@end