//
//  MainViewController.m
//  ComicMakingPage
//
//  Created by Ramesh on 15/02/16.
//  Copyright © 2016 ADNAN THATHIYA. All rights reserved.
//

#import "MainViewController.h"
#import "AppHelper.h"
#import <MediaPlayer/MediaPlayer.h>
#import <AVKit/AVKit.h>
#import <AVFoundation/AVFoundation.h>
#import "CropRegisterViewController.h"

@interface MainViewController ()
{
    AVPlayer *video;
    AVPlayerViewController *controller;
    AVPlayerItem* playerItem;
}
@property (weak, nonatomic) IBOutlet UIView *introViewHolder;
@end

@implementation MainViewController

- (void)viewDidLoad {
    
    [[GoogleAnalytics sharedGoogleAnalytics] logScreenEvent:@"Registration" Attributes:nil];
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

-(void)viewWillAppear:(BOOL)animated
{
    [AppHelper hideAllDropMessages];
    [super viewWillAppear:animated];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)btnSignUpClick:(id)sender {
    if ([AppHelper getFirstTimeSignUp] == nil) {
        [self addIntroVideo];
    }else{
        [self gotoRegisterPage];
    }
}

-(void)addIntroVideo{
    
    NSURL *fileURL = [NSURL fileURLWithPath:[[NSBundle mainBundle]
                                         pathForResource:@"introvideo" ofType:@"mp4"]];

    playerItem = [AVPlayerItem playerItemWithURL:fileURL];
    
    video = [[AVPlayer alloc] initWithPlayerItem:playerItem];

    controller=[[AVPlayerViewController alloc]init];
    controller.player=video;
    controller.view.contentMode = UIViewContentModeScaleAspectFill;
    
    [self.introViewHolder addSubview:controller.view];
    [self addSwipeEvent:self.introViewHolder];
    controller.view.frame=self.view.frame;
    
    // Subscribe to the AVPlayerItem's DidPlayToEndTime notification.
    
    [self addChildViewController:controller];
    [self.introViewHolder setHidden:NO];
    [controller.view setAlpha:0];
    //fade in
    [UIView animateWithDuration:2.0f animations:^{
        
        [controller.view setAlpha:1];
        
    } completion:^(BOOL finished) {
        [AppHelper setFirstTimeSignUp:@"YES"];
    }];
}


-(void)addSwipeEvent:(UIView*)subView{
    
    UISwipeGestureRecognizer *recognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(SwipeRecognizer:)];
    recognizer.numberOfTouchesRequired = 1;
//    recognizer.delegate = self;
    [subView addGestureRecognizer:recognizer];
    
    UISwipeGestureRecognizer *leftRecognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(SwipeRecognizer:)];
    leftRecognizer.direction=UISwipeGestureRecognizerDirectionLeft;
    leftRecognizer.numberOfTouchesRequired = 1;
//    leftRecognizer.delegate = self;
    [subView addGestureRecognizer:leftRecognizer];
    
    UISwipeGestureRecognizer *downRecognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(SwipeRecognizer:)];
    downRecognizer.direction=UISwipeGestureRecognizerDirectionDown;
    downRecognizer.numberOfTouchesRequired = 1;
//    donwRecognizer.delegate = self;
    [subView addGestureRecognizer:downRecognizer];
    
    UISwipeGestureRecognizer *upRecognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(SwipeRecognizer:)];
    upRecognizer.direction=UISwipeGestureRecognizerDirectionUp;
    upRecognizer.numberOfTouchesRequired = 1;
//    upRecognizer.delegate = self;
    [subView addGestureRecognizer:upRecognizer];
}

- (void) SwipeRecognizer:(UISwipeGestureRecognizer *)sender {
    if ( sender.direction == UISwipeGestureRecognizerDirectionLeft ||
         sender.direction == UISwipeGestureRecognizerDirectionRight ||
         sender.direction== UISwipeGestureRecognizerDirectionUp ||
         sender.direction == UISwipeGestureRecognizerDirectionDown){
        [ self removeIntroVideo];
    }
}

-(void)introVideoDoneButtonClick:(UIButton *)button {
    [self removeIntroVideo];
    // Remove playerViewController.view
}
-(void)removeIntroVideo{
    //fade out
    [UIView animateWithDuration:0.5f animations:^{
        [controller.view setAlpha:0.0];
    } completion:^(BOOL finished) {
        video = nil;
        playerItem = nil;
        [controller.view removeFromSuperview];
        [controller removeFromParentViewController];
        controller = nil;
        [self gotoRegisterPage];
    }];
}

-(void)gotoRegisterPage{
    UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:@"Main" bundle: nil];
    CropRegisterViewController *controller = (CropRegisterViewController *)[mainStoryboard instantiateViewControllerWithIdentifier:@"CropRegister"];
    [self.navigationController pushViewController:controller animated:YES];
    mainStoryboard = nil;
}
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
