//
//  BlackboardViewController.m
//  ComicMakingPage
//
//  Created by ADNAN THATHIYA on 02/02/16.
//  Copyright © 2016 ADNAN THATHIYA. All rights reserved.
//

#import "BlackboardViewController.h"
#import "UIColor+Color.h"
#import "AppConstants.h"
#import "ComicMakingViewController.h"

@interface BlackboardViewController ()

@property (weak, nonatomic) IBOutlet UIButton *btnUndo;
@property (weak, nonatomic) IBOutlet UIButton *btnBlack;
@property (weak, nonatomic) IBOutlet UIButton *btnBrown;
@property (weak, nonatomic) IBOutlet UIButton *btnBlue;

@property (weak, nonatomic) IBOutlet UIButton *btnGreen;
@property (weak, nonatomic) IBOutlet UIButton *btnYellow;
@property (weak, nonatomic) IBOutlet UIButton *btnWhite;

@property (nonatomic, strong) ComicMakingViewController *parentViewController;

@end

@implementation BlackboardViewController

@synthesize btnBlack,btnBlue,btnBrown,btnGreen,btnWhite,btnUndo,btnYellow,btnPink;
@synthesize parentViewController;

#pragma mark - UIViewController Methods
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self setButtonsFrames];
}

- (void)setButtonsFrames
{
    btnBlack.transform = CGAffineTransformMakeScale(0.8,0.8);
    btnBlue.transform = CGAffineTransformMakeScale(0.8,0.8);
    btnBrown.transform = CGAffineTransformMakeScale(0.8,0.8);
    btnGreen.transform = CGAffineTransformMakeScale(0.8,0.8);
    btnPink.transform = CGAffineTransformMakeScale(0.8,0.8);
    btnWhite.transform = CGAffineTransformMakeScale(0.8,0.8);
    btnYellow.transform = CGAffineTransformMakeScale(0.8,0.8);
}

- (IBAction)btnDrawingTap:(UIButton *)sender
{
    if (sender.isSelected)
    {
        return;
    }
    
    
    [UIView beginAnimations:@"ScaleButton" context:NULL];
    [UIView setAnimationDuration: 0.2f];
    btnBlack.transform = CGAffineTransformMakeScale(0.8,0.8);
    btnBlue.transform = CGAffineTransformMakeScale(0.8,0.8);
    btnBrown.transform = CGAffineTransformMakeScale(0.8,0.8);
    btnGreen.transform = CGAffineTransformMakeScale(0.8,0.8);
    btnPink.transform = CGAffineTransformMakeScale(0.8,0.8);
    btnWhite.transform = CGAffineTransformMakeScale(0.8,0.8);
    btnYellow.transform = CGAffineTransformMakeScale(0.8,0.8);

    [UIView commitAnimations];

    btnPink.selected = NO;
    btnBlack.selected = NO;
    btnBlue.selected = NO;
    btnBrown.selected = NO;
    btnGreen.selected = NO;
    btnWhite.selected = NO;
    btnYellow.selected = NO;
    
    [UIView beginAnimations:@"ScaleButton" context:NULL];
    [UIView setAnimationDuration: 0.2f];
    sender.transform = CGAffineTransformMakeScale(1,1);
    
    sender.selected = YES;
    [UIView commitAnimations];
    
    if (sender == btnWhite)
    {
        [parentViewController changeColorOfBackboardWithColor:[UIColor whiteColor]];
    }
    else if (sender == btnBlack)
    {
        [parentViewController changeColorOfBackboardWithColor:[UIColor blackColor]];
    }
    else if (sender == btnBlue)
    {
        [parentViewController changeColorOfBackboardWithColor:[UIColor drawingColorBlue]];
    }
    else if (sender == btnBrown)
    {
        [parentViewController changeColorOfBackboardWithColor:[UIColor drawingColorBrown]];
    }
    else if (sender == btnGreen)
    {
        [parentViewController changeColorOfBackboardWithColor:[UIColor drawingColorGreen]];
    }
    else if (sender == btnPink)
    {
        [parentViewController changeColorOfBackboardWithColor:[UIColor pinkColor]];
    }
    else if (sender == btnYellow)
    {
        [parentViewController changeColorOfBackboardWithColor:[UIColor blackboardColorYellow]];
    }
}


@end
