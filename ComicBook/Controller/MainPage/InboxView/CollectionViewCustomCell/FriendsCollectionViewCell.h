//
//  FriendsCollectionViewCell.h
//  Inbox
//
//  Created by Vishnu Vardhan PV on 20/12/15.
//  Copyright © 2015 Vishnu Vardhan PV. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Friend.h"

@protocol FriendsCellProtocol;

@interface FriendsCollectionViewCell : UICollectionViewCell

@property (nonatomic, weak) IBOutlet UIImageView *friendImageView;
@property (nonatomic, weak) IBOutlet UILabel *friendNameLabel;
@property (nonatomic, strong) Friend *friendObject;
@property (nonatomic, strong) id <FriendsCellProtocol> delegate;

- (void)populateCell:(Friend *)friendModel;

@end

@protocol FriendsCellProtocol <NSObject>

- (void)didTapProfileImageOfFriend:(Friend *)friendObj;

@end