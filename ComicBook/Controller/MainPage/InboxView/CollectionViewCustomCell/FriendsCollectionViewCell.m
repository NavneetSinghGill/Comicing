//
//  FriendsCollectionViewCell.m
//  Inbox
//
//  Created by Vishnu Vardhan PV on 20/12/15.
//  Copyright © 2015 Vishnu Vardhan PV. All rights reserved.
//

#import "FriendsCollectionViewCell.h"
#import "UIImageView+WebCache.h"
#import <QuartzCore/QuartzCore.h>
#import "AppConstants.h"

@implementation FriendsCollectionViewCell

@synthesize friendImageView;

- (void)populateCell:(Friend *)friendModel
{
    [self makeCircularImageView:friendModel];

    self.friendObject = friendModel;
    
    [self.friendImageView sd_setImageWithURL:[NSURL URLWithString:friendModel.profilePic]];
    
    self.friendNameLabel.text = friendModel.firstName;
}

- (void)makeBorderAroundImageview
{
    CALayer *borderLayer = [CALayer layer];
    
    CGRect borderFrame = CGRectMake(0, 0, (friendImageView.frame.size.width), (friendImageView.frame.size.height));
    [borderLayer setBackgroundColor:[[UIColor clearColor] CGColor]];
    [borderLayer setFrame:borderFrame];
    [borderLayer setBorderWidth:3];
    self.friendImageView.layer.cornerRadius = self.friendImageView.frame.size.width / 2;
    [borderLayer setBorderColor:[[UIColor yellowColor] CGColor]];
    [friendImageView.layer addSublayer:borderLayer];
    self.friendImageView.clipsToBounds = YES;
}

- (void)makeCircularImageView:(Friend *)frd
{
//    self.friendImageView.layer.borderWidth = 1.0f;
//    self.friendImageView.layer.borderColor = [UIColor blackColor].CGColor;
    self.friendImageView.layer.cornerRadius = self.friendImageView.bounds.size.width / 2;
    self.friendImageView.layer.masksToBounds = YES;
    CGFloat fontSize = 7;
    CGFloat borderWidthon;
    if (IS_IPHONE_5)
    {
        borderWidthon = 2;
        fontSize = 6;
        
    }
    else if (IS_IPHONE_6)
    {
        borderWidthon = 3;
        fontSize = 7;
        
    }
    else if (IS_IPHONE_6P)
    {
        borderWidthon = 3;
        fontSize = 7;
        
    }
    else
    {
        borderWidthon = 2;
        fontSize = 6;
    }
    self.friendNameLabel.font = [self.friendNameLabel.font fontWithSize:fontSize];

    if (frd.isSelected)
    {
        
        self.friendImageView.layer.borderWidth = borderWidthon;
        self.friendImageView.layer.borderColor = [UIColor yellowColor].CGColor;
    }
    else
    {
        self.friendImageView.layer.borderWidth = borderWidthon;
        self.friendImageView.layer.borderColor = [UIColor clearColor].CGColor;
    }
}
-(void)layoutSubviews
{
    [super layoutSubviews];
    self.friendImageView.layer.cornerRadius = self.friendImageView.frame.size.width / 2;
    self.friendImageView.layer.masksToBounds = YES;


}
- (IBAction)tappedProfilePic:(id)sender {
    if([self.delegate respondsToSelector:@selector(didTapProfileImageOfFriend:)]) {
        [self.delegate didTapProfileImageOfFriend:self.friendObject];
    }
}

@end
