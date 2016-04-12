//
//  GroupCell.m
//  CurlDemo
//
//  Created by Vishnu Vardhan PV on 05/02/16.
//  Copyright © 2016 Vishnu Vardhan PV. All rights reserved.
//

#import "GroupCell.h"

#define IS_IPHONE (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)
#define SCREEN_WIDTH ([[UIScreen mainScreen] bounds].size.width)
#define SCREEN_HEIGHT ([[UIScreen mainScreen] bounds].size.height)
#define SCREEN_MAX_LENGTH (MAX(SCREEN_WIDTH, SCREEN_HEIGHT))
#define SCREEN_MIN_LENGTH (MIN(SCREEN_WIDTH, SCREEN_HEIGHT))
#define IS_IPHONE_5 (IS_IPHONE && SCREEN_MAX_LENGTH == 568.0)
#define IS_IPHONE_6 (IS_IPHONE && SCREEN_MAX_LENGTH == 667.0)
#define IS_IPHONE_6P (IS_IPHONE && SCREEN_MAX_LENGTH == 736.0)

@implementation GroupCell

@synthesize widthconstraint,btnUser, profileImageView;

- (void)awakeFromNib {
    // Initialization code
    
    if(IS_IPHONE_5)
    {
        btnUser.frame = CGRectMake(CGRectGetMinX(btnUser.frame),
                                   CGRectGetMinY(btnUser.frame),
                                   60,
                                   60);
        profileImageView.frame = CGRectMake(CGRectGetMinX(profileImageView.frame),
                                   CGRectGetMinY(profileImageView.frame),
                                   60,
                                   60);
    }
    else if(IS_IPHONE_6)
    {
        btnUser.frame = CGRectMake(CGRectGetMinX(btnUser.frame),
                                   CGRectGetMinY(btnUser.frame) ,
                                   68,
                                   68);
        profileImageView.frame = CGRectMake(CGRectGetMinX(profileImageView.frame),
                                   CGRectGetMinY(profileImageView.frame) ,
                                   68,
                                   68);
    }
    else if(IS_IPHONE_6P)
    {
        btnUser.frame = CGRectMake(CGRectGetMinX(btnUser.frame),
                                   CGRectGetMinY(btnUser.frame) ,
                                   74,
                                   74);
        profileImageView.frame = CGRectMake(CGRectGetMinX(profileImageView.frame),
                                   CGRectGetMinY(profileImageView.frame) ,
                                   74,
                                   74);
    }
    
    
    
    btnUser.layer.cornerRadius = CGRectGetHeight(btnUser.frame) / 2;
    btnUser.clipsToBounds = YES;
    profileImageView.layer.cornerRadius = CGRectGetHeight(profileImageView.frame) / 2;
    profileImageView.clipsToBounds = YES;
    
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
         profileImageView.layer.transform = CATransform3DMakeScale(0.9, 0.9, 1.0);
     }];
}

- (IBAction)btnUserTouchUpInside:(id)sender
{
    [self restoreTransformWithBounceForView:btnUser];
    [self restoreTransformWithBounceForView:profileImageView];
}

- (IBAction)btnUserTouchUpOutside:(id)sender
{
    [self restoreTransformWithBounceForView:btnUser];
    [self restoreTransformWithBounceForView:profileImageView];
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
