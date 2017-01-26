//
//  ComicBubbleView.h
//  ComicBook
//
//  Created by Ramesh Prajapati on 13/01/17.
//  Copyright © 2017 Providence. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ComicBubbleView : UIView

- (id)initWithFrame:(CGRect)frame;
@property (strong, nonatomic) IBOutlet UIView *lowerRightStandardBubbleView;
@property (strong, nonatomic) IBOutlet UIView *upperRightStandardBubbleView;
@property (strong, nonatomic) IBOutlet UIView *lowerLeftStandardBubbleView;

@property (strong, nonatomic) IBOutlet UIView *upperLeftStandardBubbleView;

@end
