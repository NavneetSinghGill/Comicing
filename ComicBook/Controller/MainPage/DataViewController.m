//  Created by Subin Kurian on 10/8/15.
//  Copyright © 2015 Subin Kurian. All rights reserved.
#import "DataViewController.h"
#import "CustomScrollView.h"
#import "IndexPageVC.h"
#import "Slides.h"
#import "Enhancement.h"
#import "CustomView.h"
#import "Constants.h"

@interface DataViewController () <AVAudioPlayerDelegate> {
    UIView *audioView;
    UIImageView *img;
    NSMutableArray *audioUrlArray;
    NSMutableArray *audioDurationSecondsArray;
    NSMutableArray *downloadedAudioDataArray;
    CGFloat audioViewHeight;
    CGFloat imgHeight;
}

@property (strong, nonatomic) AVAudioPlayer *backgroundMusicPlayer;

@end

@implementation DataViewController



- (void)viewDidLoad
{
    [super viewDidLoad];
    [self setAudioView];
    
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

- (void)setAudioView {
    if(IS_IPHONE_5)
    {
        audioViewHeight=40;
        imgHeight = 30;
    }
    else if(IS_IPHONE_6)
    {
        audioViewHeight= 50;
        imgHeight = 40;
    }
    else if(IS_IPHONE_6P)
    {
        audioViewHeight= 60;
        imgHeight = 50;
    }
    
    audioView = [[UIView alloc] initWithFrame:CGRectMake(0, self.view.frame.size.height - 60, self.view.frame.size.width, audioViewHeight)];
    [audioView setBackgroundColor:[UIColor colorWithRed:241/255.0f green:199/255.0f blue:27/255.0f alpha:0.7]];
    img = [[UIImageView alloc] initWithFrame:CGRectMake(0, 5, imgHeight, imgHeight)];
    [img setImage:[UIImage imageNamed:@"mic_play"]];
    [audioView addSubview:img];
}

- (void)addAudioButton:(Slides *)slide {

    /*
     Enhancement *en = [[Enhancement alloc] init];
     en.enhancementFile = @"http://68.169.44.163/sounds/comics/slides/56dbc70542dba";
     en.xPos = @"50.0";
     en.yPos = @"75.0";
    
    Enhancement *en1 = [[Enhancement alloc] init];
    en1.enhancementFile = @"http://68.169.44.163/sounds/comics/slides/56dbc70542dba";
    en1.xPos = @"150.0";
    en1.yPos = @"75.0";
    
    Enhancement *en2 = [[Enhancement alloc] init];
    en2.enhancementFile = @"http://www.noiseaddicts.com/samples_1w72b820/4927.mp3";
    en2.xPos = @"250.0";
    en2.yPos = @"75.0";
    
     NSArray *t = @[en, en1, en2];
     slide.enhancements = t;
    
    // http://www.noiseaddicts.com/samples_1w72b820/4927.mp3
    // http://68.169.44.163/sounds/comics/slides/56dbc70542dba
    */
    
    audioUrlArray = [[NSMutableArray alloc] initWithCapacity:slide.enhancements.count];
    audioDurationSecondsArray = [[NSMutableArray alloc] initWithCapacity:slide.enhancements.count];
    downloadedAudioDataArray = [[NSMutableArray alloc] initWithCapacity:slide.enhancements.count];
    for (int i = 0; i < slide.enhancements.count; i ++) {
        [downloadedAudioDataArray addObject:[NSNull null]];
    }
    for(Enhancement *enhancement in slide.enhancements) {
        [audioUrlArray addObject:[NSURL URLWithString:enhancement.enhancementFile]];
        [self performSelectorInBackground:@selector(getTheAudioLength:) withObject:[NSNumber numberWithInteger:[slide.enhancements indexOfObject:enhancement]]];
        [self configureAudioPlayer:[slide.enhancements indexOfObject:enhancement]];
        CustomView *audioButton = [[CustomView alloc] init];
        audioButton.tag = [slide.enhancements indexOfObject:enhancement];
        [audioButton setFrame:CGRectMake([enhancement.xPos floatValue], [enhancement.yPos floatValue], 32, 25)];
        UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 32, 25)];
        imageView.image = [UIImage imageNamed:@"bubbleAudioPlay"];
        [audioButton addSubview:imageView];
        __weak __typeof(self)weakSelf = self;
        __weak __typeof(audioButton)weakAudioButton = audioButton;
        audioButton.playAudio = ^{
            [weakSelf playAudio:weakAudioButton.tag];
        };
        audioButton.pauseAudio = ^{
            [weakSelf pauseAudio];
        };
        [self.scrollView addSubview:audioButton];
    }
}

- (void)playAudio:(NSInteger)tag {
    if(downloadedAudioDataArray.count > tag) {
        NSError *error;
        self.backgroundMusicPlayer = [[AVAudioPlayer alloc] initWithData:[downloadedAudioDataArray objectAtIndex:tag] error:&error];
        [self.backgroundMusicPlayer setDelegate:self];
        self.backgroundMusicPlayer.numberOfLoops = 0;
        [self.backgroundMusicPlayer play];
        [self showAudioAnimation:tag];
    }
}

- (void)showAudioAnimation:(NSInteger)tag {
    CGFloat audioViewY;
    if(IS_IPHONE_5) {
        audioViewY = self.view.frame.size.height - 55;
    } else if(IS_IPHONE_6) {
        audioViewY = self.view.frame.size.height - 70;
    } else if(IS_IPHONE_6P) {
        audioViewY = self.view.frame.size.height - 80;
    }
    [audioView setFrame:CGRectMake(0, audioViewY, 50, audioViewHeight)];
    [self.view addSubview:audioView];
    audioView.alpha = 1;
    img.alpha = 1;
    [UIView animateWithDuration:[[audioDurationSecondsArray objectAtIndex:tag] floatValue] delay:.2 usingSpringWithDamping:.8 initialSpringVelocity:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        [audioView setFrame:CGRectMake(0, audioViewY, self.view.frame.size.width, audioViewHeight)];
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

- (void)getTheAudioLength:(NSNumber *)index {
    AVURLAsset* audioAsset = [AVURLAsset URLAssetWithURL:[audioUrlArray objectAtIndex:[index intValue]] options:nil];
    CMTime audioDuration = audioAsset.duration;
    float audioDurationSeconds = CMTimeGetSeconds(audioDuration);
    audioDurationSeconds += 1; // add extra 1 second
    [audioDurationSecondsArray addObject:[NSNumber numberWithFloat:audioDurationSeconds]];
}
- (void)configureAudioPlayer:(NSUInteger)index {
    //    NSURL *url = [NSURL URLWithString:@"http://68.169.44.163/sounds/comics/slides/56dbc70542dba"];
    [self handleDataDownloadFromUrl:[audioUrlArray objectAtIndex:index] withCompletionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
        if(connectionError == nil) {
            [downloadedAudioDataArray removeObjectAtIndex:index];
            [downloadedAudioDataArray insertObject:data atIndex:index];
            if (!data) {
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
