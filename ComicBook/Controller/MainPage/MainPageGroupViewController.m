//
//  GroupViewController.m
//  ComicApp
//
//  Created by ADNAN THATHIYA on 31/10/15.
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

#import "MainPageGroupViewController.h"
#import "CMCUserCell.h"
#import "CMCComicCell.h"
#import "MeCell.h"
#import "GroupsAPIManager.h"
#import "Group.h"
#import "ComicsModel.h"
#import "ComicBook.h"
#import "UIButton+WebCache.h"
#import "UIImageView+WebCache.h"
#import "UserDetail.h"
#import "Slides.h"
#import "GroupCell.h"
#import "GlideScrollViewController.h"

@interface MainPageGroupViewController ()
<UITableViewDataSource,
UITableViewDelegate,
UICollectionViewDataSource,
UICollectionViewDelegate>
{
    int TagRecord;
}


@property (weak, nonatomic) IBOutlet UICollectionView *clvUsers;
@property (weak, nonatomic) IBOutlet UITableView *tblvComics;
@property (weak, nonatomic) IBOutlet UIView *viewTopBar;
@property (weak, nonatomic) IBOutlet UIView *viewTransperant;
@property (weak, nonatomic) IBOutlet UIImageView *imgvGroupIcon;
@property (weak, nonatomic) IBOutlet UIView *viewPen;
@property (weak, nonatomic) IBOutlet UIImageView *imgvPinkDots;

@property (strong, nonatomic) NSMutableArray *groupMember;
@property (strong, nonatomic) NSMutableArray *comics;

@property CGRect saveTableViewFrame;

@end

@implementation MainPageGroupViewController

@synthesize groupMember,comics, tblvComics, clvUsers, viewTopBar, saveTableViewFrame, viewTransperant, ComicBookDict, imgvGroupIcon,viewPen;

#pragma mark - UIViewController Methods
- (void)viewDidLoad
{
    [[GoogleAnalytics sharedGoogleAnalytics] logScreenEvent:@"MainPage-GroupPage" Attributes:nil];
    
    ComicBookDict=[NSMutableDictionary new];
    [super viewDidLoad];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(callAPItoGetGroupsComics) name:@"UpdateGroupComics" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(startReplyComicAnimation) name:@"StartGroupReplyComicAnimation" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(stopReplyComicAnimation) name:@"StopGroupReplyComicAnimation" object:nil];
    [self prepareView];
}

#pragma mark - UIView Methods
- (void)prepareView
{
    if(IS_IPHONE_5)
    {
        imgvGroupIcon.frame = CGRectMake(CGRectGetMinX(imgvGroupIcon.frame),
                                         CGRectGetMinY(imgvGroupIcon.frame),
                                         CGRectGetWidth(imgvGroupIcon.frame),
                                         CGRectGetHeight(imgvGroupIcon.frame));
    }
    else if(IS_IPHONE_6)
    {
        imgvGroupIcon.frame = CGRectMake(CGRectGetMinX(imgvGroupIcon.frame),
                                         CGRectGetMinY(imgvGroupIcon.frame),
                                         66,
                                         66);
    }
    else if(IS_IPHONE_6P)
    {
        imgvGroupIcon.frame = CGRectMake(CGRectGetMinX(imgvGroupIcon.frame),
                                         CGRectGetMinY(imgvGroupIcon.frame),
                                         72,
                                         72);
    }
    
    comics = [[NSMutableArray alloc] init];
    groupMember = [[NSMutableArray alloc] init];
    
    saveTableViewFrame = tblvComics.frame;
    
    [self.imgvGroupIcon sd_setImageWithURL:[NSURL URLWithString:self.groupObj.groupIcon]];
    [self.imgvPinkDots setImage:[UIImage imageNamed:@"dots11"]];
    
    [self callAPItoGetGroupsMember];
    [self callAPItoGetGroupsComics];
}

- (void)startReplyComicAnimation {
    self.imgvPinkDots.animationImages = [NSArray arrayWithObjects:
                                         [UIImage imageNamed:@"dots1"],
                                         [UIImage imageNamed:@"dots2"],
                                         [UIImage imageNamed:@"dots3"],
                                         [UIImage imageNamed:@"dots4"],
                                         [UIImage imageNamed:@"dots5"],
                                         [UIImage imageNamed:@"dots6"],
                                         [UIImage imageNamed:@"dots7"],
                                         [UIImage imageNamed:@"dots8"],
                                         [UIImage imageNamed:@"dots9"],
                                         [UIImage imageNamed:@"dots10"],
                                         [UIImage imageNamed:@"dots11"],nil];
    self.imgvPinkDots.animationDuration = 2.0f;
    self.imgvPinkDots.animationRepeatCount = 0;
    [self.imgvPinkDots startAnimating];
}

- (void)stopReplyComicAnimation {
    [self.imgvPinkDots stopAnimating];
    [self.imgvPinkDots setImage:[UIImage imageNamed:@"dots11"]];
}

#pragma mark - Webservice Methods
- (void)callAPItoGetGroupsMember
{
    [GroupsAPIManager getListOfGroupMemberForGroupID:self.groupObj.groupId withSuccessBlock:^(id object)
     {
         NSLog(@"%@", object);
         
         NSDictionary *dict = object[@"data"];
         
         NSArray *members = dict[@"members"];
         
         for (NSDictionary *memberDict in members)
         {
             CMCUser *user = [[CMCUser alloc] initWithDictionary:memberDict];
             
             [groupMember addObject:user];
         }
         
         [clvUsers reloadData];
         
         NSLog(@"group member = %@",groupMember);
         
     }
                                             andFail:^(NSError *errorMessage) {
                                                 NSLog(@"%@", errorMessage);
                                                 
                                             }];
}

- (void)callAPItoGetGroupsComics
{
    [GroupsAPIManager getListComicsOfGroupForGroupID:self.groupObj.groupId  withSuccessBlock:^(id object)
     {
         NSLog(@"comic datat =  %@", object);
         NSError *error;
         ComicsModel *comicsModel = [MTLJSONAdapter modelOfClass:ComicsModel.class fromJSONDictionary:[object valueForKey:@"data"] error:&error];
         NSLog(@"%@", comicsModel);
         self.shareId = comicsModel.shareId;
         comics = comicsModel.books.copy;
         [tblvComics reloadData];
         
     } andFail:^(NSError *errorMessage)
     {
         NSLog(@"%@", errorMessage);
     }];
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
    return comics.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *simpleTableIdentifier = @"GroupCell";
    
    __block GroupCell* cell= (GroupCell*)[tableView dequeueReusableCellWithIdentifier:simpleTableIdentifier];

    cell = nil;
    if (cell == nil) {
        cell= (GroupCell*)[tableView dequeueReusableCellWithIdentifier:simpleTableIdentifier];
        if(nil!=[ComicBookDict objectForKey:[NSString stringWithFormat:@"%ld",(long)indexPath.row]])
        {
            [ComicBookDict removeObjectForKey:[NSString stringWithFormat:@"%ld",(long)indexPath.row]];
        }
        
        ComicBookVC *comic=[self.storyboard instantiateViewControllerWithIdentifier:@"ComicBookVC"];
        comic.delegate=self;
        comic.Tag=(int)indexPath.row;
        
        comic.view.frame = CGRectMake(0, 0, CGRectGetWidth(cell.viewComicBook.frame), CGRectGetHeight(cell.viewComicBook.frame));
        
        ComicBook *comicBook = [comics objectAtIndex:indexPath.row];
        [cell.profileImageView sd_setImageWithURL:[NSURL URLWithString:comicBook.userDetail.profilePic]];
        
        cell.lblDate.text = [self dateFromString:comicBook.createdDate];
        cell.lblTime.text = [self timeFromString:comicBook.createdDate];
        
        [cell.viewComicBook addSubview:comic.view];
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
    
    [UIView animateWithDuration:1 animations:^{
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

#pragma mark - Helper Methods
- (NSString *)dateFromString:(NSString *)dateString
{
    // createdDate = "2015-07-06 10:15:36";
    
    // Convert string to date object
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    [dateFormat setDateFormat:@"yyyy-MM-dd hh:mm:ss"];
    NSDate *date = [dateFormat dateFromString:dateString];
    
    // Convert date object to desired output format
    [dateFormat setDateFormat:@"MMM dd, yyyy"];
    return [dateFormat stringFromDate:date];
    
    //Oct 5,2015
}

- (NSString *)timeFromString:(NSString *)timeString
{
    // createdDate = "2015-07-06 10:15:36";
    
    // Convert string to date object
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    [dateFormat setDateFormat:@"yyyy-MM-dd hh:mm:ss"];
    NSDate *date = [dateFormat dateFromString:timeString];
    
    // Convert date object to desired output format
    [dateFormat setDateFormat:@"hh.mm a"];
    return [dateFormat stringFromDate:date];
    
    //Oct 5,2015
}

#pragma mark - UICollectionViewDataSource & UICollectionViewDelegate
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return groupMember.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    CMCUserCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"userCell" forIndexPath:indexPath];
    
    cell.user = groupMember[indexPath.row];
    
    return cell;
}


- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    if(IS_IPHONE_5)
    {
        return CGSizeMake(25, 25);
    }
    else if(IS_IPHONE_6)
    {
        return CGSizeMake(30, 30);
    }
    else if(IS_IPHONE_6P)
    {
        return CGSizeMake(35, 35);
    }
    else
    {
        return CGSizeMake(23, 25);
    }
}

#pragma mark - Events Methods
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
    [self navigateToGlideScrollView];
}

- (IBAction)btnPenTouchUpOutside:(id)sender
{
    [self restoreTransformWithBounceForView:viewPen];
    [self navigateToGlideScrollView];
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
         viewPen.layer.transform = CATransform3DIdentity;
     }
                     completion:^(BOOL finished) {
                         
//                         //send to main page
//                         
//                         UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:@"Main" bundle: [NSBundle mainBundle]];
//                         GlideScrollViewController *controller = (GlideScrollViewController *)[mainStoryboard instantiateViewControllerWithIdentifier:@"glidenavigation"];
//                         controller.
//                         
//                         [self presentViewController:controller animated:YES completion:nil];
                         
                     }];
}

- (void)navigateToGlideScrollView {
    
    [[GoogleAnalytics sharedGoogleAnalytics] logUserEvent:@"Reply" Action:@"GroupReply" Label:@""];
    
    UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:@"Main" bundle: [NSBundle mainBundle]];
    UINavigationController *navigationController = [mainStoryboard instantiateViewControllerWithIdentifier:@"glidenavigation"];
    GlideScrollViewController *controller = (GlideScrollViewController *)[navigationController.childViewControllers firstObject];
    controller.comicType = ReplyComic;
    controller.replyType = GroupReply;
    controller.friendOrGroupId = self.groupObj.groupId;
    controller.shareId = self.shareId;
    [self presentViewController:navigationController animated:YES completion:nil];
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

#pragma mark - helper methods
-(NSArray*)setupImages:(NSIndexPath*)indexPath
{
    //    NSMutableArray *images=[NSMutableArray new];
    //
    //    if(indexPath.row%2)
    //    {
    //        for(int i=1;i<9;i++)
    //        {
    //            [  images addObject:   [UIImage imageNamed:[NSString stringWithFormat:@"d%d",i]]];
    //        }
    //    }
    //    else
    //    {
    //        for(int i=8;i>0;i--)
    //        {
    //            [  images addObject:   [UIImage imageNamed:[NSString stringWithFormat:@"d%d",i]]];
    //        }
    //
    //    }
    //
    //    if(4>=images.count)
    //    {
    //        if(indexPath.row%2)
    //        {
    //            [images insertObject: [UIImage imageNamed:@"cover" ] atIndex:0];
    //        }
    //        else
    //        {
    //            [images insertObject: [UIImage imageNamed:@"cover1" ] atIndex:0];
    //        }
    //
    //        [images insertObject: [UIImage imageNamed:@"plain" ] atIndex:1];
    //
    //    }
    //    else
    //    {
    //        if(indexPath.row%2)
    //        {
    //            [images insertObject: [UIImage imageNamed:@"cover" ] atIndex:0];
    //        }
    //        else
    //        {
    //            [images insertObject: [UIImage imageNamed:@"cover1" ] atIndex:0];
    //        }
    //
    //
    //        [images insertObject: [UIImage imageNamed:@"plain" ] atIndex:1];
    //
    //        [images insertObject: [UIImage imageNamed:@"plain" ] atIndex:2];
    //
    //    }
    //    return images;
    NSMutableArray *slideImagesArray = [[NSMutableArray alloc] init];
    ComicBook *comicBook = [comics objectAtIndex:indexPath.row];
    [slideImagesArray addObject:comicBook.coverImage];
    
    for(Slides *slides in comicBook.slides) {
        [slideImagesArray addObject:slides.slideImage];
    }
    
    return slideImagesArray;
}

- (IBAction)tappedBackButton:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}
@end