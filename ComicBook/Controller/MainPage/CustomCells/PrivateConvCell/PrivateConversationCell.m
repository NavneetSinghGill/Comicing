//
//  PrivateConversationCell.m
//  CurlDemo
//
//  Created by Subin Kurian on 11/1/15.
//  Copyright © 2015 Subin Kurian. All rights reserved.
//
#define IS_IPHONE (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)
#define SCREEN_WIDTH ([[UIScreen mainScreen] bounds].size.width)
#define SCREEN_HEIGHT ([[UIScreen mainScreen] bounds].size.height)
#define SCREEN_MAX_LENGTH (MAX(SCREEN_WIDTH, SCREEN_HEIGHT))
#define SCREEN_MIN_LENGTH (MIN(SCREEN_WIDTH, SCREEN_HEIGHT))
#define IS_IPHONE_5 (IS_IPHONE && SCREEN_MAX_LENGTH == 568.0)
#define IS_IPHONE_6 (IS_IPHONE && SCREEN_MAX_LENGTH == 667.0)
#define IS_IPHONE_6P (IS_IPHONE && SCREEN_MAX_LENGTH == 736.0)

#import "PrivateConversationCell.h"

@implementation PrivateConversationCell

@synthesize widthconstraint,btnUser, userProfilePic;

- (void)awakeFromNib {
    // Initialization code
    
    if(IS_IPHONE_5)
    {
        btnUser.frame = CGRectMake(CGRectGetMinX(btnUser.frame),
                                    CGRectGetMinY(btnUser.frame),
                                    40,
                                    40);
        userProfilePic.frame = CGRectMake(CGRectGetMinX(userProfilePic.frame),
                                   CGRectGetMinY(userProfilePic.frame),
                                   40,
                                   40);
        
    }
    else if(IS_IPHONE_6)
    {
        btnUser.frame = CGRectMake(CGRectGetMinX(btnUser.frame),
                                    CGRectGetMinY(btnUser.frame) ,
                                    54,
                                    54);
        userProfilePic.frame = CGRectMake(CGRectGetMinX(userProfilePic.frame),
                                   CGRectGetMinY(userProfilePic.frame) ,
                                   54,
                                   54);
    }
    else if(IS_IPHONE_6P)
    {
        btnUser.frame = CGRectMake(CGRectGetMinX(btnUser.frame),
                                    CGRectGetMinY(btnUser.frame) ,
                                    60,
                                    60);
        userProfilePic.frame = CGRectMake(CGRectGetMinX(userProfilePic.frame),
                                   CGRectGetMinY(userProfilePic.frame) ,
                                   60,
                                   60);
    }
    
    
    
//    btnUser.layer.cornerRadius = CGRectGetHeight(btnUser.frame) / 2;
    btnUser.clipsToBounds = YES;
    
//    userProfilePic.layer.cornerRadius = CGRectGetHeight(userProfilePic.frame) / 2;
    userProfilePic.clipsToBounds = YES;

}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (IBAction)btnUserTouchDown:(id)sender
{
    [UIView animateWithDuration:0.1 animations:^
     {
         btnUser.layer.transform = CATransform3DMakeScale(0.9, 0.9, 1.0);
         userProfilePic.layer.transform = CATransform3DMakeScale(0.9, 0.9, 1.0);
     }];
}

- (IBAction)btnUserTouchUpInside:(id)sender
{
    [self restoreTransformWithBounceForView:btnUser];
    [self restoreTransformWithBounceForView:userProfilePic];
}

- (IBAction)btnUserTouchUpOutside:(id)sender
{
    [self restoreTransformWithBounceForView:btnUser];
    [self restoreTransformWithBounceForView:userProfilePic];
}

- (void)restoreTransformWithBounceForView:(UIView*)view
{
    [UIView animateWithDuration:1
                          delay:0
         usingSpringWithDamping:0.2
          initialSpringVelocity:0.3
                        options:UIViewAnimationOptionTransitionCurlDown
                     animations:^
     {
         view.layer.transform = CATransform3DIdentity;
     }
                     completion:nil];
}

@end
