//
//  BottomBarViewController.h
//  Inbox
//
//  Created by Vishnu Vardhan PV on 16/12/15.
//  Copyright © 2015 Vishnu Vardhan PV. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface BottomBarViewController : UIViewController <UIGestureRecognizerDelegate> {
    CGRect rectContainer;
}

@property (weak, nonatomic) IBOutlet UIButton *bottomButton;
@property (weak, nonatomic) IBOutlet UIView *tap_View;
@property (nonatomic,assign) CGRect openFrame;
@property (nonatomic,assign) CGRect closeFrame;

- (void)setBottombuttonToYellow;

@end
