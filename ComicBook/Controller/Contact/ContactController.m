//
//  ContactController.m
//  ComicApp
//
//  Created by Ramesh on 22/11/15.
//  Copyright © 2015 Ramesh. All rights reserved.
//

//@property (weak, nonatomic) IBOutlet AvatarView *avView;
//@property (weak, nonatomic) IBOutlet SectionDividerView *headerView1;
//@property (weak, nonatomic) IBOutlet SectionDividerView *headerView2;
//@property (weak, nonatomic) IBOutlet GroupsSection *groupSection;
//@property (weak, nonatomic) IBOutlet FriendsListView *friendsList;
//
//@property (weak, nonatomic) IBOutlet FooterView *footerView;


#import "ContactController.h"

@interface ContactController ()

@property (nonatomic) CGRect frameAvatarView;
@property (nonatomic) CGRect frameHeaderView1;
@property (nonatomic) CGRect frameHeaderView2;
@property (nonatomic) CGRect frameGroupSection;
@property (nonatomic) CGRect frameFriendsList;
@property (nonatomic) CGRect frameFooterView;

@end

@implementation ContactController

#pragma mark view lifecycle
- (void)viewDidLoad
{
    self.avView.delegate = self;
    self.groupSection.delegate = self;
    self.groupSection.enableAdd = YES;
    
    _frameAvatarView = _avView.frame;
    _frameHeaderView1 = _headerView1.frame;
    _frameHeaderView2 = _headerView2.frame;
    _frameGroupSection= _groupSection.frame;
    _frameFriendsList= _friendsList.frame;
    _frameFooterView = _footerView.frame;
    
    //   [self configViews];
    [super viewDidLoad];
    [self.friendsList getFriendsByUserId];

    // Do any additional setup after loading the view from its nib.
}

-(void)viewWillAppear:(BOOL)animated
{
    [self configRowSubView];
    self.friendsList.enableSectionTitles = NO;
    self.friendsList.enableSelection = YES;
    self.friendsList.delegate = self;
    self.friendsList.selectedActionName =@"AddToFriends";
    self.friendsList.enableInvite = NO;
    friendsFrame = self.friendsList.frame;
    [super viewWillAppear:animated];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark Methods

-(void)configRowSubView{
    [self createSectionView:self.headerView1 headerText:@"Group"];
    [self createSectionView:self.headerView2 headerText:@"Friends"];
}

-(void)configViews{
    
    CGRect frameRect = self.friendsList.view.frame;
    frameRect.size.height = self.friendsList.frame.size.height;
    self.friendsList.view.frame = frameRect;
    
}

-(void)createSectionView:(SectionDividerView*)view headerText:(NSString*)sectionText{
    @autoreleasepool {
        view.lblHeadText.text = sectionText;
    }
}


#pragma Delegates

-(void)addNewGroup{
    [self openGroup];
}

-(void)showGroup:(NSInteger)groupId
{
    UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:@"Main" bundle: nil];
    GroupViewController *controller = (GroupViewController *)[mainStoryboard instantiateViewControllerWithIdentifier:@"Group"];
    controller.group_id = groupId;
    [self.navigationController pushViewController:controller animated:YES];
}

//Search

-(void)openSearchViewController
{
    [self.avView.btnSearchById setHidden:YES];
    [self.avView.txtSearchById setHidden:NO];
    [self.avView.txtSearchById becomeFirstResponder];
    self.friendsList.enableSectionTitles = NO;
    [self openSeachController];
}

-(void)closeSearchViewController
{
    [self.avView.btnSearchById setHidden:NO];
    [self.avView.txtSearchById setHidden:YES];
    [self.avView.txtSearchById resignFirstResponder];
    self.friendsList.enableSectionTitles = YES;
    [self closeSeachController];
    [self.friendsList getFriendsByUserId];
}

-(void)postFriendsSearchResponse:(NSDictionary *)response
{
    [self.friendsList searchFriendsById:[FriendSearchResult arrayOfModelsFromDictionaries:response[@"data"]]];
}


#pragma MessageDelegate

- (void)messageComposeViewController:(MFMessageComposeViewController *)controller didFinishWithResult:(MessageComposeResult)result
{
    switch (result) {
        case MessageComposeResultCancelled:
            NSLog(@"Cancelled");
            break;
        case MessageComposeResultSent:
            
            break;
        default:
            break;
    }
    
    [self dismissViewControllerAnimated:YES completion:^{
    }];
}

-(void)openMessageComposer:(NSArray*)sendNumbers messageText:(NSString*)messageTextValue{
    
    MFMessageComposeViewController *controller = [[MFMessageComposeViewController alloc] init];
    if([MFMessageComposeViewController canSendText])
    {
        controller.body = messageTextValue;
        controller.recipients = sendNumbers;
        controller.messageComposeDelegate = self;
        [self presentViewController:controller animated:YES completion:^{
            
        }];
    }}

#pragma mark FriendsList Delegate

-(void)selectedRow:(id)object
{
    if(selectedDict == nil)
    {
        selectedDict = [[NSMutableDictionary alloc] init];
    }
    
    if ([selectedDict objectForKey:[object objectForKey:@"friend_id"]])
    {
        [selectedDict removeObjectForKey:[object objectForKey:@"friend_id"]];
    }
    
    [selectedDict setObject:object forKey:[object objectForKey:@"friend_id"]];
    
    if ([selectedDict count] > 0)
    {
        
    }
}

- (void)scrollViewWillEndDragging:(UIScrollView *)scrollView
                     withVelocity:(CGPoint)velocity
              targetContentOffset:(inout CGPoint *)targetContentOffset
{
    if (velocity.y > 0)
    {
        // NSLog(@"up");
        NSLog(@"%f",velocity.y);
        
        
        // _viewShare
        // _viewSearch
        
        [UIView animateWithDuration:0.6 animations:^
         {
          
             CGRect frame = _headerView2.frame;
             frame.origin.y = _avView.frame.origin.y + _avView.frame.size.height;
             _headerView2.frame = frame;

             frame = _friendsList.frame;
             frame.origin.y = _headerView2.frame.origin.y + _headerView2.frame.size.height;
             frame.size.height = self.view.frame.size.height - _footerView.frame.size.height - frame.origin.y - _headerView2.frame.size.height;
             _friendsList.frame = frame;
             
             _friendsList.enableSectionTitles = YES;
         
         }completion:^(BOOL finished) {
             [_friendsList.friendsListTableView reloadData];
         }];
    }

}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if (scrollView.contentOffset.y < 100)
    {
        [UIView animateWithDuration:0.6 animations:^{
            
            _headerView2.frame = _frameHeaderView2;
            _friendsList.frame = _frameFriendsList;
            
            
        }completion:^(BOOL finished) {
            _friendsList.enableSectionTitles = NO;
            [_friendsList.friendsListTableView reloadData];
        }];
        
    }

}


#pragma Events

-(void)openGroup{
    UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:@"Main" bundle: nil];
    GroupViewController *controller = (GroupViewController *)[mainStoryboard instantiateViewControllerWithIdentifier:@"Group"];
    controller.group_id = -1;
    [self.navigationController pushViewController:controller animated:YES];

}

-(void)openSeachController{
    CGRect friendsViewFrame = self.friendsList.frame;
    CGRect groupSectionFrame = self.headerView1.frame;
    
    friendsViewFrame.origin.y = groupSectionFrame.origin.y;
    friendsViewFrame.size.height = self.footerView.frame.origin.y - friendsViewFrame.origin.y;
    
    [UIView animateWithDuration:0.5 delay:0.5
                        options:UIViewAnimationOptionCurveEaseInOut
                     animations:^{
                         self.friendsList.frame =friendsViewFrame;
                         CGRect tblFrame = self.friendsList.friendsListTableView.frame;
                         tblFrame.size.height = friendsViewFrame.size.height;
                         
    } completion:^(BOOL finished) {
        
    }];
    
//    UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:@"Main" bundle: nil];
//    SearchViewController *controller = (SearchViewController *)[mainStoryboard instantiateViewControllerWithIdentifier:@"Search"];
//    [self.navigationController pushViewController:controller animated:YES];
}

-(void)closeSeachController{
    CGRect friendsViewFrame = friendsFrame;
    [UIView animateWithDuration:0.5 delay:0.5
                        options:UIViewAnimationOptionCurveEaseInOut
                     animations:^{
                         self.friendsList.frame =friendsViewFrame;
                     } completion:^(BOOL finished) {
                         
                     }];
}

-(void)openSendController{
    UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:@"Main" bundle: nil];
    SendPageViewController *controller = (SendPageViewController *)[mainStoryboard instantiateViewControllerWithIdentifier:@"SendPage"];
    [self.navigationController pushViewController:controller animated:YES];
    
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (IBAction)btnAddButtonClick:(id)sender
{
    if(selectedDict)
    {
        NSMutableArray* friendsArry = [[NSMutableArray alloc] init];
        for (NSString* key in selectedDict) {
            id value = [selectedDict objectForKey:key];
            [friendsArry addObject:value];
        }
        
        NSMutableDictionary* dataDic = [[NSMutableDictionary alloc] init];
        NSMutableDictionary* userDic = [[NSMutableDictionary alloc] init];
        [userDic setObject:friendsArry forKey:@"friends"];
        [userDic setObject:[AppHelper getCurrentLoginId] forKey:@"user_id"];
        [dataDic setObject:userDic forKey:@"data"];
        
        ComicNetworking* cmNetWorking = [ComicNetworking sharedComicNetworking];
        [cmNetWorking addRemoveFriends:dataDic completion:^(id json,id jsonResposeHeader) {
            [selectedDict removeAllObjects];
            selectedDict = nil;
        } ErrorBlock:^(JSONModelError *error) {
        }];
        dataDic = nil;
        userDic = nil;
        friendsArry = nil;
    }
}

- (IBAction)btnBackClick:(id)sender {
    self.avView.txtSearchById.text = @"";
    [self closeSeachController];
    [self.navigationController popViewControllerAnimated:YES];
}

@end
