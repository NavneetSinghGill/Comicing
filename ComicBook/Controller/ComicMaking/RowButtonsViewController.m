//
//  RowButtonsViewController.m
//  ComicMakingPage
//
//  Created by Adnan on 12/24/15.
//  Copyright © 2015 ADNAN THATHIYA. All rights reserved.
//

#import "RowButtonsViewController.h"
#import "ComicMakingViewController.h"
#import "Global.h"
#import "JTAlertView.h"

@interface RowButtonsViewController ()

@property (nonatomic, strong) ComicMakingViewController *parentViewController;



@end

@implementation RowButtonsViewController

@synthesize parentViewController;
@synthesize btnBlackboard,btnBubble,btnCamera,btnExclamation,btnPen,btnSticker,btnText, isNewSlide;

#pragma mark - UIViewController Methods
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    if (isNewSlide)
    {
        btnCamera.selected = NO;
        
        [self allButtonsFadeOut:btnCamera];
    }
    else
    {
        btnCamera.selected = YES;
        
        [self allButtonsFadeIn:btnCamera];
    }
}

- (IBAction)btnBlackboardTap:(UIButton *)sender
{
    [UIView animateWithDuration:1
                          delay:0
         usingSpringWithDamping:0.2
          initialSpringVelocity:0.3
                        options:UIViewAnimationOptionTransitionCurlDown
                     animations:^
     {
         sender.layer.transform = CATransform3DIdentity;
     }
                     completion:nil];
    
    if (btnBlackboard.selected == YES && GlobalObject.isBlackBoardOpen == YES)
    {
        [parentViewController openBlackBoardColors];
    }
    else
    {
        if (GlobalObject.isTakePhoto == YES)
        {
            JTAlertView *alertView = [parentViewController showAlertView:@"Do you want abandon?" image:nil height:200];
            
            [alertView addButtonWithTitle:@"CANCEL" style:JTAlertViewStyleDefault action:^(JTAlertView *alertView)
             {
                 [alertView hide];
             }];
            
            [alertView addButtonWithTitle:@"OK" style:JTAlertViewStyleDestructive action:^(JTAlertView *alertView)
             {
                 [alertView hide];
                 
                 btnCamera.selected = YES;
                 [self allButtonsFadeIn:btnBlackboard];
                 [parentViewController openBlackBoard];
             }];
            
            [alertView show];
        }
        else
        {
            btnCamera.selected = YES;
            [self allButtonsFadeIn:btnBlackboard];
            [parentViewController openBlackBoard];
        }
        
        btnBlackboard.selected = YES;
        GlobalObject.isBlackBoardOpen = YES;
    }
}

- (IBAction)btnTextTap:(UIButton *)sender
{
    //    [UIView animateWithDuration:1
    //                          delay:0
    //         usingSpringWithDamping:0.2
    //          initialSpringVelocity:0.3
    //                        options:UIViewAnimationOptionTransitionCurlDown
    //                     animations:^
    //     {
    //         [parentViewController openCaptionView];
    //     }
    //                     completion:nil];
    [parentViewController openCaptionView];
    
    [self checkStatusForBlackBoardWithButton:sender];
}

- (IBAction)btnExclamationTap:(UIButton *)sender
{
    [UIView animateWithDuration:1
                          delay:0
         usingSpringWithDamping:0.2
          initialSpringVelocity:0.3
                        options:UIViewAnimationOptionTransitionCurlDown
                     animations:^
     {
         sender.layer.transform = CATransform3DIdentity;
     }
                     completion:^(BOOL finished) {
                         [self checkStatusForBlackBoardWithButton:sender];
                         [parentViewController openExclamationList];
                     }];
}

- (IBAction)btnCameraTap:(UIButton *)sender
{
    if (btnCamera.selected)
    {
        JTAlertView *alertView = [parentViewController showAlertView:@"Do you want take another Picture" image:nil height:200];
        
        [alertView addButtonWithTitle:@"CANCEL" style:JTAlertViewStyleDefault action:^(JTAlertView *alertView)
         {
             [alertView hide];
         }];
        
        [alertView addButtonWithTitle:@"OK" style:JTAlertViewStyleDestructive action:^(JTAlertView *alertView)
         {
             btnCamera.selected = NO;
             
             [parentViewController closeCamera];
             
             [self allButtonsFadeOut:btnCamera];
             
             [alertView hide];
         }];
        
        [alertView show];
    }
    else
    {
        btnCamera.selected = YES;
        
        [parentViewController btnCameraTap:nil];
        
        [self allButtonsFadeIn:btnCamera];
    }
    
    [self checkStatusForBlackBoardWithButton:sender];
}

- (IBAction)btnBubbleTap:(UIButton *)sender
{
    [UIView animateWithDuration:1
                          delay:0
         usingSpringWithDamping:0.2
          initialSpringVelocity:0.3
                        options:UIViewAnimationOptionTransitionCurlDown
                     animations:^
     {
         sender.layer.transform = CATransform3DIdentity;
     }
                     completion:^(BOOL finished) {
                         [parentViewController openBubbleList];
                         [self checkStatusForBlackBoardWithButton:sender];
                     }];
}

- (IBAction)btnPenTap:(UIButton *)sender
{
    [UIView animateWithDuration:1
                          delay:0
         usingSpringWithDamping:0.2
          initialSpringVelocity:0.3
                        options:UIViewAnimationOptionTransitionCurlDown
                     animations:^
     {
         sender.layer.transform = CATransform3DIdentity;
     }
                     completion:nil];
    
    //    if (GlobalObject.isBlackBoardOpen)
    //    {
    //
    //    }
    //    else
    //    {
    if (btnPen.selected)
    {
        btnPen.selected = NO;
        
        [self allButtonsFadeIn:btnPen];
        
        [parentViewController stopDrawing];
    }
    else
    {
        btnPen.selected = YES;
        
        [self allButtonsFadeOut:btnPen];
        
        [parentViewController startDrawing];
        
        [self checkStatusForBlackBoardWithButton:sender];
    }
    //    }
}
//
- (IBAction)btnStickerTap:(UIButton *)sender
{
    [UIView animateWithDuration:0.5
                          delay:0
         usingSpringWithDamping:0.2
          initialSpringVelocity:0.3
                        options:UIViewAnimationOptionTransitionCurlDown
                     animations:^
     {
         sender.layer.transform = CATransform3DIdentity;
         
     }completion:^(BOOL finished)
     {
         [parentViewController openStickerList];
         [self checkStatusForBlackBoardWithButton:sender];
     }];
    
    
}

- (void)checkStatusForBlackBoardWithButton:(UIButton *)sender
{
    if (GlobalObject.isBlackBoardOpen && sender != btnBlackboard)
    {
        [parentViewController closeBlackBoardColors];
    }
}

#pragma mark - Jelly Effect
- (IBAction)buttonTouchDown:(UIButton *)sender
{
    [UIView animateWithDuration:0.1 animations:^
     {
         sender.layer.transform = CATransform3DMakeScale(0.9, 0.9, 1.0);
     }];
}

- (IBAction)buttonTouchUpOutside:(UIButton *)sender
{
    [self restoreTransformWithBounceForView:sender];
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

#pragma mark - Helper Methods
- (void)allButtonsFadeOut:(UIButton *)sender
{
    [self checkStatusForBlackBoardWithButton:sender];
    
    CGFloat speed = 0.5;
    
    if (sender == btnBlackboard)
    {
        [UIView animateWithDuration:speed animations:^{
            
            btnBubble.alpha = 0;
            btnCamera.alpha = 0;
            btnExclamation.alpha = 0;
            btnPen.alpha = 0;
            btnSticker.alpha = 0;
            btnText.alpha = 0;
        }];
    }
    else if (sender == btnBubble)
    {
        [UIView animateWithDuration:speed animations:^{
            
            btnBlackboard.alpha = 0;
            btnCamera.alpha = 0;
            btnExclamation.alpha = 0;
            btnPen.alpha = 0;
            btnSticker.alpha = 0;
            btnText.alpha = 0;
        }];
    }
    else if (sender == btnCamera)
    {
        [UIView animateWithDuration:speed animations:^{
            
            btnBlackboard.alpha = 1;
            btnBubble.alpha = 0;
            btnExclamation.alpha = 0;
            btnPen.alpha = 0;
            btnSticker.alpha = 0;
            btnText.alpha = 0;
        }];
    }
    else if (sender == btnExclamation)
    {
        [UIView animateWithDuration:speed animations:^{
            
            btnBlackboard.alpha = 0;
            btnBubble.alpha = 0;
            btnCamera.alpha = 0;
            btnPen.alpha = 0;
            btnSticker.alpha = 0;
            btnText.alpha = 0;
        }];
    }
    else if (sender == btnPen)
    {
        [UIView animateWithDuration:speed animations:^{
            
            btnCamera.alpha = 0;
            btnBlackboard.alpha = 0;
            btnBubble.alpha = 0;
            btnExclamation.alpha = 0;
            btnSticker.alpha = 0;
            btnText.alpha = 0;
            
            //            if (GlobalObject.isTakePhoto)
            //            {
            //                btnBlackboard.alpha = 0;
            //                btnBubble.alpha = 0;
            //                btnExclamation.alpha = 0;
            //                btnSticker.alpha = 0;
            //                btnText.alpha = 0;
            //            }
            //            else
            //            {
            //                btnBlackboard.alpha = 1;
            //                btnBubble.alpha = 1;
            //                btnExclamation.alpha = 1;
            //                btnSticker.alpha = 1;
            //                btnText.alpha = 1;
            //
            //            }
        }];
    }
    else if (sender == btnSticker)
    {
        [UIView animateWithDuration:speed animations:^{
            
            btnBlackboard.alpha = 0;
            btnBubble.alpha = 0;
            btnCamera.alpha = 0;
            btnExclamation.alpha = 0;
            btnPen.alpha = 0;
            btnText.alpha = 0;
        }];
    }
    else if (sender == btnText)
    {
        [UIView animateWithDuration:speed animations:^{
            
            btnBlackboard.alpha = 0;
            btnBubble.alpha = 0;
            btnCamera.alpha = 0;
            btnExclamation.alpha = 0;
            btnPen.alpha = 0;
            btnSticker.alpha = 0;
        }];
    }
}

- (void)allButtonsFadeIn:(UIButton *)sender
{
    [self checkStatusForBlackBoardWithButton:sender];
    
    CGFloat speed = 0.5;
    
    if (sender == btnBlackboard)
    {
        [UIView animateWithDuration:speed animations:^{
            
            btnBubble.alpha = 1;
            btnCamera.alpha = 1;
            btnExclamation.alpha = 1;
            btnPen.alpha = 1;
            btnSticker.alpha = 1;
            btnText.alpha = 1;
            btnBlackboard.alpha = 1;
        }];
    }
    else if (sender == btnBubble)
    {
        [UIView animateWithDuration:speed animations:^{
            
            btnBlackboard.alpha = 1;
            btnCamera.alpha = 1;
            btnExclamation.alpha = 1;
            btnPen.alpha = 1;
            btnSticker.alpha = 1;
            btnText.alpha = 1;
            btnBubble.alpha = 0;
            
        }];
    }
    else if (sender == btnCamera)
    {
        [UIView animateWithDuration:speed animations:^{
            
            btnBlackboard.alpha = 1;
            btnBubble.alpha = 1;
            btnExclamation.alpha = 1;
            btnPen.alpha = 1;
            btnSticker.alpha = 1;
            btnText.alpha = 1;
            btnCamera.alpha = 1;
            
            
        }];
    }
    else if (sender == btnExclamation)
    {
        [UIView animateWithDuration:speed animations:^{
            
            btnBlackboard.alpha = 1;
            btnBubble.alpha = 1;
            btnCamera.alpha = 1;
            btnPen.alpha = 1;
            btnSticker.alpha = 1;
            btnText.alpha = 1;
            btnExclamation.alpha = 0;
            
        }];
    }
    else if (sender == btnPen)
    {
        [UIView animateWithDuration:speed animations:^{
            
            btnBlackboard.alpha = 1;
            btnBubble.alpha = 1;
            btnCamera.alpha = 1;
            btnExclamation.alpha = 1;
            btnSticker.alpha = 1;
            btnText.alpha = 1;
            btnPen.alpha = 1;
            
            
            //            if (GlobalObject.isBlackBoardOpen)
            //            {
            //
            //            }
            //            else
            //            {
            //                if (GlobalObject.isTakePhoto)
            //                {
            //                    btnBlackboard.alpha = 1;
            //                    btnBubble.alpha = 1;
            //                    btnCamera.alpha = 1;
            //                    btnExclamation.alpha = 1;
            //                    btnSticker.alpha = 1;
            //                    btnText.alpha = 1;
            //                    btnPen.alpha = 1;
            //                }
            //                else
            //                {
            //                    btnBlackboard.alpha = 0;
            //                    btnBubble.alpha = 0;
            //                    btnCamera.alpha = 1;
            //                    btnExclamation.alpha = 0;
            //                    btnSticker.alpha = 0;
            //                    btnText.alpha = 0;
            //                    btnPen.alpha = 1;
            //                }
            //
            //            }
        }];
    }
    else if (sender == btnSticker)
    {
        [UIView animateWithDuration:speed animations:^{
            
            btnBlackboard.alpha = 1;
            btnBubble.alpha = 1;
            btnCamera.alpha = 1;
            btnExclamation.alpha = 1;
            btnPen.alpha = 1;
            btnText.alpha = 1;
            btnSticker.alpha = 0;
            
        }];
    }
    else if (sender == btnText)
    {
        [UIView animateWithDuration:speed animations:^{
            
            btnBlackboard.alpha = 1;
            btnBubble.alpha = 1;
            btnCamera.alpha = 1;
            btnExclamation.alpha = 1;
            btnPen.alpha = 1;
            btnSticker.alpha = 1;
            btnText.alpha = 0;
            
        }];
    }
}


@end
