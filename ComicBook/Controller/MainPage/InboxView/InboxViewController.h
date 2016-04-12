//
//  InboxViewController.h
//  CurlDemo
//
//  Created by Vishnu Vardhan PV on 14/01/16.
//  Copyright © 2016 Vishnu Vardhan PV. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FriendsCollectionViewCell.h"
#import "GroupsCollectionViewCell.h"

@interface InboxViewController : UIViewController <UICollectionViewDataSource,UICollectionViewDelegate, FriendsCellProtocol, GroupsCellProtocol>

@property (weak, nonatomic) IBOutlet UICollectionView *groupCV;
@property (weak, nonatomic) IBOutlet UICollectionView *friendsCV;
@property (weak, nonatomic) IBOutlet UICollectionView *alphabetCV;

@property (strong, nonatomic) NSArray *alphabets;

@property (strong, nonatomic) NSTimer *timer;

@end
