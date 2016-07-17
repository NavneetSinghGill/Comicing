//
//  PrivateConversationTextCell.h
//  ComicBook
//
//  Created by Guntikogula Dinesh on 10/07/16.
//  Copyright © 2016 ADNAN THATHIYA. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PrivateConversationTextCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIImageView *userProfilePic;
@property (weak, nonatomic) IBOutlet UILabel *lblDate;
@property (weak, nonatomic) IBOutlet UILabel *lblTime;
@property (weak, nonatomic) IBOutlet UIButton *btnUser;
@property (weak, nonatomic) IBOutlet UILabel *mUserName;
@property (weak, nonatomic) IBOutlet UIView *mMessageHolderView;
@property (weak, nonatomic) IBOutlet UILabel *mMessage;
@property (weak, nonatomic) IBOutlet UILabel *mChatStatus;

@end