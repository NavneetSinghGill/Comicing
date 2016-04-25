//
//  DrawingColorsViewController.m
//  ComicMakingPage
//
//  Created by ADNAN THATHIYA on 25/12/15.
//  Copyright © 2015 ADNAN THATHIYA. All rights reserved.
//

#import "DrawingColorsViewController.h"
#import "ComicMakingViewController.h"
#import "UIColor+Color.h"
#import "AppConstants.h"

@interface DrawingColorsViewController ()

@property (weak, nonatomic) IBOutlet UIButton *btnUndo;
@property (weak, nonatomic) IBOutlet UIButton *btnBlack;
@property (weak, nonatomic) IBOutlet UIButton *btnBrown;
@property (weak, nonatomic) IBOutlet UIButton *btnBlue;

@property (weak, nonatomic) IBOutlet UIButton *btnGreen;
@property (weak, nonatomic) IBOutlet UIButton *btnYellow;
@property (weak, nonatomic) IBOutlet UIButton *btnWhite;

@property (weak, nonatomic) IBOutlet UIButton *btnOrange;
@property (weak, nonatomic) IBOutlet UIButton *btnCyan;
@property (weak, nonatomic) IBOutlet UIButton *btnPink;
@property (weak, nonatomic) IBOutlet UIButton *btnPurple;

@property (nonatomic, strong) ComicMakingViewController *parentViewController;

@end

@implementation DrawingColorsViewController

@synthesize btnBlack,btnBlue,btnBrown,btnGreen,btnRed,btnUndo,btnWhite,btnYellow,btnCyan,btnOrange,btnPink,btnPurple;
@synthesize parentViewController;

#pragma mark - UIViewController Methods
- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self setColorButtonsSize];
}

- (void)setColorButtonsSize
{
    CGFloat dx;
    CGFloat dy;
    
    if (IS_IPHONE_5)
    {
        dx = 14;
        dy = 14;
    }
    else if (IS_IPHONE_6)
    {
        dx = 14;
        dy = 14;
    }
    else if (IS_IPHONE_6P)
    {
        dx = 14;
        dy = 14;
    }
    
    CALayer *subblack = [CALayer new];
    subblack.frame = CGRectInset(btnBlack.bounds, dx, dy);
    btnBlack.layer.cornerRadius = CGRectGetHeight(btnBlack.frame) / 2;
    subblack.cornerRadius = CGRectGetHeight(subblack.frame) / 2;
    btnBlack.clipsToBounds = YES;
    btnBlack.backgroundColor = [UIColor clearColor];
    subblack.backgroundColor = [UIColor blackColor].CGColor;
    [btnBlack.layer addSublayer:subblack];
    
    CALayer *subblue = [CALayer new];
    subblue.frame = CGRectInset(btnBlack.bounds, dx, dy);
    subblue.cornerRadius = CGRectGetHeight(subblue.frame) / 2;
    
    btnBlue.layer.cornerRadius = CGRectGetHeight(btnBlack.frame) / 2;
    btnBlue.clipsToBounds = YES;
    btnBlue.backgroundColor = [UIColor clearColor];
    subblue.backgroundColor = [UIColor drawingColorBlue].CGColor;
    [btnBlue.layer addSublayer:subblue];
    
    CALayer *subbrown = [CALayer new];
    subbrown.frame = CGRectInset(btnBlack.bounds, dx, dy);
    subbrown.cornerRadius = CGRectGetHeight(subblue.frame) / 2;
    
    btnBrown.layer.cornerRadius = CGRectGetHeight(btnBlack.frame) / 2;
    btnBrown.clipsToBounds = YES;
    btnBrown.backgroundColor = [UIColor clearColor];
    subbrown.backgroundColor = [UIColor drawingColorBrown].CGColor;
    [btnBrown.layer addSublayer:subbrown];
    
    CALayer *subgreen = [CALayer new];
    subgreen.frame = CGRectInset(btnBlack.bounds, dx, dy);
    subgreen.cornerRadius = CGRectGetHeight(subgreen.frame) / 2;
    
    btnGreen.layer.cornerRadius = CGRectGetHeight(btnBlack.frame) / 2;
    btnGreen.clipsToBounds = YES;
    btnGreen.backgroundColor = [UIColor clearColor];
    subgreen.backgroundColor = [UIColor drawingColorGreen].CGColor;
    [btnGreen.layer addSublayer:subgreen];
    
    CALayer *subred = [CALayer new];
    subred.frame = CGRectInset(btnBlack.bounds, dx, dy);
    subred.cornerRadius = CGRectGetHeight(subred.frame) / 2;
    
    btnRed.layer.cornerRadius = CGRectGetHeight(btnBlack.frame) / 2;
    btnRed.clipsToBounds = YES;
    btnRed.backgroundColor = [UIColor clearColor];
    subred.backgroundColor = [UIColor drawingColorRed].CGColor;
    [btnRed.layer addSublayer:subred];
    
    CALayer *subwhite = [CALayer new];
    subwhite.frame = CGRectInset(btnWhite.bounds, dx, dy);
    subwhite.cornerRadius = CGRectGetHeight(subwhite.frame) / 2;
    
    btnWhite.layer.cornerRadius = CGRectGetHeight(btnWhite.frame) / 2;
    btnWhite.clipsToBounds = YES;
    btnWhite.backgroundColor = [UIColor clearColor];
    subwhite.backgroundColor = [UIColor whiteColor].CGColor;
    [btnWhite.layer addSublayer:subwhite];
    
    CALayer *subyellow = [CALayer new];
    subyellow.frame = CGRectInset(btnBlack.bounds, dx, dy);
    subyellow.cornerRadius = CGRectGetHeight(subyellow.frame) / 2;
    
    btnYellow.layer.cornerRadius = CGRectGetHeight(btnBlack.frame) / 2;
    btnYellow.clipsToBounds = YES;
    btnYellow.backgroundColor = [UIColor clearColor];
    subyellow.backgroundColor = [UIColor drawingColorYellow].CGColor;
    [btnYellow.layer addSublayer:subyellow];
    
    CALayer *subbtnCyan = [CALayer new];
    subbtnCyan.frame = CGRectInset(btnBlack.bounds, dx, dy);
    subbtnCyan.cornerRadius = CGRectGetHeight(subbtnCyan.frame) / 2;
    
    btnCyan.layer.cornerRadius = CGRectGetHeight(btnBlack.frame) / 2;
    btnCyan.clipsToBounds = YES;
    btnCyan.backgroundColor = [UIColor clearColor];
    subbtnCyan.backgroundColor = [UIColor drawingColorCyan].CGColor;
    [btnCyan.layer addSublayer:subbtnCyan];
    
    CALayer *subbtnOrange = [CALayer new];
    subbtnOrange.frame = CGRectInset(btnBlack.bounds, dx, dy);
    subbtnOrange.cornerRadius = CGRectGetHeight(subbtnOrange.frame) / 2;
    
    btnOrange.layer.cornerRadius = CGRectGetHeight(btnBlack.frame) / 2;
    btnOrange.clipsToBounds = YES;
    btnOrange.backgroundColor = [UIColor clearColor];
    subbtnOrange.backgroundColor = [UIColor drawingColorOrange].CGColor;
    [btnOrange.layer addSublayer:subbtnOrange];
    
    CALayer *subbtnPink = [CALayer new];
    subbtnPink.frame = CGRectInset(btnBlack.bounds, dx, dy);
    subbtnPink.cornerRadius = CGRectGetHeight(subbtnPink.frame) / 2;
    
    btnPink.layer.cornerRadius = CGRectGetHeight(btnBlack.frame) / 2;
    btnPink.clipsToBounds = YES;
    btnPink.backgroundColor = [UIColor clearColor];
    subbtnPink.backgroundColor = [UIColor drawingColorPink].CGColor;
    [btnPink.layer addSublayer:subbtnPink];
    
    CALayer *subbtnPurple = [CALayer new];
    subbtnPurple.frame = CGRectInset(btnBlack.bounds, dx, dy);
    subbtnPurple.cornerRadius = CGRectGetHeight(subbtnPurple.frame) / 2;
    
    btnPurple.layer.cornerRadius = CGRectGetHeight(btnBlack.frame) / 2;
    btnPurple.clipsToBounds = YES;
    btnPurple.backgroundColor = [UIColor clearColor];
    subbtnPurple.backgroundColor = [UIColor drawingColorPurple].CGColor;
    [btnPurple.layer addSublayer:subbtnPurple];


}

- (IBAction)btnDrawingTap:(UIButton *)sender
{
    [UIView beginAnimations:@"ScaleButton" context:NULL];
    [UIView setAnimationDuration: 0.2f];
    btnBlack.transform = CGAffineTransformMakeScale(1,1);
    btnBlue.transform = CGAffineTransformMakeScale(1,1);
    btnBrown.transform = CGAffineTransformMakeScale(1,1);
    btnGreen.transform = CGAffineTransformMakeScale(1,1);
    btnRed.transform = CGAffineTransformMakeScale(1,1);
    btnWhite.transform = CGAffineTransformMakeScale(1,1);
    btnYellow.transform = CGAffineTransformMakeScale(1,1);
    btnCyan.transform = CGAffineTransformMakeScale(1,1);
    btnPink.transform = CGAffineTransformMakeScale(1,1);
    btnPurple.transform = CGAffineTransformMakeScale(1,1);
    btnOrange.transform = CGAffineTransformMakeScale(1,1);
    [UIView commitAnimations];
    
    [UIView beginAnimations:@"ScaleButton" context:NULL];
    [UIView setAnimationDuration: 0.2f];
    sender.transform = CGAffineTransformMakeScale(2,2);
    [UIView commitAnimations];
    
    if (sender == btnWhite)
    {
        [parentViewController drawingColorTapEventWithColor:@"white"];
    }
    else if (sender == btnBlack)
    {
        [parentViewController drawingColorTapEventWithColor:@"black"];
    }
    else if (sender == btnBlue)
    {
        [parentViewController drawingColorTapEventWithColor:@"blue"];
    }
    else if (sender == btnBrown)
    {
        [parentViewController drawingColorTapEventWithColor:@"brown"];
    }
    else if (sender == btnGreen)
    {
        [parentViewController drawingColorTapEventWithColor:@"green"];
    }
    else if (sender == btnRed)
    {
        [parentViewController drawingColorTapEventWithColor:@"red"];
    }
    else if (sender == btnYellow)
    {
        [parentViewController drawingColorTapEventWithColor:@"yellow"];
    }
    else if (sender == btnPink)
    {
        [parentViewController drawingColorTapEventWithColor:@"pink"];
    }
    else if (sender == btnPurple)
    {
        [parentViewController drawingColorTapEventWithColor:@"purple"];
    }
    else if (sender == btnOrange)
    {
        [parentViewController drawingColorTapEventWithColor:@"orange"];
    }
    else if (sender == btnCyan)
    {
        [parentViewController drawingColorTapEventWithColor:@"cyan"];
    }

}

- (IBAction)btnUndoTap:(id)sender
{
    [parentViewController drawingUndoTap];
}
@end
