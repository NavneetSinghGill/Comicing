//
//  FriendsListView.h
//  ComicApp
//
//  Created by Ramesh on 22/11/15.
//  Copyright © 2015 Ramesh. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UIColor+colorWithHexString.h"
#import "FriendsListTableViewCell.h"
#import "ComicNetworking.h"
#import "BaseModel.h"

@protocol FriendListDelegate <NSObject>

@optional

-(void)selectedRow:(id)object;
-(void)selectedRow:(id)object param:(id)objectList;
-(void)openMessageComposer:(NSArray*)sendNumbers messageText:(NSString*)messageTextValue;
@end

@interface FriendsListView : UIView<UITableViewDataSource,UITableViewDelegate,ComicNetworkingDelegate>
{
//    NSMutableArray* friendsArray;
    NSArray *alphabetsSectionTitles;
    NSArray* groupMembersList;
    NSMutableDictionary* friendsDictWithAlpabets;
    
    NSMutableArray* contactList;
    NSMutableArray* contactNumber;
    NSArray* temContactList;
}
@property (strong, nonatomic) IBOutlet UIView *view;
@property (weak, nonatomic) IBOutlet UITableView *friendsListTableView;
@property (strong, nonatomic) IBOutlet FriendsListTableViewCell *tabCell;
@property (weak, nonatomic) IBOutlet UILabel *headerName;
@property (strong, nonatomic) NSString * selectedActionName;
@property (nonatomic, assign) id<FriendListDelegate> delegate;
@property (assign, nonatomic) BOOL enableSectionTitles;
@property (assign, nonatomic) BOOL enableSelection;
@property (assign, nonatomic) BOOL enableInvite;
@property (strong,nonatomic)  NSMutableArray* friendsArray;
@property (weak, nonatomic) IBOutlet UIView *tableHolderView;


-(void)getFriendsByUserId;
-(void)searchFriendsById:(NSMutableArray*)list;
-(void)getFriendsByUserId:(NSArray*)groupMembers;
@end
