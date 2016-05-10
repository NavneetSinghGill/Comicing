//
//  MePageVC.m
//  CurlDemo
//
//  Created by Subin Kurian on 10/28/15.
//  Copyright © 2015 Subin Kurian. All rights reserved.
//

#import "MePageVC.h"
#import "MeCell.h"
#import "FriendCell.h"
#import "ComicCommentPeopleVC.h"
#import "MeAPIManager.h"
#import "ComicsModel.h"
#import "ComicBook.h"
#import "Slides.h"
#import "MePageDetailsVC.h"
#import "DateLabel.h"
#import "Utilities.h"
#import "Constants.h"
#import "TopBarViewController.h"
#import "CameraViewController.h"
#import "ContactsViewController.h"
#import "MainPageVC.h"
#import "TopSearchVC.h"
#import "AppHelper.h"
#import "ContactController.h"
#import "UIImageView+WebCache.h"
#import "AppHelper.h"
#import "CommentModel.h"

#define IS_IPHONE (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)
#define SCREEN_WIDTH ([[UIScreen mainScreen] bounds].size.width)
#define SCREEN_HEIGHT ([[UIScreen mainScreen] bounds].size.height)
#define SCREEN_MAX_LENGTH (MAX(SCREEN_WIDTH, SCREEN_HEIGHT))
#define SCREEN_MIN_LENGTH (MIN(SCREEN_WIDTH, SCREEN_HEIGHT))
#define IS_IPHONE_5 (IS_IPHONE && SCREEN_MAX_LENGTH == 568.0)
#define IS_IPHONE_6 (IS_IPHONE && SCREEN_MAX_LENGTH == 667.0)
#define IS_IPHONE_6P (IS_IPHONE && SCREEN_MAX_LENGTH == 736.0)

@interface MePageVC ()<commentersDelegate> {
    int TagRecord;
    NSMutableArray *comicsArray;
    NSUInteger selectedRow;
    NSUInteger currentPageDownScroll;
    NSUInteger currentPageUpScroll;
    NSUInteger lastPageDownScroll;
    NSUInteger lastPageUpScroll;
    NSString *nowLabel;
    NSString *currentlyShowingTimelinePeriodDownScroll;
    NSString *currentlyShowingTimelinePeriodUpScroll;
    TopBarViewController *topBarView;
    ComicsModel *comicsModelObj;
    UIRefreshControl *refreshControl;
    NSMutableArray *bubbleLabels;
}
@property (weak, nonatomic) IBOutlet UIView *NameView;
@property (weak, nonatomic) IBOutlet UITableView *tableview;
@property (assign, nonatomic) CATransform3D initialTransformation;

@property (weak, nonatomic) IBOutlet UIButton *NowButton;
@property (weak, nonatomic) IBOutlet UIButton *SecondButton;
@property (weak, nonatomic) IBOutlet UIButton *ThirdButton;
@property (weak, nonatomic) IBOutlet UIButton *FourthButton;
@property (weak, nonatomic) IBOutlet UIImageView *meUserPicImageView;
@property (weak, nonatomic) IBOutlet UILabel *lblFirstName;
@property (weak, nonatomic) IBOutlet UILabel *lblComicCount;

@end

@implementation MePageVC
@synthesize ComicBookDict;
- (void)viewDidLoad {
    
    [[GoogleAnalytics sharedGoogleAnalytics] logScreenEvent:@"MePage" Attributes:nil];

    [super viewDidLoad];
    [self addTopBarView];
    [self addUIRefreshControl];
    
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
    
    currentPageDownScroll = 0;
    currentPageUpScroll = 0;
    [self callAPIToGetTheComicsWithPageNumber:currentPageDownScroll + 1  andTimelinePeriod:@"" andDirection:@"" shouldClearAllData:YES];
    
    //Set Current User Pic
    [self.meUserPicImageView sd_setImageWithURL:[NSURL URLWithString:[[AppHelper initAppHelper] getCurrentUser].profile_pic]];
    self.lblFirstName.text = [[AppHelper initAppHelper] getCurrentUser].first_name;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 80;
}
- (UIView *) tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, tableView.bounds.size.width, 80)];
    [headerView setBackgroundColor:[UIColor clearColor]];
    return headerView;
}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
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
    //    if(currentPage < lastPage) {
    //        return comicsArray.count + 1;
    //    }
    return comicsArray.count;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    ComicBook *comicBook = [comicsArray objectAtIndex:indexPath.row];
    /* Test code for comments.
    CommentModel *commentModel1 = [[CommentModel alloc] init];
    commentModel1.firstName = @"Test1";
    commentModel1.lastName = @"Name1";
    commentModel1.profilePic = @"http://68.169.44.163/images/profileThumb/1.jpg";
    commentModel1.commentText = @"Test comment 1";
    
    CommentModel *commentModel2 = [[CommentModel alloc] init];
    commentModel2.firstName = @"Test2";
    commentModel2.lastName = @"Name2";
    commentModel2.profilePic = @"http://68.169.44.163/images/profileThumb/572a81e18cf01";
    commentModel2.commentText = @"Test comment 2";
    NSArray *a = @[commentModel1, commentModel2];
    comicBook.comments = a;
    */
    if(comicBook.comments.count > 0) {
        static NSString *simpleTableIdentifier = @"Cell";
        __block MeCell* cell= (MeCell*)[tableView dequeueReusableCellWithIdentifier:simpleTableIdentifier];
        cell=nil;
        if (cell == nil) {
            NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"MeCell" owner:self options:nil];
            cell = [nib objectAtIndex:0];
            if(nil!=[ComicBookDict objectForKey:[NSString stringWithFormat:@"%ld",(long)indexPath.row]])
                [ComicBookDict removeObjectForKey:[NSString stringWithFormat:@"%ld",(long)indexPath.row]];
            UIView *container=[cell viewWithTag:1];
            ComicBookVC*comic=[self.storyboard instantiateViewControllerWithIdentifier:@"ComicBookVC"];
            comic.delegate=self;
            comic.Tag=(int)indexPath.row;
            [container addSubview:comic.view];
//            [comic setImages: [self setupImages:indexPath]];
            
            ComicBook *comicBook = [comicsArray objectAtIndex:indexPath.row];
            [comic setSlidesArray:comicBook.slides];
            
            [comic setupBook];
            [self addChildViewController:comic];
            [ comic.view setTranslatesAutoresizingMaskIntoConstraints:NO];
            [self setBoundary:0 :0 toView:container addView:comic.view];
            [ComicBookDict setObject:comic forKey:[NSString stringWithFormat:@"%ld",(long)indexPath.row]];
            UIView *peopleContainer=[cell viewWithTag:2];
            peopleContainer.tag = indexPath.row;
            [self performSelectorInBackground:@selector(addCommentPeople:) withObject:peopleContainer];
        }
        return cell;
    } else {
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
//            [comic setImages: [self setupImages:indexPath]];
            
            ComicBook *comicBook = [comicsArray objectAtIndex:indexPath.row];
            // vishnu
            NSMutableArray *slidesArray = [[NSMutableArray alloc] init];
            [slidesArray addObjectsFromArray:comicBook.slides];
            
            // To repeat the cover image again on index page as the first slide.
            if(slidesArray.count > 1) {
                [slidesArray insertObject:[slidesArray firstObject] atIndex:1];
                
                // Adding a sample slide to array to maintain the logic
                Slides *slides = [Slides new];
                [slidesArray insertObject:slides atIndex:1];
            }
            
            [comic setSlidesArray:slidesArray];
            
            [comic setupBook];
            [ComicBookDict setObject:comic forKey:[NSString stringWithFormat:@"%ld",(long)indexPath.row]];
        }
        
        return cell;
    }
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

-(void)bookChanged:(int)Tag
{
    if(TagRecord!=Tag)
    {
        ComicBookVC*comic=(ComicBookVC*)[ComicBookDict objectForKey:[NSString stringWithFormat:@"%d",TagRecord]];
        [comic ResetBook];
    }
    TagRecord=Tag;
    
}

- (void)addTopBarView {
    topBarView = [self.storyboard instantiateViewControllerWithIdentifier:TOP_BAR_VIEW];
    [topBarView.view setFrame:CGRectMake(0, 0, self.view.frame.size.width, 50)];
    [self addChildViewController:topBarView];
    [self.view addSubview:topBarView.view];
    [topBarView didMoveToParentViewController:self];
    
    __block typeof(self) weakSelf = self;
    topBarView.homeAction = ^(void) {
        //        currentPageDownScroll = 0;
        //        currentPageUpScroll = 0;
        //        [weakSelf callAPIToGetTheComicsWithPageNumber:currentPageDownScroll + 1  andTimelinePeriod:@"" andDirection:@"" shouldClearAllData:YES];
        
//        MainPageVC *contactsView = [weakSelf.storyboard instantiateViewControllerWithIdentifier:MAIN_PAGE_VIEW];
//        [weakSelf presentViewController:contactsView animated:YES completion:nil];
        
        [weakSelf.navigationController popViewControllerAnimated:YES];
    };
    topBarView.contactAction = ^(void) {
//        ContactsViewController *contactsView = [weakSelf.storyboard instantiateViewControllerWithIdentifier:CONTACTS_VIEW];
//        [weakSelf presentViewController:contactsView animated:YES completion:nil];
        [AppHelper closeMainPageviewController:weakSelf];
    };
    topBarView.meAction = ^(void) {
        
    };
    topBarView.searchAction = ^(void) {
        TopSearchVC *topSearchView = [weakSelf.storyboard instantiateViewControllerWithIdentifier:TOP_SEARCH_VIEW];
        [topSearchView displayContentController:weakSelf];
        //        [weakSelf presentViewController:topSearchView animated:YES completion:nil];
    };
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

-(void)addCommentPeople:(UIView*)peopleContainer
{
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

- (void)callAPIToGetTheComicsWithPageNumber:(NSUInteger)page andTimelinePeriod:(NSString *)period andDirection:(NSString *)direction shouldClearAllData:(BOOL)clearData {
    [MeAPIManager getTimelineWithPageNumber:page
                             timelinePeriod:period
                                  direction:direction
                              currentUserId:[AppHelper getCurrentLoginId]
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
                                   
                                   
                                   //                                   NSMutableArray *tempArray = [[NSMutableArray alloc] init];
                                   //                                   [tempArray addObjectsFromArray:comicsModel.books];
                                   
                                   // adding the active code to each Book object so that it is possible to find the comics according to specific dates.
                                   
                                   //                                   for (ComicBook *book in tempArray) {
                                   //                                       book.periodCode = period;
                                   //                                   }
                                   
                                   // check if we have the same periodCode data, then add this response to it. If we dont have, then check the position to be added and add it.
                                   //                                   if([self haveComicForThePeriod:period]) {
                                   //                                       NSRange range;
                                   //                                       range.length = tempArray.count;
                                   //                                       range.location = [self getLastIndexOfComicForThePeriod:period] + 1;
                                   //                                       NSIndexSet *indexSet = [NSIndexSet indexSetWithIndexesInRange:range];
                                   //                                       [comicsArray insertObjects:tempArray atIndexes:indexSet];
                                   //                                   } else {
                                   //                                       if([period isEqualToString:ONE_MONTH]) {
                                   //                                           NSRange range;
                                   //                                           range.length = tempArray.count;
                                   //                                           range.location = [self getLastIndexOfComicForThePeriod:ONE_WEEK] + 1;
                                   //                                           NSIndexSet *indexSet = [NSIndexSet indexSetWithIndexesInRange:range];
                                   //                                           [comicsArray insertObjects:tempArray atIndexes:indexSet];
                                   //                                       } else {
                                   //                                           // all comics for ONE_WEEK and THREE_MONTHS
                                   //                                           [comicsArray addObjectsFromArray:tempArray];
                                   //                                       }
                                   //                                   }
                                   self.lblComicCount.text =  @"0 Comic";
                                   if(clearData) {
                                       [comicsArray removeAllObjects];
                                       lastPageDownScroll = [comicsModelObj.pagination.last integerValue];
                                       currentPageDownScroll = [comicsModelObj.pagination.current integerValue];
                                       [comicsArray addObjectsFromArray:comicsModelObj.books];
                                       
                                       NSString *period = [self getTheDefaultPeriod:comicsModelObj];
                                       currentlyShowingTimelinePeriodUpScroll = period;
                                       currentlyShowingTimelinePeriodDownScroll = period;
                                       self.lblComicCount.text = [NSString stringWithFormat:@"%lu Comics",(unsigned long)[comicsArray count]];
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

- (NSUInteger)getFirstIndexOfComicForThePeriod:(NSString *)period {
    NSString *predStr = [NSString stringWithFormat:@"periodCode == \"%@\"", period];
    NSPredicate *pred = [NSPredicate predicateWithFormat:predStr];
    NSArray *result = [comicsArray filteredArrayUsingPredicate:pred];
    if(result.count > 0) {
        ComicBook *comicBook = result[0];
        NSLog(@"%lu", (unsigned long)[comicsArray indexOfObject:comicBook]);
        return (unsigned long)[comicsArray indexOfObject:comicBook];
    }
    return 0;
}

- (NSUInteger)getLastIndexOfComicForThePeriod:(NSString *)period {
    NSString *predStr = [NSString stringWithFormat:@"periodCode == \"%@\"", period];
    NSPredicate *pred = [NSPredicate predicateWithFormat:predStr];
    NSArray *result = [comicsArray filteredArrayUsingPredicate:pred];
    if(result.count > 0) {
        ComicBook *comicBook = [result lastObject];
        NSLog(@"%lu", (unsigned long)[comicsArray indexOfObject:comicBook]);
        return (unsigned long)[comicsArray indexOfObject:comicBook];
    }
    return 0;
}

- (BOOL)haveComicForThePeriod:(NSString *)period {
    NSString *predStr = [NSString stringWithFormat:@"periodCode == \"%@\"", period];
    NSPredicate *pred = [NSPredicate predicateWithFormat:predStr];
    NSArray *result = [comicsArray filteredArrayUsingPredicate:pred];
    if(result.count > 0) {
        return YES;
    }
    return NO;
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

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if([segue.identifier isEqualToString:@"MePageDetailsVC"]) {
        MePageDetailsVC *mePageDetails = [segue destinationViewController];
        mePageDetails.comicBook = [comicsArray objectAtIndex:selectedRow];
    }
}

- (IBAction)btnContactClick:(id)sender {
    
    UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:@"Main" bundle: nil];
    ContactController* cVc = (ContactController *)[mainStoryboard instantiateViewControllerWithIdentifier:@"Contact"];
    mainStoryboard = nil;
    [self.navigationController pushViewController:cVc animated:YES];
//    [self presentViewController:cVc animated:YES
//                   completion:^{
//                   }];
}

@end
