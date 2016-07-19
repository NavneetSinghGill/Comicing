//
//  GroupViewController.m
//  ComicApp
//
//  Created by ADNAN THATHIYA on 31/10/15.
//  Copyright (c) 2015 ADNAN THATHIYA. All rights reserved.
//

//#define IS_IPHONE (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)
//#define SCREEN_WIDTH ([[UIScreen mainScreen] bounds].size.width)
//#define SCREEN_HEIGHT ([[UIScreen mainScreen] bounds].size.height)
//#define SCREEN_MAX_LENGTH (MAX(SCREEN_WIDTH, SCREEN_HEIGHT))
//#define SCREEN_MIN_LENGTH (MIN(SCREEN_WIDTH, SCREEN_HEIGHT))
//#define IS_IPHONE_5 (IS_IPHONE && SCREEN_MAX_LENGTH == 568.0)
//#define IS_IPHONE_6 (IS_IPHONE && SCREEN_MAX_LENGTH == 667.0)
//#define IS_IPHONE_6P (IS_IPHONE && SCREEN_MAX_LENGTH == 736.0)

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
#import "AppConstants.h"
#import "ComicConversationModel.h"
#import "ComicConversationBook.h"
#import "PrivateConversationTextCell.h"

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

@property (nonatomic,weak) IBOutlet UIView *mHolderView;
@property (nonatomic,weak) IBOutlet UITextField *mCommentInputTF;
@property (nonatomic,weak) IBOutlet UIButton *mSendCommentButton;
@property (nonatomic, assign) BOOL keyboardShown;
@property (nonatomic,weak) IBOutlet NSLayoutConstraint *HolderViewBottomConstraint;
@property (nonatomic,weak) IBOutlet NSLayoutConstraint *HolderViewHeightConstraint;
@property (nonatomic, assign) int initialHeight;
@property (nonatomic, assign) BOOL allowToAnimate;

@property CGRect saveTableViewFrame;

@end

@implementation MainPageGroupViewController

@synthesize groupMember,comics, tblvComics, clvUsers, viewTopBar, saveTableViewFrame, viewTransperant, ComicBookDict, imgvGroupIcon,viewPen;



#pragma mark - UIViewController Methods
- (void)viewDidLoad
{
    UIScreen *mainScreen = [UIScreen mainScreen];
    self.initialHeight = mainScreen.bounds.size.height - 20;
    
    [[GoogleAnalytics sharedGoogleAnalytics] logScreenEvent:@"MainPage-GroupPage" Attributes:nil];
    
    ComicBookDict=[NSMutableDictionary new];
    [super viewDidLoad];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(callAPItoGetGroupsComics) name:@"UpdateGroupComics" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(startReplyComicAnimation) name:@"StartGroupReplyComicAnimation" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(stopReplyComicAnimation) name:@"StopGroupReplyComicAnimation" object:nil];
    [self prepareView];
}


#pragma mark - keyboard handling methods & Textfield delgates

- (void)resetAnimationVariables
{
    self.allowToAnimate = YES;
}

- (void)viewWillAppear:(BOOL)animated
{
    
    [super viewWillAppear:YES];
    
    [self resetAnimationVariables];
    
    NSAttributedString *str = [[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@"Say Something to @%@", self.groupObj.groupTitle]
                                                              attributes:@{ NSForegroundColorAttributeName : [UIColor whiteColor] }];
    self.mCommentInputTF.attributedPlaceholder = str;
    
    [self.mCommentInputTF setClipsToBounds:YES];
    [self.mCommentInputTF.layer setMasksToBounds:YES];
    [self.mCommentInputTF.layer setCornerRadius:3];
    
    [[NSNotificationCenter defaultCenter]
     addObserver:self selector:@selector(keyboardWillShow:)
     name:UIKeyboardWillShowNotification object:nil];
    
    [[NSNotificationCenter defaultCenter]
     addObserver:self selector:@selector(keyboardWillHide:)
     name:UIKeyboardWillHideNotification object:nil];
}

// Unsubscribe from keyboard show/hide notifications.
- (void)viewWillDisappear:(BOOL)animated
{
    [[NSNotificationCenter defaultCenter]
     removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    
    [[NSNotificationCenter defaultCenter]
     removeObserver:self name:UIKeyboardWillHideNotification object:nil];
}

// Setup keyboard handlers to slide the view containing the table view and
// text field upwards when the keyboard shows, and downwards when it hides.
- (void)keyboardWillShow:(NSNotification*)notification
{
    //[self moveView:[notification userInfo] up:YES];
    
    CGSize keyboardSize = [[[notification userInfo] objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue].size;
    
    if (!self.keyboardShown)
    {
        
        self.keyboardShown = YES;
        self.allowToAnimate = !self.keyboardShown;

        
        self.HolderViewBottomConstraint.constant = keyboardSize.height;

        [UIView animateWithDuration:0.5 animations:^{
            
            self.mHolderView.frame = CGRectMake(self.mHolderView.frame.origin.x,
                                                20,
                                                self.mHolderView.frame.size.width,
                                                self.initialHeight - keyboardSize.height);
        } completion:^(BOOL finished) {
            if (!self.tblvComics.isDragging && (self.tblvComics.frame.size.height < self.tblvComics.contentSize.height)) {
                CGPoint offset = CGPointMake(0, self.tblvComics.contentSize.height - self.tblvComics.frame.size.height);
                [self.tblvComics setContentOffset:offset animated:NO];
            }
        }];
    }
    else
    {
        self.mHolderView.frame = CGRectMake(self.mHolderView.frame.origin.x,
                                            20,
                                            self.mHolderView.frame.size.width,
                                            self.initialHeight - keyboardSize.height);
        
        self.HolderViewBottomConstraint.constant = keyboardSize.height;
        
        if (!self.tblvComics.isDragging && (self.tblvComics.frame.size.height < self.tblvComics.contentSize.height)) {
            CGPoint offset = CGPointMake(0, self.tblvComics.contentSize.height - self.tblvComics.frame.size.height);
            [self.tblvComics setContentOffset:offset animated:NO];
        }
    }
    
    
}

- (void)keyboardWillHide:(NSNotification*)notification
{
    //[self moveView:[notification userInfo] up:NO];
    
    //CGSize keyboardSize = [[[notification userInfo] objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue].size;
    
    
    [UIView animateWithDuration:0.5 animations:^{
        
        self.mHolderView.frame = CGRectMake(self.mHolderView.frame.origin.x,
                                            20,
                                            self.mHolderView.frame.size.width,
                                            self.initialHeight);
        self.HolderViewBottomConstraint.constant = 0;
        
    } completion:^(BOOL finished) {
        self.keyboardShown = NO;
        self.allowToAnimate = !self.keyboardShown;
    }];
}

#pragma mark TextField Delegates

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    
    if (self.mCommentInputTF.text.length > 0)
    {
        [GroupsAPIManager postGroupConversationV2CommentWithGroupID:self.groupObj.groupId
                                                                          shareText:self.mCommentInputTF.text
                                                                      currentUserId:[AppHelper getCurrentLoginId]
                                                                       SuccessBlock:^(id object) {
                                                                           NSLog(@"Post object response : %@", object);
                                                                           self.mCommentInputTF.text = @"";
                                                                           self.allowToAnimate = NO;
                                                                           [self callAPItoGetGroupsComics];
                                                                       } andFail:^(NSError *errorMessage) {
                                                                           
                                                                       }];
    }
    return YES;
}

#define MAX_LENGTH 50

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    if (textField.text.length >= MAX_LENGTH && range.length == 0)
    {
        return NO; // return NO to not change text
    }
    else
    {
        return YES;
    }
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
    [self.imgvPinkDots setImage:[UIImage imageNamed:@"orangeDots11"]];
    
    [self callAPItoGetGroupsMember];
    [self callAPItoGetGroupsComics];
}

- (void)startReplyComicAnimation {
    self.imgvPinkDots.animationImages = [NSArray arrayWithObjects:
                                         [UIImage imageNamed:@"orangeDots1"],
                                         [UIImage imageNamed:@"orangeDots2"],
                                         [UIImage imageNamed:@"orangeDots3"],
                                         [UIImage imageNamed:@"orangeDots4"],
                                         [UIImage imageNamed:@"orangeDots5"],
                                         [UIImage imageNamed:@"orangeDots6"],
                                         [UIImage imageNamed:@"orangeDots7"],
                                         [UIImage imageNamed:@"orangeDots8"],
                                         [UIImage imageNamed:@"orangeDots9"],
                                         [UIImage imageNamed:@"orangeDots10"],
                                         [UIImage imageNamed:@"orangeDots11"],nil];
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
         //ComicsModel *comicsModel = [MTLJSONAdapter modelOfClass:ComicsModel.class fromJSONDictionary:[object valueForKey:@"data"] error:&error];
         
         ComicConversationModel *comicsModel = [MTLJSONAdapter modelOfClass:ComicConversationModel.class fromJSONDictionary:[object valueForKey:@"data"] error:&error];

         NSLog(@"%@", comicsModel);
         self.shareId = comicsModel.shareId;
         comics = comicsModel.books.copy;
         comics = [NSMutableArray arrayWithArray:[[comics reverseObjectEnumerator] allObjects]];
         [tblvComics reloadData];
         
         CGPoint offset = CGPointMake(0, self.tblvComics.contentSize.height - self.tblvComics.frame.size.height);
         [self.tblvComics setContentOffset:offset animated:NO];
         
         //PUT request to update SEEN comic/ text object
         [GroupsAPIManager putSeenStatusWithGroupID:self.groupObj.groupId
                                                          userId:[AppHelper getCurrentLoginId]
                                                    SuccessBlock:^(id object) {
                                                        NSLog(@"Updated lastSeen comic/ text object");
                                                    } andFail:^(NSError *errorMessage) {
                                                        NSLog(@"fails to update lastSeen comic/ text object");
                                                    }];
         //---------------
         
         [self performSelector:@selector(resetAnimationVariables) withObject:nil afterDelay:1];
         
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

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    CGFloat height = 45;
    return height;
}

- (UIView *) tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, tableView.bounds.size.width, 45)];
    [headerView setBackgroundColor:[UIColor clearColor]];
    return headerView;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return comics.count;
}

#define CONVERSTION_TYPE_COMIC @"comic"
#define CONVERSTION_TYPE_TEXT  @"text"

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *simpleTableIdentifier = @"GroupCell";
    
    ComicConversationBook *mComicConversatinBook = (ComicConversationBook *)[comics objectAtIndex:indexPath.row];
    
    if ([mComicConversatinBook.conversationType isEqualToString:CONVERSTION_TYPE_COMIC])
    {
        __block GroupCell* cell= (GroupCell*)[tableView dequeueReusableCellWithIdentifier:simpleTableIdentifier];
        
        cell = nil;
        if (cell == nil) {
            NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"GroupCell" owner:self options:nil];
            
            cell = [nib objectAtIndex:0];
            
            //cell= (GroupCell*)[tableView dequeueReusableCellWithIdentifier:simpleTableIdentifier];
            
            if(nil!=[ComicBookDict objectForKey:[NSString stringWithFormat:@"%ld",(long)indexPath.row]])
            {
                [ComicBookDict removeObjectForKey:[NSString stringWithFormat:@"%ld",(long)indexPath.row]];
            }
            
            ComicBookVC *comic=[self.storyboard instantiateViewControllerWithIdentifier:@"ComicBookVC"];
            comic.delegate=self;
            comic.Tag=(int)indexPath.row;
            
            
            ComicBook *comicBook = (ComicBook *)mComicConversatinBook.coversation[0];
            CGRect lblFrame = cell.lblComicTitle.frame;

            
            if ([comicBook.comicTitle isEqualToString:@""] || comicBook.comicTitle == nil)
            {
                cell.lblComicTitle.hidden = YES;
                cell.topSpacingComicView.constant = 5;
                
                CGRect frameViewComicBook = cell.viewComicBook.frame;
                frameViewComicBook.origin.y = lblFrame.origin.y;
                frameViewComicBook.size.height = cell.frame.size.height;
                cell.viewComicBook.frame = frameViewComicBook;
                
                cell.lblComicTitle.frame = lblFrame;
                
                comic.view.frame = CGRectMake(0, 0, CGRectGetWidth(cell.viewComicBook.frame), CGRectGetHeight(cell.viewComicBook.frame) - 10);
                
                [cell layoutIfNeeded];
            }
            else
            {
                cell.lblComicTitle.hidden = NO;
                cell.lblComicTitle.text = comicBook.comicTitle;
            }
            
            
            comic.view.frame = CGRectMake(0, 0, CGRectGetWidth(cell.viewComicBook.frame), CGRectGetHeight(cell.viewComicBook.frame));
            
            
            
            
            [cell.profileImageView sd_setImageWithURL:[NSURL URLWithString:comicBook.userDetail.profilePic]];
            
            //dinesh
            cell.mUserName.text = comicBook.userDetail.firstName;
            cell.lblDate.text = [self dateFromString:comicBook.createdDate];
            cell.lblTime.text = [self timeFromString:comicBook.createdDate];
            
            [cell.viewComicBook addSubview:comic.view];
            
            // vishnu
            NSMutableArray *slidesArray = [[NSMutableArray alloc] init];
            [slidesArray addObjectsFromArray:comicBook.slides];
            
            // To repeat the cover image again on index page as the first slide.
            if(slidesArray.count > 1) {
                [slidesArray insertObject:[slidesArray firstObject] atIndex:1];
                
                // Adding a sample slide to array to maintain the logic
                Slides *slides = [Slides new];
                [slidesArray insertObject:slides atIndex:1];
                
                // vishnuvardhan logic for the second page
                if(6<slidesArray.count) {
                    [slidesArray insertObject:[slidesArray firstObject] atIndex:0];
                }
            }
            
            [comic setSlidesArray:slidesArray];
            [comic setupBook];
            
            [self addChildViewController:comic];
            
            [ComicBookDict setObject:comic forKey:[NSString stringWithFormat:@"%ld",(long)indexPath.row]];
            
        }
        
        return cell;
    }
    else
    {
        
//        ComicBook *comicBook = [comics objectAtIndex:indexPath.row];
        ComicBook *comicBook = (ComicBook *)mComicConversatinBook.coversation[0];

        PrivateConversationTextCell *cell = (PrivateConversationTextCell *)[tableView dequeueReusableCellWithIdentifier:@"fs"];
        
        if (cell == nil)
        {
            NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"PrivateConversationTextCell" owner:self options:nil];
            cell = [nib objectAtIndex:0];
        }
        
//        ComicBook *comicBook = (ComicBook *)mComicConversatinBook.coversation[0];
        [cell.userProfilePic sd_setImageWithURL:[NSURL URLWithString:comicBook.userDetail.profilePic]];
        
        
       
        
        //dinesh
        cell.mUserName.text = comicBook.userDetail.firstName;
        
        NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
        [dateFormat setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
        NSDate *dateFromStr = [dateFormat dateFromString:comicBook.createdDate];
        [dateFormat setDateFormat:@"MMM dd, yyyy"];
        NSString *dateStr = [dateFormat stringFromDate:dateFromStr];
        [dateFormat setDateFormat:@"hh.mm a"];
        NSString *timeStr = [dateFormat stringFromDate:dateFromStr];
        
        cell.lblDate.text = dateStr;
        cell.lblTime.text = timeStr;
        
        cell.mMessage.text = comicBook.message;
        
        // NSLog(@"Book : %@", comicBook);
        

        //no need to display chat status since its a group chat
        [cell.mChatStatus setHidden:YES];
        
        CGSize fontSize = [cell.mMessage.text sizeWithAttributes:
                           @{NSFontAttributeName:cell.mMessage.font}];
        
        NSLog(@"fontSize : %@", NSStringFromCGSize(fontSize));
        
        if (fontSize.width > cell.mMessage.bounds.size.width)
        {
            cell.mMessageHolderView.frame = CGRectMake(cell.mMessageHolderView.frame.origin.x,
                                                       cell.mMessageHolderView.frame.origin.y,
                                                       cell.mMessageHolderView.frame.size.width,
                                                       54);
        }
        
        return cell;
    }

}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    ComicConversationBook *mComicConversatinBook = (ComicConversationBook *)[comics objectAtIndex:indexPath.row];
    
    ComicBook *comicBook = (ComicBook *)mComicConversatinBook.coversation[0];
    
    if ([mComicConversatinBook.conversationType isEqualToString:CONVERSTION_TYPE_COMIC])
    {
        int height=0;
        
        if ([comicBook.comicTitle isEqualToString:@""] || comicBook.comicTitle == nil)
        {
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
        }
        else
        {
            if(IS_IPHONE_5)
            {
                height=109;
            }
            else if(IS_IPHONE_6)
            {
                height= 139;
            }
            else if(IS_IPHONE_6P)
            {
                height= 169;
            }
        }
        
        return self.initialHeight - height;
        
        //return tableView.bounds.size.height-height;
    }
    else if ([mComicConversatinBook.conversationType isEqualToString:CONVERSTION_TYPE_TEXT])
    {
        return 128;
    }
    
    return 0;
    
}

-(void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (self.allowToAnimate)
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
    
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if (self.allowToAnimate)
    {
        CGFloat offset = scrollView.contentOffset.y; // here you will get the offset value
        CGFloat value = offset / tblvComics.frame.size.height;
        
        NSLog(@"value = %f",value);
        
        if(value > 0 && value < 1)
        {
            self.viewTransperant.alpha = 1-value/4;
        }
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
#pragma mark - statusbar

- (UIStatusBarStyle) preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
}

- (BOOL)prefersStatusBarHidden
{
    return NO;
}
@end