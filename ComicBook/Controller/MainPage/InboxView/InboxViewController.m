//
//  InboxViewController.m
//  CurlDemo
//
//  Created by Vishnu Vardhan PV on 14/01/16.
//  Copyright © 2016 Vishnu Vardhan PV. All rights reserved.
//

#import "InboxViewController.h"
#import "AppDelegate.h"
#import "FriendsAPIManager.h"
#import "GroupsAPIManager.h"
#import "FriendPageVC.h"
#import "GroupViewController.h"
#import "AlphabetCollectionViewCell.h"
#import "InboxAPIManager.h"
#import "PrivateConversationViewController.h"
#import "AppHelper.h"
#import "MainPageGroupViewController.h"
#import "ContactController.h"

NSString *const GroupCellIdentifier = @"GroupCell";
NSString *const FriendCellIdentifier = @"FriendCell";
NSString *const AlphabetCellIdentifier = @"AlphabetCell";
NSUInteger const GroupCollectionViewTag = 11;
NSUInteger const FriendCollectionViewTag = 22;
NSUInteger const AlphabetsCollectionViewTag = 33;

@interface InboxViewController()
{

    IBOutlet UIImageView *img_ForFriend;
    IBOutlet UILabel *lbl_Friends;
    IBOutlet UILabel *lbl_Groups;
    IBOutlet NSLayoutConstraint *const_HeightOfFriend;
}
@end
@implementation InboxViewController
@synthesize alphabets,alphabetCV, timer;

- (void)viewDidLoad
{
    [super viewDidLoad];

    [self setupAlphabetCollectionView];
    //img_ForFriend.hidden = YES;

    UITapGestureRecognizer *tapGest = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tappedOnConnectFriendImage)];
    [img_ForFriend addGestureRecognizer:tapGest];
    CGFloat fontSize = 13;
    if (IS_IPHONE_5)
    {
        fontSize = 11;
    }
    else if (IS_IPHONE_6)
    {
        fontSize = 12;
    }
    else if (IS_IPHONE_6P)
    {
        fontSize = 13;
    }
    lbl_Groups.font = [lbl_Groups.font fontWithSize:fontSize];
    lbl_Friends.font = [lbl_Friends.font fontWithSize:fontSize];
    /*if (IS_IPHONE_6P)
    {
        self.friendsCV.frame = CGRectMake(self.friendsCV.frame.origin.x, self.friendsCV.frame.origin.y, self.friendsCV.frame.size.width, (self.friendsCV.frame.size.width/3.0416666667)+100);
    }
    else
    {*/
    
    //}
    

    //    [self setupInbox];
    // Do any additional setup after loading the view.
    CGFloat ratioOn = 3.0416666667f;
    if (IS_IPHONE_6P)
    {
        ratioOn = 2.7f;
    }
    else if (IS_IPHONE_6)
    {
        ratioOn = 2.8f;
    }
    else if (IS_IPHONE_5)
    {
        ratioOn = 2.95f;
    }
    const_HeightOfFriend.constant = [UIScreen mainScreen].bounds.size.width/ratioOn;
    [self.friendsCV layoutIfNeeded];
}

- (void)viewWillAppear:(BOOL)animated
{
    //img_ForFriend.hidden = YES;
    [self firstTimeCallAPITogetActiveFriends];
    
   timer = [NSTimer scheduledTimerWithTimeInterval:120
                                     target:self
                                   selector:@selector(getActiveFriendsAfterTwoMinutes:)
                                   userInfo:nil
                                    repeats:YES];
}

- (void)viewDidAppear:(BOOL)animated
{
   // [timer invalidate];
    
}
-(void)viewDidLayoutSubviews
{
    
    
}
- (void)setupAlphabetCollectionView
{
   /* CGFloat width = CGRectGetWidth(self.view.frame) -  CGRectGetMinX(alphabetCV.frame);
    
    CGRect frame = CGRectMake(CGRectGetMinX(alphabetCV.frame),
                              CGRectGetMinY(alphabetCV.frame),
                              width,
                              CGRectGetHeight(alphabetCV.frame));
    
    alphabetCV.frame = frame;*/
    
    alphabets = @[@"A", @"B", @"C", @"D", @"E", @"F", @"G", @"H", @"I", @"J", @"K", @"L", @"M", @"N", @"O", @"P", @"Q", @"R", @"S", @"T", @"U", @"V", @"W", @"X", @"Y", @"Z"];
    
    [alphabetCV reloadData];
}

#pragma mark - timer Methods
- (void)getActiveFriendsAfterTwoMinutes:(NSTimer *)timer
{
    //do smth
    [InboxAPIManager getActiveFriendsForUserID:[AppHelper getCurrentLoginId] SuccessBlock:^(id object)
    {
        NSLog(@"%@", object);
        
        if ([AppDelegate application].dataManager.activeInboxArray.count > 0)
        {
            [[NSNotificationCenter defaultCenter] postNotificationName:@"changeInboxButtonColor" object:nil];
        }
        
        [AppDelegate application].dataManager.activeInboxArray = object[@"data"];
        
        [self setActiveFriendsWithFriends:[AppDelegate application].dataManager.friendsArray];
        [self setActiveGroupsWithGroups:[AppDelegate application].dataManager.groupsArray];
        
    } andFail:^(NSError *errorMessage) {
        
        NSLog(@"%@", errorMessage);
        
    }];
}

- (void)setActiveFriendsWithFriends:(NSArray *)friends
{
    NSMutableArray *activeFrd = [[NSMutableArray alloc] init];
    
    NSSortDescriptor *sort = [NSSortDescriptor sortDescriptorWithKey:@"firstName" ascending:YES];
    NSMutableArray *sortedArray = [[friends sortedArrayUsingDescriptors:@[sort]] mutableCopy];
    
    NSLog(@"array = %@",sortedArray);
    
    for (NSDictionary *activeFriendDict in [AppDelegate application].dataManager.activeInboxArray)
    {
        if ([activeFriendDict[@"share_type"] isEqualToString:@"F"])
        {
            NSString *frdID = activeFriendDict[@"user_id"];
            
            for (Friend *frd in sortedArray.copy)
            {
                if ([frdID isEqualToString:frd.friendId] || frd.isSelected == YES)
                {
                    frd.isSelected = YES;
                    
                    [activeFrd addObject:frd];
                    
                    [sortedArray removeObject:frd];
                }
            }
        }
    }
    
    [activeFrd addObjectsFromArray:sortedArray];
    
    [AppDelegate application].dataManager.friendsArray = activeFrd.copy;
    
    [self.friendsCV reloadData];

}

- (void)setActiveGroupsWithGroups:(NSArray *)allGroups
{
    NSMutableArray *activeGroups = [[NSMutableArray alloc] init];
    
    NSSortDescriptor *sort = [NSSortDescriptor sortDescriptorWithKey:@"groupTitle" ascending:YES];
    NSMutableArray *sortedArray = [[allGroups sortedArrayUsingDescriptors:@[sort]] mutableCopy];
    
    NSLog(@"array = %@",sortedArray);
    
    for (NSDictionary *activeFriendDict in [AppDelegate application].dataManager.activeInboxArray)
    {
        if ([activeFriendDict[@"share_type"] isEqualToString:@"G"])
        {
            NSString *grpID = activeFriendDict[@"group_id"];
            
            for (Group *grp in sortedArray.copy)
            {
                if ([grpID integerValue] == [grp.groupId integerValue] || grp.isSelected == YES)
                {
                    grp.isSelected = YES;
                    
                    [activeGroups addObject:grp];
                    
                    [sortedArray removeObject:grp];
                }
                else
                {
                    grp.isSelected = NO;
                }
            }
        }
    }
    
    [activeGroups addObjectsFromArray:sortedArray];
    
    [AppDelegate application].dataManager.groupsArray = activeGroups.copy;
    
    [self.groupCV reloadData];
}

#pragma mark - API Methods

- (void)firstTimeCallAPITogetActiveFriends
{
    [InboxAPIManager getActiveFriendsForUserID:[AppHelper getCurrentLoginId] SuccessBlock:^(id object)
    {
        
        NSLog(@"%@", object);
        
        [AppDelegate application].dataManager.activeInboxArray = object[@"data"];
        
        if ([AppDelegate application].dataManager.activeInboxArray.count > 0)
        {
            [[NSNotificationCenter defaultCenter] postNotificationName:@"changeInboxButtonColor" object:nil];
        }
        
//        if([AppDelegate application].dataManager.friendsArray.count == 0)
//        {
            [self callAPIToGetFriends];
//        }
//        else
//        {
            if ([AppDelegate application].dataManager.friendsArray.count>5  )
            {
                [UIView animateWithDuration:0.3 animations:^{
                    img_ForFriend.alpha = 0;
                } completion: ^(BOOL finished) {
                    img_ForFriend.hidden = YES;
                }];
            }
            else
            {
                [UIView animateWithDuration:0.3 animations:^{
                    if ([AppDelegate application].isShownFriendImage)
                    {
                        img_ForFriend.alpha = 1;
                    }
                    else
                    {
                        img_ForFriend.alpha = 0;
                    }
                } completion: ^(BOOL finished) {
                    img_ForFriend.hidden = [AppDelegate application].isShownFriendImage;
                }];
            }
//        }
        
//        if([AppDelegate application].dataManager.groupsArray.count == 0)
//        {
            [self callAPIToGetGroups];
//        }
//        else
//        {
            [self setActiveGroupsWithGroups:[AppDelegate application].dataManager.groupsArray];
//        }
        
    } andFail:^(NSError *errorMessage) {
       
         NSLog(@"%@", errorMessage);
        
    }];
}

- (void)callAPIToGetFriends
{
    [FriendsAPIManager getTheListOfFriendsForTheUserID:[AppHelper getCurrentLoginId] withSuccessBlock:^(id object)
    {
        NSLog(@"%@", object);
        NSLog(@"%@", [MTLJSONAdapter modelsOfClass:[Friend class] fromJSONArray:[object valueForKey:@"data"] error:nil]);
       
        NSMutableArray *friends = [[MTLJSONAdapter modelsOfClass:[Friend class] fromJSONArray:[object valueForKey:@"data"] error:nil] mutableCopy];
        if (friends.count>5 )
        {
            [UIView animateWithDuration:0.3 animations:^{
                img_ForFriend.alpha = 0;
            } completion: ^(BOOL finished) {
                img_ForFriend.hidden = YES;
            }];
        }
        else
        {
            
            [UIView animateWithDuration:0.3 animations:^{
                if ([AppDelegate application].isShownFriendImage)
                {
                    img_ForFriend.alpha = 1;
                }
                else
                {
                    img_ForFriend.alpha = 0;
                }
                } completion: ^(BOOL finished) {
                img_ForFriend.hidden = [AppDelegate application].isShownFriendImage;
            }];
        }
        [self setActiveFriendsWithFriends:friends.copy];
        
    } andFail:^(NSError *errorMessage) {
        img_ForFriend.hidden = NO;
        NSLog(@"%@", errorMessage);
    }];
}

- (void)callAPIToGetGroups
{
    [GroupsAPIManager getTheListOfGroupsForTheUserID:[AppHelper getCurrentLoginId] withSuccessBlock:^(id object)
    {
        NSLog(@"%@", object);
    
        NSLog(@"%@", [MTLJSONAdapter modelsOfClass:[Group class] fromJSONArray:[object valueForKey:@"data"] error:nil]);
        
        NSMutableArray *groups = [[MTLJSONAdapter modelsOfClass:[Group class] fromJSONArray:[object valueForKey:@"data"] error:nil] mutableCopy];
        
        [self setActiveGroupsWithGroups:groups.copy];
        
        
    } andFail:^(NSError *errorMessage) {
        
        NSLog(@"%@", errorMessage);
    
    }];
}

#pragma mark - CollectionView Methods
- (NSInteger)collectionView:(UICollectionView *)view numberOfItemsInSection:(NSInteger)section
{
    if(view.tag == GroupCollectionViewTag)
        return [[AppDelegate application].dataManager.groupsArray count];
    
    if(view.tag == FriendCollectionViewTag)
        return [[AppDelegate application].dataManager.friendsArray count];
    
    if (view.tag == AlphabetsCollectionViewTag)
        return alphabets.count;
        
    return 0;
}

- (NSInteger)numberOfSectionsInCollectionView: (UICollectionView *)collectionView
{
    return 1;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    if(collectionView.tag == GroupCollectionViewTag)
    {
        [[GoogleAnalytics sharedGoogleAnalytics] logUserEvent:@"Inbox-Group" Action:@"Click" Label:@""];
        
        GroupsCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:GroupCellIdentifier forIndexPath:indexPath];
        cell.delegate = self;
        [cell populateCell:[[AppDelegate application].dataManager.groupsArray objectAtIndex:indexPath.row]];
        return cell;
    }
    else if(collectionView.tag == FriendCollectionViewTag)
    {
        [[GoogleAnalytics sharedGoogleAnalytics] logUserEvent:@"Inbox-Friends" Action:@"Click" Label:@""];
        FriendsCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:FriendCellIdentifier forIndexPath:indexPath];
        cell.delegate = self;
        [cell populateCell:[[AppDelegate application].dataManager.friendsArray objectAtIndex:indexPath.row]];
        return cell;
    }
    else if (collectionView.tag == AlphabetsCollectionViewTag)
    {
        AlphabetCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:AlphabetCellIdentifier forIndexPath:indexPath];

        cell.lblAlphabet.text = alphabets[indexPath.row];
        
        return cell;
    }
    
    return nil;
}

-(CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    if(collectionView.tag == GroupCollectionViewTag)
    {
        CGFloat heightShouldbe = ([UIScreen mainScreen].bounds.size.width-28)/5.4677419355;
        return CGSizeMake(0.9615384615*heightShouldbe, heightShouldbe);
    }
    else if (collectionView.tag == FriendCollectionViewTag)
    {
       /* if (IS_IPHONE_6P)
        {
            return CGSizeMake(collectionView.frame.size.height/2*0.59, (collectionView.frame.size.height/2)-7);
        }*/
        return CGSizeMake(const_HeightOfFriend.constant/2*0.56, const_HeightOfFriend.constant/2);
    }
    else
    {
        CGFloat sizeOFCcell = 22;
        if (IS_IPHONE_5)
        {
            sizeOFCcell = 18;
        }
        else if(IS_IPHONE_6)
        {
            sizeOFCcell = 19;
        }
        else if (IS_IPHONE_6P)
        {
            sizeOFCcell = 20;
        }
        return CGSizeMake(sizeOFCcell, sizeOFCcell);
    }
}
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    if (collectionView.tag == AlphabetsCollectionViewTag)
    {
        NSLog(@"click : %@",alphabets[indexPath.row]);
        
        int index = 0;
        
        BOOL isFriendFound = NO;
        
        for (Friend *friendObject in [AppDelegate application].dataManager.friendsArray)
        {
            if (friendObject.firstName.length != 0 && friendObject.isSelected == NO)
            {
                NSString *firstLetter = [friendObject.firstName substringToIndex:1];
                
                if ([[firstLetter uppercaseString] isEqualToString:alphabets[indexPath.row]])
                {
                    isFriendFound = YES;
                    break;
                }
            }
            
            index ++;
        }
        
        if (isFriendFound)
        {
            NSIndexPath *scrollIndexPath = [NSIndexPath indexPathForItem:index inSection:0];
            
            [self.friendsCV scrollToItemAtIndexPath:scrollIndexPath atScrollPosition:UICollectionViewScrollPositionLeft animated:YES];
        }
    }
}

#pragma mark - CollectionView Cell delegates

- (void)didTapProfileImageOfFriend:(Friend *)friendObj {
    NSLog(@"-----tappedFriendImage----- %@", friendObj);
    friendObj.isSelected = NO;
    PrivateConversationViewController *friendView = [[PrivateConversationViewController alloc] init];
    friendView = [self.storyboard instantiateViewControllerWithIdentifier:@"PrivateConversationView"];
    friendView.friendObj = friendObj;
    [CATransaction begin];
    [self.navigationController pushViewController:friendView animated:YES];
    [CATransaction setCompletionBlock:^{
        //whatever you want to do after the push
        [(BottomBarViewController *)self.parentViewController closeMenu];
    }];
    [CATransaction commit];
    //Pushed By Sanjay: navigation stack can be overflowing
   // [self presentViewController:friendView animated:YES completion:nil];
}
- (void)didTapImageOfGroup:(Group *)groupObj
{
    NSLog(@"******tappedGroupImage******* %@", groupObj);

    groupObj.isSelected = NO;
   
    
    MainPageGroupViewController *groupView = [[MainPageGroupViewController alloc] init];
    groupView = [self.storyboard instantiateViewControllerWithIdentifier:@"GroupView"];
    groupView.groupObj = groupObj;
    [CATransaction begin];
    [self.navigationController pushViewController:groupView animated:YES];
    [CATransaction setCompletionBlock:^{
        //whatever you want to do after the push
        [(BottomBarViewController *)self.parentViewController closeMenu];
    }];
    [CATransaction commit];
//Pushed By Sanjay: navigation stack can be overflowing
    //[self presentViewController:groupView animated:YES completion:nil];
}
#pragma mark - tap Gesture Event
-(void)tappedOnConnectFriendImage
{
    [AppDelegate application].isShownFriendImage = YES;
    [UIView animateWithDuration:0.3 animations:^{
        img_ForFriend.alpha = 0;
    } completion: ^(BOOL finished) {
        img_ForFriend.hidden = YES;
    }];
}
- (IBAction)tappedConnectFriendButton:(id)sender {
    UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:@"Main" bundle: nil];
    ContactController* cVc = (ContactController *)[mainStoryboard instantiateViewControllerWithIdentifier:@"Contact"];
    mainStoryboard = nil;
    [self.navigationController pushViewController:cVc animated:YES];
}
@end
