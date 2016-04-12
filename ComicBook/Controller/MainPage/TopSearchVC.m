//
//  TopSearchVC.m
//  CurlDemo
//
//  Created by Ramesh on 18/02/16.
//  Copyright © 2016 Vishnu Vardhan PV. All rights reserved.
//

#import "TopSearchVC.h"
#import "ContactsViewController.h"
#import "CameraViewController.h"
#import "MePageVC.h"
#import "Constants.h"
#import "FriendsAPIManager.h"
#import "DateLabel.h"
#import "UserSearch.h"
#import "UIImageView+WebCache.h"
#import "MainPageVC.h"
#import "AppHelper.h"
#import "FriendPageVC.h"

const int blurViewTag = 1010;

@interface TopSearchVC ()


@property (weak, nonatomic) IBOutlet UITableView *tableview;

@end

@implementation TopSearchVC

- (void)viewDidLoad {
    
    [self addTopBarView];
    [self addBlurEffectOverImageView];
    self.tableview.delegate = self;
    
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

// write this method in MainViewController
- (void) displayContentController: (UIViewController*) parentViewContent
{
    [parentViewContent addChildViewController:self];                 // 1
    self.view.bounds = parentViewContent.view.bounds;                 //2
    [parentViewContent.view addSubview:self.view];
    [parentViewContent didMoveToParentViewController:parentViewContent];          // 3
    [parentViewContent.view bringSubviewToFront:self.view];
    
    [self.view setAlpha:0.0f];
    //fade in
    [UIView animateWithDuration:2.0f animations:^{
        [self.view setAlpha:1.0f];
    } completion:^(BOOL finished) {
    }];
}

//you can also write this method in MainViewController to remove the child VC you added before.
- (void) hideContentController
{
    //fade out
    [UIView animateWithDuration:2.0f animations:^{
        [self.view setAlpha:0.0f];
        [[self.parentViewController.view viewWithTag:blurViewTag] setAlpha:0.0];
    } completion:^(BOOL finished) {
        [[self.parentViewController.view viewWithTag:blurViewTag] removeFromSuperview];
        [self willMoveToParentViewController:nil];  // 1
        [self.view removeFromSuperview];            // 2
        [self removeFromParentViewController];      // 3
    }];
    

}

- (IBAction)tappedBackButton:(id)sender {
    [self hideContentController];
}

#pragma mark Methods

- (void)addTopBarView {
    topBarView = [self.storyboard instantiateViewControllerWithIdentifier:TOP_BAR_VIEW];
    [topBarView.view setFrame:CGRectMake(0, 0, self.view.frame.size.width, 50)];
    [self addChildViewController:topBarView];
    [self.view addSubview:topBarView.view];
    [topBarView didMoveToParentViewController:self];
    
    __block typeof(self) weakSelf = self;
    topBarView.homeAction = ^(void) {
        MainPageVC *contactsView = [weakSelf.storyboard instantiateViewControllerWithIdentifier:MAIN_PAGE_VIEW];
//        [weakSelf presentViewController:contactsView animated:YES completion:nil];
        [weakSelf.navigationController pushViewController:contactsView animated:YES];
    };
    topBarView.contactAction = ^(void) {
//        ContactsViewController *contactsView = [weakSelf.storyboard instantiateViewControllerWithIdentifier:CONTACTS_VIEW];
//        [weakSelf presentViewController:contactsView animated:YES completion:nil];
        [AppHelper closeMainPageviewController:self];
    };
    topBarView.meAction = ^(void) {
        MePageVC *meView = [weakSelf.storyboard instantiateViewControllerWithIdentifier:ME_VIEW];
//        [weakSelf presentViewController:meView animated:YES completion:nil];
        [weakSelf.navigationController pushViewController:meView animated:YES];
    };
    topBarView.searchAction = ^(void) {
        [topBarView handleSearchControl:YES];
    };
    topBarView.searchUser = ^(NSString* searchText){
//        [topBarView handleSearchControl:YES];
        [self doSearchUser:searchText];
    };
    
    //By default handle textSearch
    [topBarView handleSearchControl:YES];
}
-(void) addBlurEffectOverImageView{
    UIVisualEffect *blurEffect;
    blurEffect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleLight];
    
    UIVisualEffectView *visualEffectView;
    visualEffectView = [[UIVisualEffectView alloc] initWithEffect:blurEffect];
    
    visualEffectView.frame = self.view.bounds;
    visualEffectView.tag = blurViewTag;
    
    [self.parentViewController.view addSubview:visualEffectView];
    [visualEffectView setAlpha:0.0f];
    
    [UIView animateWithDuration:1.0f animations:^{
        [visualEffectView setAlpha:1.0f];
    } completion:^(BOOL finished) {
    }];
}


#pragma mark api

-(void)doSearchUser:(NSString*)txtSearch{
    
    [FriendsAPIManager getTheListOfFriendsByID:txtSearch withSuccessBlock:^(id object) {
        self.searchResultArray = [MTLJSONAdapter modelsOfClass:[UserSearch class] fromJSONArray:[object valueForKey:@"data"] error:nil];
        [self.tableview reloadData];
    } andFail:^(NSError *errorMessage) {
        NSLog(@"%@", errorMessage);
    }];
    
//    __block typeof(self) weakSelf = self;
//    FriendPageVC *contactsView = [weakSelf.storyboard instantiateViewControllerWithIdentifier:FRIEND_PAGE_VIEW];
//    [weakSelf.navigationController pushViewController:contactsView animated:YES];
}

#pragma mark TableViewDelegate

//-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
//{
//    return 80;
//
//}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.searchResultArray count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    self.friendSearchObject = self.searchResultArray[indexPath.row];

    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell"];
    
    //Profile Pic
    UIImageView*imageView=(UIImageView*)[cell viewWithTag:1];
    [imageView sd_setImageWithURL:[NSURL URLWithString:self.friendSearchObject.profilePic]];
    imageView.layer.cornerRadius =  imageView.frame.size.width / 2;
    imageView.clipsToBounds = YES;
    imageView.layer.masksToBounds=YES;
    
    //Profile Name
    UILabel*labl=(UILabel*)[cell viewWithTag:2];
    labl.textColor=[UIColor whiteColor];
    cell.backgroundColor=[UIColor clearColor];
    cell.contentView.backgroundColor=[UIColor clearColor];
    labl.text = [NSString stringWithFormat:@"%@ %@",self.friendSearchObject.firstName,self.friendSearchObject.lastName];
    
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
   self.friendSearchObject = self.searchResultArray[indexPath.row];
    
    __block typeof(self) weakSelf = self;
    FriendPageVC *contactsView = [weakSelf.storyboard instantiateViewControllerWithIdentifier:FRIEND_PAGE_VIEW];
    [weakSelf.navigationController pushViewController:contactsView animated:YES];
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
