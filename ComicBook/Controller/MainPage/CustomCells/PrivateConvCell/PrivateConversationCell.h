//
//  PrivateConversationCell.h
//  CurlDemo
//
//  Created by Subin Kurian on 11/1/15.
//  Copyright © 2015 Subin Kurian. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PrivateConversationCell : UITableViewCell

@property(nonatomic,weak)IBOutlet NSLayoutConstraint*widthconstraint;
@property (weak, nonatomic) IBOutlet UIImageView *userProfilePic;
@property (weak, nonatomic) IBOutlet UILabel *lblDate;
@property (weak, nonatomic) IBOutlet UILabel *lblTime;
@property (weak, nonatomic) IBOutlet UIView *viewComicBook;
@property (weak, nonatomic) IBOutlet UIButton *btnUser;
@property (weak, nonatomic) IBOutlet UILabel *mUserName;
@property (weak, nonatomic) IBOutlet UILabel *mChatStatus;

@property (weak, nonatomic) IBOutlet UILabel *lblComicTitle;
@end
