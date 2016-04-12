//  Created by Subin Kurian on 10/8/15.
//  Copyright © 2015 Subin Kurian. All rights reserved.
#import "DataViewController.h"
#import "CustomScrollView.h"
#import "IndexPageVC.h"
#import "Slides.h"
#import "Enhancement.h"
#import "CustomView.h"

@interface DataViewController () <AVAudioPlayerDelegate> {
    CustomView *audioButton;
    NSData *downloadedAudioData;
    UIView *audioView;
    UIImageView *img;
    float audioDurationSeconds;
}

@property (strong, nonatomic) AVAudioPlayer *backgroundMusicPlayer;
@property (strong, nonatomic) NSURL *audioUrl;

@end

@implementation DataViewController



- (void)viewDidLoad
{
    [super viewDidLoad];
    audioView = [[UIView alloc] initWithFrame:CGRectMake(0, self.view.frame.size.height - 80, self.view.frame.size.width, 60)];
    [audioView setBackgroundColor:[UIColor colorWithRed:241/255.0f green:199/255.0f blue:27/255.0f alpha:0.7]];
    img = [[UIImageView alloc] initWithFrame:CGRectMake(0, 5, 50, 50)];
    [img setImage:[UIImage imageNamed:@"mic_play"]];
    [audioView addSubview:img];
    
    /**
     *  image array contains the whole images and page number is the current pagenumber
     *  Checking if it is a table of content page or ordinary page.
     */


    if(7>self.slidesArray.count)
    {
        
        
        if( self.pageNumber<self.slidesArray.count)
        {
            if(self.pageNumber==1)
            {
                /**
                 *  second page of comic book table of content
                 */
                [self SetupTableofContants];
                
            }
            else
            {
                /**
                 *  setting comic book else pages
                 */
                [self.scrollView setPage:[self.slidesArray objectAtIndex:self.pageNumber]];
                [self addAudioButton:[self.slidesArray objectAtIndex:self.pageNumber]];
            }
        }
    }
    else
    {
        if( self.pageNumber<self.slidesArray.count)
        {
            if(self.pageNumber==1)
            {
                /**
                 *  second page of comic book table of content
                 */
                [self SetupTableofContants];
                
            }
            else if(self.pageNumber==2)
            {
                /**
                 *  second page of comic book table of content
                 */
                [self SetupTableofContants];
                
            }
            else
            {
                /**
                 *  setting comic book else pages
                 */
                [self.scrollView setPage:[self.slidesArray objectAtIndex:self.pageNumber]];
                [self addAudioButton:[self.slidesArray objectAtIndex:self.pageNumber]];
            }
        }
    }
}

- (void)addAudioButton:(Slides *)slide {
    if(slide.enhancements.count > 0) {
        Enhancement *enhancement = slide.enhancements[1];
        self.audioUrl = [NSURL URLWithString:enhancement.enhancementFile];
        [self performSelectorInBackground:@selector(getTheAudioLength) withObject:nil];
        [self configureAudioPlayer];
        audioButton = [[CustomView alloc] init];
        [audioButton setFrame:CGRectMake([enhancement.xPos floatValue], [enhancement.yPos floatValue], 32, 25)];
        UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 32, 25)];
        imageView.image = [UIImage imageNamed:@"bubbleAudioPlay"];
        [audioButton addSubview:imageView];
        __weak __typeof(self)weakSelf = self;
        audioButton.playAudio = ^{
            [weakSelf playAudio];
        };
        audioButton.pauseAudio = ^{
            [weakSelf pauseAudio];
        };
        [self.scrollView addSubview:audioButton];
    }
}

- (void)playAudio {
    NSError *error;
    self.backgroundMusicPlayer = [[AVAudioPlayer alloc] initWithData:downloadedAudioData error:&error];
    [self.backgroundMusicPlayer setDelegate:self];
    self.backgroundMusicPlayer.numberOfLoops = 0;
    [self.backgroundMusicPlayer play];
    [self showAudioAnimation];
}

- (void)showAudioAnimation {
    [audioView setFrame:CGRectMake(0, self.view.frame.size.height - 80, 50, 60)];
    [self.view addSubview:audioView];
    audioView.alpha = 1;
    img.alpha = 1;
    [UIView animateWithDuration:audioDurationSeconds delay:.2 usingSpringWithDamping:.8 initialSpringVelocity:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        [audioView setFrame:CGRectMake(0, self.view.frame.size.height - 80, self.view.frame.size.width, 60)];
        audioView.alpha = 1;
    } completion:^(BOOL finished) {
    }];
}

- (void)pauseAudio {
    [self.backgroundMusicPlayer stop];
    [self hideAudioAnimation];
}

- (void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag {
    [self.backgroundMusicPlayer stop];
    [self hideAudioAnimation];
}

- (void)hideAudioAnimation {
    [UIView animateWithDuration:2 delay:.2 usingSpringWithDamping:.8 initialSpringVelocity:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        
//        [audioView setFrame:CGRectMake(0, self.view.frame.size.height - 80, 0, 60)];
        audioView.alpha = 0;
        img.alpha = 0;
    } completion:^(BOOL finished) {
    }];
}

- (void)getTheAudioLength {
    AVURLAsset* audioAsset = [AVURLAsset URLAssetWithURL:self.audioUrl options:nil];
    CMTime audioDuration = audioAsset.duration;
    audioDurationSeconds = CMTimeGetSeconds(audioDuration);
    audioDurationSeconds += 1; // add extra 1 second
}
- (void)configureAudioPlayer {
    //    NSURL *url = [NSURL URLWithString:@"http://68.169.44.163/sounds/comics/slides/56dbc70542dba"];
    [self handleDataDownloadFromUrl:self.audioUrl withCompletionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
        if(connectionError == nil) {
            downloadedAudioData = data;
            if (!downloadedAudioData) {
                NSLog(@"not downloaded");
            } else {
            }
        }
    }];
    
}

- (void)handleDataDownloadFromUrl:(NSURL *)url
            withCompletionHandler:(void (^)(NSURLResponse* response, NSData* data, NSError* connectionError)) handler {
    NSURLRequest *request = [[NSURLRequest alloc] initWithURL:url];
    [NSURLConnection sendAsynchronousRequest:request
                                       queue:[NSOperationQueue mainQueue]
                           completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
                               handler(response, data, connectionError);
                           }];
}

- (void)didReceiveMemoryWarning {
    
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


/**
 *  Adding table of content collection view
 */
-(void)SetupTableofContants
{
    
    UIStoryboard *mystoryboard = [UIStoryboard storyboardWithName:@"Main_MainPage" bundle:nil];
    IndexPageVC *indexPage = [mystoryboard instantiateViewControllerWithIdentifier:@"IndexPage"];
    indexPage.slidesArray = [NSMutableArray arrayWithArray:self.slidesArray];
    indexPage.pageNumber=self.pageNumber;
    [indexPage.view setTranslatesAutoresizingMaskIntoConstraints:NO];
    indexPage.Tag=self.Tag;
    [self.scrollView addSubview:indexPage.view];
    [self addChildViewController:indexPage];
    [self setBoundaryX:0 Y:0 width:0 height:0 toView:self.scrollView ChildView:indexPage.view];
    
    
    
}
/**
 *  setting  the bounds of view
 *
 *  @param x      X Constant
 *  @param Y      Y Constant
 *  @param width  width Constant
 *  @param height height Constant
 *  @param parent parent is the perent view
 *  @param child  child subview which added to the parent
 */
-(void)setBoundaryX:(int)x Y:(int)Y width:(int)width height:(int)height toView:(UIView*)parent ChildView:(UIView*)child

{
        
    [parent addConstraint:[NSLayoutConstraint constraintWithItem:child
                                                       attribute:NSLayoutAttributeWidth
                                                       relatedBy:NSLayoutRelationEqual
                                                          toItem:parent
                                                       attribute:NSLayoutAttributeWidth
                                                      multiplier:1.0
                                                        constant:width]];
    
    // Height constraint, half of parent view height
    [parent addConstraint:[NSLayoutConstraint constraintWithItem:child
                                                       attribute:NSLayoutAttributeHeight
                                                       relatedBy:NSLayoutRelationEqual
                                                          toItem:parent
                                                       attribute:NSLayoutAttributeHeight
                                                      multiplier:1
                                                        constant:height]];
    
    
    // Center horizontally
    [parent addConstraint:[NSLayoutConstraint constraintWithItem:child
                                                       attribute:NSLayoutAttributeCenterX
                                                       relatedBy:NSLayoutRelationEqual
                                                          toItem:parent
                                                       attribute:NSLayoutAttributeCenterX
                                                      multiplier:1.0
                                                        constant:0.0]];
    
    // Center vertically
    [parent addConstraint:[NSLayoutConstraint constraintWithItem:child
                                                       attribute:NSLayoutAttributeCenterY
                                                       relatedBy:NSLayoutRelationEqual
                                                          toItem:parent
                                                       attribute:NSLayoutAttributeCenterY
                                                      multiplier:1.0
                                                        constant:0.0]];
    
}


@end
