//
//  MainPageCell.m
//  ComicBook
//
//  Created by ADNAN THATHIYA on 26/06/16.
//  Copyright © 2016 ADNAN THATHIYA. All rights reserved.
//

#import "MainPageCell.h"
#import "AppConstants.h"

@implementation MainPageCell
@synthesize widthconstraint,btnUser, profileImageView, lblComicTitle, btnBubble, btnTwitter, btnFacebook, btnBubbleBottomConstraint,btnTwitterBottomConstraint,btnFacebookBottomConstraint;

-(void)layoutSubviews
{
    [super layoutSubviews];
    
    [self layoutCell];
}

-(void)layoutCell
{
    [self layoutIfNeeded];
    
    [profileImageView layoutIfNeeded];
    
    [btnFacebook layoutIfNeeded];
    [btnTwitter layoutIfNeeded];
    [btnBubble layoutIfNeeded];
    
    btnUser.layer.cornerRadius = CGRectGetHeight(btnUser.frame) / 2;
    btnUser.clipsToBounds = YES;
    profileImageView.layer.cornerRadius = CGRectGetHeight(profileImageView.frame) / 2;
    profileImageView.clipsToBounds = YES;
    
    btnBubbleBottomConstraint.constant = 56;
    btnTwitterBottomConstraint.constant = 56;
    btnFacebookBottomConstraint.constant = 56;
    
}

- (void)awakeFromNib
{
    [super awakeFromNib];

    // Initialization code
    
    if(IS_IPHONE_5)
    {
        lblComicTitle.font = [UIFont fontWithName:@"Arial-BoldMT" size:32];
    }
    else if(IS_IPHONE_6)
    {
        lblComicTitle.font = [UIFont fontWithName:@"Arial-BoldMT" size:38];

    }
    else if(IS_IPHONE_6P)
    {
        lblComicTitle.font = [UIFont fontWithName:@"Arial-BoldMT" size:52];
    }
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