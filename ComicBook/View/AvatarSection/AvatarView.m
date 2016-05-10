//
//  AvatarViewViewController.m
//  ComicApp
//
//  Created by Ramesh on 22/11/15.
//  Copyright © 2015 Ramesh. All rights reserved.
//

#import "AvatarView.h"

@interface AvatarView ()

@end

@implementation AvatarView

-(id)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if(self)
    {
    }
    return self;
}
-(id)initWithCoder:(NSCoder *)aDecoder{
    self = [super initWithCoder:aDecoder];
    if(self)
    {
        //Load from xib
        [[NSBundle mainBundle] loadNibNamed:@"AvatarView" owner:self options:nil];
        
        [self addSubview:self.view];
        [self configView];
    }
    return self;
}

-(void)configView{
    self.txtSearchById.clearButtonMode = UITextFieldViewModeWhileEditing;

    [self.view setBackgroundColor:[UIColor colorWithHexStr:@"31ADE0"]];
    [self.myFriendButton.titleLabel setFont:[UIFont  fontWithName:@"MYRIADPRO-REGULAR" size:38]];
    [self getGroupsByUserId];
}

-(void)bindData{
 if(userObject)
 {
//         [self.avatarImage sd_setImageWithURL:[NSURL URLWithString:userObject.profile_pic]
//                                    placeholderImage:[UIImage imageNamed:@"Placeholder.png"]
//                                           completed:^(UIImage *image, NSError *error,
//                                                       SDImageCacheType cacheType, NSURL *imageURL) {
//                                           }];
  
     [self.avatarImage downloadImageWithURL:[NSURL URLWithString:userObject.profile_pic]
                         placeHolderImage:[UIImage imageNamed:@"Placeholder.png"]
                          completionBlock:^(BOOL succeeded, UIImage *image) {
                              self.avatarImage.image = image;
                          }];

     
 }
}

#pragma TextField Delegate

-(BOOL)textFieldShouldEndEditing:(UITextField *)textField{
    return YES;
}

-(BOOL)textFieldShouldReturn:(UITextField *)textField{
    [self.txtSearchById resignFirstResponder];
    if ([textField.text isEqualToString:@""]) {
        if (self.delegate && [self.delegate respondsToSelector:@selector(closeSearchViewController)])
        {
            [self.delegate closeSearchViewController];
        }
    }
    ComicNetworking* cmNetWorking = [ComicNetworking sharedComicNetworking];
    [cmNetWorking searchById:textField.text completion:^(id json,id jsonResposeHeader) {
        if (self.delegate && [self.delegate respondsToSelector:@selector(postFriendsSearchResponse:)])
        {
            [self.delegate postFriendsSearchResponse:json];
        }
    } ErrorBlock:^(JSONModelError *error) {
    }];
    
    return YES;
}

-(BOOL)textFieldShouldClear:(UITextField *)textField{
    if (self.delegate && [self.delegate respondsToSelector:@selector(closeSearchViewController)])
    {
        [self.delegate closeSearchViewController];
    }
    return NO;
}

#pragma Actions

-(void)getGroupsByUserId{
    
    ComicNetworking* cmNetWorking = [ComicNetworking sharedComicNetworking];
//    cmNetWorking.delegate= self;
    [cmNetWorking userDetailsByLoginId:[AppHelper getCurrentLoginId] completion:^(id json,id jsonResposeHeader) {
        [self UserDetailsResponse:json];
    } ErrorBlock:^(JSONModelError *error) {
    }];
}

-(void)UserDetailsResponse:(NSDictionary *)response{
    //initialize the models
    userObject = [[User alloc] init];
 //   [userObject setValuesForKeysWithDictionary:response[@"data"]];
    [self bindData];
}

- (IBAction)searchButtonClick:(id)sender {
    if (self.delegate && [self.delegate respondsToSelector:@selector(openSearchViewController)])
    {
        [self.delegate openSearchViewController];
    }
}

@end
