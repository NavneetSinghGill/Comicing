//
//  OpenCuteStickersGiftBoxViewController.m
//  ComicBook
//
//  Created by Guntikogula Dinesh on 17/07/16.
//  Copyright © 2016 ADNAN THATHIYA. All rights reserved.
//

#import "OpenCuteStickersGiftBoxViewController.h"
#import "YLGIFImage.h"
#import "AppHelper.h"
#import "InviteScore.h"
#import "UIImageView+AnimatedGif.h"

@interface OpenCuteStickersGiftBoxViewController () <AnimatedGifDelegate>

@property (nonatomic, weak) IBOutlet UIImageView *mGiftBoxImageView;
@property (nonatomic, weak) IBOutlet UIImageView *mGiftBoxOpenImageView;
@property (nonatomic, weak) IBOutlet UIButton *mScissorButton;
@property (nonatomic, weak) IBOutlet UILabel *mTapToOpenLabel;

@end

@implementation OpenCuteStickersGiftBoxViewController

@synthesize mGiftBoxImageView, mGiftBoxOpenImageView;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Do any additional setup after loading the view from its nib.
}

- (void)viewWillAppear:(BOOL)animated
{
    float scoreValue = [self getCurrentScoreFromDB];
    
    if (scoreValue >= INVITE_POINT_200) {
        mGiftBoxImageView.image = [YLGIFImage imageNamed:@"box03.gif"];
        
    }else if(scoreValue >= INVITE_POINT_100 &&
             scoreValue <= INVITE_POINT_200) {
        mGiftBoxImageView.image = [YLGIFImage imageNamed:@"box02.gif"];
        
    }else if(scoreValue >= INVITE_POINT_50 &&
             scoreValue <= INVITE_POINT_100) {
        mGiftBoxImageView.image = [YLGIFImage imageNamed:@"box01.gif"];
    }else{
        mGiftBoxImageView.image = [YLGIFImage imageNamed:@"box03.gif"];
    }

    
    [super viewWillAppear:YES];
    [mGiftBoxImageView setHidden:NO];
    [mGiftBoxOpenImageView setHidden:YES];
    
    
    UITapGestureRecognizer *mtapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(openGitBox:)];
    [mtapGesture setNumberOfTapsRequired:1];
    [mGiftBoxImageView setUserInteractionEnabled:YES];
    [mGiftBoxImageView addGestureRecognizer:mtapGesture];
    
}

- (void)openGitBox: (UIGestureRecognizer *)gesture
{
    [mGiftBoxImageView setHidden:YES];
    [mGiftBoxOpenImageView setHidden:NO];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(animatedGifDidStart:) name:AnimatedGifDidStartLoadingingEvent object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(animatedGifDidFinish:) name:AnimatedGifDidFinishLoadingingEvent object:nil];
    
    float scoreValue = [self getCurrentScoreFromDB];
    
    NSString *path = nil;
    
    if (scoreValue >= INVITE_POINT_200) {        
        path = [[NSBundle mainBundle] pathForResource:@"openbox-15" ofType:@"gif"];

    }else if(scoreValue >= INVITE_POINT_100 &&
             scoreValue <= INVITE_POINT_200) {
        path = [[NSBundle mainBundle] pathForResource:@"openbox-10" ofType:@"gif"];

    }else if(scoreValue >= INVITE_POINT_50 &&
             scoreValue <= INVITE_POINT_100) {
        path = [[NSBundle mainBundle] pathForResource:@"openbox-5" ofType:@"gif"];
    }else{
        path = [[NSBundle mainBundle] pathForResource:@"openbox-15" ofType:@"gif"];
    }
    
    AnimatedGif * animation = [AnimatedGif getAnimationForGifAtUrl:[NSURL fileURLWithPath:path]];
    animation.delegate = self;
    
    [mGiftBoxOpenImageView setAnimatedGif:animation startImmediately:YES];
    [animation start];
}


#pragma mark - AnimatedGif events

-(void)animatedGifDidStart:(NSNotification*) notify {
    AnimatedGif * object = notify.object;
    NSLog(@"Url will be loaded: %@", object.url);
}
-(void)animatedGifDidFinish:(NSNotification*) notify {
    AnimatedGif * object = notify.object;
    NSLog(@"Url is loaded: %@", object.url);
}

#pragma mark - AnimatedGifDelegate

- (void)animationWillRepeat:(AnimatedGif *)animatedGif
{
    NSLog(@"\nanimationWillRepeat");
    [animatedGif stop];
}

-(float)getCurrentScoreFromDB{
    NSManagedObjectContext *context = [[AppHelper initAppHelper] managedObjectContext];
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] initWithEntityName:@"InviteScore"];
    NSError *error      = nil;
    NSArray *results    = [context executeFetchRequest:fetchRequest error:&error];
    if ([results count] == 0) {
        return 0;
    }else{
        NSString* scoreValue = ((InviteScore*)results[0]).scoreValue;
        CGFloat fScoreValue = [scoreValue floatValue];
        return fScoreValue;
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (IBAction)scissorButtonClicke:(id)sender
{


}

- (IBAction)closeClicked:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:^{
        
    }];
}

@end
