//
//  ComicBubbleView.m
//  ComicBook
//
//  Created by Ramesh Prajapati on 13/01/17.
//  Copyright © 2017 Providence. All rights reserved.
//

#import "ComicBubbleView.h"
#import "ComicMakingViewController.h"
@implementation ComicBubbleView

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/
- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        NSString *className = NSStringFromClass([self class]);
        NSArray *array=[[NSBundle mainBundle] loadNibNamed:className owner:self options:nil];
        self.upperLeftStandardBubbleView = [array objectAtIndex:0];
        self.lowerLeftStandardBubbleView = [array objectAtIndex:1];
        self.lowerRightStandardBubbleView = [array objectAtIndex:2];
        self.upperRightStandardBubbleView = [array objectAtIndex:3];
        
        [self addSubview:self.lowerLeftStandardBubbleView];
        [self addSubview:self.lowerRightStandardBubbleView];
        [self addSubview:self.upperRightStandardBubbleView];
        [self addSubview:self.upperLeftStandardBubbleView];
        
        for(UIImageView *imageView in [self.upperLeftStandardBubbleView subviews])
        {
            if(imageView.tag!=999)
            {
                imageView.alpha=0;
            }
        }
    }
    return self;
}

//-(void)addStandardBubbleWithLowerLeftTail:(ComicMakingViewController*)controller
//{
//    UIImage *plusIcon=[self getPlusIcon];
//    UIImage *angryIcon=[self getAngryIcon];
//    UIImage *heartIcon=[self getHeartIcon];
//    UIImage *questionIcon=[self getQuestionIcon];
//    UIImage *scaryIcon=[self getScaryIcon];
//    UIImage *starIcon=[self getStarIcon];
//    UIImage *thinkingIcon=[self getThinkingIcon];
//    UIImage *zzzIcon=[self getZZZIcon];
//    
//    UIImage *standardBubbleImage=[UIImage imageNamed:@"LL_Standard_Bubble.png"];
//    UIImageView *standardBubbleImageView=[[UIImageView alloc]initWithFrame:CGRectMake(0, 0, standardBubbleImage.size.width, standardBubbleImage.size.height)];
//    
//    UIView *bubbleView=[[UIView alloc]initWithFrame:CGRectMake(100, 100, standardBubbleImage.size.width, standardBubbleImage.size.height)];
//    
//    
//}
-(UIImage*)getPlusIcon
{
    UIImage *questionIcon=[UIImage imageNamed:@"Plus_sign"];
    return questionIcon;
}
-(UIImage*)getAngryIcon
{
    UIImage *angryIcon=[UIImage imageNamed:@"Angry_SubButtons"];
    return angryIcon;
}
-(UIImage*)getHeartIcon
{
    UIImage *heartIcon=[UIImage imageNamed:@"Heart_SubButtons"];
    return heartIcon;
}
-(UIImage*)getQuestionIcon
{
    UIImage *questionIcon=[UIImage imageNamed:@"question-mark"];
    return questionIcon;
}
-(UIImage*)getScaryIcon
{
    UIImage *scaryIcon=[UIImage imageNamed:@"Scary_SubButton"];
    return scaryIcon;
}
-(UIImage*)getStarIcon
{
    UIImage *starIcon=[UIImage imageNamed:@"Star_SubButtons"];
    return starIcon;
}
-(UIImage*)getThinkingIcon
{
    UIImage *thinkingIcon=[UIImage imageNamed:@"Thinking_SubButtons"];
    return thinkingIcon;
}
-(UIImage*)getZZZIcon
{
    UIImage *zzzIcon=[UIImage imageNamed:@"ZZZ_SubButtons"];
    return zzzIcon;
}

@end
