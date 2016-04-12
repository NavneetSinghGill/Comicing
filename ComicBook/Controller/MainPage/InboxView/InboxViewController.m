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

NSString *const GroupCellIdentifier = @"GroupCell";
NSString *const FriendCellIdentifier = @"FriendCell";
NSString *const AlphabetCellIdentifier = @"AlphabetCell";
NSUInteger const GroupCollectionViewTag = 11;
NSUInteger const FriendCollectionViewTag = 22;
NSUInteger const AlphabetsCollectionViewTag = 33;


@implementation InboxViewController
@synthesize alphabets,alphabetCV, timer;

- (void)viewDidLoad
{
    [super viewDidLoad];

    [self setupAlphabetCollectionView];
    
    //    [self setupInbox];
    // Do any additional setup after loading the view.
}

- (void)viewWillAppear:(BOOL)animated
{
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

- (void)setupAlphabetCollectionView
{
    CGFloat width = CGRectGetWidth(self.view.frame) -  CGRectGetMinX(alphabetCV.frame);
    
    CGRect frame = CGRectMake(CGRectGetMinX(alphabetCV.frame),
                              CGRectGetMinY(alphabetCV.frame),
                              width,
                              CGRectGetHeight(alphabetCV.frame));
    
    alphabetCV.frame = frame;
    
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
        
        if([AppDelegate application].dataManager.friendsArray.count == 0)
        {
            [self callAPIToGetFriends];
        }
        else
        {
            [self setActiveFriendsWithFriends:[AppDelegate application].dataManager.friendsArray];
        }
        
        if([AppDelegate application].dataManager.groupsArray.count == 0)
        {
            [self callAPIToGetGroups];
        }
        else
        {
            [self setActiveGroupsWithGroups:[AppDelegate application].dataManager.groupsArray];
        }
        
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
        
        [self setActiveFriendsWithFriends:friends.copy];
        
    } andFail:^(NSError *errorMessage) {
        
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
        GroupsCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:GroupCellIdentifier forIndexPath:indexPath];
        cell.delegate = self;
        [cell populateCell:[[AppDelegate application].dataManager.groupsArray objectAtIndex:indexPath.row]];
        return cell;
    }
    else if(collectionView.tag == FriendCollectionViewTag)
    {
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
    [self presentViewController:friendView animated:YES completion:nil];
}
- (void)didTapImageOfGroup:(Group *)groupObj
{
    NSLog(@"******tappedGroupImage******* %@", groupObj);

    groupObj.isSelected = NO;
   
    
    MainPageGroupViewController *groupView = [[MainPageGroupViewController alloc] init];
    groupView = [self.storyboard instantiateViewControllerWithIdentifier:@"GroupView"];
    groupView.groupObj = groupObj;
    [self presentViewController:groupView animated:YES completion:nil];
}

@end
