//
//  SendPageViewController.m
//  ComicApp
//
//  Created by Ramesh on 27/11/15.
//  Copyright © 2015 Ramesh. All rights reserved.
//

#import "SendPageViewController.h"
#import "ComicPage.h"

@interface SendPageViewController ()

@end

@implementation SendPageViewController

#define FB 10
#define IM 11
#define TW 12
#define IN 13

- (void)viewDidLoad {
    
    [self configViews];
    [self configText];
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}

-(void)viewWillAppear:(BOOL)animated{
    self.friendsListView.enableSectionTitles = YES;
    self.friendsListView.enableSelection = YES;
    self.friendsListView.delegate = self;
    self.groupsView.delegate = self;
    self.groupsView.enableSelection= YES;
    [self.friendsListView getFriendsByUserId];
    [self bindComicImages];
    [super viewWillAppear:animated];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
#pragma Methods

-(void)configViews{

    [self.headerView.btn1 setImage:[UIImage imageNamed:@"pen.png"] forState:UIControlStateNormal];
    [self.headerView.btn3 setImage:[UIImage imageNamed:@"smile.png"] forState:UIControlStateNormal];
    CGRect frame = self.headerView.btn3.frame;
//    frame.size = CGSizeMake(34, 34);
    frame = CGRectMake(frame.origin.x + 8, frame.origin.y + 5, 34, 34);
    self.headerView.btn3.frame = frame;
    
    frame = self.headerView.btn1.frame;
    frame.size = CGSizeMake(24, 34);
    self.headerView.btn1.frame = frame;
    
    frame =  self.friendsListView.headerName.frame;
    frame.origin.x = 20;
    self.friendsListView.headerName.frame = frame;
    
    frame = self.friendsListView.tableHolderView.frame;
    frame.origin.y = frame.origin.y - 5;
    self.friendsListView.tableHolderView.frame = frame;
    
    CGRect friendListRect = self.friendsListView.view.frame;
    friendListRect.size.height = self.friendsListView.frame.size.height;
    self.friendsListView.view.frame = friendListRect;
    
    frame = self.groupsView.frame;
    frame.size.height = 87;
    self.groupsView.frame = frame;
    
    frame = self.groupsView.groupCollectionView.frame;
    frame.origin.x = 0;
    frame.size.height = 87;
    self.groupsView.groupCollectionView.frame = frame;
}
-(void)configText{
    
    [self.lblGroup setFont:[UIFont  fontWithName:@"MYRIADPRO-REGULAR" size:22]];
    [self.lblFriends setFont:[UIFont  fontWithName:@"MYRIADPRO-REGULAR" size:22]];
    [self.friendsListView.headerName setFont:[UIFont  fontWithName:@"MYRIADPRO-REGULAR" size:12]];
    self.friendsListView.headerName.text = @"Best friends";
    [self.friendsListView.headerName setTextColor:[UIColor colorWithHexStr:@"231f20"]];
    
}

-(NSDictionary*)getGroupShares:(UserGroup*) ug{
    @autoreleasepool {
        NSMutableDictionary* dict = [[NSMutableDictionary alloc] init];
        if(ug)
        {
            [dict setValue:ug.group_id forKey:@"group_id"];
            [dict setValue:@"1" forKey:@"status"];
        }
        return dict;
    }

}

-(NSDictionary*)getFriendsShares:(UserFriends*) uf{
    @autoreleasepool {
        NSMutableDictionary* dict = [[NSMutableDictionary alloc] init];
        if(uf)
        {
            [dict setValue:uf.friend_id forKey:@"friend_id"];
            [dict setValue:@"1" forKey:@"status"];
        }
        return dict;
    }
}

-(void)generateGroupShareArray:(UserGroup*)ug
{
    if(shareGroupsArray == nil)
        shareGroupsArray = [[NSMutableArray alloc] init];
    if(ug)
    {
        [shareGroupsArray addObject:[self getGroupShares:ug]];
    }
}

-(void)generateFriendShareArray:(UserFriends*)uf
{
    if(shareFriendsArray == nil)
        shareFriendsArray = [[NSMutableArray alloc] init];
    if(uf)
    {
        [shareFriendsArray addObject:[self getFriendsShares:uf]];
    }
}
-(NSMutableDictionary*)setPutParamets{
//    @autoreleasepool {
        NSMutableDictionary* dataDic = [[NSMutableDictionary alloc] init];
        NSMutableDictionary* userDic = [[NSMutableDictionary alloc] init];
        [userDic setObject:[AppHelper getCurrentcomicId] forKey:@"comic_id"];
        [userDic setObject:[AppHelper getCurrentLoginId] forKey:@"user_id"];
        if(shareGroupsArray){
            [userDic setObject:shareGroupsArray forKey:@"groupShares"];
        }
        if (shareFriendsArray) {
            [userDic setObject:shareFriendsArray forKey:@"friendShares"];
        }
        [dataDic setObject:userDic forKey:@"data"];
        return dataDic;
//    }
}

-(void)doSendData
{
    ComicNetworking* cmNetWorking = [ComicNetworking sharedComicNetworking];
//    cmNetWorking.delegate= self;
    //i d't know what is 3 .. need to confirm with Shy
    [cmNetWorking shareComicImage:[self setPutParamets] Id:[AppHelper getCurrentcomicId] completion:^(id json,id jsonResposeHeader) {
        NSLog(@"Share Sucess");
    } ErrorBlock:^(JSONModelError *error) {
        NSLog(@"Share Error %@",error);
    }];

}

-(void)doShareTo :(ShapeType)type ShareImage:(UIImage*)imgShareto{
    
    NSData *imageData = UIImagePNGRepresentation(imgShareto);
    UIImage *image=[UIImage imageWithData:imageData];
    
//    UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil);
    
    //Just to test
    
//     UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil);
//     NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
//     NSString *documentsPath = [paths objectAtIndex:0]; //Get the docs directory
//     NSString *filePath = [documentsPath stringByAppendingPathComponent:@"image.png"]; //Add the file name
//     [imageData writeToFile:filePath atomically:YES]; //Write the file
//    NSLog(@"Log %@",filePath);
    
    
    /* Commented for testing*/
    ShareHelper* sHelper = [ShareHelper shareHelperInit];
    sHelper.parentviewcontroller = self;
    [sHelper shareAction:type ShareText:@""
              ShareImage:image
              completion:^(BOOL status) {
              }];
    
}

#pragma Events

- (IBAction)backButtonClick:(id)sender {
    
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)btnEveryOnceClick:(id)sender {
    
    //do loop for the group
    if (self.groupsView.groupsArray) {
        for (UserGroup* ug in self.groupsView.groupsArray) {
            [self generateGroupShareArray:ug];
        }
    }
    //do loop for the Friends
    if (self.friendsListView.friendsArray) {
        for (UserFriends* uf in self.friendsListView.friendsArray) {
            [self generateFriendShareArray:uf];
        }
    }
    [self doSendData];
}

- (IBAction)btnShareComic:(id)sender {
    [self doSendData];
}
- (IBAction)btnShareToSocialMedia:(id)sender {
    switch (((UIButton*)sender).tag) {
        case FB:
        {
            
//            [self doShareTo:FACEBOOK ShareImage:[self.comicShareViewView getComicShareImage:@[[UIImage imageNamed:@"Glide-1"],
//                                                                                             [UIImage imageNamed:@"Glide-2"],
//                                                                                             [UIImage imageNamed:@"Glide-3"]]]];
            
            [self doShareTo:FACEBOOK ShareImage:[self.comicShareViewView getComicShareImage:imageArray]];
        }
            break;
        case IM:
        {
            [self doShareTo:MESSAGE ShareImage:[self.comicShareViewView getComicShareImage:imageArray]];
        
            break;
        }
        case TW:
        {
            [self doShareTo:TWITTER ShareImage:[self.comicShareViewView getComicShareImage:imageArray]];
        }
            break;
        case IN:
        {
//            [self doShareTo:INSTAGRAM ShareImage:[self.comicShareViewView getComicShareImage:@[[UIImage imageNamed:@"Image_Slide1"]]]];
            
            [self doShareTo:INSTAGRAM ShareImage:[self.comicShareViewView getComicShareImage:imageArray]];
                        break;
        }
        default:
            break;
    }
}

-(void)bindComicImages{
    imageArray = [[NSMutableArray alloc] init];
    
    NSMutableArray* comicSlides = [AppHelper getDataFromFile:@"ComicSlide"];
    //[[[NSUserDefaults standardUserDefaults] objectForKey:@"comicSlides"] mutableCopy];
    for (NSData* data in comicSlides) {
        ComicPage* cmPage = [NSKeyedUnarchiver unarchiveObjectWithData:data];
        
        //ComicSlides Object
        [imageArray  addObject:[AppHelper getImageFile:cmPage.printScreenPath]];
    }
//    [imageArray addObject:@"01.png"];
//    [imageArray addObject:@"02.png"];
//    [imageArray addObject:@"03.png"];
//    [imageArray addObject:@"04.png"];
    
    [self.comicImageList refeshList:imageArray];
    comicSlides = nil;
//    imageArray = nil;
}

#pragma mark GroupList Delegate

-(void)selectGroupItems:(id)object
{
    UserGroup* ug = (UserGroup*)object;
    if(ug)
        [self generateGroupShareArray:ug];
}

#pragma mark FriendsList Delegate

-(void)selectedRow:(id)object
{
    
    UserFriends* uf = (UserFriends*)object;
    if(uf)
        [self generateFriendShareArray:uf];
}

#pragma mark Api Delegate

-(void)comicNetworking:(id)sender postFailResponse:(NSDictionary *)response{
    
}
-(void)comicNetworking:(id)sender postShareComicResponse:(NSDictionary *)response
{
    NSLog(@"Share Sucess");
}

@end
