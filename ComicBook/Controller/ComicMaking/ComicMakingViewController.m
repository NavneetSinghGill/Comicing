//
//  ComicMakingViewController.m
//  ComicMakingPage
//
//  Created by ADNAN THATHIYA on 23/12/15.
//  Copyright © 2015 ADNAN THATHIYA. All rights reserved.
//



#import "ComicMakingViewController.h"
#import "AVCamPreviewView.h"
#import <AVFoundation/AVFoundation.h>
#import <AssetsLibrary/AssetsLibrary.h>
#import "DrawingColorsViewController.h"
#import "RowButtonsViewController.h"
#import "ACEDrawingView.h"
#import "UIColor+Color.h"
#import "CropStickerViewController.h"
#import "StickerList.h"
#import "Global.h"
#import "UIColor+colorWithHexString.h"
#import "UIView+draggable.h"
#import "AppConstants.h"
#import "BubbleViewItem.h"
#import "UIButton+Property.h"
#import "ComicPage.h"
#import "ZoomInteractiveTransition.h"
#import "ZoomTransitionProtocol.h"
#import "ComicItem.h"
#import "UIImage+Image.h"
#import "GlideScrollViewController.h"
#import "BlackboardViewController.h"
#import "ComicNetworking.h"
#import "SendPageViewController.h"
#import "UIImage+Trim.h"
#import "CropRegisterViewController.h"
#import "AppHelper.h"
#import "UIImage+ColorAtPixel.h"
#import "InstructionView.h"
#import "UIImage+GIF.h"
#import "ComicCropView.h"
#import "AnimationCollectionVC.h"
#import "YLGIFImage.h"
#import "UIImageView+AnimatedGif.h"
#import "UIImage+animatedGIF.h"
#import "ComicBubbleList.h"
#import "CombineGifImages.h"
#import "YYImage.h"
#import "ComicBubbleView.h"
#import <ImageIO/ImageIO.h>
#import <MobileCoreServices/MobileCoreServices.h>
#import "NSGIF.h"
#import "PBJVision.h"

#import <Photos/Photos.h>
#import <GLKit/GLKit.h>
#import <ImageIO/ImageIO.h>
#import "RSSliderView.h"

#import "UIImage+animatedGIF.h"

static NSString * const PBJViewControllerPhotoAlbum = @"Comicing";

CGSize CGSizeAbsolute2(CGSize size) {
    return (CGSize){fabs(size.width), fabs(size.height)};
}

////////////

#pragma mark - UIImage Additions

@interface UIImage (SecretAddition)

+ (NSData *)writeMetadataIntoImageData:(NSData *)imageData metadata:(NSDictionary *)metadata;

@end

@implementation UIImage (SecretAddition)

+ (NSData *)writeMetadataIntoImageData:(NSData *)imageData metadata:(NSDictionary *)metadata {
    CGImageSourceRef source = CGImageSourceCreateWithData((__bridge CFDataRef)imageData, NULL);
    CFStringRef sourceType = CGImageSourceGetType(source);
    
    NSMutableData *imageDataWithMetadata = [NSMutableData data];
    
    CGImageDestinationRef destination = CGImageDestinationCreateWithData((__bridge CFMutableDataRef)imageDataWithMetadata, sourceType, 1, NULL);
    if (!destination) {
        NSLog(@"could not create image destination");
    }
    
    CGImageDestinationAddImageFromSource(destination, source, 0, (__bridge CFDictionaryRef) metadata);
    BOOL success = NO;
    success = CGImageDestinationFinalize(destination);
    if (!success) {
        NSLog(@"could not finalize image at destination");
    }
    
    if (destination)
        CFRelease(destination);
    
    if (source)
        CFRelease(source);
    
    return imageDataWithMetadata;
}

@end


/////////////


static void * CapturingStillImageContext = &CapturingStillImageContext;
static void * RecordingContext = &RecordingContext;
static void * SessionRunningAndDeviceAuthorizedContext = &SessionRunningAndDeviceAuthorizedContext;
static int CaptionViewTextViewTag = 9191;
static CGRect CaptionTextViewMinRect;
static RowButtonCallBack _completionHandler ;

//static NSURL *videoURLForGIF;
//static int videoFrameIndex=1;

@interface ComicMakingViewController ()<ACEDrawingViewDelegate,CropStickerViewControllerDelegate, UIGestureRecognizerDelegate,UITextFieldDelegate,AVAudioRecorderDelegate,UITextViewDelegate,ZoomTransitionProtocol,UINavigationControllerDelegate,UIImagePickerControllerDelegate,InstructionViewDelegate,ComicCropViewDelegate,UIAlertViewDelegate,PBJVisionDelegate,RSliderViewDelegate>
{
    CGPoint backupOtherViewCenter;
    CGPoint backupToolCenter;
    CGPoint chatIconCenter;
    CGPoint uploadIconCenter;
    CGPoint voiceViewCenter;
    BOOL openStatus;
    NSDate *inflateStart;
    CADisplayLink *inflateDisplayLink;
    CGRect voiceRect;
    
    CGFloat distanceFromPrevious;
    CGFloat speed;
    
    //Ramesh
    //Start//
    CGRect captionHolderViewFrame;
    NSTimer *colourBoxTimer;
    CGRect captionFrameMain;
    NSArray* captionTextColourArray;
    CGRect temImagFrame;
    CGPoint shinkLimit;
    NSDictionary *currentWorkingAnimation;
    UITapGestureRecognizer *currentAnimationInstructionTap;
    UIPanGestureRecognizer *currentAnimationPan;
    
    YYAnimatedImageView *currentAnimInstSubView;
    BOOL haveAnimationOnPage;
    BOOL pauseAnimation;
    ComicItemAnimatedComponent *refAnimatedSticker;
    ComicItemAnimatedSticker *refToCombineAnimatedSticker;
    
    AnimationCollectionVC *animationCollection;
    NSInteger currentTapIndex;
    CGPoint currentAnimationTouchPoint;
    //    NSMutableArray *arrOfActiveAnimations;
    NSInteger indexMaxRun;
    //    ComicItemAnimatedSticker *mainAnimationGifView;
    BOOL hasStartedBezierForAnimation;
    NSMutableArray *allPointsForRedFace;
    BOOL haveCreateMainGif;
    NSInteger tempIndexForFace;
    CGPoint tempTouchPointForFace;
    
    
    CGRect comicImageFrame;
    GLKViewController *_effectsViewController;
}

@property (weak, nonatomic) IBOutlet UIView *viewCamera;
//@property (weak, nonatomic) IBOutlet AVCamPreviewView *viewCameraPreview;
@property (strong, nonatomic) IBOutlet UIView *viewCameraPreview;
@property (strong, nonatomic) YLGIFImage *imageIn;

@property (weak, nonatomic) IBOutlet UIView *viewRowButtons;

@property (weak, nonatomic) IBOutlet UIButton *chatIcon;
@property (weak, nonatomic) IBOutlet UIButton *uploadIcon;

@property (weak, nonatomic) IBOutlet UIView *viewStickerList;
@property (weak, nonatomic) IBOutlet UIView *viewDrawing;
@property (weak, nonatomic) IBOutlet UIButton *btnClose;
@property (weak, nonatomic) IBOutlet UIView *glideViewHolder;
@property (weak, nonatomic) IBOutlet UIButton *btnCloseComic;
@property (weak, nonatomic) IBOutlet UIView *viewBlackBoard;
@property CGRect frameBlackboardView;
@property (strong, nonatomic) UIPinchGestureRecognizer *pinchGesture;

@property (strong, nonatomic) UIImage *printScreen;
@property (weak, nonatomic) IBOutlet UIButton *btnSend;

@property (nonatomic) BOOL isSlideShrink;

// Camera Session management.
@property (nonatomic) dispatch_queue_t sessionQueue; // Communicate with the session and other session objects on this queue.
@property (nonatomic) AVCaptureSession *session;
@property (nonatomic) AVCaptureDeviceInput *videoDeviceInput;
@property (nonatomic) AVCaptureMovieFileOutput *movieFileOutput;
@property (nonatomic) AVCaptureStillImageOutput *stillImageOutput;
@property (strong, nonatomic) AVCaptureVideoPreviewLayer *cameraPreviewLayer;

// Camera Utilities.
@property (nonatomic) UIBackgroundTaskIdentifier backgroundRecordingID;
@property (nonatomic, getter = isDeviceAuthorized) BOOL deviceAuthorized;
@property (nonatomic, readonly, getter = isSessionRunningAndDeviceAuthorized) BOOL sessionRunningAndDeviceAuthorized;
@property (nonatomic) BOOL lockInterfaceRotation;
@property (nonatomic) id runtimeErrorHandlingObserver;

// drawing
@property (nonatomic, strong) DrawingColorsViewController *drawingColor;
@property CGRect frameDrawingView;
@property (strong, nonatomic) ACEDrawingView *drawView;
@property CGPoint centerImgvComic;
@property (nonatomic) CGFloat lastScale;

@property CGFloat shrinkHeight;
@property CGRect viewFrame;
@property CGFloat shrinkCount;
@property ( nonatomic) NSTimeInterval previousTimestamp;
@property CGRect frameImgvComic;

/*Ramesh - Bubbles*/
@property (weak, nonatomic) IBOutlet UIView *bubbleListView;
@property (weak, nonatomic) IBOutlet UIView *voiceView;
@property (weak, nonatomic) IBOutlet UIButton *btnRecord;
//END

/*Ramesh - Exaggerated*/
@property (weak, nonatomic) IBOutlet UIView *exclamationListView;
//END
@property (weak, nonatomic) IBOutlet UIImageView *ImgvComic2;

@property (nonatomic, assign) ComicItemType comicItemType;
@property (nonatomic, strong) id<ComicItem> comicItem;
@property (nonatomic,strong) NSMutableArray* comicItemArray;
@property (nonatomic,strong) RowButtonsViewController *rowButton;
@property (nonatomic) BOOL isAlreadyDoubleDrawColor;
@property (nonatomic) UIColor *onColor;

@property BOOL captionHeightSmall;

@property (strong, nonatomic) ComicCropView *comicCropView;
@property (nonatomic) BOOL isCameraOn;
@property (nonatomic) BOOL isshrinkingEnd;

@property (weak, nonatomic) IBOutlet UIView *bubbleContainerView;
@property (weak, nonatomic) IBOutlet UIView *stickerlistContainerView;
@property (nonatomic, strong) UIBezierPath *croppingPath;
@property (weak, nonatomic) IBOutlet UIView *animationContainerView;

@property (assign, nonatomic) BOOL startRecordingFlag;
@property (assign, nonatomic) BOOL pauseRecordingFlag;
@property (assign, nonatomic) int videoDuration;
@property (strong,nonatomic) IBOutlet UIView *sliderView;
@property (strong,nonatomic) NSURL *outputVideoURL;
@property (strong,nonatomic) UIImageView *videoImg;
@property (strong,nonatomic) UIImageView *stillPicImg;
@property (strong,nonatomic) IBOutlet RSSliderView *vertSlider;
@property (strong,nonatomic) UIButton *crossSegmentBtn;
@property (weak, nonatomic) IBOutlet UIButton *btnPlayAnimation;

@property (strong, nonatomic) NSString *gifLayerPath;

@end

int sliderViewWidthDeltaChange;


@implementation ComicMakingViewController

@synthesize viewCameraPreview, viewCamera, imgvComic, uploadIcon, viewStickerList, viewRowButtons,cameraPreviewLayer;
@synthesize drawingColor,viewDrawing,frameDrawingView, drawView, centerImgvComic,lastScale, btnClose,btnCloseComic,bubbleListView,exclamationListView,shrinkHeight,viewFrame, shrinkCount, previousTimestamp, isNewSlide,viewBlackBoard,frameBlackboardView,onColor,isAlreadyDoubleDrawColor;
@synthesize comicPage,printScreen, isSlideShrink,frameImgvComic,pinchGesture, isWideSlide,comicCropView, isCameraOn;

#pragma mark - UIViewController Methods
- (void)viewDidLoad
{
    [super viewDidLoad];
    
  //  [self addBubbleListViewController];
    [self _setup];
    sliderViewWidthDeltaChange=[UIScreen mainScreen].bounds.size.width/7;
   // [self addBubbleListViewController];
    [self addStickerListViewController];
    [self addAnimationListViewController];
    _captionHeightSmall = YES;
    
    frameImgvComic = imgvComic.frame;
    frameBlackboardView = viewBlackBoard.frame;
    
    frameDrawingView = viewDrawing.frame;
    centerImgvComic = imgvComic.center;
    viewRowButtons.alpha = 0;
    self.chatIcon.alpha = 0;
    
    
    if (isWideSlide == YES)
    {
        isCameraOn = YES;
        [self addComicCropViewWithImage:nil];
    }
    
    [[GoogleAnalytics sharedGoogleAnalytics] logScreenEvent:@"ComicMaking" Attributes:nil];
    
    // set up the filename to save based on the friend/group id.
    if(self.comicType == ReplyComic && self.replyType == FriendReply) {
        self.fileNameToSave = [NSString stringWithFormat:@"ComicSlide_F%@", self.friendOrGroupId];
    } else if(self.comicType == ReplyComic && self.replyType == GroupReply) {
        self.fileNameToSave = [NSString stringWithFormat:@"ComicSlide_G%@", self.friendOrGroupId];
    } else {
        self.fileNameToSave = @"ComicSlide";
    }
    
    
    if ([[NSUserDefaults standardUserDefaults] boolForKey:kIsUserEnterSecondTimeComicMaking] == YES)
    {
        // open slideB Instruction
        dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0 * NSEC_PER_SEC));
        dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
            NSLog(@"Do some work");
            
            if ([InstructionView getBoolValueForSlide:kInstructionSlide15] == YES)
            {
                if ([InstructionView getBoolValueForSlide:kInstructionSlideB] == NO)
                {
                    InstructionView *instView = [[InstructionView alloc] initWithFrame:self.view.bounds];
                    instView.delegate = self;
                    [instView showInstructionWithSlideNumber:SlideNumberB withType:InstructionBubbleType];
                    [instView setTrueForSlide:kInstructionSlideB];
                    
                    [self.view addSubview:instView];
                }
                
            }
        });
    }
    
#if !TARGET_OS_SIMULATOR
    
    [self setUpCameraPreview];
    
#endif
    [self prepareGlideView];
    [self prepareCaptionView];
    [self prepareView];
    [self prepareVoiceView];
    
    
    // open Instruction
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC));
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        NSLog(@"Do some work");
        
        if ([InstructionView getBoolValueForSlide:kInstructionSlide1] == NO)
        {
            InstructionView *instView = [[InstructionView alloc] initWithFrame:self.view.bounds];
            instView.delegate = self;
            [instView showInstructionWithSlideNumber:SlideNumber1 withType:InstructionBoxType];
            [instView setTrueForSlide:kInstructionSlide1];
            
            [self.view addSubview:instView];
        }
    });
    
    comicImageFrame = self.imgvComic.frame;
    
    self.switchToToggle.transform=CGAffineTransformRotate(self.switchToToggle.transform,270.0/180*M_PI);
    
}

#pragma mark- setting preview for camera

-(void) setUpCameraPreview {
    
    // preview and AV layer
    viewCameraPreview = [[UIView alloc] initWithFrame:CGRectZero];
    viewCameraPreview.backgroundColor = [UIColor blackColor];//CGRectGetHeight
    CGRect previewFrame = CGRectMake(0, 60.0f, CGRectGetWidth([UIScreen mainScreen].bounds), CGRectGetHeight([UIScreen mainScreen].bounds)-100);
    viewCameraPreview.frame = previewFrame;
    cameraPreviewLayer = [[PBJVision sharedInstance] previewLayer];
    cameraPreviewLayer.frame = viewCameraPreview.bounds;
    cameraPreviewLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
    [viewCameraPreview.layer addSublayer:cameraPreviewLayer];
    
    // onion skin
    _effectsViewController = [[GLKViewController alloc] init];
    _effectsViewController.preferredFramesPerSecond = 60;
    
    GLKView *view = (GLKView *)_effectsViewController.view;
    CGRect viewFrame1 = viewCameraPreview.bounds;
    view.frame = viewFrame1;
    view.context = [[PBJVision sharedInstance] context];
    view.contentScaleFactor = [[UIScreen mainScreen] scale];
    view.alpha = 0.5f;
    view.hidden = YES;
    [[PBJVision sharedInstance] setPresentationFrame:viewCameraPreview.frame];
    [viewCameraPreview addSubview:_effectsViewController.view];
    [self setUpSliderView];
}

-(void) setUpCameraPreviewForPhoto {
    
    // preview and AV layer
    viewCameraPreview = [[UIView alloc] initWithFrame:CGRectZero];
    viewCameraPreview.backgroundColor = [UIColor blackColor];//CGRectGetHeight
    CGRect previewFrame = CGRectMake(0, 60.0f, CGRectGetWidth([UIScreen mainScreen].bounds), CGRectGetHeight([UIScreen mainScreen].bounds)-100);
    viewCameraPreview.frame = previewFrame;
    cameraPreviewLayer = [[PBJVision sharedInstance] previewLayer];
    cameraPreviewLayer.frame = viewCameraPreview.bounds;
    [viewCameraPreview.layer addSublayer:cameraPreviewLayer];
    
    // onion skin
    _effectsViewController = [[GLKViewController alloc] init];
    _effectsViewController.preferredFramesPerSecond = 60;
    
    GLKView *view = (GLKView *)_effectsViewController.view;
    CGRect viewFrame1 = viewCameraPreview.bounds;
    view.frame = viewFrame1;
    view.context = [[PBJVision sharedInstance] context];
    view.contentScaleFactor = [[UIScreen mainScreen] scale];
    view.alpha = 0.5f;
    view.hidden = YES;
    [[PBJVision sharedInstance] setPresentationFrame:viewCameraPreview.frame];
    [viewCameraPreview addSubview:_effectsViewController.view];
    [self setUpSliderView];
}


#pragma mark- method for slider view

//-(void)setUpSliderView {
//    
//    // top slider
//    self.sliderView=[[UIView alloc] initWithFrame:CGRectMake(0, 0, 0, 50)];
//    [viewCameraPreview addSubview:self.sliderView];
//    [self.sliderView setBackgroundColor:[UIColor colorWithRed:0.0/255.0 green:174.0/255.0 blue:239.0/255.0 alpha:1.0]];
//    
//    
//    // toggel Slider for video and image
//    
//    self.vertSlider = [[RSSliderView alloc] initWithFrame:CGRectMake([UIScreen mainScreen].bounds.size.width/2-35, viewCameraPreview.frame.size.height-190, 70, 170) andOrientation:Vertical];
//    self.vertSlider.delegate = self;
//    
//    [self.vertSlider setColorsForBackground:[UIColor clearColor]
//                                 foreground:[UIColor clearColor]
//                                     handle:[UIColor clearColor]
//                                     border:[UIColor colorWithRed:159.0/255.0 green:220.0/255.0 blue:249.0/255.0 alpha:1.0]];
//    
//    [viewCameraPreview addSubview:self.vertSlider];
//    
//    // image for video and still picture  video-tape-icon.png
//    
//    self.videoImg=[[UIImageView alloc] initWithFrame:CGRectMake(self.vertSlider.frame.origin.x+self.vertSlider.frame.size.width+20, self.vertSlider.frame.origin.y+20, 30, 30)];
//    [self.videoImg setImage:[UIImage imageNamed:@"video-tape-icon.png"]];
//    [viewCameraPreview addSubview:self.videoImg];
//    
//    self.stillPicImg=[[UIImageView alloc] initWithFrame:CGRectMake(self.vertSlider.frame.origin.x+self.vertSlider.frame.size.width+20, self.vertSlider.frame.origin.y+self.vertSlider.frame.size.height-50, 30, 30)];
//    [self.stillPicImg setImage:[UIImage imageNamed:@"camera-icon.png"]];
//    [viewCameraPreview addSubview:self.stillPicImg];
//    
//    
//    // done button created
//    UIButton *doneVideoBtn=[UIButton buttonWithType:UIButtonTypeCustom];
//    [doneVideoBtn setImage:[UIImage imageNamed:@"tick-button.png"] forState:UIControlStateNormal];
//    [doneVideoBtn setFrame:CGRectMake(viewCameraPreview.frame.origin.x+viewCameraPreview.frame.size.width-50, viewCameraPreview.frame.size.height+viewCameraPreview.frame.origin.y-130, 40, 40)];
//    [viewCameraPreview addSubview:doneVideoBtn];
//    [doneVideoBtn addTarget:self action:@selector(doneVideoBtnClicked) forControlEvents:UIControlEventTouchUpInside];
//    
//    // cross button
//    
//    self.crossSegmentBtn=[UIButton buttonWithType:UIButtonTypeCustom];
//    [self.crossSegmentBtn setImage:[UIImage imageNamed:@"profilePicClose.png"] forState:UIControlStateNormal];
//    [self.crossSegmentBtn setFrame:CGRectMake(viewCameraPreview.frame.origin.x+20, self.sliderView.frame.origin.y+self.sliderView.frame.size.height+30, 21, 19)];
//    [viewCameraPreview addSubview:self.crossSegmentBtn];
//    [self.crossSegmentBtn addTarget:self action:@selector(crossButtonClicked) forControlEvents:UIControlEventTouchUpInside];
//    [self.crossSegmentBtn setHidden:YES];
//    
//    
//}

#pragma mark- done video button method

-(void)doneVideoBtnClicked {
#if TARGET_OS_SIMULATOR
    viewCamera.hidden = YES;
    [viewCameraPreview setHidden:YES];
    [self.imgGifLayer setHidden:NO];
//    NSString* sContentsPath = [[GifURL absoluteString] stringByReplacingOccurrencesOfString:@"file:///" withString:@"//"];
//    UIImage* imgObj = [UIImage imageWithContentsOfFile:sContentsPath];
//    self.imgGifLayer.image = imgObj;
    [self copytoDocument:@"Slide-2B" type:@"gif"];
    self.gifLayerPath = @"Slide-2B.gif";
    
    NSString* sContentsPath = [[AppHelper getGifLayerFilePath] stringByAppendingString:self.gifLayerPath];
    NSData *gifData = [NSData dataWithContentsOfFile: sContentsPath];
    self.imgGifLayer.image =  [UIImage sd_animatedGIFWithData:gifData];
    
//    self.imgGifLayer.image =  [UIImage sd_animatedGIFNamed:@"Slide-2B.gif"];//  [YYImage imageWithContentsOfFile:animationPath];
    
    //Visible middle layer
    [self handleMiddleLayer];
#else
    [NSGIF createGIFfromURL:self.outputVideoURL
             withFrameCount:30
                  delayTime:.010
                  loopCount:0
                 completion:^(NSURL *GifURL,NSString* GifFileName) {
                     NSLog(@"Finished generating GIF: %@", GifURL);
                     if (GifURL) {
                         viewCamera.hidden = YES;
                         [viewCameraPreview setHidden:YES];
                         [self.imgGifLayer setHidden:NO];
                         NSString* sContentsPath = [[AppHelper getGifLayerFilePath] stringByAppendingString:GifFileName];
                         NSData *gifData = [NSData dataWithContentsOfFile: sContentsPath];
                         self.imgGifLayer.image =  [UIImage sd_animatedGIFWithData:gifData];
                         self.gifLayerPath = GifFileName;
                         //Visible middle layer
                         [self handleMiddleLayer];
                     }
    }]; 
#endif
    // [viewCameraPreview removeFromSuperview];
}

-(void) copytoDocument:(NSString*)fileName type:(NSString*)type{
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSError *error;
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    
    NSString *filePath = [documentsDirectory stringByAppendingPathComponent:[fileName stringByAppendingString:[NSString stringWithFormat:@".%@",type]]];
    
    if ([fileManager fileExistsAtPath:filePath] == NO)
    {
        NSString *resourcePath = [[NSBundle mainBundle] pathForResource:fileName ofType:type];
        [fileManager copyItemAtPath:resourcePath toPath:filePath error:&error];
        if (error) {
            NSLog(@"Error on copying file: %@\nfrom path: %@\ntoPath: %@", error, resourcePath, filePath);
        }
    }
}

-(void)handleMiddleLayer{
    
    [self.imgvComic setHidden:NO];
    [imgvComic setImage:[UIImage imageNamed:@"middleLayer_Transparent"]];
    
    RowButtonsViewController *rowButtonsController;
    for (UIViewController *controller in self.childViewControllers)
    {
        if ([controller isKindOfClass:[RowButtonsViewController class]])
        {
            rowButtonsController = (RowButtonsViewController *)controller;
        }
    }
    rowButtonsController.btnCamera.selected = YES;
    
    [rowButtonsController allButtonsFadeIn:rowButtonsController.btnCamera];
}

#pragma mark- cross button clicked

-(void)crossButtonClicked {
    
    [self.crossSegmentBtn setHidden:NO];
    CGRect frame=self.sliderView.frame;
    frame.size.width=0.0;
    self.sliderView.frame=frame;
    self.videoDuration=0;
    NSError *error;
    NSFileManager *fileManager = [NSFileManager defaultManager];
    BOOL success = [fileManager removeItemAtPath:[NSString stringWithFormat:@"%@",self.outputVideoURL] error:&error];
    
}

#pragma mark- delegate method for RSSlider View

-(void)sliderValueChanged:(RSSliderView *)sender {
    
    [self methodForProgressBar];
    if(!self.startRecordingFlag) {
        if(!self.vertSlider.slideDownFlag) {
            [self.crossSegmentBtn setHidden:NO];
            [self.stillPicImg setHidden:YES];
            [self startVideoRecording];
            self.startRecordingFlag=YES;
            
        }
        
    }
    else {
        
        if(self.pauseRecordingFlag) {
            self.pauseRecordingFlag=NO;
            [[PBJVision sharedInstance] resumeVideoCapture];
        }
    }
    
}

-(void)sliderValueChangeEnded:(RSSliderView *)sender {
    
    if(self.videoDuration<7)
        [[PBJVision sharedInstance] pauseVideoCapture];
    else {
        [[PBJVision sharedInstance] endVideoCapture];
        [self.stillPicImg setHidden:NO];
        self.vertSlider.slideDownFlag=YES;
        [self.vertSlider setValue:0.0 withAnimation:NO completion:nil];
        
    }
    
    self.pauseRecordingFlag=YES;
}

-(void)tapToStillPicture {
    
    [self _setupForStillImage];
    [self setUpCameraPreviewForPhoto];
//    [self btnCameraTap:nil];
    //if([[PBJVision sharedInstance] canCapturePhoto])
        [[PBJVision sharedInstance] capturePhoto];
}

#pragma mark- method for handling switch to toggle button clicked

//-(IBAction)switchToToggleButtonClicked:(id)sender {
//
//    NSLog(@"******switchToToggleButtonClicked******* %f",self.switchToToggle.value);
//
//    if(self.switchToToggle.value>0.5) {
//
//        if(!self.startRecordingFlag) {
//            [self startVideoRecording];
//            self.startRecordingFlag=YES;
//        }
//        [self methodForProgressBar];
//    }
//}

#pragma mark- method for playing video for 7 sec

-(void)startVideoRecording {
    
    [[PBJVision sharedInstance] startVideoCapture];
}


-(void)progressBarValueChanged {
    
    // if(self.videoDuration<=7) {
    
    [UIView animateWithDuration:1.0
                          delay:0
                        options:UIViewAnimationCurveEaseInOut
                     animations:^ {
                         self.sliderView.frame = CGRectMake(self.view.frame.origin.x, self.view.frame.origin.y, self.sliderView.frame.size.width+2.0, 50);
                         
                     }completion:^(BOOL finished) {
                         
                     }];
    
    
    if(!self.pauseRecordingFlag)
        [self methodForProgressBar];
    else
        self.videoDuration=0;
    //    }
    //    else {
    //
    //        self.videoDuration=0;
    //
    //    }
    
}

- (void)_setup
{
    
    
    [PBJVision sharedInstance].delegate = self;
    [PBJVision sharedInstance].cameraMode = PBJCameraModeVideo;
    // [PBJVision sharedInstance].cameraMode = PBJCameraModePhoto; // PHOTO: uncomment to test photo capture
    [PBJVision sharedInstance].cameraOrientation = PBJCameraOrientationPortrait;
    [PBJVision sharedInstance].focusMode = PBJFocusModeContinuousAutoFocus;
    [PBJVision sharedInstance].outputFormat = PBJOutputFormatSquare;
    [[PBJVision sharedInstance] setMaximumCaptureDuration:CMTimeMakeWithSeconds(8, 30)]; // ~ 5 seconds
    [PBJVision sharedInstance].videoRenderingEnabled = YES;
    [PBJVision sharedInstance].additionalCompressionProperties = @{AVVideoProfileLevelKey : AVVideoProfileLevelH264Baseline30};
    
    
    
}
- (void)_setupForStillImage
{
    
    
    [PBJVision sharedInstance].delegate = self;
    [PBJVision sharedInstance].cameraMode = PBJCameraModePhoto; // PHOTO: uncomment to test photo capture
    [PBJVision sharedInstance].cameraOrientation = PBJCameraOrientationPortrait;
    [PBJVision sharedInstance].focusMode = PBJFocusModeContinuousAutoFocus;
    [PBJVision sharedInstance].outputFormat = PBJOutputFormatSquare;
   // [[PBJVision sharedInstance] setMaximumCaptureDuration:CMTimeMakeWithSeconds(8, 30)]; // ~ 5 seconds
   // [PBJVision sharedInstance].videoRenderingEnabled = YES;
  //  [PBJVision sharedInstance].additionalCompressionProperties = @{AVVideoProfileLevelKey : AVVideoProfileLevelH264Baseline30};
    
    
    
}


/* Delegate method */

#pragma mark - PBJVisionDelegate

// session

- (void)visionSessionWillStart:(PBJVision *)vision
{
}

- (void)visionSessionDidStart:(PBJVision *)vision
{
    if (![viewCameraPreview superview]) {
        [self.view addSubview:viewCameraPreview];
        // [self.view bringSubviewToFront:_gestureView];
    }
}

- (void)visionSessionDidStop:(PBJVision *)vision
{
    // // [viewCameraPreview removeFromSuperview];
}

// preview

- (void)visionSessionDidStartPreview:(PBJVision *)vision
{
    NSLog(@"Camera preview did start");
    
}

- (void)visionSessionDidStopPreview:(PBJVision *)vision
{
    NSLog(@"Camera preview did stop");
}

// device

- (void)visionCameraDeviceWillChange:(PBJVision *)vision
{
    NSLog(@"Camera device will change");
}

- (void)visionCameraDeviceDidChange:(PBJVision *)vision
{
    NSLog(@"Camera device did change");
}

// mode

- (void)visionCameraModeWillChange:(PBJVision *)vision
{
    NSLog(@"Camera mode will change");
}

- (void)visionCameraModeDidChange:(PBJVision *)vision
{
    NSLog(@"Camera mode did change");
}

// format

- (void)visionOutputFormatWillChange:(PBJVision *)vision
{
    NSLog(@"Output format will change");
}

- (void)visionOutputFormatDidChange:(PBJVision *)vision
{
    NSLog(@"Output format did change");
}

- (void)vision:(PBJVision *)vision didChangeCleanAperture:(CGRect)cleanAperture
{
}

// focus / exposure

- (void)visionWillStartFocus:(PBJVision *)vision
{
}

- (void)visionDidStopFocus:(PBJVision *)vision
{
    //    if (_focusView && [_focusView superview]) {
    //        [_focusView stopAnimation];
    //    }
}

- (void)visionWillChangeExposure:(PBJVision *)vision
{
}

- (void)visionDidChangeExposure:(PBJVision *)vision
{
    //    if (_focusView && [_focusView superview]) {
    //        [_focusView stopAnimation];
    //    }
}

// flash

- (void)visionDidChangeFlashMode:(PBJVision *)vision
{
    NSLog(@"Flash mode did change");
}

// photo

- (void)visionWillCapturePhoto:(PBJVision *)vision
{
}

- (void)visionDidCapturePhoto:(PBJVision *)vision
{
}


- (void)visionDidStartVideoCapture:(PBJVision *)vision
{
    
}

- (void)visionDidPauseVideoCapture:(PBJVision *)vision
{
    // [_strobeView stop];
}

- (void)visionDidResumeVideoCapture:(PBJVision *)vision
{
    // [_strobeView start];
}


// progress

- (void)vision:(PBJVision *)vision didCaptureVideoSampleBuffer:(CMSampleBufferRef)sampleBuffer
{
    //    NSLog(@"captured audio (%f) seconds", vision.capturedAudioSeconds);
}

- (void)vision:(PBJVision *)vision didCaptureAudioSample:(CMSampleBufferRef)sampleBuffer
{
    //    NSLog(@"captured video (%f) seconds", vision.capturedVideoSeconds);
}

/////////////////////////


- (void)vision:(PBJVision *)vision capturedVideo:(NSDictionary *)videoDict error:(NSError *)error
{
    if (error && [error.domain isEqual:PBJVisionErrorDomain] && error.code == PBJVisionErrorCancelled) {
        NSLog(@"recording session cancelled");
        return;
    } else if (error) {
        NSLog(@"encounted an error in video capture (%@)", error);
        return;
    }
    
    NSDictionary *_currentVideo = videoDict;
    self.startRecordingFlag=NO;
    NSString *videoPath = [_currentVideo  objectForKey:PBJVisionVideoPathKey];
    self.outputVideoURL = [NSURL fileURLWithPath:videoPath];
    
    
    [[PBJVision sharedInstance] endVideoCapture];
    [self.stillPicImg setHidden:NO];
    self.vertSlider.slideDownFlag=YES;
    [self.vertSlider setValue:0.0 withAnimation:NO completion:nil];
    
}

#pragma mark- setting preview for camera

//-(void) setUpCameraPreview {
//    
//    // preview and AV layer
//    viewCameraPreview = [[UIView alloc] initWithFrame:CGRectZero];
//    viewCameraPreview.backgroundColor = [UIColor blackColor];//CGRectGetHeight
//    CGRect previewFrame = CGRectMake(0, 60.0f, CGRectGetWidth([UIScreen mainScreen].bounds), CGRectGetHeight([UIScreen mainScreen].bounds)-100);
//    viewCameraPreview.frame = previewFrame;
//    cameraPreviewLayer = [[PBJVision sharedInstance] previewLayer];
//    cameraPreviewLayer.frame = viewCameraPreview.bounds;
//    cameraPreviewLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
//    [viewCameraPreview.layer addSublayer:cameraPreviewLayer];
//    
//    // onion skin
//    _effectsViewController = [[GLKViewController alloc] init];
//    _effectsViewController.preferredFramesPerSecond = 60;
//    
//    GLKView *view = (GLKView *)_effectsViewController.view;
//    CGRect viewFrame1 = viewCameraPreview.bounds;
//    view.frame = viewFrame1;
//    view.context = [[PBJVision sharedInstance] context];
//    view.contentScaleFactor = [[UIScreen mainScreen] scale];
//    view.alpha = 0.5f;
//    view.hidden = YES;
//    [[PBJVision sharedInstance] setPresentationFrame:viewCameraPreview.frame];
//    [viewCameraPreview addSubview:_effectsViewController.view];
//    [self setUpSliderView];
//}

//-(void) setUpCameraPreviewForPhoto {
//    
//    // preview and AV layer
//    viewCameraPreview = [[UIView alloc] initWithFrame:CGRectZero];
//    viewCameraPreview.backgroundColor = [UIColor blackColor];//CGRectGetHeight
//    CGRect previewFrame = CGRectMake(0, 60.0f, CGRectGetWidth([UIScreen mainScreen].bounds), CGRectGetHeight([UIScreen mainScreen].bounds)-100);
//    viewCameraPreview.frame = previewFrame;
//    cameraPreviewLayer = [[PBJVision sharedInstance] previewLayer];
//    cameraPreviewLayer.frame = viewCameraPreview.bounds;
//    [viewCameraPreview.layer addSublayer:cameraPreviewLayer];
//    
//    // onion skin
//    _effectsViewController = [[GLKViewController alloc] init];
//    _effectsViewController.preferredFramesPerSecond = 60;
//    
//    GLKView *view = (GLKView *)_effectsViewController.view;
//    CGRect viewFrame1 = viewCameraPreview.bounds;
//    view.frame = viewFrame1;
//    view.context = [[PBJVision sharedInstance] context];
//    view.contentScaleFactor = [[UIScreen mainScreen] scale];
//    view.alpha = 0.5f;
//    view.hidden = YES;
//    [[PBJVision sharedInstance] setPresentationFrame:viewCameraPreview.frame];
//    [viewCameraPreview addSubview:_effectsViewController.view];
//    [self setUpSliderView];
//}


#pragma mark- method for slider view

-(void)setUpSliderView {
    
    // top slider
    self.sliderView=[[UIView alloc] initWithFrame:CGRectMake(0, 0, 0, 50)];
    [viewCameraPreview addSubview:self.sliderView];
    [self.sliderView setBackgroundColor:[UIColor colorWithRed:0.0/255.0 green:174.0/255.0 blue:239.0/255.0 alpha:1.0]];
    
    
    // toggel Slider for video and image
    
    self.vertSlider = [[RSSliderView alloc] initWithFrame:CGRectMake([UIScreen mainScreen].bounds.size.width/2-35, viewCameraPreview.frame.size.height-190, 70, 170) andOrientation:Vertical];
    self.vertSlider.delegate = self;
    
    [self.vertSlider setColorsForBackground:[UIColor clearColor]
                                 foreground:[UIColor clearColor]
                                     handle:[UIColor clearColor]
                                     border:[UIColor colorWithRed:159.0/255.0 green:220.0/255.0 blue:249.0/255.0 alpha:1.0]];
    
    [viewCameraPreview addSubview:self.vertSlider];
    
    // image for video and still picture  video-tape-icon.png
    
    self.videoImg=[[UIImageView alloc] initWithFrame:CGRectMake(self.vertSlider.frame.origin.x+self.vertSlider.frame.size.width+20, self.vertSlider.frame.origin.y+20, 30, 30)];
    [self.videoImg setImage:[UIImage imageNamed:@"video-tape-icon.png"]];
    [viewCameraPreview addSubview:self.videoImg];
    
    self.stillPicImg=[[UIImageView alloc] initWithFrame:CGRectMake(self.vertSlider.frame.origin.x+self.vertSlider.frame.size.width+20, self.vertSlider.frame.origin.y+self.vertSlider.frame.size.height-50, 30, 30)];
    [self.stillPicImg setImage:[UIImage imageNamed:@"camera-icon.png"]];
    [viewCameraPreview addSubview:self.stillPicImg];
    
    
    // done button created
    UIButton *doneVideoBtn=[UIButton buttonWithType:UIButtonTypeCustom];
    [doneVideoBtn setImage:[UIImage imageNamed:@"tick-button.png"] forState:UIControlStateNormal];
    [doneVideoBtn setFrame:CGRectMake(viewCameraPreview.frame.origin.x+viewCameraPreview.frame.size.width-50, viewCameraPreview.frame.size.height+viewCameraPreview.frame.origin.y-130, 40, 40)];
    [viewCameraPreview addSubview:doneVideoBtn];
    [doneVideoBtn addTarget:self action:@selector(doneVideoBtnClicked) forControlEvents:UIControlEventTouchUpInside];
    
    // cross button
    
    self.crossSegmentBtn=[UIButton buttonWithType:UIButtonTypeCustom];
    [self.crossSegmentBtn setImage:[UIImage imageNamed:@"profilePicClose.png"] forState:UIControlStateNormal];
    [self.crossSegmentBtn setFrame:CGRectMake(viewCameraPreview.frame.origin.x+20, self.sliderView.frame.origin.y+self.sliderView.frame.size.height+30, 21, 19)];
    [viewCameraPreview addSubview:self.crossSegmentBtn];
    [self.crossSegmentBtn addTarget:self action:@selector(crossButtonClicked) forControlEvents:UIControlEventTouchUpInside];
    [self.crossSegmentBtn setHidden:YES];
    
    
    // adding tap gesture
    
//    UITapGestureRecognizer *capturePhotoGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapToStillPictureGesture)];
//
//    capturePhotoGesture.numberOfTapsRequired = 1;
//    [self.vertSlider addGestureRecognizer:capturePhotoGesture];
}

#pragma mark- done video button method

-(void)animatedGIFFIle:(NSURL *)gifURL {
    
    //NSURL *url = [[NSBundle mainBundle] URLForResource:@"Logo_Spinner" withExtension:@"gif"];
    
    UIImageView *animatingImageView=[[UIImageView alloc] initWithFrame:CGRectMake(0, 50, [UIScreen mainScreen].bounds.size.width,  [UIScreen mainScreen].bounds.size.height)];
    [self.view addSubview:animatingImageView];
     
    animatingImageView.image  = [UIImage animatedImageWithAnimatedGIFURL:gifURL];
}

#pragma mark- delegate method for RSSlider View

-(void)tapToStillPictureGesture {//:(UITapGestureRecognizer*)sender {
    
    [self _setupForStillImage];
    [self setUpCameraPreviewForPhoto];
//    [self btnCameraTap:nil];
    //if([[PBJVision sharedInstance] canCapturePhoto])
        [[PBJVision sharedInstance] capturePhoto];
}

#pragma mark- method for handling switch to toggle button clicked

//-(IBAction)switchToToggleButtonClicked:(id)sender {
//
//    NSLog(@"******switchToToggleButtonClicked******* %f",self.switchToToggle.value);
//
//    if(self.switchToToggle.value>0.5) {
//
//        if(!self.startRecordingFlag) {
//            [self startVideoRecording];
//            self.startRecordingFlag=YES;
//        }
//        [self methodForProgressBar];
//    }
//}

#pragma mark- method for playing video for 7 sec


-(void) methodForProgressBar {
    
    self.videoDuration+=1;
    [self performSelector:@selector(progressBarValueChanged) withObject:nil afterDelay:1.0];
}

/* Delegate method */

#pragma mark - PBJVisionDelegate

/////////////////////////


- (void)vision:(PBJVision *)vision capturedPhoto:(NSDictionary *)photoDict error:(NSError *)error
{
    if (error) {
        // handle error properly
        return;
    }
    NSDictionary *_currentPhoto = photoDict;
    
    // pointers for the appropriate photo information
    NSData *photoData = _currentPhoto[PBJVisionPhotoJPEGKey];
    NSDictionary *metadata = _currentPhoto[PBJVisionPhotoMetadataKey];
    
    // create an album
    __block PHObjectPlaceholder *album;
    [[PHPhotoLibrary sharedPhotoLibrary] performChanges:^{
        PHAssetCollectionChangeRequest *changeRequest = [PHAssetCollectionChangeRequest creationRequestForAssetCollectionWithTitle:PBJViewControllerPhotoAlbum];
        album = changeRequest.placeholderForCreatedAssetCollection;
    } completionHandler:^(BOOL success1, NSError *error1) {
        if (success1) {
            PHFetchResult *fetchResult = [PHAssetCollection fetchAssetCollectionsWithLocalIdentifiers:@[album.localIdentifier] options:nil];
            PHAssetCollection *assetCollection = fetchResult.firstObject;
            
            // add image with metadata to the album
            [[PHPhotoLibrary sharedPhotoLibrary] performChanges:^{
                UIImage *photoImage = [UIImage imageWithData:[UIImage writeMetadataIntoImageData:photoData metadata:metadata]] ;
                PHAssetChangeRequest *assetChangeRequest = [PHAssetChangeRequest creationRequestForAssetFromImage:photoImage];
                PHAssetCollectionChangeRequest *assetCollectionChangeRequest = [PHAssetCollectionChangeRequest changeRequestForAssetCollection:assetCollection];
                [assetCollectionChangeRequest addAssets:@[[assetChangeRequest placeholderForCreatedAsset]]];
            } completionHandler:^(BOOL success2, NSError *error2) {
                if (success2) {
                    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Photo Saved!" message:@"Saved to the camera roll." preferredStyle:UIAlertControllerStyleAlert];
                    UIAlertAction *ok = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil];
                    [alertController addAction:ok];
                    [self presentViewController:alertController animated:YES completion:nil];
                }
            }];
        } else if (error1) {
            NSLog(@"error: %@", error1);
        }
    }];
    
    _currentPhoto = nil;
}



- (void)visionDidEndVideoCapture:(PBJVision *)vision {
    
    NSLog(@"vision------>%@",vision);
    
}


-(void)viewWillAppear:(BOOL)animated
{
    //[self _setup];
    [[PBJVision sharedInstance] startPreview];
    //  [self addNotificationCenter];
}

-(void)viewDidAppear:(BOOL)animated
{
    //    AppHelper* apHelper = [[AppHelper alloc] init];
    //    [apHelper AddToMainView:self];
    //    [AppHelper addSwipeDownGesture:self];
    
    //Reseting Print Screen
    viewCameraPreview.hidden = NO;
    
    [self doAutoSave:nil];
    [super viewDidAppear:animated];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [self removeNotificationCenter];
    if (self.isMovingFromParentViewController || self.isBeingDismissed)
    {
        imgvComic.image = nil;
        imgvComic = nil;
        
        self.ImgvComic2.image = nil;
        self.ImgvComic2 = nil;
        
        if ([[NSUserDefaults standardUserDefaults] boolForKey:kIsUserEnterFirstTimeComicMaking] == YES) {
            //    // user firsttime enter
            [[NSUserDefaults standardUserDefaults] setBool:YES forKey:kIsUserEnterSecondTimeComicMaking];
            [[NSUserDefaults standardUserDefaults] synchronize];
        }
        
        
        //    // user firsttime enter
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:kIsUserEnterFirstTimeComicMaking];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
}

- (void)viewDidUnload {
    [super viewDidUnload];
}

#pragma mark - ZoomTransitionProtocol

-(UIView *)viewForZoomTransition:(BOOL)isSource
{
    //    return imgvComic;
    //    return  imgvComic;
    UIView *newView = (isSlideShrink ? self.ImgvComic2: imgvComic);
    /*if (haveAnimationOnPage)
     {
     [newView addSubview:refAnimatedSticker];
     [newView bringSubviewToFront:refAnimatedSticker];
     
     }*/
    return newView;
}

#pragma mark - ComicCrop Methods
- (void)addComicCropViewWithImage:(UIImage *)image
{
    if (comicCropView != nil)
    {
        [comicCropView removeFromSuperview];
    }
    
    comicCropView  = [[ComicCropView alloc] initWithFrame:self.view.frame];
    if (image != nil)
    {
        comicCropView.image = image;
        
    }
    comicCropView.delegate = self;
    [self.view insertSubview:comicCropView belowSubview:viewRowButtons];
}

- (void)removeComicCropView
{
    [comicCropView removeFromSuperview];
}

- (void)updateComicCropFrame:(CGRect)frame
{
    comicCropView.frame = frame;
    
    [comicCropView updateAllFrames];
}

#pragma mark - ComicCropViewDelegate Methods
- (void)didTapOnComicCropView:(ComicCropView *)view
{
    if (isCameraOn == NO)
    {
        UIImage *cropimage = [comicCropView outputImage];
        imgvComic.image = cropimage;
        
        [self doAutoSave:nil];
        
        
        [self removeComicCropView];
        
        RowButtonsViewController *rowButtonsController;
        
        for (UIViewController *controller in self.childViewControllers)
        {
            if ([controller isKindOfClass:[RowButtonsViewController class]])
            {
                rowButtonsController = (RowButtonsViewController *)controller;
            }
        }
        
        rowButtonsController.btnCamera.selected = YES;
        [rowButtonsController allButtonsFadeIn:rowButtonsController.btnCamera];
        
        [self setComicImageViewSize];
        [self doAutoSave:nil];
        
        //dinesh
        [self.mSendComicButton setHidden:NO];
    }
}

#pragma mark - UIView Methods

- (void)prepareView
{
    dispatch_queue_t sessionQueue = dispatch_queue_create("session queue", DISPATCH_QUEUE_SERIAL);
    [self setSessionQueue:sessionQueue];
    
#if !TARGET_OS_SIMULATOR
    //[self prepareCameraView];
    //[self performSelector:@selector(prepareCameraView) withObject:nil afterDelay:5.0];
#endif
    [self prepareForSlide];
    
    [UIView animateWithDuration:0.4 animations:^{
        viewRowButtons.alpha = 1;
    }];
    
    [self.rowButton viewDidLoad];
}

- (void)addPinchGesture
{
    pinchGesture = [[UIPinchGestureRecognizer alloc]initWithTarget:self action:@selector(pinchDone:)];
    viewCameraPreview.userInteractionEnabled = YES;
    [viewCameraPreview addGestureRecognizer:pinchGesture];
}

-(void)prepareForSlide{
    
    //To check if imgvComic frame is correct or not
    //if not reset it back
    if (temImagFrame.size.width > 0 && temImagFrame.size.height > 0) {
        imgvComic.frame = temImagFrame;
    }
    
    viewFrame = imgvComic.frame;
    
    //Assiginig the frame to temp
    temImagFrame = imgvComic.frame;
    //    temButtonFrame = viewRowButtons.frame;
    //    temChatButtonFrame = self.chatIcon.frame;
    //    temUploadButtonFrame = self.uploadIcon.frame;
    
    shrinkHeight = viewFrame.size.height - ( viewFrame.size.height / 12);
    
    CGRect rect =   viewStickerList.frame;
    rect.origin.x   =   viewStickerList.frame.size.width;
    viewStickerList.frame   =   rect;
    
    CGRect rect1    =   _chatIcon.frame;
    rect1.origin.y  =   rect1.origin.y + _chatIcon.frame.size.height;
    _chatIcon.frame =   rect1;
    
    //Bubles
    CGRect rect_bubble =   bubbleListView.frame;
    rect_bubble.origin.x   =   bubbleListView.frame.size.width;
    bubbleListView.frame   =   rect_bubble;
    
    //exclamation
    CGRect rect_exclamation =   exclamationListView.frame;
    rect_exclamation.origin.x   =   exclamationListView.frame.size.width;
    exclamationListView.frame   =   rect_exclamation;
    exclamationLeftConstaint.constant = exclamationListView.frame.size.width;

    
    CGRect frame = viewDrawing.frame;
    frame.origin.x = CGRectGetMaxX(self.view.frame);
    viewDrawing.frame = frame;
    viewDrawing.alpha = 0;
    [viewDrawing setBackgroundColor:[UIColor clearColor]];
    //    RowButtonsViewController *rowButton;
    
    CGRect frameViewBlackboard = viewBlackBoard.frame;
    frameViewBlackboard.origin.x = CGRectGetMaxX(self.view.frame);
    viewBlackBoard.frame = frameViewBlackboard;
    viewBlackBoard.alpha = 0;
    
    
    
    for (UIViewController *controller in self.childViewControllers)
    {
        if ([controller isKindOfClass:[RowButtonsViewController class]])
        {
            self.rowButton = (RowButtonsViewController *)controller;
            
        }
    }
    
    if (isNewSlide)
    {
        imgvComic.hidden = YES;
        btnClose.hidden = YES;
        btnCloseComic.hidden = YES;
        self.rowButton.isNewSlide = YES;
        [self.btnSend setEnabled:NO];
        
        [[GoogleAnalytics sharedGoogleAnalytics] logUserEvent:@"SlideCreate" Action:@"Create" Label:@""];
        
        if ([[NSUserDefaults standardUserDefaults] boolForKey:kIsUserEnterFirstTimeComicMaking] == YES)
        {
            // open slide 11 Instruction
            dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0 * NSEC_PER_SEC));
            dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
                NSLog(@"Do some work");
                
                if ([InstructionView getBoolValueForSlide:kInstructionSlide15] == NO)
                {
                    InstructionView *instView = [[InstructionView alloc] initWithFrame:self.view.bounds];
                    instView.delegate = self;
                    [instView showInstructionWithSlideNumber:SlideNumber15 withType:InstructionBubbleType];
                    [instView setTrueForSlide:kInstructionSlide15];
                    
                    [self.view addSubview:instView];
                }
            });
            
            
            //second time user enter in comicmaking
        }
    }
    else
    {
        imgvComic.hidden = NO;
        btnClose.hidden = NO;
        btnCloseComic.hidden = NO;
        viewCamera.hidden = YES;
        [self.mSendComicButton setHidden:NO];//dinesh
        self.rowButton.isNewSlide = NO;
        
        imgvComic.image = [AppHelper getImageFile:comicPage.containerImagePath]; //[UIImage imageWithData:comicPage.containerImage];
        
        //        NSLog(@"************* SUBVIEW ***************");
        //        NSLog(@"%@",comicPage.subviews);
        //        NSLog(@"************* SUBVIEW ***************");
        
        if ([comicPage.slideType isEqualToString:slideTypeWide])
        {
            isWideSlide = YES;
        }
        else
        {
            isWideSlide = NO;
        }
        
        for (int i = 0; i < comicPage.subviews.count; i ++)
        {
            id imageView = comicPage.subviews[i];
            CGRect myRect = [comicPage.subviewData[i] CGRectValue];
            CGAffineTransform tt;
            NSString* strTrasformValue = nil;
            if ([comicPage.subviewTranformData count] > i) {
                strTrasformValue = comicPage.subviewTranformData[i];
                tt = [comicPage.subviewTranformData[i] CGAffineTransformValue];
            }
            [self addComicItem:imageView ItemImage:nil rectValue:myRect TranformData:tt];
        }
    }
}

- (void)addImageViewWithView:(UIView*)view
{
    //Handle BubbleView
    if ([view isKindOfClass:[BubbleViewItem class]])
    {
        view.clipsToBounds = NO;
        view.cagingArea = self.view.frame;
        [view enableDragging:10];
        
        [view setdraggingClosedBlock:^{
            [self closeBubbleImage:view];
        }];
        
        [view setDraggingEndedBlock:^
         {
             [self changeBubbleTail:view imageName:@""];
         }];
        
        //Adding Long Press event
        UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(handleLongPressBubbleGestures:)];
        longPress.minimumPressDuration = 0.5f;
        [view addGestureRecognizer:longPress];
        
        UIPinchGestureRecognizer *pinchRecognizer = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(handlePinchGesture:)];
        [pinchRecognizer setDelegate:self];
        [view addGestureRecognizer:pinchRecognizer];
        
        [imgvComic addSubview:view];
    }
    else
    {
        //Normal View
        
        [view setDraggable:YES];
        
        [imgvComic addSubview:view];
    }
    
}

//Ramesh
/*
 To Prepare voie view
 */
-(void)prepareVoiceView{
    
    CGRect rect=_voiceView.frame;
    rect.origin.x=rect.origin.x-_voiceView.frame.size.width;
    _voiceView.frame=rect;
}
-(void)prepareCaptionView{
    
    captionTextColourArray = [[NSArray alloc] initWithObjects:@"2E3192",@"73CDDA",@"AED136",@"F15A29",@"BE1E2D",@"006838", nil];
}
-(void)openComicEditMode:(BOOL)isAddnew{
    [self.glideViewHolder setHidden:YES];
    
    //Removing subviews
    for (UIView* temView in [imgvComic subviews]) {
        [temView removeFromSuperview];
    }
    
    isNewSlide = isAddnew;
    //    [self prepareForSlide];
    
    //Just Reseting the Row buttons
    if (isNewSlide) {
        self.rowButton.btnCamera.selected = NO;
        //        [self.rowButton viewDidLoad];
        [self.rowButton allButtonsFadeOut:self.rowButton.btnCamera];
    }
    
    viewStickerList.alpha = 0;
    btnClose.alpha = 1;
    btnCloseComic.alpha = 1;
    viewRowButtons.alpha = 1;
    self.chatIcon.alpha = 0;
    self.uploadIcon.alpha = 1;
    
    //Resetting Bottom Buttons
    [self prepareForSlide];
    [self addNotificationCenter];
    
    //    if (isNewSlide) {
    //        [UIView animateWithDuration:0.4 animations:^{
    //            viewRowButtons.alpha = 1;
    //        }];
    
    //
    //    }
}
-(void)prepareGlideView{
    
    //    GlideScrollViewController *glideScrollView;
    
    for (UIViewController *controller in self.childViewControllers)
    {
        if ([controller isKindOfClass:[GlideScrollViewController class]])
        {
            self.glideScrollView = (GlideScrollViewController *)controller;
        }
    }
    
}
//End
- (void)prepareCameraView
{
    // Create the AVCaptureSession
    
    [self addPinchGesture];
    
    AVCaptureSession *session = [[AVCaptureSession alloc] init];
    //  AVCaptureSession *session =[PBJVision sharedInstance]._captureSession;
    
    
    
    [self setSession:session];
    
    
    
    //[self addNotificationCenter];
    // Setup the preview view
    // [viewCameraPreview setSession:session];//[PBJVision sharedInstance]._captureSession];
    
    
    
    //[viewCameraPreview setSession:session];
    // [[PBJVision sharedInstance] startPreview];
    
    
    
    // Check for device authorization
    [self checkDeviceAuthorizationStatus];
    
    dispatch_async([self sessionQueue], ^{
        
        
        [self setBackgroundRecordingID:UIBackgroundTaskInvalid];
        
        NSError *error = nil;
        
        AVCaptureDevice *videoDevice = [ComicMakingViewController deviceWithMediaType:AVMediaTypeVideo preferringPosition:AVCaptureDevicePositionBack];
        
        if ([videoDevice respondsToSelector:@selector(setVideoZoomFactor:)]) {
            if ([ videoDevice lockForConfiguration:nil]) {
                float zoomFactor = videoDevice.activeFormat.videoZoomFactorUpscaleThreshold;
                [videoDevice setVideoZoomFactor:zoomFactor];
                [videoDevice unlockForConfiguration];
            }
        }
        
        //        [videoDevice setVideoZoomFactor:[DefaultZoomFactor floatValue]];
        //        videoDevice.videoZoomFactor = 2.0f;
        AVCaptureDeviceInput *videoDeviceInput = [AVCaptureDeviceInput deviceInputWithDevice:videoDevice error:&error];
        
        if (error)
        {
            NSLog(@"%@", error);
        }
        
        if ([session canAddInput:videoDeviceInput])
        {
            [session addInput:videoDeviceInput];
            [self setVideoDeviceInput:videoDeviceInput];
            
            dispatch_async(dispatch_get_main_queue(), ^{
                // Why are we dispatching this to the main queue?
                // Because AVCaptureVideoPreviewLayer is the backing layer for AVCamPreviewView and UIView can only be manipulated on main thread.
                // Note: As an exception to the above rule, it is not necessary to serialize video orientation changes on the AVCaptureVideoPreviewLayer’s connection with other session manipulation.
                
                [[(AVCaptureVideoPreviewLayer *)[viewCameraPreview layer] connection] setVideoOrientation:(AVCaptureVideoOrientation)[self interfaceOrientation]];
            });
        }
        
        AVCaptureDevice *audioDevice = [[AVCaptureDevice devicesWithMediaType:AVMediaTypeAudio] firstObject];
        AVCaptureDeviceInput *audioDeviceInput = [AVCaptureDeviceInput deviceInputWithDevice:audioDevice error:&error];
        
        if (error)
        {
            NSLog(@"%@", error);
        }
        
        if ([session canAddInput:audioDeviceInput])
        {
            [session addInput:audioDeviceInput];
        }
        
        /*AVCaptureMovieFileOutput *movieFileOutput = [[AVCaptureMovieFileOutput alloc] init];
         
         if ([session canAddOutput:movieFileOutput])
         {
         [session addOutput:movieFileOutput];
         
         AVCaptureConnection *connection = [movieFileOutput connectionWithMediaType:AVMediaTypeVideo];
         if ([connection isVideoStabilizationSupported])
         [connection setEnablesVideoStabilizationWhenAvailable:YES];
         
         [self setMovieFileOutput:movieFileOutput];
         }*/
        
        AVCaptureStillImageOutput *stillImageOutput = [[AVCaptureStillImageOutput alloc] init];
        if ([session canAddOutput:stillImageOutput])
        {
            [stillImageOutput setOutputSettings:@{AVVideoCodecKey : AVVideoCodecJPEG}];
            
            [session addOutput:stillImageOutput];
            
            [self setStillImageOutput:stillImageOutput];
        }
    });
    
}

#pragma mark - NotificationCenter

-(void)addNotificationCenter{
    
    dispatch_async([self sessionQueue], ^
                   {
                       [self addObserver:self forKeyPath:@"sessionRunningAndDeviceAuthorized" options:(NSKeyValueObservingOptionOld | NSKeyValueObservingOptionNew) context:SessionRunningAndDeviceAuthorizedContext];
                       [self addObserver:self forKeyPath:@"stillImageOutput.capturingStillImage" options:(NSKeyValueObservingOptionOld | NSKeyValueObservingOptionNew) context:CapturingStillImageContext];
                       [self addObserver:self forKeyPath:@"movieFileOutput.recording" options:(NSKeyValueObservingOptionOld | NSKeyValueObservingOptionNew) context:RecordingContext];
                       //   [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(subjectAreaDidChange:) name:AVCaptureDeviceSubjectAreaDidChangeNotification object:[[self videoDeviceInput] device]];
                       
                       __weak ComicMakingViewController *weakSelf = self;
                       
                       [self setRuntimeErrorHandlingObserver:[[NSNotificationCenter defaultCenter] addObserverForName:AVCaptureSessionRuntimeErrorNotification object:[self session] queue:nil usingBlock:^(NSNotification *note) {
                           ComicMakingViewController *strongSelf = weakSelf;
                           dispatch_async([strongSelf sessionQueue], ^{
                               // Manually restarting the session since it must have been stopped due to an error.
                               [[strongSelf session] startRunning];
                           });
                           
                       }]];
                       
                       [[self session] startRunning];
                       //                       if([[PBJVision sharedInstance]._captureSession isRunning]) {
                       //
                       //                           [[PBJVision sharedInstance]._captureSession commitConfiguration];
                       //                           [[PBJVision sharedInstance]._captureSession stopRunning];
                       //                           [[PBJVision sharedInstance]._captureSession startRunning];
                       //                       }
                       //                       else {
                       //                           [[PBJVision sharedInstance]._captureSession commitConfiguration];
                       //                           [[PBJVision sharedInstance]._captureSession startRunning];
                       //                       }
                       
                   });
    
}

-(void)removeNotificationCenter{
    
    dispatch_async([self sessionQueue], ^{
        [[self session] stopRunning];
        
        [[NSNotificationCenter defaultCenter] removeObserver:self name:AVCaptureDeviceSubjectAreaDidChangeNotification object:[[self videoDeviceInput] device]];
        [[NSNotificationCenter defaultCenter] removeObserver:[self runtimeErrorHandlingObserver]];
        
        //        [self removeObserver:self forKeyPath:@"sessionRunningAndDeviceAuthorized" context:SessionRunningAndDeviceAuthorizedContext];
        //        [self removeObserver:self forKeyPath:@"stillImageOutput.capturingStillImage" context:CapturingStillImageContext];
        //        [self removeObserver:self forKeyPath:@"movieFileOutput.recording" context:RecordingContext];
    });
}

#pragma mark - Camera Methods
- (BOOL)isSessionRunningAndDeviceAuthorized
{
    return [[self session] isRunning] && [self isDeviceAuthorized];
}

+ (NSSet *)keyPathsForValuesAffectingSessionRunningAndDeviceAuthorized
{
    return [NSSet setWithObjects:@"session.running", @"deviceAuthorized", nil];
}


- (BOOL)prefersStatusBarHidden
{
    return YES;
}

- (BOOL)shouldAutorotate
{
    // Disable autorotation of the interface when recording is in progress.
    return ![self lockInterfaceRotation];
}

- (NSUInteger)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskAll;
}

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    [[(AVCaptureVideoPreviewLayer *)[viewCameraPreview layer] connection] setVideoOrientation:(AVCaptureVideoOrientation)toInterfaceOrientation];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    
    //    UITextView *tv = object;
    //    CGFloat topCorrect = ([tv bounds].size.height - [tv contentSize].height * [tv zoomScale])/2.0;
    //    topCorrect = ( topCorrect < 0.0 ? 0.0 : topCorrect );
    //    tv.contentOffset = (CGPoint){.x = 0, .y = -topCorrect};
    
    if (context == CapturingStillImageContext)
    {
        BOOL isCapturingStillImage = [change[NSKeyValueChangeNewKey] boolValue];
        
        if (isCapturingStillImage)
        {
            [self runStillImageCaptureAnimation];
        }
    }
    else if (context == SessionRunningAndDeviceAuthorizedContext)
    {
        BOOL isRunning = [change[NSKeyValueChangeNewKey] boolValue];
    }
    else if ([object isKindOfClass:[UITextView class]])
    {
        UITextView *tv = object;
        CGFloat topCorrect = ([tv bounds].size.height - [tv contentSize].height * [tv zoomScale])/2.0;
        topCorrect = ( topCorrect < 0.0 ? 0.0 : topCorrect );
        tv.contentOffset = (CGPoint){.x = 0, .y = -topCorrect};
    }
    else
    {
        
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    }
}
- (void)subjectAreaDidChange:(NSNotification *)notification
{
    CGPoint devicePoint = CGPointMake(.5, .5);
    
    [self focusWithMode:AVCaptureFocusModeContinuousAutoFocus exposeWithMode:AVCaptureExposureModeContinuousAutoExposure atDevicePoint:devicePoint monitorSubjectAreaChange:NO];
}

#pragma mark - Camera File Output Delegate
- (void)captureOutput:(AVCaptureFileOutput *)captureOutput didFinishRecordingToOutputFileAtURL:(NSURL *)outputFileURL fromConnections:(NSArray *)connections error:(NSError *)error
{
    if (error)
        NSLog(@"%@", error);
    
    [self setLockInterfaceRotation:NO];
    
    // Note the backgroundRecordingID for use in the ALAssetsLibrary completion handler to end the background task associated with this recording. This allows a new recording to be started, associated with a new UIBackgroundTaskIdentifier, once the movie file output's -isRecording is back to NO — which happens sometime after this method returns.
    UIBackgroundTaskIdentifier backgroundRecordingID = [self backgroundRecordingID];
    [self setBackgroundRecordingID:UIBackgroundTaskInvalid];
    
    [[[ALAssetsLibrary alloc] init] writeVideoAtPathToSavedPhotosAlbum:outputFileURL completionBlock:^(NSURL *assetURL, NSError *error)
     {
         if (error)
             NSLog(@"%@", error);
         
         [[NSFileManager defaultManager] removeItemAtURL:outputFileURL error:nil];
         
         if (backgroundRecordingID != UIBackgroundTaskInvalid)
             [[UIApplication sharedApplication] endBackgroundTask:backgroundRecordingID];
     }];
}

#pragma mark - Camera Device Configuration

- (void)focusWithMode:(AVCaptureFocusMode)focusMode exposeWithMode:(AVCaptureExposureMode)exposureMode atDevicePoint:(CGPoint)point monitorSubjectAreaChange:(BOOL)monitorSubjectAreaChange
{
    dispatch_async([self sessionQueue], ^{
        AVCaptureDevice *device = [[self videoDeviceInput] device];
        NSError *error = nil;
        if ([device lockForConfiguration:&error])
        {
            if ([device isFocusPointOfInterestSupported] && [device isFocusModeSupported:focusMode])
            {
                [device setFocusMode:focusMode];
                [device setFocusPointOfInterest:point];
            }
            if ([device isExposurePointOfInterestSupported] && [device isExposureModeSupported:exposureMode])
            {
                [device setExposureMode:exposureMode];
                [device setExposurePointOfInterest:point];
            }
            [device setSubjectAreaChangeMonitoringEnabled:monitorSubjectAreaChange];
            [device unlockForConfiguration];
        }
        else
        {
            NSLog(@"%@", error);
        }
    });
}

+ (void)setFlashMode:(AVCaptureFlashMode)flashMode forDevice:(AVCaptureDevice *)device
{
    if ([device hasFlash] && [device isFlashModeSupported:flashMode])
    {
        NSError *error = nil;
        if ([device lockForConfiguration:&error])
        {
            [device setFlashMode:flashMode];
            [device unlockForConfiguration];
        }
        else
        {
            NSLog(@"%@", error);
        }
    }
}

+ (AVCaptureDevice *)deviceWithMediaType:(NSString *)mediaType preferringPosition:(AVCaptureDevicePosition)position
{
    NSArray *devices = [AVCaptureDevice devicesWithMediaType:mediaType];
    AVCaptureDevice *captureDevice = [devices firstObject];
    
    for (AVCaptureDevice *device in devices)
    {
        if ([device position] == position)
        {
            captureDevice = device;
            break;
        }
    }
    
    return captureDevice;
}



#pragma mark - Camera UI
- (IBAction)pinchDone:(UIPinchGestureRecognizer *)gestureRecognizer
{
    if([gestureRecognizer state] == UIGestureRecognizerStateBegan)
    {
        // Reset the last scale, necessary if there are multiple objects with different scales
        lastScale = [gestureRecognizer scale];
    }
    
    if ([gestureRecognizer state] == UIGestureRecognizerStateBegan ||
        
        [gestureRecognizer state] == UIGestureRecognizerStateChanged)
    {
        
        CGFloat currentScale = [[[gestureRecognizer view].layer valueForKeyPath:@"transform.scale"] floatValue];
        
        // Constants to adjust the max/min values of zoom
        const CGFloat kMaxScale = 2.0;
        const CGFloat kMinScale = 1.0;
        
        CGFloat newScale = 1 -  (lastScale - [gestureRecognizer scale]);
        
        newScale = MIN(newScale, kMaxScale / currentScale);
        newScale = MAX(newScale, kMinScale / currentScale);
        
        CGAffineTransform transform = CGAffineTransformScale([[gestureRecognizer view] transform], newScale, newScale);
        
        [gestureRecognizer view].transform = transform;
        
        lastScale = [gestureRecognizer scale];  // Store the previous scale factor for the next pinch gesture call
    }
}

- (void)runStillImageCaptureAnimation
{
    dispatch_async(dispatch_get_main_queue(), ^
                   {
                       [[viewCameraPreview layer] setOpacity:0.0];
                       
                       [UIView animateWithDuration:.25 animations:^{
                           [[viewCameraPreview layer] setOpacity:1.0];
                       }];
                   });
}

- (void)checkDeviceAuthorizationStatus
{
    NSString *mediaType = AVMediaTypeVideo;
    
    [AVCaptureDevice requestAccessForMediaType:mediaType completionHandler:^(BOOL granted) {
        if (granted)
        {
            //Granted access to mediaType
            [self setDeviceAuthorized:YES];
        }
        else
        {
            //Not granted access to mediaType
            dispatch_async(dispatch_get_main_queue(), ^{
                [[[UIAlertView alloc] initWithTitle:@"AVCam!"
                                            message:@"AVCam doesn't have permission to use Camera, please change privacy settings"
                                           delegate:self
                                  cancelButtonTitle:@"OK"
                                  otherButtonTitles:nil] show];
                [self setDeviceAuthorized:NO];
            });
        }
    }];
}

#pragma mark - Close Camera Event
- (IBAction)closeCamera:(id)sender
{
    JTAlertView *alertView = [self showAlertView:@"Do you want take another Picture" image:nil height:200];
    
    [alertView addButtonWithTitle:@"CANCEL" style:JTAlertViewStyleDefault action:^(JTAlertView *alertView)
     {
         [alertView hide];
     }];
    
    [alertView addButtonWithTitle:@"OK" style:JTAlertViewStyleDestructive action:^(JTAlertView *alertView)
     {
         [alertView hideWithCompletion:^{
             
             CABasicAnimation *rotate =
             [CABasicAnimation animationWithKeyPath:@"transform.rotation"];
             rotate.byValue = @(M_PI); // Change to - angle for counter clockwise rotation
             rotate.duration = 0.5;
             
             [btnClose.layer addAnimation:rotate
                                   forKey:@"myRotationAnimation"];
             
             dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                 [self closeCamera];
                 
                 RowButtonsViewController *rowButtonsController;
                 
                 for (UIViewController *controller in self.childViewControllers)
                 {
                     if ([controller isKindOfClass:[RowButtonsViewController class]])
                     {
                         rowButtonsController = (RowButtonsViewController *)controller;
                     }
                 }
                 
                 rowButtonsController.btnCamera.selected = NO;
                 
                 [rowButtonsController allButtonsFadeOut:rowButtonsController.btnCamera];
                 
                 
                 [self doRemoveAllItem:nil];
                 [self.btnSend setEnabled:NO];
             });
             
             
             
             //             imgvComic.hidden=NO;
             //             [UIView transitionWithView:btnClose
             //                               duration:0.5
             //                                options:UIViewAnimationOptionTransitionFlipFromTop
             //                             animations:^{
             //
             //                             } completion:^(BOOL finished) {
             //                                 [self closeCamera];
             //
             //                                 RowButtonsViewController *rowButtonsController;
             //
             //                                 for (UIViewController *controller in self.childViewControllers)
             //                                 {
             //                                     if ([controller isKindOfClass:[RowButtonsViewController class]])
             //                                     {
             //                                         rowButtonsController = (RowButtonsViewController *)controller;
             //                                     }
             //                                 }
             //
             //                                 rowButtonsController.btnCamera.selected = NO;
             //
             //                                 [rowButtonsController allButtonsFadeOut:rowButtonsController.btnCamera];
             //
             //
             //                                 [self doRemoveAllItem:nil];
             //                             }];
             //
             
             
             //             viewCamera.hidden=YES;
             //             [UIView transitionWithView:viewCamera
             //                               duration:0.5
             //                                options:UIViewAnimationOptionTransitionFlipFromLeft
             //                             animations:^{
             //                                 viewCamera.hidden=NO;
             //                             } completion:^(BOOL finished) {
             //                                 [self closeCamera];
             //
             //                                 RowButtonsViewController *rowButtonsController;
             //
             //                                 for (UIViewController *controller in self.childViewControllers)
             //                                 {
             //                                     if ([controller isKindOfClass:[RowButtonsViewController class]])
             //                                     {
             //                                         rowButtonsController = (RowButtonsViewController *)controller;
             //                                     }
             //                                 }
             //
             //                                 rowButtonsController.btnCamera.selected = NO;
             //
             //                                 [rowButtonsController allButtonsFadeOut:rowButtonsController.btnCamera];
             //
             //
             //                                 [self doRemoveAllItem:nil];
             //                             }];
             
             
             
             
             
             
             
         } animated:NO];
         
         
         
     }];
    
    [alertView show];
}

- (void)closeCamera
{
    [[imgvComic subviews] makeObjectsPerformSelector:@selector(removeFromSuperview)];
    
    imgvComic.image = nil;
    imgvComic.hidden = YES;
    imgvComic.frame =  frameImgvComic;
    viewCamera.hidden = NO;
    [self.mSendComicButton setHidden:YES];//dinesh
    btnClose.hidden = YES;
    btnCloseComic.hidden = YES;
    GlobalObject.isTakePhoto = NO;
    isCameraOn = YES;
    
    if (isWideSlide)
    {
        [self addComicCropViewWithImage:nil];
        
    }
    
}

- (IBAction)btnCloseComicTap:(id)sender
{
    CGFloat height = [self getGlideItemHight];
    CGFloat width = [self getGlideItemWidth];
    
    CGFloat x = self.view.frame.size.width /2 - width/2 ;
    CGFloat y =  (self.view.frame.size.height /2 - height/2) + height/10 ;
    
    [self.view exchangeSubviewAtIndex:0 withSubviewAtIndex:1];
    //        imgvComic.autoresizesSubviews = YES;
    for (UIView* subview in [imgvComic subviews]) {
        subview.autoresizingMask = UIViewAutoresizingNone;
    }
    
    self.ImgvComic2.image = printScreen;
    
    isSlideShrink = YES;
    
    //Ramesh ****** Start ****
    if (isWideSlide == YES)
    {
        UIImageView *cropImageView = [[UIImageView alloc] initWithFrame:temImagFrame];
        cropImageView.image = printScreen;
        cropImageView.contentMode = UIViewContentModeScaleAspectFit;
        
        //CGPoint center  = [self.view convertPoint:self.view.center fromView:parent.superview];
        
        CGFloat y = (CGRectGetMaxY(temImagFrame) - CGRectGetMinY(temImagFrame)) / 2;
        
        CGRect cropframe = CGRectMake(0, y - (wideBoxHeight / 2), temImagFrame.size.width, wideBoxHeight);
        
        UIImage *image = [self croppedImage:printScreen withImageView:cropImageView WithFrame:cropframe];
        
        printScreen = image;
        
        NSLog(@"cropped");
    }
    
    [self.delegate comicMakingViewControllerWithEditingDone:self
                                              withImageView:imgvComic
                                            withPrintScreen:printScreen
                                               gifLayerPath:self.gifLayerPath
                                               withNewSlide:isNewSlide
                                                withPopView:YES withIsWideSlide:isWideSlide];
    
    //Ramesh ****** End ****
    //Ramesh commented Adnan's Code
    //    [UIView animateWithDuration:0.5 animations:^{
    //
    //        self.ImgvComic2.frame = CGRectMake(x, y, width, height);
    //        imgvComic.frame = self.ImgvComic2.frame;
    //
    //    }completion:^(BOOL finished) {
    //
    //
    //        if (isWideSlide == YES)
    //        {
    //            UIImageView *cropImageView = [[UIImageView alloc] initWithFrame:temImagFrame];
    //            cropImageView.image = printScreen;
    //            cropImageView.contentMode = UIViewContentModeScaleAspectFit;
    //
    //            //CGPoint center  = [self.view convertPoint:self.view.center fromView:parent.superview];
    //
    //            CGFloat y = (CGRectGetMaxY(temImagFrame) - CGRectGetMinY(temImagFrame)) / 2;
    //
    //            CGRect cropframe = CGRectMake(0, y - (wideBoxHeight / 2), temImagFrame.size.width, wideBoxHeight);
    //
    //            UIImage *image = [self croppedImage:printScreen withImageView:cropImageView WithFrame:cropframe];
    //
    //            printScreen = image;
    //
    //            NSLog(@"cropped");
    //        }
    //
    //        [self.delegate comicMakingViewControllerWithEditingDone:self
    //                                                  withImageView:imgvComic
    //                                                withPrintScreen:printScreen
    //                                                   withNewSlide:isNewSlide
    //                                                    withPopView:YES withIsWideSlide:isWideSlide];
    //    }];
    
}

#pragma mark - Camera Events
- (IBAction)btnCameraReverseTap:(id)sender
{
    [UIView transitionWithView:viewCamera
                      duration:0.5
                       options:UIViewAnimationOptionTransitionFlipFromLeft
                    animations:^{
                        
                        dispatch_async([self sessionQueue], ^{
                            AVCaptureDevice *currentVideoDevice = [[self videoDeviceInput] device];
                            AVCaptureDevicePosition preferredPosition = AVCaptureDevicePositionUnspecified;
                            AVCaptureDevicePosition currentPosition = [currentVideoDevice position];
                            
                            switch (currentPosition)
                            {
                                case AVCaptureDevicePositionUnspecified:
                                    preferredPosition = AVCaptureDevicePositionBack;
                                    break;
                                case AVCaptureDevicePositionBack:
                                    preferredPosition = AVCaptureDevicePositionFront;
                                    break;
                                case AVCaptureDevicePositionFront:
                                    preferredPosition = AVCaptureDevicePositionBack;
                                    break;
                            }
                            
                            AVCaptureDevice *videoDevice = [ComicMakingViewController deviceWithMediaType:AVMediaTypeVideo preferringPosition:preferredPosition];
                            AVCaptureDeviceInput *videoDeviceInput = [AVCaptureDeviceInput deviceInputWithDevice:videoDevice error:nil];
                            
                            [[self session] beginConfiguration];
                            
                            [[self session] removeInput:[self videoDeviceInput]];
                            if ([[self session] canAddInput:videoDeviceInput])
                            {
                                [[NSNotificationCenter defaultCenter] removeObserver:self name:AVCaptureDeviceSubjectAreaDidChangeNotification object:currentVideoDevice];
                                
                                [ComicMakingViewController setFlashMode:AVCaptureFlashModeAuto forDevice:videoDevice];
                                [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(subjectAreaDidChange:) name:AVCaptureDeviceSubjectAreaDidChangeNotification object:videoDevice];
                                
                                [[self session] addInput:videoDeviceInput];
                                [self setVideoDeviceInput:videoDeviceInput];
                            }
                            else
                            {
                                [[self session] addInput:[self videoDeviceInput]];
                            }
                            
                            [[self session] commitConfiguration];
                            
                            dispatch_async(dispatch_get_main_queue(), ^
                                           {
                                               
                                           });
                        });
                        
                    } completion:nil];
}

- (void)btnCameraTap:(UIButton *)sender
{
    
    [self.btnSend setEnabled:YES];
#if TARGET_OS_SIMULATOR
    NSLog(@"camera tap");
    viewCamera.hidden = YES;
    [self.mSendComicButton setHidden:NO];

    [self doneVideoBtnClicked];
//    [imgvComic setImage:[UIImage imageNamed:@"cat-demo"]];
    imgvComic.hidden = NO;
    
    if (isWideSlide)
    {
        // ComicCropView code
        comicCropView.imageView = self.imgvComic;
        UIImage *cropimage = [comicCropView outputImage];
        imgvComic.image = cropimage ;
        [self removeComicCropView];
        
    }
    
    GlobalObject.isTakePhoto = YES;
    btnClose.hidden = NO;
    btnCloseComic.hidden = NO;
    [self setComicImageViewSize];
    [self doAutoSave:nil];
    
#else
    
    dispatch_async([self sessionQueue], ^{
        // Update the orientation on the still image output video connection before capturing.
        [[[self stillImageOutput] connectionWithMediaType:AVMediaTypeVideo] setVideoOrientation:[[(AVCaptureVideoPreviewLayer *)[viewCameraPreview layer] connection] videoOrientation]];
        
        // Flash set to Auto for Still Capture
        [ComicMakingViewController setFlashMode:AVCaptureFlashModeAuto forDevice:[[self videoDeviceInput] device]];
        
        // Capture a still image.
        [[self stillImageOutput] captureStillImageAsynchronouslyFromConnection:[[self stillImageOutput] connectionWithMediaType:AVMediaTypeVideo] completionHandler:^(CMSampleBufferRef imageDataSampleBuffer, NSError *error)
         {
             
             if (imageDataSampleBuffer)
             {
                 viewCamera.hidden = YES;
                 [self.mSendComicButton setHidden:NO];//dinesh
                 
                 NSData *imageData = [AVCaptureStillImageOutput jpegStillImageNSDataRepresentation:imageDataSampleBuffer];
                 
                 UIImage *image = [[UIImage alloc] initWithData:imageData];
                 
                 CGRect cropRects = [imgvComic convertRect:imgvComic.frame toView:viewCameraPreview];
                 
                 CGFloat factor = (image.size.width * image.scale) / CGRectGetWidth(self.view.frame);
                 
                 cropRects.origin.x *= factor;
                 cropRects.origin.y *= factor;
                 
                 cropRects.size.width  *= factor;
                 cropRects.size.height *= factor;
                 
                 UIImage *cropedImage = [image cropedImagewithCropRect:cropRects];
                 
                 imgvComic.image = cropedImage;
                 
                 
                 if (isWideSlide)
                 {
                     // ComicCropView code
                     comicCropView.imageView = self.imgvComic;
                     UIImage *cropimage = [comicCropView outputImage];
                     
                     imgvComic.image = cropimage ;
                     [self removeComicCropView];
                     
                 }
                 
                 
                 imgvComic.hidden = NO;
                 
                 GlobalObject.isTakePhoto = YES;
                 
                 //remove Cropview
                 
                 btnClose.hidden = NO;
                 btnCloseComic.hidden = NO;
                 [self setComicImageViewSize];
                 [self doAutoSave:nil];
                 
                 // open slide 2 Instruction
                 dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0 * NSEC_PER_SEC));
                 dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
                     NSLog(@"Do some work");
                     
                     if ([InstructionView getBoolValueForSlide:kInstructionSlide3] == NO)
                     {
                         InstructionView *instView = [[InstructionView alloc] initWithFrame:self.view.bounds];
                         instView.delegate = self;
                         [instView showInstructionWithSlideNumber:SlideNumber3 withType:InstructionBubbleType];
                         [instView setTrueForSlide:kInstructionSlide3];
                         
                         [self.view addSubview:instView];
                     }
                 });
                 
                 
                 if ([[NSUserDefaults standardUserDefaults] boolForKey:kIsUserEnterFirstTimeComicMaking] == YES)
                 {
                     
                     // open slide 12 Instruction
                     dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0 * NSEC_PER_SEC));
                     dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
                         NSLog(@"Do some work");
                         
                         if ([InstructionView getBoolValueForSlide:kInstructionSlide12repeat] == NO)
                         {
                             InstructionView *instView = [[InstructionView alloc] initWithFrame:self.view.bounds];
                             instView.delegate = self;
                             [instView showInstructionWithSlideNumber:SlideNumber12 withType:InstructionGIFType];
                             [instView setTrueForSlide:kInstructionSlide12repeat];
                             
                             [self.view addSubview:instView];
                         }
                     });
                 }
             }
         }];
    });
#endif
}

- (void)setComicImageViewSize
{
    //    float widthRatio = imgvComic.bounds.size.width / imgvComic.image.size.width;
    //    float heightRatio = imgvComic.bounds.size.height / imgvComic.image.size.height;
    //    float scale = MIN(widthRatio, heightRatio);
    //    float imageWidth = scale * imgvComic.image.size.width;
    //    float imageHeight = scale * imgvComic.image.size.height;
    //
    //    imgvComic.frame = CGRectMake(0, 0, imageWidth, imageHeight);
    //
    //    imgvComic.center = centerImgvComic;
    //
    //  //  [self updateComicCropFrame:imgvComic.frame];
    //
    //    imgvComic.layer.masksToBounds = YES;
    ////    temImagFrame = imgvComic.frame;
}

#pragma mark - Upload Picture Methods
- (IBAction)btnUploadPicTap:(id)sender
{
    UIImagePickerController * picker = [[UIImagePickerController alloc] init];
    picker.delegate=self;
    [picker setSourceType:(UIImagePickerControllerSourceTypePhotoLibrary)];
    [self presentViewController:picker animated:YES completion:Nil];
}

#pragma mark - UIImagePickerControllerDelegate Method
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    [self dismissViewControllerAnimated:YES completion:^
     {
         [self.btnSend setEnabled:YES];
         UIImage *selectedImage = info[UIImagePickerControllerOriginalImage];
         viewCamera.hidden = YES;
         [self.mSendComicButton setHidden:NO];//dinesh
         
         imgvComic.image = selectedImage;
         imgvComic.hidden = NO;
         
         GlobalObject.isTakePhoto = YES;
         
         btnClose.hidden = NO;
         btnCloseComic.hidden = NO;
         RowButtonsViewController *rowButtonsController;
         
         for (UIViewController *controller in self.childViewControllers)
         {
             if ([controller isKindOfClass:[RowButtonsViewController class]])
             {
                 rowButtonsController = (RowButtonsViewController *)controller;
             }
         }
         
         rowButtonsController.btnCamera.selected = YES;
         
         if (isWideSlide)
         {
             [self addComicCropViewWithImage:selectedImage];
         }
         else
         {
             rowButtonsController.btnCamera.selected = YES;
             [rowButtonsController allButtonsFadeIn:rowButtonsController.btnCamera];
             
             [self setComicImageViewSize];
             [self doAutoSave:nil];
             
             //dinesh
             [self.mSendComicButton setHidden:NO];
         }
         
         // add crop view
         isCameraOn = NO;
     }];
    
    if(self.startRecordingFlag) {
        
        self.startRecordingFlag=NO;
        NSLog(@"UIImagePickerControllerMediaURL----->%@",[info objectForKey:@"UIImagePickerControllerMediaURL"]);
        // [self makeAnimatedGifForVideo:[info objectForKey:@"UIImagePickerControllerMediaURL"]];
        //        [NSGIF optimalGIFfromURL:[info objectForKey:@"UIImagePickerControllerMediaURL"] loopCount:0 completion:^(NSURL *GifURL) {
        //
        //            NSLog(@"Finished generating GIF: %@", GifURL);
        //
        //        }];
        
        //        [NSGIF createGIFfromURL:[info objectForKey:@"UIImagePickerControllerMediaURL"] withFrameCount:30 delayTime:.010 loopCount:0 completion:^(NSURL *GifURL) {
        //            NSLog(@"Finished generating GIF: %@", GifURL);
        //        }];
    }
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    //dinesh
    [self.mSendComicButton setHidden:NO];
    
    [self dismissViewControllerAnimated:YES completion:nil];
}


#pragma mark - Sticker Events
- (void)showCropViewController
{
    CropStickerViewController *csv = [self.storyboard instantiateViewControllerWithIdentifier:@"CropStickerViewController"];
    
    csv.delegate = self;
    
    csv.providesPresentationContextTransitionStyle = YES;
    csv.definesPresentationContext = YES;
    
    [csv setModalPresentationStyle:UIModalPresentationOverCurrentContext];
    
    [self presentViewController:csv animated:YES completion:nil];
}

- (void)openStickerList
{
    backupToolCenter = viewRowButtons.center;
    backupOtherViewCenter = viewStickerList.center;
    
    [UIView animateWithDuration:.6 delay:0 usingSpringWithDamping:100 initialSpringVelocity:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        btnClose.alpha = 0;
        btnCloseComic.alpha = 0;
        viewRowButtons.center = CGPointMake(backupToolCenter.x-100, backupToolCenter.y );
        viewRowButtons.alpha = 0;
    } completion:^(BOOL finished)
     {
         
     }];
    
    viewStickerList.alpha = 0;
    
    [UIView animateWithDuration:.8 delay:.2 usingSpringWithDamping:80 initialSpringVelocity:10 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        
        viewStickerList.center = CGPointMake(backupOtherViewCenter.x -viewStickerList.bounds.size.width, backupOtherViewCenter.y );
        viewStickerList.alpha = 1;
    } completion:^(BOOL finished)
     {
         
         // open slide 4 Instruction
         dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0 * NSEC_PER_SEC));
         dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
             NSLog(@"Do some work");
             
             if ([InstructionView getBoolValueForSlide:kInstructionSlide4] == NO)
             {
                 InstructionView *instView = [[InstructionView alloc] initWithFrame:self.view.bounds];
                 instView.delegate = self;
                 [instView showInstructionWithSlideNumber:SlideNumber4 withType:InstructionBubbleType];
                 [instView setTrueForSlide:kInstructionSlide4];
                 
                 [self.view addSubview:instView];
             }
         });
         
         
         if ([[NSUserDefaults standardUserDefaults] boolForKey:kIsUserEnterFirstTimeComicMaking] == YES)
         {
             // open slide 11 Instruction
             dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0 * NSEC_PER_SEC));
             dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
                 NSLog(@"Do some work");
                 
                 if ([InstructionView getBoolValueForSlide:kInstructionSlide11] == NO)
                 {
                     InstructionView *instView = [[InstructionView alloc] initWithFrame:self.view.bounds];
                     instView.delegate = self;
                     [instView showInstructionWithSlideNumber:SlideNumber11 withType:InstructionBubbleType];
                     [instView setTrueForSlide:kInstructionSlide11];
                     
                     [self.view addSubview:instView];
                 }
             });
             
         }
         
         
     }];
    
    chatIconCenter = _chatIcon.center;
    uploadIconCenter = uploadIcon.center;
    
    [UIView animateWithDuration:.3 delay:0 usingSpringWithDamping:10 initialSpringVelocity:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        
        self.uploadIcon.center = CGPointMake(uploadIconCenter.x, uploadIconCenter.y-30 );
        self.uploadIcon.alpha = 0;
    } completion:^(BOOL finished) {
        
    }];
    
    self.chatIcon.alpha = 0;
    [UIView animateWithDuration:.4 delay:.2 usingSpringWithDamping:.8 initialSpringVelocity:10 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        
        self.chatIcon.center = CGPointMake(chatIconCenter.x, chatIconCenter.y-self.chatIcon.bounds.size.height );
        self.chatIcon.alpha = 1;
    } completion:^(BOOL finished) {
        
    }];
    
}

- (void)addDeactiveDeleteMode
{
    UIView *superView = self.parentViewController.view;
    
    NSLog(@"call");
    UIButton *btn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(superView.frame), CGRectGetHeight(superView.frame))];
    btn.backgroundColor = [UIColor clearColor];
    btn.tag = 1200;
    [btn addTarget:self action:@selector(deactiveDeleteMode:) forControlEvents:UIControlEventTouchUpInside];
    
    [self.view insertSubview:btn belowSubview:viewStickerList];
    
    [self.view bringSubviewToFront:viewStickerList];
}

- (void)deactiveDeleteMode:(UIButton *)sender
{
    if (sender == nil)
    {
        UIButton *btn = (UIButton *)[self.view viewWithTag:1200];
        [btn removeFromSuperview];
    }
    else
    {
        [sender removeFromSuperview];
    }
    
    StickerList *stickerController;
    
    for (UIViewController *controller in self.childViewControllers)
    {
        if ([controller isKindOfClass:[StickerList class]])
        {
            stickerController = (StickerList *)controller;
        }
    }
    
    [stickerController deactiveDeleteMode];
}

- (void)closeStickerList
{
    [self deactiveDeleteMode:nil];
    
    [UIView animateWithDuration:.6 delay:0 usingSpringWithDamping:100 initialSpringVelocity:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        
        viewStickerList.center = CGPointMake(backupOtherViewCenter.x, backupOtherViewCenter.y );
        
        viewStickerList.alpha = 0;
        
        btnClose.alpha = 1;
        btnCloseComic.alpha = 1;
    } completion:^(BOOL finished) {
        
    }];
    
    viewRowButtons.alpha = 0;
    
    [UIView animateWithDuration:.8 delay:.2 usingSpringWithDamping:80 initialSpringVelocity:10 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        
        viewRowButtons.center = CGPointMake(backupToolCenter.x, backupToolCenter.y );
        viewRowButtons.alpha = 1;
    } completion:^(BOOL finished) {
        
    }];
    
    [UIView animateWithDuration:.3 delay:0 usingSpringWithDamping:10 initialSpringVelocity:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        
        self.chatIcon.center = CGPointMake(chatIconCenter.x, chatIconCenter.y );
        self.chatIcon.alpha = 0;
        
        
    } completion:^(BOOL finished) {
        
    }];
    
    self.uploadIcon.alpha = 0;
    [UIView animateWithDuration:.4 delay:.2 usingSpringWithDamping:.8 initialSpringVelocity:10 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        self.uploadIcon.center = CGPointMake(uploadIconCenter.x, uploadIconCenter.y );
        self.uploadIcon.alpha = 1;
        
    } completion:^(BOOL finished) {
        
    }];
}

- (void)addStickerWithPath:(NSString *)stickerImageSting
{
    UIImage* sticker = [UIImage imageWithContentsOfFile:stickerImageSting];
    [self addStickerWithImage:sticker];
}

- (void)addStickerWithImage:(UIImage *)sticker
{
    // open slide 10 Instruction
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0 * NSEC_PER_SEC));
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        NSLog(@"Do some work");
        
        if ([InstructionView getBoolValueForSlide:kInstructionSlide10] == NO)
        {
            InstructionView *instView = [[InstructionView alloc] initWithFrame:self.view.bounds];
            instView.delegate = self;
            [instView showInstructionWithSlideNumber:SlideNumber10 withType:InstructionGIFType];
            [instView setTrueForSlide:kInstructionSlide10];
            
            [self.view addSubview:instView];
        }
    });
    
    ComicItemSticker* imageView = [self getComicItems:ComicSticker];
    imageView.frame = CGRectMake(0, 0, 150, 150);
    imageView.contentMode = UIViewContentModeScaleAspectFit;
    imgvComic.userInteractionEnabled = YES;
    imgvComic.clipsToBounds = YES;
    
    imageView.image = sticker;
    
    float widthRatio = imageView.bounds.size.width / imageView.image.size.width;
    float heightRatio = imageView.bounds.size.height / imageView.image.size.height;
    float scale = MIN(widthRatio, heightRatio);
    float imageWidth = scale * imageView.image.size.width;
    float imageHeight = scale * imageView.image.size.height;
    
    imageView.frame = CGRectMake(0, 0, imageWidth, imageHeight);
    imageView.center = imgvComic.center;
    
    [self addComicItem:imageView ItemImage:sticker];
    
    //Handle Auto Save
    [self doAutoSave:imageView];
    
    
    
    
}

#pragma mark Exclamation

/*Ramesh */
//Handle Exclamation
- (void)openExclamationList :(RowButtonCallBack)completionHandler
{
    _completionHandler = completionHandler;
    
    backupToolCenter = viewRowButtons.center;
    backupOtherViewCenter = exclamationListView.center;
    [exclamationListView setHidden:NO];
    
    [UIView animateWithDuration:.6 delay:0 usingSpringWithDamping:100 initialSpringVelocity:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        btnClose.alpha = 0;
        btnCloseComic.alpha = 0;
        
        //        viewRowButtons.center = CGPointMake(backupToolCenter.x-100, backupToolCenter.y );
        //        viewRowButtons.alpha = 0;
    } completion:^(BOOL finished) {
        _completionHandler(YES);
    }];
    
    exclamationListView.alpha = 0;
    
    [UIView animateWithDuration:.8 delay:.2 usingSpringWithDamping:80 initialSpringVelocity:10 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        
        exclamationListView.center = CGPointMake(backupOtherViewCenter.x -viewStickerList.bounds.size.width, backupOtherViewCenter.y );
        
        exclamationLeftConstaint.constant = 0;
        exclamationListView.alpha = 1;
        
    } completion:^(BOOL finished) {
        
    }];
    
    chatIconCenter = _chatIcon.center;
    uploadIconCenter = uploadIcon.center;
    
    [UIView animateWithDuration:.3 delay:0 usingSpringWithDamping:10 initialSpringVelocity:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        
        self.uploadIcon.center = CGPointMake(uploadIconCenter.x, uploadIconCenter.y-30 );
        self.uploadIcon.alpha = 0;
    } completion:^(BOOL finished) {
        
    }];
    
    self.chatIcon.alpha = 0;
    [UIView animateWithDuration:.4 delay:.2 usingSpringWithDamping:.8 initialSpringVelocity:10 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        
        self.chatIcon.center = CGPointMake(chatIconCenter.x, chatIconCenter.y-self.chatIcon.bounds.size.height );
        self.chatIcon.alpha = 1;
    } completion:^(BOOL finished) {
    }];
}

- (void)closeExclamationList
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"closeExclamation" object:nil];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"closeExclamation" object:nil];
    
    if (!haveAnimationOnPage)
    {
        if ([self.view.subviews containsObject:currentAnimInstSubView])
        {
            [currentAnimInstSubView removeFromSuperview];
        }
        if ([self.view.gestureRecognizers containsObject:currentAnimationInstructionTap])
        {
            [self.view removeGestureRecognizer:currentAnimationInstructionTap];
        }
    }
    
    NSArray* animationColl = [self getAnimatedComponentCollection];
    for (ComicItemAnimatedComponent* objColl in animationColl) {
        [objColl stopAnimating];
    }
    
    ComicItemAnimatedSticker* aniSticker = [self getAnimatesStickerFromComic];
    if (aniSticker != nil && aniSticker.combineAnimationFileName) {
        [aniSticker stopAnimating];
    }
    pauseAnimation = YES;
    [UIView animateWithDuration:.6 delay:0 usingSpringWithDamping:100 initialSpringVelocity:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        
//        exclamationListView.center = CGPointMake(backupOtherViewCenter.x, backupOtherViewCenter.y );
        
        exclamationListView.alpha = 0;
        
        btnClose.alpha = 1;
        btnCloseComic.alpha = 1;
        exclamationLeftConstaint.constant = exclamationListView.frame.size.width;
    } completion:^(BOOL finished) {
        
    }];
    
    viewRowButtons.alpha = 0;
    
    [UIView animateWithDuration:.8 delay:.2 usingSpringWithDamping:80 initialSpringVelocity:10 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        
        viewRowButtons.center = CGPointMake(backupToolCenter.x, backupToolCenter.y );
        viewRowButtons.alpha = 1;
    } completion:^(BOOL finished) {
        
    }];
    
    [UIView animateWithDuration:.3 delay:0 usingSpringWithDamping:10 initialSpringVelocity:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        
        self.chatIcon.center = CGPointMake(chatIconCenter.x, chatIconCenter.y );
        self.chatIcon.alpha = 0;
        
        
    } completion:^(BOOL finished) {
        
    }];
    
    self.uploadIcon.alpha = 0;
    [UIView animateWithDuration:.4 delay:.2 usingSpringWithDamping:.8 initialSpringVelocity:10 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        self.uploadIcon.center = CGPointMake(uploadIconCenter.x, uploadIconCenter.y );
        self.uploadIcon.alpha = 1;
        
    } completion:^(BOOL finished) {
        
    }];
}
- (void)addExclamationListImage:(NSString *)exclamationImageString{
    
    [[GoogleAnalytics sharedGoogleAnalytics] logUserEvent:@"Exclamation" Action:@"AddExclamation" Label:@""];
    
    UIImage* exclamationImage = [UIImage imageNamed:exclamationImageString];
    
    ComicItemExclamation* imageView = [self getComicItems:ComicExclamation];
    imageView.frame = CGRectMake(15, 15, 150, 150);
    imageView.image = exclamationImage;
    
    float widthRatio = imageView.bounds.size.width / imageView.image.size.width;
    float heightRatio = imageView.bounds.size.height / imageView.image.size.height;
    float scale = MIN(widthRatio, heightRatio);
    float imageWidth = scale * imageView.image.size.width;
    float imageHeight = scale * imageView.image.size.height;
    
    imageView.frame = CGRectMake(0, 0, imageWidth, imageHeight);
    [self addComicItem:imageView ItemImage:exclamationImage];
    
    imageView.center = imageView.center;
    [self doAutoSave:imageView];
}

#pragma mark Animation

-(ComicItemAnimatedSticker*)getAnimatesStickerFromComic{
    for (id subview in [imgvComic subviews]) {
        if ([subview isKindOfClass:[ComicItemAnimatedSticker class]]) {
            return (ComicItemAnimatedSticker*)subview;
        }
    }
    return nil;
}

-(NSMutableArray*)getAnimatedComponentCollection{
    ComicItemAnimatedSticker* animatedObj = [self getAnimatesStickerFromComic];
    if (animatedObj != nil) {
        return animatedObj.animatedComponentArray;
    }
    return nil;
}

- (void)addAnimatedSticker:(NSString *)exclamationImageString AtRect:(CGRect)rect{
    
    [[GoogleAnalytics sharedGoogleAnalytics] logUserEvent:@"AnimatedSticker" Action:@"AddAnimatedSticker" Label:@""];
    
    ComicItemAnimatedSticker* imageView = [self getAnimatesStickerFromComic];
    //Checking if ComicItemAnimatedSticker already exiting, if that so no need to create
    // Just add the gif component to ComicItemAnimatedSticker.
    
    if (imageView == nil) {
        imageView = [self getComicItems:ComicAnimatedSticker];
        imageView.animatedComponentArray = [[NSMutableArray alloc] init];
        imageView.frame = CGRectMake(0, 0, imgvComic.frame.size.width, imgvComic.frame.size.height);
    }
    
    
    ComicItemAnimatedComponent* animatedComponent = [self getComicItems:ComicAnimatedComponent];
    
    animatedComponent.frame = rect;
    animatedComponent.animatedStickerName = exclamationImageString;
    
    animatedComponent.startDelay = [[[[[currentWorkingAnimation valueForKey:@"resources"] objectAtIndex:currentTapIndex] valueForKey:@"animation"] valueForKey:@"timeInterval"] floatValue];
    animatedComponent.endDelay = [[[[[currentWorkingAnimation valueForKey:@"resources"] objectAtIndex:currentTapIndex] valueForKey:@"animation"] valueForKey:@"endInterval"] floatValue];
    
    //    mainAnimationGifView = [[ComicItemAnimatedSticker alloc]initWithFrame:[UIScreen mainScreen].bounds];
    
//    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(singleTapAnimation:)];
//    tapGesture.numberOfTapsRequired = 1;
//    [animatedComponent addGestureRecognizer:tapGesture];
    
    [imageView.animatedComponentArray addObject:animatedComponent];
    
    if([self getAnimatesStickerFromComic] == nil){
        [imgvComic addSubview:imageView];
        [imgvComic bringSubviewToFront:imageView];
    }
    [self addComicItem:imageView ItemImage:nil];
    
    imgvComic.clipsToBounds = YES;
    imageView.center = imageView.center;
    [self doAutoSave:imageView];
}
- (void)addAnimation:(NSString *)gifImageName {
    
    [[GoogleAnalytics sharedGoogleAnalytics] logUserEvent:@"AnimatedSticker" Action:@"AddAnimatedSticker" Label:@""];
    
    ComicItemAnimatedSticker* imageView = [self getComicItems:ComicAnimatedSticker];
    //Remove, AnimatedSticker.
    for (id imgSticker in [imgvComic subviews] ) {
        if([imgSticker isKindOfClass:[ComicItemAnimatedSticker class]]){
            [imgSticker removeFromSuperview];
        }
    }
    
    
    //Checking if ComicItemAnimatedSticker already exiting, if that so no need to create
    // Just add the gif component to ComicItemAnimatedSticker.
    
    //    if (imageView == nil) {
    //        imageView = [self getComicItems:ComicAnimatedSticker];
    //        imageView.animatedComponentArray = [[NSMutableArray alloc] init];
    //        imageView.frame = CGRectMake(0, 0, imgvComic.frame.size.width, imgvComic.frame.size.height);
    //    }
    
    
    //    ComicItemAnimatedComponent* animatedComponent = [self getComicItems:ComicAnimatedComponent];
    //
    //    animatedComponent.frame = rect;
    //    animatedComponent.animatedStickerName = exclamationImageString;
    
    imageView.combineAnimationFileName = [gifImageName stringByAppendingString:@".gif"];
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(singleTapAnimation:)];
    tapGesture.numberOfTapsRequired = 1;
    [imageView addGestureRecognizer:tapGesture];
    
    //    [imageView.animatedComponentArray addObject:animatedComponent];
    
    //    if([self getAnimatesStickerFromComic] == nil){
    //        [imgvComic addSubview:imageView];
    //        [imgvComic bringSubviewToFront:imageView];
    //    }
    imageView.frame = CGRectMake(100, 100, 150, 150);
//    imageView.frame = CGRectMake(0, 0, 150, 150);
    [self addComicItem:imageView ItemImage:nil];
    
    imgvComic.clipsToBounds = YES;
    imageView.center = imageView.center;
//    [self doAutoSave:imageView];
}
-(void)addAnimationWithInstructionForObj:(NSDictionary *)animationObj
{
    if (haveAnimationOnPage)
    {
        [animationCollection showGarbageBinForSomeMoment];
        return;
    }
    
    [animationCollection showInstructionAndGarbageBinForSomeMoment];
    currentWorkingAnimation = animationObj;
    [self addAnimatedStickerFromStartAtIndex:0];
    //    mainAnimationGifView = [[ComicItemAnimatedSticker alloc]initWithFrame:[UIScreen mainScreen].bounds];
    //
    //    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(singleTapAnimation:)];
    //    tapGesture.numberOfTapsRequired = 1;
    //    [mainAnimationGifView addGestureRecognizer:tapGesture];
    //
    ////    [self.view insertSubview:mainAnimationGifView atIndex:2];
    //    [imgvComic addSubview:mainAnimationGifView];
    //    [imgvComic bringSubviewToFront:mainAnimationGifView];
    /*
     {
     "animationId": "1",
     "numberOfResources":"1",
     "thumImage":"cat1Anim1",
     "name": "Drill",
     "categoryid": "0",
     "resources":[
     {
     "type":"filter",
     "instraction":
     {
     "imagename":"tab-forehead.png",
     "type":"forehead",
     "position":
     {
     "x":239,
     "y":28,
     },
     "size":
     {
     "width":117,
     "height":117
     }
     }
     "animation":
     {
     "boundry":
     {
     "topA":80,
     "topB":178,
     "leftA":0,
     "leftB":0,
     "rightA":0,
     "rightB":0,
     "downA":0,
     "downB":0
     },
     "centerPoint":
     {
     "x":97,
     "y":137
     },
     "face":
     {
     "type":"single",
     "imageA":"drillAnimation",
     "imageB":""
     },
     "sizeDefault":
     {
     "width":200,
     "height":178
     },
     "timeInterval":0
     }
     
     }
     
     
     ]
     
     }
     */
}
-(void)addAnimatedStickerFromStartAtIndex:(NSInteger)index
{
    if ([[currentWorkingAnimation valueForKey:@"resources"] count]>index)
    {
        if ([[[[currentWorkingAnimation valueForKey:@"resources"] objectAtIndex:index] valueForKey:@"type"] isEqualToString:@"filter"])
        {
            [animationCollection stopBeingExcutedAfterSomeMoment];
            [self proceedToAddRealAnimationWithPoint:CGPointZero andCurrentIndex:index];
            /* [self addAnimatedSticker:[[[[[currentWorkingAnimation valueForKey:@"resources"] objectAtIndex:index] valueForKey:@"animation"] valueForKey:@"face"] valueForKey:@"imageA"] AtRect:rectForAnimation];*/
            //NSInteger newInt = index+1;
            //[self addAnimatedStickerFromStartAtIndex:newInt];
            return;
        }
        else if ([[[[currentWorkingAnimation valueForKey:@"resources"] objectAtIndex:index] valueForKey:@"type"] isEqualToString:@"Noplug&play"])
        {
            [self proceedToAddRealAnimationWithPoint:currentAnimationTouchPoint andCurrentIndex:index];
            return;
        }
        else if ([[[[currentWorkingAnimation valueForKey:@"resources"] objectAtIndex:index] valueForKey:@"type"] isEqualToString:@"round&play"])
        {
            NSDictionary *instctionObj = [[[currentWorkingAnimation valueForKey:@"resources"] objectAtIndex:index] valueForKey:@"instraction"];
            CGRect instructionRect = CGRectMake([[[instctionObj valueForKey:@"position"] valueForKey:@"x"] floatValue],
                                                [[[instctionObj valueForKey:@"position"] valueForKey:@"y"] floatValue],
                                                [[[instctionObj valueForKey:@"size"] valueForKey:@"width"] floatValue],
                                                [[[instctionObj valueForKey:@"size"] valueForKey:@"height"] floatValue]);
            currentAnimInstSubView = [[YYAnimatedImageView alloc]initWithFrame:[self rectOntheBasisOfScreen:instructionRect]];
            currentAnimInstSubView.image  = [YYImage imageNamed:[NSString stringWithFormat:@"%@.gif",[instctionObj valueForKey:@"imagename"]]];
            [self.view addSubview:currentAnimInstSubView];
            [self.view bringSubviewToFront:currentAnimInstSubView];
            [self addBeizerSquarewithIndex:currentTapIndex];
            //[self addTouchEventwithIndex:index];
        }
        else if ([[[[currentWorkingAnimation valueForKey:@"resources"] objectAtIndex:index] valueForKey:@"type"] isEqualToString:@"Movableplug&play"])
        {
            [animationCollection stopBeingExcutedAfterSomeMoment];
            CGPoint newPoinnt=  [self pointFromAnimationsRealPoint:self.view.center fromCenterX:[[[currentWorkingAnimation valueForKey:@"centerPoint"] valueForKey:@"x"] floatValue] fromCenterY:[[[currentWorkingAnimation valueForKey:@"centerPoint"] valueForKey:@"y"] floatValue]];
            [self proceedToAddRealAnimationWithPoint:newPoinnt andCurrentIndex:index];
        }
        else
        {
            NSDictionary *instctionObj = [[[currentWorkingAnimation valueForKey:@"resources"] objectAtIndex:index] valueForKey:@"instraction"];
            CGRect instructionRect = CGRectMake([[[instctionObj valueForKey:@"position"] valueForKey:@"x"] floatValue],
                                                [[[instctionObj valueForKey:@"position"] valueForKey:@"y"] floatValue],
                                                [[[instctionObj valueForKey:@"size"] valueForKey:@"width"] floatValue],
                                                [[[instctionObj valueForKey:@"size"] valueForKey:@"height"] floatValue]);
            currentAnimInstSubView = [[YYAnimatedImageView alloc]initWithFrame:[self rectOntheBasisOfScreen:instructionRect]];
            currentAnimInstSubView.image  = [YYImage imageNamed:[NSString stringWithFormat:@"%@.gif",[instctionObj valueForKey:@"imagename"]]];
            [self.view addSubview:currentAnimInstSubView];
            [self.view bringSubviewToFront:currentAnimInstSubView];
            [self addTouchEventwithIndex:index];
        }
    }
}
-(void)addBeizerSquarewithIndex:(NSInteger)index
{
    hasStartedBezierForAnimation = YES;
    currentTapIndex = index;
    self.croppingPath = [[UIBezierPath alloc] init];
    [self.croppingPath setLineJoinStyle:kCGLineJoinBevel];
    
}
-(void)addTouchEventwithIndex:(NSInteger)index
{
    currentAnimationInstructionTap = [[UITapGestureRecognizer alloc]init];
    currentTapIndex = index;
    [currentAnimationInstructionTap addTarget:self action:@selector(didTapOnAnimationPage:)];
    [self.view addGestureRecognizer:currentAnimationInstructionTap];
}
-(void)addPanEventWithIndexFor:(ComicItemAnimatedSticker *)componenet
{
    currentAnimationPan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panGestureForAnimatedStickerDetected:)];
    [currentAnimationPan setDelegate:self];
    [componenet addGestureRecognizer:currentAnimationPan];
}
-(void)didTapOnAnimationPage:(UITapGestureRecognizer *)gesture
{
    CGPoint touchPoint = [gesture locationInView:self.view];
    [currentAnimInstSubView removeFromSuperview];
    [self.view removeGestureRecognizer:gesture];
    if (currentTapIndex==0)
    {
        [animationCollection stopBeingExcutedAfterSomeMoment];
    }
    [self proceedToAddRealAnimationWithPoint:touchPoint andCurrentIndex:currentTapIndex];
}
-(void)proceedToAddRealAnimationWithPoint:(CGPoint)touchPoint andCurrentIndex:(NSInteger)index
{
    
    if (![[[[[[currentWorkingAnimation valueForKey:@"resources"] objectAtIndex:currentTapIndex] valueForKey:@"animation"] valueForKey:@"face"] valueForKey:@"type"] isEqualToString:@"single"])
    {
        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:nil message:@"Is user nose facing right or left?" delegate:self cancelButtonTitle:@"Left" otherButtonTitles:@"Right", nil];
        alert.tag = 301;
        tempIndexForFace = index;
        tempTouchPointForFace = touchPoint;
        [alert show];
        
        return;
    }
    [self proceedAgainForTheAnsweredFaceisLeft:YES ForPoints:touchPoint AndIndex:index];
}
-(void)proceedAgainForTheAnsweredFaceisLeft:(BOOL)isLeft ForPoints:(CGPoint)touchPoint AndIndex:(NSInteger)index
{
    NSString *boundryKey;
    NSString *imageNameKey;
    NSString *centerPointKey;
    if (isLeft)
    {
        boundryKey = @"boundry";
        imageNameKey = @"imageA";
        centerPointKey = @"centerPoint";
    }
    else
    {
        boundryKey = @"boundry2";
        imageNameKey = @"imageB";
        centerPointKey = @"centerPoint2";
    }
    NSDictionary *currentBoundry  = [[[[currentWorkingAnimation valueForKey:@"resources"] objectAtIndex:index] valueForKey:@"animation"] valueForKey:boundryKey];
    
    
    /*
     
     "topA":0,
     "topB":0,
     "leftA":0,
     "leftB":0,
     "rightA":0,
     "rightB":0,
     "downA":0,
     "downB":0
     
     */
    //Get Boundries for Different Screen Size
    CGFloat boundrytopA = [self DifferenceInYAxisFromPoint:[[currentBoundry valueForKey:@"topA"] floatValue]];
    // CGFloat boundrytopB = [self DifferenceInYAxisFromPoint:[[currentBoundry valueForKey:@"topB"] floatValue]];
    CGFloat boundrybottomA = [self DifferenceInYAxisFromPoint:[[currentBoundry valueForKey:@"downA"] floatValue]];
    // CGFloat boundrybottomB = [self DifferenceInYAxisFromPoint:[[currentBoundry valueForKey:@"downB"] floatValue]];
    CGFloat boundryleftA = [self DifferenceInYAxisFromPoint:[[currentBoundry valueForKey:@"leftA"] floatValue]];
    //  CGFloat boundryleftB = [self DifferenceInYAxisFromPoint:[[currentBoundry valueForKey:@"leftB"] floatValue]];
    CGFloat boundryrightA = [self DifferenceInYAxisFromPoint:[[currentBoundry valueForKey:@"rightA"] floatValue]];
    // CGFloat boundryrightB = [self DifferenceInYAxisFromPoint:[[currentBoundry valueForKey:@"rightB"] floatValue]];
    
    
    
    NSDictionary *currentAnimationSize = [[[[currentWorkingAnimation valueForKey:@"resources"] objectAtIndex:index] valueForKey:@"animation"] valueForKey:@"sizeDefault"];
    //Check the case where we know to shrink the GIF or should throw error message
    CGRect rectForAnimation;
    CGFloat widthFromJson = [self DifferenceInXAxisFromPoint:[[currentAnimationSize valueForKey:@"width"] floatValue]];
    CGFloat heightFromJson = [self DifferenceInYAxisFromPoint:[[currentAnimationSize valueForKey:@"height"] floatValue]];
    NSDictionary *centerPointObj = [[[[currentWorkingAnimation valueForKey:@"resources"] objectAtIndex:index] valueForKey:@"animation"] valueForKey:centerPointKey];
    if (touchPoint.y<boundrytopA||touchPoint.x<boundryleftA || (touchPoint.x>boundryrightA && boundryrightA != 0) ||(touchPoint.y>boundrybottomA && boundrybottomA != 0)) {
        
        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"There isn’t any room!" message:nil delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles: nil];
        [alert show];
        
        return;
    }
    /************Shrinking logic has been discarded - Sanjay*********/
    /*if (touchPoint.y>boundrytopA && touchPoint.y<boundrytopB)
     {
     //Checking for the point inside the top boundries.
     // Should Shrink because we have big gif frame
     
     CGFloat newSizeHeight = heightFromJson - boundrytopB+touchPoint.y;
     CGFloat newSizeWidth = (widthFromJson/heightFromJson)*newSizeHeight;
     rectForAnimation = CGRectMake(touchPoint.x, touchPoint.y,
     newSizeWidth,
     newSizeHeight);
     CGFloat xFactor = newSizeWidth/widthFromJson;
     CGFloat yFactor = newSizeHeight/heightFromJson;
     
     rectForAnimation.origin = [self pointFromAnimationsRealPoint:touchPoint fromCenterX:[[centerPointObj valueForKey:@"x"] floatValue]*xFactor fromCenterY:[[centerPointObj valueForKey:@"y"] floatValue]*yFactor];
     }
     else if (touchPoint.y>boundrybottomA && touchPoint.y<boundrybottomB)
     {
     //Checking for the point inside the bottom boundries.
     // Should Shrink because we have big gif frame
     
     CGFloat newSizeHeight = heightFromJson - boundrybottomA+touchPoint.y;
     CGFloat newSizeWidth = (widthFromJson/heightFromJson)*newSizeHeight;
     rectForAnimation = CGRectMake(touchPoint.x, touchPoint.y,
     newSizeWidth,
     newSizeHeight);
     CGFloat xFactor = newSizeWidth/widthFromJson;
     CGFloat yFactor = newSizeHeight/heightFromJson;
     
     rectForAnimation.origin = [self pointFromAnimationsRealPoint:touchPoint fromCenterX:[[centerPointObj valueForKey:@"x"] floatValue]*xFactor fromCenterY:[[centerPointObj valueForKey:@"y"] floatValue]*yFactor];
     }
     else if (touchPoint.x>boundryleftA && touchPoint.x<boundryleftB)
     {
     //Checking for the point inside the left boundries.
     // Should Shrink because we have big gif frame
     
     
     
     CGFloat newSizeWidth = widthFromJson - boundryleftB+touchPoint.x;
     CGFloat newSizeHeight = (widthFromJson/heightFromJson)*newSizeWidth;
     rectForAnimation = CGRectMake(touchPoint.x, touchPoint.y,
     newSizeWidth,
     newSizeHeight);
     CGFloat xFactor = newSizeWidth/widthFromJson;
     CGFloat yFactor = newSizeHeight/heightFromJson;
     
     rectForAnimation.origin = [self pointFromAnimations2RealPoint:touchPoint fromCenterX:[[centerPointObj valueForKey:@"x"] floatValue]*xFactor fromCenterY:[[centerPointObj valueForKey:@"y"] floatValue]*yFactor];
     }
     else if (touchPoint.x>boundryrightA && touchPoint.x<boundryrightB)
     {
     //Checking for the point inside the right boundries.
     // Should Shrink because we have big gif frame
     
     CGFloat newSizeWidth = widthFromJson - boundryrightA+touchPoint.x;
     CGFloat newSizeHeight = (widthFromJson/heightFromJson)*newSizeWidth;
     rectForAnimation = CGRectMake(touchPoint.x, touchPoint.y,
     newSizeWidth,
     newSizeHeight);
     CGFloat xFactor = newSizeWidth/widthFromJson;
     CGFloat yFactor = newSizeHeight/heightFromJson;
     
     rectForAnimation.origin = [self pointFromAnimationsRealPoint:touchPoint fromCenterX:[[centerPointObj valueForKey:@"x"] floatValue]*xFactor fromCenterY:[[centerPointObj valueForKey:@"y"] floatValue]*yFactor];
     }*/
    else
    {
        // else create particular rect.
        rectForAnimation = CGRectMake(touchPoint.x, touchPoint.y,
                                      widthFromJson,
                                      heightFromJson);
        rectForAnimation.origin = [self pointFromAnimationsRealPoint:touchPoint fromCenterX:[[centerPointObj valueForKey:@"x"] floatValue] fromCenterY:[[centerPointObj valueForKey:@"y"] floatValue]];
    }
    
    
    //// choose face to add alert and change name..
    
    [self addAnimatedSticker:[[[[[currentWorkingAnimation valueForKey:@"resources"] objectAtIndex:currentTapIndex] valueForKey:@"animation"] valueForKey:@"face"] valueForKey:imageNameKey] AtRect:rectForAnimation];
    currentAnimationTouchPoint = touchPoint;
    currentTapIndex++;
    [self addAnimatedStickerFromStartAtIndex:currentTapIndex];
}//END

/*Ramesh */
//Handle Bubble Methods
#pragma mark - Bubble Methods
-(void)addStandardBubbleOnFirstTime
{
    ComicBubbleView *view=[[ComicBubbleView alloc]initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT)];
    view.lowerLeftStandardBubbleView.frame=CGRectMake(120, 90, view.lowerLeftStandardBubbleView.frame.size.width, view.lowerLeftStandardBubbleView.frame.size.height);
    view.lowerRightStandardBubbleView.frame=CGRectMake(20, 300, view.lowerRightStandardBubbleView.frame.size.width, view.lowerRightStandardBubbleView.frame.size.height);
    view.upperLeftStandardBubbleView.frame=CGRectMake(120, 300, view.upperLeftStandardBubbleView.frame.size.width, view.upperLeftStandardBubbleView.frame.size.height);
     view.upperRightStandardBubbleView.frame=CGRectMake(10, 90, view.upperRightStandardBubbleView.frame.size.width, view.upperRightStandardBubbleView.frame.size.height);
  //  [imgvComic addSubview:view.lowerLeftStandardBubbleView];
   // [imgvComic addSubview:view.lowerRightStandardBubbleView];
   // [imgvComic addSubview:view.upperRightStandardBubbleView];
    [imgvComic addSubview:view.upperRightStandardBubbleView];
}
- (void)openBubbleList
{
    backupToolCenter = viewRowButtons.center;
    backupOtherViewCenter = bubbleListView.center;
    
    [UIView animateWithDuration:.6 delay:0 usingSpringWithDamping:100 initialSpringVelocity:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        btnClose.alpha = 0;
        btnCloseComic.alpha = 0;
        viewRowButtons.center = CGPointMake(backupToolCenter.x-100, backupToolCenter.y );
        viewRowButtons.alpha = 0;
    } completion:^(BOOL finished) {
        
    }];
    
    bubbleListView.alpha = 0;
    
    [UIView animateWithDuration:.8 delay:.2 usingSpringWithDamping:80 initialSpringVelocity:10 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        
        bubbleListView.center = CGPointMake(backupOtherViewCenter.x -viewStickerList.bounds.size.width, backupOtherViewCenter.y );
        bubbleListView.alpha = 1;
    } completion:^(BOOL finished) {
        
    }];
    
    chatIconCenter = _chatIcon.center;
    uploadIconCenter = uploadIcon.center;
    
    [UIView animateWithDuration:.3 delay:0 usingSpringWithDamping:10 initialSpringVelocity:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        
        self.uploadIcon.center = CGPointMake(uploadIconCenter.x, uploadIconCenter.y-30 );
        self.uploadIcon.alpha = 0;
    } completion:^(BOOL finished) {
        
    }];
    
    self.chatIcon.alpha = 0;
    [UIView animateWithDuration:.4 delay:.2 usingSpringWithDamping:.8 initialSpringVelocity:10 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        
        self.chatIcon.center = CGPointMake(chatIconCenter.x, chatIconCenter.y-self.chatIcon.bounds.size.height );
        self.chatIcon.alpha = 1;
    } completion:^(BOOL finished) {
        
        
        
    }];
    
}

- (void)closeBubbleList
{
    [UIView animateWithDuration:.6 delay:0 usingSpringWithDamping:100 initialSpringVelocity:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        
        bubbleListView.center = CGPointMake(backupOtherViewCenter.x, backupOtherViewCenter.y );
        
        bubbleListView.alpha = 0;
        
        btnClose.alpha = 1;
        btnCloseComic.alpha = 1;
    } completion:^(BOOL finished) {
        
    }];
    
    viewRowButtons.alpha = 0;
    
    [UIView animateWithDuration:.8 delay:.2 usingSpringWithDamping:80 initialSpringVelocity:10 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        
        viewRowButtons.center = CGPointMake(backupToolCenter.x, backupToolCenter.y );
        viewRowButtons.alpha = 1;
    } completion:^(BOOL finished) {
        
    }];
    
    [UIView animateWithDuration:.3 delay:0 usingSpringWithDamping:10 initialSpringVelocity:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        
        self.chatIcon.center = CGPointMake(chatIconCenter.x, chatIconCenter.y );
        self.chatIcon.alpha = 0;
        
        
    } completion:^(BOOL finished) {
        
    }];
    
    self.uploadIcon.alpha = 0;
    [UIView animateWithDuration:.4 delay:.2 usingSpringWithDamping:.8 initialSpringVelocity:10 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        self.uploadIcon.center = CGPointMake(uploadIconCenter.x, uploadIconCenter.y );
        self.uploadIcon.alpha = 1;
        
    } completion:^(BOOL finished) {
        
    }];
}

- (void)addBubbleWithImage:(NSString *)bubbleImageString TextFiledRect:(CGRect)textViewSize
{
    [[GoogleAnalytics sharedGoogleAnalytics] logUserEvent:@"BubbleCreate" Action:@"Create" Label:@""];
    ComicItemBubble* bubbleHolderView = [self getComicItems:ComicBubble];
    
    bubbleHolderView.bubbleString = bubbleImageString;
    UIImage* bubbleImage = [UIImage imageNamed:bubbleImageString];
    bubbleHolderView.frame = CGRectMake(50, 50, 150, 150);
    bubbleHolderView.clipsToBounds = NO;
    
    //Adding Bubble image
    CGFloat imgWidth = 120;
    CGFloat imgHeight = 120;
    //This is very quick & dirty solution.
    if (bubbleImageString && ([bubbleImageString containsString:@"firstBubble"] ||
                              [bubbleImageString containsString:@"Oh no"])) {
        imgWidth = 150;
        imgHeight = 150;
    }
    bubbleHolderView.imageView = [[UIImageView alloc] initWithFrame:CGRectMake(15, 15, imgWidth, imgHeight)];
    bubbleHolderView.imageView.image = bubbleImage;
    bubbleHolderView.imageView.contentMode = UIViewContentModeScaleAspectFit;
    bubbleHolderView.imagebtn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 150, 150)];
    //End Bubble image
    
    //Adding bubble Text
    bubbleHolderView.txtBuble = [[UITextView alloc] initWithFrame:textViewSize];
    //adnan
    bubbleHolderView.txtBuble.textAlignment = NSTextAlignmentCenter;
    [bubbleHolderView.txtBuble setBackgroundColor:[UIColor clearColor]];
    //End bubble Text
    
    //Add Bubble audio
    CGFloat audioImageX = (textViewSize.origin.x + textViewSize.size.width) - 20;
    CGFloat audioImageY = (textViewSize.origin.y + textViewSize.size.height) - 10;
    
    bubbleHolderView.audioImageButton = [[UIButton alloc] initWithFrame:CGRectMake(audioImageX,audioImageY, 16, 16)];
    bubbleHolderView.audioImageButton.contentMode = UIViewContentModeScaleAspectFit;
    [bubbleHolderView.audioImageButton setImage:[UIImage imageNamed:@"bubbleAudioPlay"] forState:UIControlStateNormal];
    [bubbleHolderView.audioImageButton setAlpha:0];
    
    [self addComicItem:bubbleHolderView ItemImage:bubbleImage];
    bubbleHolderView.center = bubbleHolderView.center;
    
    [self doAutoSave:bubbleHolderView];
}

-(void)closeBubbleImage:(UIView*)viewToClose{
    
    [UIView animateWithDuration:0.5
                          delay:0.2
                        options:UIViewAnimationOptionCurveEaseOut
                     animations:^{
                         [viewToClose setAlpha:0];
                     } completion:^(BOOL finished) {
                         dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 1 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
                             [viewToClose removeFromSuperview];
                         });
                     }];
}
- (IBAction)closeSpeach:(id)sender {
    openStatus=false;
    [UIView animateWithDuration:0.5
                          delay:0.2
                        options:UIViewAnimationOptionCurveEaseOut
                     animations:^{
                         [_voiceView setAlpha:0];
                     } completion:^(BOOL finished) {
                         _voiceView .frame = voiceRect;
                     }];
}
- (void)openSpeach:(ComicItemBubble*)bbView {
    if (!bbView)
        return;
    
    if(!openStatus)
    {
        [_voiceView setTranslatesAutoresizingMaskIntoConstraints:NO];
        
        openStatus=true;
        voiceViewCenter=_voiceView.center;
        voiceRect=_voiceView.frame;
        self.voiceView.alpha = 1;
        CGRect  animateWidth = self.voiceView.frame;
        animateWidth.size.width = self.view.frame.size.width;
        animateWidth.origin.x = 0;
        
        CGRect boundsFrame = self.voiceView.frame;
        boundsFrame.origin.x = 0;
        
        if ([bbView isPlayVoice])
        {
            [self.btnRecord setImage:[UIImage imageNamed:@"mic_play"] forState:UIControlStateNormal];
            [self.btnRecord setAlpha:0];
            //NSLog(@"Playing sound from Path: %@",recorderFilePath);
            self.voiceView.alpha = 1;
            self.voiceView.frame = boundsFrame;
            [UIView animateWithDuration:[bbView playDuration]
                                  delay:0
                                options:UIViewAnimationOptionCurveEaseInOut animations:^{
                                    [self.btnRecord setAlpha:1];
                                    self.voiceView.frame = animateWidth;
                                } completion:^(BOOL finished) {
                                    
                                }];
            [bbView playAction];
        }else{
            [self.btnRecord setAlpha:1];
            [self.btnRecord setImage:[UIImage imageNamed:@"mic"] forState:UIControlStateNormal];
            [UIView animateWithDuration:.4 delay:.2 usingSpringWithDamping:.8 initialSpringVelocity:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
                self.voiceView.center = CGPointMake(voiceViewCenter.x+self.voiceView.bounds.size.width, voiceViewCenter.y );
                self.voiceView.alpha = 1;
            } completion:^(BOOL finished) {
                [bbView recordAction];
            }];
            [UIView animateWithDuration:7
                                  delay:1
                                options:UIViewAnimationOptionCurveEaseInOut animations:^{
                                    self.voiceView.frame = animateWidth;
                                } completion:^(BOOL finished) {
                                }];
        }
    }
}

-(void)updateTailImage :(UIView*)holderViews imageName:(NSString*)imageName{
    for (UIView *i in [holderViews subviews]){
        if([i isKindOfClass:[UIImageView class]]){
            UIImageView *newLbl = (UIImageView *)i;
            [newLbl setImage:[UIImage imageNamed:imageName]];
        }
    }
}

-(void)changeBubbleTail:(UIView*)bubbleHolderView imageName:(NSString*)bubbleImageString
{
    if (bubbleImageString == nil) {
        return;
    }
    NSLog(@"%@", NSStringFromCGPoint(bubbleHolderView.center));
    CGPoint location = bubbleHolderView.frame.origin;
    if ((location.x + bubbleHolderView.frame.size.width/2) <= self.view.center.x && location.y <= (self.view.center.y - bubbleListView.frame.size.height)) {
        NSLog(@"TOP LEFT");
        [self updateTailImage:bubbleHolderView imageName:[NSString stringWithFormat:@"%@%@",bubbleImageString,BOTTOMRIGHT]];
        
        //Very quick and dirty code, it may have to change later
        if ([[bubbleImageString lowercaseString] containsString:@"firstbubble"]) {
            [self handleBubbleTextFrame:bubbleHolderView frame:CGRectMake(55, 40, 80, 70)];
        }else if ([[bubbleImageString lowercaseString] containsString:@"scared_large"]) {
            [self handleBubbleTextFrame:bubbleHolderView frame:CGRectMake(10,30,120,65)];
        }
    }else if ((location.x + bubbleHolderView.frame.size.width/2) >= self.view.center.x && location.y <= (self.view.center.y - bubbleListView.frame.size.height)) {
        NSLog(@"TOP RIGHT");
        [self updateTailImage:bubbleHolderView imageName:[NSString stringWithFormat:@"%@_%@",bubbleImageString,BOTTOMLEFT]];
        //Very quick and dirty code, it may have to change later
        if ([[bubbleImageString lowercaseString] containsString:@"firstbubble"]) {
            [self handleBubbleTextFrame:bubbleHolderView frame:CGRectMake(55, 40, 80, 70)];
        }else if ([[bubbleImageString lowercaseString] containsString:@"scared_large"]) {
            [self handleBubbleTextFrame:bubbleHolderView frame:CGRectMake(20,30,120,65)];
        }
    }else if (location.x <= self.view.center.x && location.y >= (self.view.center.y - bubbleListView.frame.size.height)) {
        NSLog(@"BOTTOM LEFT");
        [self updateTailImage:bubbleHolderView imageName:[NSString stringWithFormat:@"%@_%@",bubbleImageString,TOPRIGHT]];
        //Very quick and dirty code, it may have to change later
        if ([[bubbleImageString lowercaseString] containsString:@"firstbubble"]) {
            [self handleBubbleTextFrame:bubbleHolderView frame:CGRectMake(50, 70, 80, 70)];
        }else if ([[bubbleImageString lowercaseString] containsString:@"scared_large"]) {
            [self handleBubbleTextFrame:bubbleHolderView frame:CGRectMake(10,50,120,65)];
        }
    }else if (location.x >= self.view.center.x && location.y >= (self.view.center.y - bubbleListView.frame.size.height)) {
        NSLog(@"BOTTOM Right");
        [self updateTailImage:bubbleHolderView imageName:[NSString stringWithFormat:@"%@_%@",bubbleImageString,TOPLEFT]];
        //Very quick and dirty code, it may have to change later
        if ([[bubbleImageString lowercaseString] containsString:@"firstbubble"]) {
            [self handleBubbleTextFrame:bubbleHolderView frame:CGRectMake(50, 70, 80, 70)];
        }else if ([[bubbleImageString lowercaseString] containsString:@"scared_large"]) {
            [self handleBubbleTextFrame:bubbleHolderView frame:CGRectMake(20,50,120,65)];
        }
    }
    else{
        NSLog(@"BOTTOMRIGHT");
        [self updateTailImage:bubbleHolderView imageName:[NSString stringWithFormat:@"%@%@",bubbleImageString,BOTTOMRIGHT]];
        //Very quick and dirty code, it may have to change later
        if ([[bubbleImageString lowercaseString] containsString:@"firstbubble"]) {
            [self handleBubbleTextFrame:bubbleHolderView frame:CGRectMake(55, 40, 80, 70)];
        }
    }
}

-(void)handleBubbleTextFrame:(UIView*)bubbleHolderView frame:(CGRect)rctFrame{
    
    //Very quick and dirty code, it may have to change later
    for (id txtView in [bubbleHolderView subviews]) {
        if ([txtView isKindOfClass:[UITextView class]]) {
            ((UITextView*)txtView).frame = rctFrame;
        }
        if ([txtView isKindOfClass:[UIButton class]]) {
            CGRect rectButton = rctFrame;
            rectButton.origin.x = (rctFrame.origin.x + rctFrame.size.width) - 20;
            rectButton.origin.y = (rctFrame.origin.y + rctFrame.size.height) - 10;
            rectButton.size.height = 16;
            rectButton.size.width = 16;
            ((UIButton*)txtView).frame = rectButton;
        }
    }
}
//END

#pragma mark - UIGestureRecognizerDelegate Methods

//Ramesh GestureRecognizerDelegate
- (void)handleLongPressBubbleGestures:(UILongPressGestureRecognizer *)sender
{
    if (sender.state == UIGestureRecognizerStateBegan)
    {
        [self openSpeach:((ComicItemBubble*)sender.view)];
        
    }else if (sender.state == UIGestureRecognizerStateRecognized)
    {
        //closing speed view with animation
        [self closeSpeach:nil];
        //Stop Recordring;
        [((ComicItemBubble*)sender.view) stopRecording];
        
        //open Audio icon image with animation
        [UIView animateWithDuration:0.7
                              delay:0.2
                            options:UIViewAnimationOptionCurveEaseOut
                         animations:^{
                             [((ComicItemBubble*)sender.view).audioImageButton setAlpha:1];
                         } completion:^(BOOL finished) {
                             
                         }];
        
    }
    
    if (sender.state == UIGestureRecognizerStateEnded)
    {
        [self doAutoSave:sender.view];
    }
    
}
- (void)handlePinchGesture:(UIPinchGestureRecognizer *)recognizer {
    
    static float initialDifference = 0.0;
    static float oldScale = 1.0;
    
    if (recognizer.state == UIGestureRecognizerStateBegan){
        initialDifference = oldScale - recognizer.scale;
    }
    
    CGFloat scale = oldScale - (oldScale - recognizer.scale) + initialDifference;
    
    recognizer.view.transform = CGAffineTransformScale(self.view.transform, scale, scale);
    
    oldScale = scale;
    
    if (recognizer.state == UIGestureRecognizerStateEnded)
    {
        [self doAutoSave:recognizer.view];
    }
    
}
//END

- (void)handleImgvEditTap:(UIGestureRecognizer *)gestureRecognizer
{
    NSArray *subviews = [imgvComic subviews];
    
    for (UIView *view in subviews)
    {
        NSArray *innerSubviews = [view subviews];
        
        for (UIView *view in innerSubviews)
        {
            UIButton *btnDelete = (UIButton *)view;
            
            [btnDelete removeFromSuperview];
        }
    }
}

- (void)rotatePiece:(UIRotationGestureRecognizer *)gestureRecognizer
{
    [self adjustAnchorPointForGestureRecognizer:gestureRecognizer];
    
    if ([gestureRecognizer state] == UIGestureRecognizerStateBegan || [gestureRecognizer state] == UIGestureRecognizerStateChanged)
    {
        [gestureRecognizer view].transform = CGAffineTransformRotate([[gestureRecognizer view] transform], [gestureRecognizer rotation]);
        [gestureRecognizer setRotation:0];
        NSLog(@"RAMESH : rotatePiece");
    }
    
    if ([gestureRecognizer state] == UIGestureRecognizerStateEnded){
        [self doAutoSave:gestureRecognizer.view];
    }
}

- (void)handleLongPressGestures:(UILongPressGestureRecognizer *)sender
{
    if (sender.state == UIGestureRecognizerStateBegan)
    {
        UIImageView *imageView = (UIImageView *)sender.view;
        
        UIButton *deleteButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 15, 15)];
        [deleteButton setImage:[UIImage imageNamed:@"xbutton"] forState:UIControlStateNormal];
        
        [deleteButton addTarget:self action:@selector(deleteSticker:) forControlEvents:UIControlEventTouchUpInside];
        
        [imageView addSubview:deleteButton];
    }
}

- (void)deleteSticker:(UIButton *)sender
{
    UIImageView *imageView = (UIImageView *)sender.superview;
    [imageView removeFromSuperview];
}

- (void)panGestureDetected:(UIPanGestureRecognizer *)recognizer
{
    UIGestureRecognizerState state = [recognizer state];
    
    if (state == UIGestureRecognizerStateBegan || state == UIGestureRecognizerStateChanged)
    {
        CGPoint translation = [recognizer translationInView:imgvComic];
        recognizer.view.center = CGPointMake(recognizer.view.center.x + translation.x,
                                             recognizer.view.center.y + translation.y);
        
        [recognizer setTranslation:CGPointMake(0, 0) inView:imgvComic];
        
        ((ComicItemAnimatedSticker*)recognizer.view).objFrame = recognizer.view.frame;
    }
    
    //Handle remove items
    [self isEndOfPan:recognizer.view success:^(bool isOutOfFrame) {
        if (isOutOfFrame) {
            [recognizer.view setUserInteractionEnabled:NO];
            [recognizer.view removeFromSuperview];
            
            [self doRemoveItem:recognizer.view];
        }
    }];
    if (state == UIGestureRecognizerStateEnded) {
        [self doAutoSave:recognizer.view];
    }
}
- (void)panGestureForAnimatedStickerDetected:(UIPanGestureRecognizer *)recognizer
{
    UIGestureRecognizerState state = [recognizer state];
    
    if (state == UIGestureRecognizerStateBegan || state == UIGestureRecognizerStateChanged)
    {
        CGPoint translation = [recognizer translationInView:imgvComic];
        recognizer.view.center = CGPointMake(recognizer.view.center.x + translation.x,
                                             recognizer.view.center.y + translation.y);
        
        [recognizer setTranslation:CGPointMake(0, 0) inView:imgvComic];
        
        ((ComicItemAnimatedComponent*)recognizer.view).objFrame = recognizer.view.frame;
    }
    
    //Handle remove items
    /* [self isEndOfPan:recognizer.view success:^(bool isOutOfFrame) {
     if (isOutOfFrame) {
     [recognizer.view setUserInteractionEnabled:NO];
     [recognizer.view removeFromSuperview];
     
     [self doRemoveItem:recognizer.view];
     }
     }];*/
    if (state == UIGestureRecognizerStateEnded) {
        [self doAutoSave:recognizer.view];
    }
}

- (void)panGestureBubbleDetected:(UIPanGestureRecognizer *)recognizer
{
    UIGestureRecognizerState state = [recognizer state];
    
    if (state == UIGestureRecognizerStateBegan || state == UIGestureRecognizerStateChanged)
    {
        CGPoint translation = [recognizer translationInView:imgvComic];
        recognizer.view.center = CGPointMake(recognizer.view.center.x + translation.x,
                                             recognizer.view.center.y + translation.y);
        [recognizer setTranslation:CGPointMake(0, 0) inView:imgvComic];
    }
    //Handle remove items
    [self isEndOfPan:recognizer.view success:^(bool isOutOfFrame) {
        if (isOutOfFrame) {
            for (UITextView* tempView in [recognizer.view subviews]) {
                if ([tempView isKindOfClass:[UITextView class]]) {
                    tempView.delegate = nil;
                    //                    [tempView removeObserver:self forKeyPath:@"contentSize"];
                    [tempView resignFirstResponder];
                    [tempView removeFromSuperview];
                    //                    return;
                }
            }
            [recognizer.view removeFromSuperview];
            [self doRemoveItem:recognizer.view];
        }
    }];
    if (state == UIGestureRecognizerStateEnded) {
        
        ComicItemBubble* bubbleView = (ComicItemBubble*)recognizer.view;
        [self changeBubbleTail:recognizer.view imageName:bubbleView.bubbleString];
        
        [self doAutoSave:recognizer.view];
    }
}

- (void)scalePiece:(UIPinchGestureRecognizer *)gestureRecognizer {
    [self adjustAnchorPointForGestureRecognizer:gestureRecognizer];
    
    if([gestureRecognizer state] == UIGestureRecognizerStateBegan) {
        // Reset the last scale, necessary if there are multiple objects with different scales
        lastScale = [gestureRecognizer scale];
        //        NSLog(@"RAMESH :: lastScale %f ",lastScale);
    }
    
    if ([gestureRecognizer state] == UIGestureRecognizerStateBegan ||
        [gestureRecognizer state] == UIGestureRecognizerStateChanged) {
        
        CGFloat currentScale = [[[gestureRecognizer view].layer valueForKeyPath:@"transform.scale"] floatValue];
        
        // Constants to adjust the max/min values of zoom
        const CGFloat kMaxScale = 20.0;
        const CGFloat kMinScale = 0.7;
        
        CGFloat newScale = 1 -  (lastScale - [gestureRecognizer scale]);
        newScale = MIN(newScale, kMaxScale / currentScale);
        newScale = MAX(newScale, kMinScale / currentScale);
        CGAffineTransform transform = CGAffineTransformScale([[gestureRecognizer view] transform], newScale, newScale);
        [gestureRecognizer view].transform = transform;
        //        NSLog(@"RAMESH :: scalePiece scale value X %f Y %f",transform.a , transform.b);
        lastScale = [gestureRecognizer scale];  // Store the previous scale factor for the next pinch gesture call
    }
    
    if ([gestureRecognizer state] == UIGestureRecognizerStateEnded){
        [self doAutoSave:gestureRecognizer.view];
        
        NSLog(@"RAMESH :: lastScale %f ",lastScale);
    }
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
    // if the gesture recognizers are on different views, don't allow simultaneous recognition
    if (gestureRecognizer.view != otherGestureRecognizer.view)
        return NO;
    
    // if either of the gesture recognizers is the long press, don't allow simultaneous recognition
    if ([gestureRecognizer isKindOfClass:[UILongPressGestureRecognizer class]] || [otherGestureRecognizer isKindOfClass:[UILongPressGestureRecognizer class]])
        return NO;
    
    return YES;
}
-(BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer
{
    return YES;
}
- (void)adjustAnchorPointForGestureRecognizer:(UIGestureRecognizer *)gestureRecognizer {
    if (gestureRecognizer.state == UIGestureRecognizerStateBegan) {
        UIView *piece = gestureRecognizer.view;
        CGPoint locationInView = [gestureRecognizer locationInView:piece];
        CGPoint locationInSuperview = [gestureRecognizer locationInView:piece.superview];
        
        piece.layer.anchorPoint = CGPointMake(locationInView.x / piece.bounds.size.width, locationInView.y / piece.bounds.size.height);
        piece.center = locationInSuperview;
    }
}

- (void)singleTapAnimation:(UIGestureRecognizer *)gestureRecognizer
{
    ComicItemAnimatedSticker* imgAnimation = (ComicItemAnimatedSticker*)gestureRecognizer.view;
//=======
//{        ComicItemAnimatedSticker* imgAnimation = (ComicItemAnimatedSticker*)gestureRecognizer.view;
//>>>>>>> origin/Registration_page
    if ([imgAnimation isAnimating]) {
        [imgAnimation stopAnimating];
        pauseAnimation = YES;
    }else{
        [imgAnimation startAnimating];
        pauseAnimation = NO;
    }
//    for(id ObjAnimationCell in [self.ImgvComic2 subviews])
//    {
//        if([ObjAnimationCell isKindOfClass:[ComicItemAnimatedSticker class]]){
//            if ([((ComicItemAnimatedComponent*)ObjAnimationCell) isAnimating]) {
//                [((ComicItemAnimatedComponent*)ObjAnimationCell) stopAnimating];
//            }else{
//                [((ComicItemAnimatedComponent*)ObjAnimationCell) startAnimating];
//            }
//        }
//    }

    for (ComicItemAnimatedComponent* objColl in imgAnimation.animatedComponentArray) {
        if ([objColl isAnimating]) {
            [objColl stopAnimating];
            pauseAnimation = YES;
        }else{
            [objColl startAnimating];
            pauseAnimation = NO;
        }
    }
}
- (void)payPauseAnimation
{
    for(id ObjAnimationCell in [self.imgvComic subviews])
    {
        if([ObjAnimationCell isKindOfClass:[ComicItemAnimatedSticker class]]){
            if ([((ComicItemAnimatedSticker*)ObjAnimationCell) isAnimating]) {
                [((ComicItemAnimatedSticker*)ObjAnimationCell) stopAnimating];
                [self.btnPlayAnimation setImage:[UIImage imageNamed:@"Sticker_play"] forState:UIControlStateNormal];
            }else{
                [((ComicItemAnimatedSticker*)ObjAnimationCell) startAnimating];
                [self.btnPlayAnimation setImage:[UIImage imageNamed:@"Sticker_pause"] forState:UIControlStateNormal];
            }
        }
    }

}

#pragma mark - Tocuh Events

-(NSInteger)getShrinkValue
{
    return [self getSpeedLength];
}
-(NSInteger)getGlideItemHight
{
    if (IS_IPHONE_5)
    {
        return 378;
    }
    else if (IS_IPHONE_6)
    {
        return 444;
    }
    else if (IS_IPHONE_6P)
    {
        return 490;
    }
    else
    {
        return 378;
    }
}

-(NSInteger)getGlideItemWidth
{
    if (IS_IPHONE_5)
    {
        return 195;
    }
    else if (IS_IPHONE_6)
    {
        return 225;
    }
    else if (IS_IPHONE_6P)
    {
        return 250;
    }
    else
    {
        return 195;
    }
}


-(NSInteger)getGlideSpeed{
    return 1;
}
-(NSInteger)getGlidelength{
    return 2;
}
-(NSInteger)getSpeedCount{
    //    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    //    NSString* strValue = [defaults objectForKey:@"shrink_values"];
    //    if (strValue == nil) {
    return 1;
    //    }else
    //        return [strValue intValue];
}
-(NSInteger)getSpeedLength{
    //    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    //    NSString* strValue = [defaults objectForKey:@"shrink_length"];
    //    if (strValue == nil) {
    return 100;
    //    }else
    //        return [strValue intValue];
}
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    UITouch *touch = [touches anyObject];
    
    if (hasStartedBezierForAnimation)
    {
        if ([[NSUserDefaults standardUserDefaults]objectForKey:@"tappEnder"] != nil)
        {
            if (![[[NSUserDefaults standardUserDefaults]objectForKey:@"tappEnder"] isEqualToString:@"not"])
            {
                
                //animationView.hidden = false;
                
                UITouch *mytouch=[[touches allObjects] objectAtIndex:0];
                [self.croppingPath moveToPoint:[mytouch locationInView:self.view]];
                if (allPointsForRedFace == nil)
                {
                    allPointsForRedFace = [[NSMutableArray alloc]init];
                }
                [allPointsForRedFace addObject:[NSValue valueWithCGPoint:[mytouch locationInView:self.view]]];
            }
        }
        else
        {
            //animationView.hidden = false;
            
            UITouch *mytouch=[[touches allObjects] objectAtIndex:0];
            [self.croppingPath moveToPoint:[mytouch locationInView:self.view]];
            if (allPointsForRedFace == nil)
            {
                allPointsForRedFace = [[NSMutableArray alloc]init];
            }
            [allPointsForRedFace addObject:[NSValue valueWithCGPoint:[mytouch locationInView:self.view]]];
        }
    }
    else
    {
        if (touch.view == self.view || touch.view == imgvComic)
        {
            isSlideShrink = NO;
            
            [self.view exchangeSubviewAtIndex:0 withSubviewAtIndex:1];
            //        imgvComic.autoresizesSubviews = YES;
            for (UIView* subview in [imgvComic subviews]) {
                subview.autoresizingMask = UIViewAutoresizingNone;
            }
            self.previousTimestamp = event.timestamp;
            shinkLimit = [touch locationInView:self.view];
        }
    }
}

CGFloat diffX,diffY;
- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    
    if (hasStartedBezierForAnimation)
    {
        CGPoint nowPoint = [[touches anyObject] locationInView:self.view];
        CGPoint prevPoint = [[touches anyObject] previousLocationInView:self.view];
        
        if ([[NSUserDefaults standardUserDefaults]objectForKey:@"tappEnder"] != nil)
        {
            if (![[[NSUserDefaults standardUserDefaults]objectForKey:@"tappEnder"] isEqualToString:@"not"])
            {
                UITouch *mytouch=[[touches allObjects] objectAtIndex:0];
                
                CGPoint touchLocation = [mytouch locationInView:self.view];
                
                // move the image view
                // animationView.center = touchLocation;
                
                [self.croppingPath addLineToPoint:[mytouch locationInView:self.view]];
                [allPointsForRedFace addObject:[NSValue valueWithCGPoint:[mytouch locationInView:self.view]]];
                // [self setNeedsDisplay];
            }
        }
        else
        {
            UITouch *mytouch=[[touches allObjects] objectAtIndex:0];
            
            CGPoint touchLocation = [mytouch locationInView:self.view];
            
            // move the image view
            //animationView.center = touchLocation;
            [self.croppingPath addLineToPoint:[mytouch locationInView:self.view]];
            [allPointsForRedFace addObject:[NSValue valueWithCGPoint:[mytouch locationInView:self.view]]];
            
            //[self setNeedsDisplay];
        }
    }
    else
    {
        UITouch *touch = [touches anyObject];
        CGPoint location = [touch locationInView:self.view];
        
        if ((touch.view == self.view || touch.view == imgvComic || [touch.view isKindOfClass:[ComicItemAnimatedSticker class]]) &&
            (fabs(location.y - shinkLimit.y) > [self getShrinkValue] ||
             fabs(location.x - shinkLimit.x) > [self getShrinkValue]) &&
            self.ImgvComic2.frame.size.height > [self getGlideItemHight]
            )
        {
            CGPoint prevLocation = [touch previousLocationInView:self.view];
            CGFloat xDist = (location.x - prevLocation.x); //[2]
            CGFloat yDist = (location.y - prevLocation.y); //[3]
            
            distanceFromPrevious = sqrt((xDist * xDist) + (yDist * yDist)); //[4]
            
            NSTimeInterval timeSincePrevious = event.timestamp - self.previousTimestamp;
            
            speed = distanceFromPrevious/timeSincePrevious;
            self.previousTimestamp = event.timestamp;
            speed = speed /300;
            CGFloat speedX = speed * 1.2;
            CGFloat speedY = speed * 2.0;
            
            CGFloat speedWidth = speed * 2.4;
            CGFloat speedHeight = speed * 4.0;
            
            NSLog(@"speed :  %f",speed);
            
            CGRect comicFrame = CGRectMake(CGRectGetMinX(self.ImgvComic2.frame) + speedX,
                                           CGRectGetMinY(self.ImgvComic2.frame) + speedY ,
                                           CGRectGetWidth(self.ImgvComic2.frame) - speedWidth,
                                           CGRectGetHeight(self.ImgvComic2.frame) - speedHeight);
            
            comicImageFrame = self.imgvComic.frame;
            
            if (comicFrame.size.height > [self getGlideItemHight])
            {
                self.ImgvComic2.frame = CGRectMake(CGRectGetMinX(self.ImgvComic2.frame) + speedX,
                                                   CGRectGetMinY(self.ImgvComic2.frame) + speedY ,
                                                   CGRectGetWidth(self.ImgvComic2.frame) - speedWidth,
                                                   CGRectGetHeight(self.ImgvComic2.frame) - speedHeight);
                
                self.ImgvComic2.image = printScreen;
                imgvComic.frame = self.ImgvComic2.frame;
                self.imgGifLayer.frame = self.ImgvComic2.frame;
                
                [self shrinkAnimatedImages:speedX speedY:speedY speedWidth:speedWidth speedHeight:speedHeight];
                
            }
        }
    }
}

- (void)shrinkAnimatedImages:(CGFloat)speedX
                      speedY:(CGFloat)speedY
                  speedWidth:(CGFloat)speedWidth
                 speedHeight:(CGFloat)speedHeight
{
    
    
    //    CGFloat ff = 1;
    for (UIView* subview in [self.view subviews]) {
        if ([subview isKindOfClass:[ComicItemAnimatedSticker class]]) {
            
            float ratioX = comicImageFrame.size.width / imgvComic.frame.size.width;
            float ratioY = comicImageFrame.size.height / imgvComic.frame.size.height;
            
            //            ratioX = 1.000178;
            //            ratioY = 1.000167;
            
            //            NSLog(@"comicImageFrame %@",NSStringFromCGRect(imgvComic.frame));
            
            float newX = subview.frame.origin.x + ratioX;
            float newY = subview.frame.origin.y + ratioY;
            
            float newWidth = subview.frame.size.width / ratioX;
            float newHeight = subview.frame.size.height / ratioY;
            
            //            subview.frame = CGRectMake(newX, newY, newWidth, newHeight);
            
            
            //            CGFloat multiplerX,multiplery;
            speedWidth = (subview.frame.size.width*speedWidth)/imgvComic.frame.size.width;
            speedHeight = (subview.frame.size.height*speedHeight)/imgvComic.frame.size.height;
            
            /*
             //            speedX = (speedX * subview.frame.origin.x)/imgvComic.frame.origin.x;
             //            speedY = (speedY * subview.frame.origin.y)/imgvComic.frame.origin.y;
             `
             //            speedX =  self.view.frame.origin.x - imgvComic.frame.origin.x;
             //            speedY =  self.view.frame.origin.y - imgvComic.frame.origin.y;
             
             multiplerX = (self.view.center.x-subview.center.x);
             multiplery = (self.view.center.y-subview.center.y);
             
             int xx = self.view.frame.size.width /imgvComic.frame.size.width;
             int yy = self.view.frame.size.height /imgvComic.frame.size.height;
             
             
             xx = subview.frame.origin.x / xx;
             yy = subview.frame.origin.x / yy;
             
             if (multiplerX>0) {
             multiplerX = multiplerX/(0.26*self.ImgvComic2.frame.size.width);
             }
             else
             {
             multiplerX = multiplerX/(0.9*self.ImgvComic2.frame.size.width);
             }
             if (multiplery>0)
             {
             multiplery = multiplery/(0.175*self.ImgvComic2.frame.size.height);
             }
             else
             {
             multiplery = multiplery/(0.4*self.ImgvComic2.frame.size.height);
             }
             
             NSLog(@"multiplerX %f multiplery %f",multiplerX,multiplery);
             
             //            subview.frame = CGRectMake((CGRectGetMinX(subview.frame) + speedX) -  (CGRectGetWidth(subview.frame) -  speedWidth),
             //                                       (CGRectGetMinY(subview.frame) - speedY) - (CGRectGetHeight(subview.frame) - speedHeight),
             //                                       CGRectGetWidth(subview.frame) -  speedWidth,
             //                                       CGRectGetHeight(subview.frame) - speedHeight);
             
             //            subview.frame = CGRectMake(CGRectGetMinX(subview.frame) + speedX*multiplerX ,
             //                                       CGRectGetMinY(subview.frame) + speedY*multiplery ,
             //                                       CGRectGetWidth(subview.frame) -  speedWidth,
             //                                       CGRectGetHeight(subview.frame) - speedHeight);
             
             //            subview.frame = CGRectMake(CGRectGetMinX(subview.frame) + speedX ,
             //                                       CGRectGetMinY(subview.frame) - speedY,
             //                                       CGRectGetWidth(subview.frame) -  speedWidth,
             //                                       CGRectGetHeight(subview.frame) - speedHeight);
             
             subview.frame = CGRectMake(xx,
             yy ,
             CGRectGetWidth(subview.frame) -  speedWidth,
             CGRectGetHeight(subview.frame) - speedHeight);
             
             NSLog(@"X value :%d  Y Value %d", xx,yy);
             */
            
            subview.frame = CGRectMake(CGRectGetMinX(subview.frame) + (speedX - 0.2),
                                       CGRectGetMinY(subview.frame) + speedY,
                                       CGRectGetWidth(subview.frame) -  speedWidth,
                                       CGRectGetHeight(subview.frame) - speedHeight);
            
        }
    }
    
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    
    if (hasStartedBezierForAnimation)
    {
        // animationView.hidden = true;
        [[NSUserDefaults standardUserDefaults]setObject:@"not" forKey:@"tappEnder"];
        [[NSUserDefaults standardUserDefaults]synchronize];
        
        /* [[NSNotificationCenter defaultCenter] postNotificationName:@"cropFinished"
         object:self];*/
        NSLog(@"%@",self.croppingPath);
        
        hasStartedBezierForAnimation = NO;
        [currentAnimInstSubView removeFromSuperview];
        
        [self addAnimatedSticker:[[[[[currentWorkingAnimation valueForKey:@"resources"] objectAtIndex:currentTapIndex] valueForKey:@"animation"] valueForKey:@"face"] valueForKey:@"imageA"] AtRect:self.croppingPath.bounds];
        currentAnimationTouchPoint = self.croppingPath.bounds.origin;
        currentTapIndex++;
        [self addAnimatedStickerFromStartAtIndex:currentTapIndex];
        
        //[self proceedToAddRealAnimationWithPoint:self.croppingPath.bounds.origin andCurrentIndex:currentTapIndex];
        //[self.delegate didFinishedTouch];
    }
    else
    {
        UITouch *touch = [touches anyObject];
        
        if (touch.view == self.view || touch.view == imgvComic || [touch.view isKindOfClass:[ComicItemAnimatedSticker class]])
        {
            if (self.ImgvComic2.frame.size.height < shrinkHeight && isSlideShrink == NO)
            {
                isSlideShrink = YES;
                
                if (isWideSlide == YES)
                {
                    UIImageView *cropImageView = [[UIImageView alloc] initWithFrame:temImagFrame];
                    cropImageView.image = printScreen;
                    cropImageView.contentMode = UIViewContentModeScaleAspectFit;
                    
                    //CGPoint center  = [self.view convertPoint:self.view.center fromView:parent.superview];
                    
                    CGFloat y = (CGRectGetMaxY(temImagFrame) - CGRectGetMinY(temImagFrame)) / 2;
                    
                    CGRect cropframe = CGRectMake(0, y - (wideBoxHeight / 2), temImagFrame.size.width, wideBoxHeight);
                    
                    UIImage *image = [self croppedImage:printScreen withImageView:cropImageView WithFrame:cropframe];
                    
                    printScreen = image;
                    
                    NSLog(@"cropped");
                    
                }
                
                /*for (UIView* subview in [self.view subviews]) {
                 if ([subview isKindOfClass:[ComicItemAnimatedSticker class]]) {
                 
                 float scaleFactor = self.ImgvComic2.image.size.width / printScreen.size.width;
                 
                 CGRect rectValue = subview.frame;
                 rectValue.origin.x = rectValue.origin.x * scaleFactor;
                 rectValue.origin.y = rectValue.origin.y * scaleFactor;
                 rectValue.size.width = rectValue.size.width * scaleFactor;
                 rectValue.size.height = rectValue.size.height * scaleFactor;
                 subview.frame = rectValue;
                 
                 [self.ImgvComic2 addSubview:subview];
                 }
                 }*/
                
                [self.delegate comicMakingViewControllerWithEditingDone:self
                                                          withImageView:imgvComic
                                                        withPrintScreen:printScreen
                                                           gifLayerPath:self.gifLayerPath
                                                           withNewSlide:isNewSlide
                                                            withPopView:YES withIsWideSlide:isWideSlide];
                
            }
            else
            {
                [self.view exchangeSubviewAtIndex:1 withSubviewAtIndex:0];
                imgvComic.frame = viewFrame;
                self.ImgvComic2.frame = imgvComic.frame;
                self.imgGifLayer.frame = imgvComic.frame;
                self.ImgvComic2.image = nil;
            }
        }
    }
}
-(CGRect)originalRectFromRectGot:(CGRect)rectGot
{
    CGFloat x = rectGot.origin.x;
    CGFloat y = rectGot.origin.y;
    CGFloat width = (1242*rectGot.size.width)/[[[[[[currentWorkingAnimation valueForKey:@"resources"] objectAtIndex:currentTapIndex] valueForKey:@"animation"] valueForKey:@"originalRect"] valueForKey:@"width"] floatValue];
    CGFloat height = (2208*rectGot.size.height)/[[[[[[currentWorkingAnimation valueForKey:@"resources"] objectAtIndex:currentTapIndex] valueForKey:@"animation"] valueForKey:@"originalRect"] valueForKey:@"height"] floatValue];
    return CGRectMake(x, y, width, height);
}
#pragma mark - CropStickerViewControllerDelegate Methods
- (void)cropStickerViewController:(CropStickerViewController *)controll didSelectDoneWithImage:(UIImageView *)stickerImageView withBorderImage:(UIImage *)imageWithBorder
{
    [[GoogleAnalytics sharedGoogleAnalytics] logScreenEvent:@"StickerCreation" Attributes:nil];
    [[GoogleAnalytics sharedGoogleAnalytics] logUserEvent:@"StickerCreation" Action:@"Create" Label:@""];
    stickerImageView.center = self.view.center;
    
    [self.view addSubview:stickerImageView];
    
    [self dismissViewControllerAnimated:YES completion:^{
        
        StickerList *stickerController;
        
        for (UIViewController *controller in self.childViewControllers)
        {
            if ([controller isKindOfClass:[StickerList class]])
            {
                stickerController = (StickerList *)controller;
            }
        }
        
        stickerController.addingSticker = YES;
        
        [stickerController.collectionView performBatchUpdates:^
         {
             [UIView animateWithDuration:0.5 animations:^
              {
                  //[clvView insertItemsAtIndexPaths:@[indexPath]];
                  if (IS_IPHONE_5)
                  {
                      // return CGSizeMake(60, 60);
                      stickerImageView.frame = CGRectMake(60 + 6, CGRectGetMinY(viewStickerList.frame) + 4, 60, 60);
                  }
                  else if (IS_IPHONE_6)
                  {
                      // return CGSizeMake(66, 66);
                      
                      stickerImageView.frame = CGRectMake(66 + 8, CGRectGetMinY(viewStickerList.frame) + 6, 66, 66);
                  }
                  else if (IS_IPHONE_6P)
                  {
                      // return CGSizeMake(72, 72);
                      
                      stickerImageView.frame = CGRectMake(72 + 14, CGRectGetMinY(viewStickerList.frame) + 8, 72, 72);
                  }
                  
                  [stickerController addStickerWithSticker:stickerImageView.image withBorderImage:imageWithBorder];
              }
                              completion:^(BOOL finished)
              {
                  stickerController.addingSticker = NO;
                  [stickerImageView removeFromSuperview];
                  [stickerController.collectionView reloadData];
              }];
         }completion:^(BOOL finished) {
             
             
             // open slide 9 Instruction
             dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0 * NSEC_PER_SEC));
             dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
                 NSLog(@"Do some work");
                 
                 if ([InstructionView getBoolValueForSlide:kInstructionSlide9] == NO)
                 {
                     InstructionView *instView = [[InstructionView alloc] initWithFrame:self.view.bounds];
                     instView.delegate = self;
                     [instView showInstructionWithSlideNumber:SlideNumber9 withType:InstructionBubbleType];
                     [instView setTrueForSlide:kInstructionSlide9];
                     
                     [self.view addSubview:instView];
                 }
             });
             
             
         }];
    }];
}

- (void)cropStickerViewControllerWithCropCancel:(CropStickerViewController *)controll
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - Blackboard Methods
- (void)openBlackBoard
{
    if(isWideSlide)
    {
        if (comicCropView != nil)
        {
            [comicCropView removeFromSuperview];
        }
    }
    
    viewBlackBoard.alpha = 0;
    viewCamera.hidden = YES;
    [self.mSendComicButton setHidden:NO];//dinesh
    btnClose.hidden = YES;
    btnCloseComic.hidden = YES;
    imgvComic.hidden = NO;
    imgvComic.frame =  frameImgvComic;
    
    [self.btnSend setEnabled:YES];
    
    [UIView transitionWithView:imgvComic
                      duration:0.5
                       options:UIViewAnimationOptionTransitionFlipFromLeft
                    animations:^{
                        
                        imgvComic.image = [self prefix_resizeableImageWithColor:[UIColor pinkColor] withFrame:imgvComic.frame];
                        
                    } completion:^(BOOL finished)
     {
         
         BlackboardViewController *blackBoardController;
         
         for (UIViewController *controller in self.childViewControllers)
         {
             if ([controller isKindOfClass:[BlackboardViewController class]])
             {
                 blackBoardController = (BlackboardViewController *)controller;
             }
         }
         
         [UIView beginAnimations:@"ScaleButton" context:NULL];
         [UIView setAnimationDuration: 0.2f];
         blackBoardController.btnPink.selected = YES;
         blackBoardController.btnPink.transform = CGAffineTransformMakeScale(1,1);
         [UIView commitAnimations];
         
         [self changeColorOfBackboardWithColor:[UIColor pinkColor]];
         
         [self openBlackBoardColors];
     }];
}

- (UIImage *)prefix_resizeableImageWithColor:(UIColor *)color withFrame:(CGRect)frame
{
    //    CGRect rect = CGRectMake(0.0f, 0.0f, 3.0f, 3.0f);
    
    CGRect rect = CGRectMake(0.0f,
                             0.0f,
                             CGRectGetWidth(frame),
                             CGRectGetHeight(frame));
    
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGContextSetFillColorWithColor(context, [color CGColor]);
    CGContextFillRect(context, rect);
    
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    image = [image resizableImageWithCapInsets:UIEdgeInsetsMake(0, 0, 0, 0)];
    
    return image;
}

- (void)openBlackBoardColors
{
    [UIView animateWithDuration:.6 delay:0 usingSpringWithDamping:100 initialSpringVelocity:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        
        viewBlackBoard.frame = frameBlackboardView;
        
        viewBlackBoard.alpha = 1;
        
    } completion:^(BOOL finished)
     {
         
     }];
}

- (void)closeBlackBoardColors
{
    [UIView animateWithDuration:.6 delay:0 usingSpringWithDamping:100 initialSpringVelocity:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        
        CGRect frame = viewBlackBoard.frame;
        frame.origin.x = CGRectGetMaxX(self.view.frame);
        viewBlackBoard.frame = frame;
        
        viewBlackBoard.alpha = 0;
        
    } completion:^(BOOL finished) {
        GlobalObject.isBlackBoardOpen = NO;
    }];
    
    
}

- (void)closeBlackBoard
{
    GlobalObject.isBlackBoardOpen = NO;
    
}

- (void)changeColorOfBackboardWithColor:(UIColor *)color
{
    imgvComic.image = [self prefix_resizeableImageWithColor:color withFrame:imgvComic.frame];
    [self doAutoSave:nil];
}

#pragma mark - Drawing Methods
- (void)startDrawing
{
    viewDrawing.alpha = 0;
    viewCamera.hidden = YES;
    [self.mSendComicButton setHidden:NO];//dinesh
    btnClose.hidden = YES;
    btnCloseComic.hidden = YES;
    drawView = [[ACEDrawingView alloc] init];
    drawView.delegate = self;
    
    drawView.frame = CGRectMake(0, 0, CGRectGetWidth(imgvComic.frame),CGRectGetHeight(imgvComic.frame));
    DrawingColorsViewController *drawingController;
    for (UIViewController *controller in self.childViewControllers)
    {
        if ([controller isKindOfClass:[DrawingColorsViewController class]])
        {
            drawingController = (DrawingColorsViewController *)controller;
        }
    }
    [UIView beginAnimations:@"ScaleButton" context:NULL];
    [UIView setAnimationDuration: 0.0f];
    [drawingController allScaleToNormal];
    [UIView commitAnimations];
    [UIView animateWithDuration:.6 delay:0 usingSpringWithDamping:100 initialSpringVelocity:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        
        viewDrawing.frame = frameDrawingView;
        
        viewDrawing.alpha = 1;
        
    } completion:^(BOOL finished)
     {
         [self addDrawingView];
         
         // open slide C Instruction
         dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.3 * NSEC_PER_SEC));
         dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
             NSLog(@"Do some work");
             
             if ([InstructionView getBoolValueForSlide:kInstructionSlideC] == NO)
             {
                 InstructionView *instView = [[InstructionView alloc] initWithFrame:self.view.bounds];
                 instView.delegate = self;
                 [instView showInstructionWithSlideNumber:SlideNumberC withType:InstructionBubbleType];
                 [instView setTrueForSlide:kInstructionSlideC];
                 
                 [self.view addSubview:instView];
             }
         });
         
     }];
    
}

- (void)addDrawingView
{
    //    if (GlobalObject.isTakePhoto == NO)
    //    {
    //        drawView.frame = CGRectMake(0, 0, CGRectGetWidth(drawView.frame),CGRectGetHeight(imgvComic.frame));
    //        imgvComic.hidden = NO;
    //
    //    }
    //    else
    //    {
    ////        float widthRatio = imgvComic.bounds.size.width / imgvComic.image.size.width;
    ////        float heightRatio = imgvComic.bounds.size.height / imgvComic.image.size.height;
    ////        float scale = MIN(widthRatio, heightRatio);
    ////        float imageWidth = scale * imgvComic.image.size.width;
    ////        float imageHeight = scale * imgvComic.image.size.height;
    //
    //        drawView.frame = CGRectMake(0, 0, CGRectGetWidth(drawView.frame),CGRectGetHeight(imgvComic.frame));
    //    }
    imgvComic.userInteractionEnabled = YES;
    [imgvComic addSubview:drawView];
    
    DrawingColorsViewController *drawingController;
    
    for (UIViewController *controller in self.childViewControllers)
    {
        if ([controller isKindOfClass:[DrawingColorsViewController class]])
        {
            drawingController = (DrawingColorsViewController *)controller;
        }
    }
    [UIView beginAnimations:@"ScaleButton" context:NULL];
    [UIView setAnimationDuration: 0.0f];
    [drawingController allScaleToNormal];
    [UIView commitAnimations];
    [UIView beginAnimations:@"ScaleButton" context:NULL];
    [UIView setAnimationDuration: 0.2f];
    [drawingController allScaleToNormal];
    drawingController.btnRed.transform = CGAffineTransformMakeScale(1.8f,1.8f);
    [UIView commitAnimations];
    [self drawingColorTapEventWithColor:@"red"];
}

- (void)removeDrawingView
{
    // imgvComic.userInteractionEnabled = NO;
    
    [drawView removeFromSuperview];
}

- (void)stopDrawing
{
    [[GoogleAnalytics sharedGoogleAnalytics] logUserEvent:@"Drawing" Action:@"Create" Label:@""];
    
    [self setComicImageViewSize];
    
    NSArray *subViews = imgvComic.subviews;
    
    for (UIView *view in subViews)
    {
        if (![view isKindOfClass:[ACEDrawingView class]])
        {
            view.hidden = YES;
        }
    }
    
    //    CGSize size = CGSizeMake(CGRectGetWidth(drawView.frame), CGRectGetHeight(drawView.frame));
    CGSize size = CGSizeMake(CGRectGetWidth(temImagFrame), CGRectGetHeight(temImagFrame));
    imgvComic.frame = temImagFrame;
    
    UIGraphicsBeginImageContextWithOptions(size, NO,1);
    
    [imgvComic.layer renderInContext:UIGraphicsGetCurrentContext()];
    [drawView.layer renderInContext:UIGraphicsGetCurrentContext()];
    
    UIImage *finalImage = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    //    finalImage = [UIImage fixrotation:finalImage];
    
    imgvComic.image = finalImage;
    //    temImagFrame = imgvComic.frame;
    
    viewDrawing.alpha = 1;
    
    for (UIView *view in subViews)
    {
        if (![view isKindOfClass:[ACEDrawingView class]])
        {
            view.hidden = NO;
        }
    }
    
    [UIView animateWithDuration:.6 delay:0 usingSpringWithDamping:100 initialSpringVelocity:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        
        CGRect frame = viewDrawing.frame;
        frame.origin.x = CGRectGetMaxX(self.view.frame);
        viewDrawing.frame = frame;
        
        viewDrawing.alpha = 0;
        btnClose.hidden = NO;
        btnCloseComic.hidden = NO;
        //        [drawView setHidden:YES];
        [drawView removeFromSuperview];
        
    } completion:^(BOOL finished) {
        [self doPrintScreen];
    }];
}

- (void)drawingUndoTap
{
    [drawView undoLatestStep];
}

- (void)drawingColorTapEventWithColor:(NSString *)colorName
{
    [[GoogleAnalytics sharedGoogleAnalytics] logUserEvent:@"DrawingColour" Action:colorName Label:colorName];
    
    RowButtonsViewController *rowController;
    
    for (UIViewController *controller in self.childViewControllers)
    {
        if ([controller isKindOfClass:[RowButtonsViewController class]])
        {
            rowController = (RowButtonsViewController *)controller;
        }
    }
    if ([colorName isEqualToString:@"white"])
    {
        [rowController.btnPen setImage:[UIImage imageNamed:@"pen-icon-white"] forState:UIControlStateSelected];
        
        drawView.lineColor = [UIColor drawingColorWhite];
    }
    else if ([colorName isEqualToString:@"black"])
    {
        [rowController.btnPen setImage:[UIImage imageNamed:@"pen-icon-black"] forState:UIControlStateSelected];
        
        drawView.lineColor = [UIColor blackColor];
    }
    else if ([colorName isEqualToString:@"blue"])
    {
        [rowController.btnPen setImage:[UIImage imageNamed:@"pen-icon-blue"] forState:UIControlStateSelected];
        
        drawView.lineColor = [UIColor drawingColorBlue];
    }
    else if ([colorName isEqualToString:@"red"])
    {
        [rowController.btnPen setImage:[UIImage imageNamed:@"pen-icon-red"] forState:UIControlStateSelected];
        
        drawView.lineColor = [UIColor drawingColorRed];
    }
    else if ([colorName isEqualToString:@"yellow"])
    {
        [rowController.btnPen setImage:[UIImage imageNamed:@"pen-icon-yellow"] forState:UIControlStateSelected];
        
        drawView.lineColor = [UIColor drawingColorYellow];
    }
    else if ([colorName isEqualToString:@"brown"])
    {
        [rowController.btnPen setImage:[UIImage imageNamed:@"pen-icon-brown"] forState:UIControlStateSelected];
        
        drawView.lineColor = [UIColor drawingColorBrown];
    }
    else if ([colorName isEqualToString:@"green"])
    {
        [rowController.btnPen setImage:[UIImage imageNamed:@"pen-icon-green"] forState:UIControlStateSelected];
        
        drawView.lineColor = [UIColor drawingColorGreen];
    }
    else if ([colorName isEqualToString:@"pink"])
    {
        [rowController.btnPen setImage:[UIImage imageNamed:@"pen-icon-pink"] forState:UIControlStateSelected];
        
        drawView.lineColor = [UIColor drawingColorPink];
    }
    else if ([colorName isEqualToString:@"purple"])
    {
        [rowController.btnPen setImage:[UIImage imageNamed:@"pen-icon-purple"] forState:UIControlStateSelected];
        
        drawView.lineColor = [UIColor drawingColorPurple];
    }
    else if ([colorName isEqualToString:@"orange"])
    {
        [rowController.btnPen setImage:[UIImage imageNamed:@"pen-icon-orange"] forState:UIControlStateSelected];
        
        drawView.lineColor = [UIColor drawingColorOrange];
    }
    else if ([colorName isEqualToString:@"cyan"])
    {
        [rowController.btnPen setImage:[UIImage imageNamed:@"pen-icon-cyan"] forState:UIControlStateSelected];
        
        drawView.lineColor = [UIColor drawingColorCyan];
    }
    
    if ([onColor isEqual: drawView.lineColor])
    {
        if (isAlreadyDoubleDrawColor)
        {
            isAlreadyDoubleDrawColor = NO;
            drawView.lineWidth = 2.8f;
        }
        else
        {
            isAlreadyDoubleDrawColor = YES;
            drawView.lineWidth = 5.64f;
        }
    }
    else
    {
        isAlreadyDoubleDrawColor = NO;
        drawView.lineWidth = 2.8f;
        onColor = drawView.lineColor;
    }
}

#pragma mark - ACEDrawingViewDelegate Methods
- (void)drawingView:(ACEDrawingView *)view willBeginDrawUsingTool:(id<ACEDrawingTool>)tool
{
    NSLog(@"start drawing");
    [UIView animateWithDuration:0.2 animations:^{
        viewDrawing.alpha = 0;
    }];
    
}
- (void)drawingView:(ACEDrawingView *)view didEndDrawUsingTool:(id<ACEDrawingTool>)tool
{
    NSLog(@"stop drawing");
    [UIView animateWithDuration:0.2 animations:^{
        viewDrawing.alpha = 1;
    }];
    [self doAutoSave:nil];
}

#pragma mark - AlertView Methods
- (JTAlertView *)showAlertView:(NSString*)message image:(UIImage *)image height:(CGFloat)height
{
    JTAlertView *alertView = [[JTAlertView alloc]initWithTitle:message andImage:image];
    
    alertView.size = CGSizeMake(280,height);
    alertView.popAnimation = YES;
    alertView.parallaxEffect = true;
    alertView.backgroundShadow = true;
    alertView.titleShadow = false;
    
    alertView.overlayColor = [UIColor lightGray];
    alertView.titleColor = [UIColor blackColor];
    
    return alertView;
}

//Ramesh -> function
//// Start/////

#pragma mark - Caption Methods
-(ComicItemCaption*)createCaptionView{
    
    //Create Holder
    
    [[GoogleAnalytics sharedGoogleAnalytics] logUserEvent:@"Caption" Action:@"Create" Label:@""];
    
    ComicItemCaption* captionHolder = [self getComicItems:ComicCaption];
    
    CGRect frameCaptionHolder;
    CGRect frameBGImageView;
    CGRect frameTxtCaption;
    CGRect framePlusButton;
    
    CGFloat fontsize;
    
    if (IS_IPHONE_5)
    {
        frameCaptionHolder = CGRectMake(10, 111, 310, 60);
        frameBGImageView = CGRectMake(0, 0, 300, 33);
        frameTxtCaption = CGRectMake(0, 2, 270, 30);
        framePlusButton = CGRectMake(265, -4, 30, 30);
        fontsize = 17;
        
    }
    else if (IS_IPHONE_6)
    {
        frameCaptionHolder = CGRectMake(10, 111, 367, 60);
        frameBGImageView = CGRectMake(0, 0, 345, 40);
        frameTxtCaption = CGRectMake(0, 2, 320, 35);
        framePlusButton = CGRectMake(310, 2, 30, 30);
        
        fontsize = 20;
    }
    else if (IS_IPHONE_6P)
    {
        frameCaptionHolder = CGRectMake(10, 111, 410, 60);
        frameBGImageView = CGRectMake(0, 0, 380, 40);
        frameTxtCaption = CGRectMake(0, 2, 340, 35);
        framePlusButton = CGRectMake(340, 2, 30, 30);
        
        fontsize = 22;
    }
    else
    {
        frameCaptionHolder = CGRectMake(10, 111, 301, 60);
        frameBGImageView = CGRectMake(0, 0, 280, 33);
        frameTxtCaption = CGRectMake(0, 2, 270, 30);
        framePlusButton = CGRectMake(272, 2, 30, 30);
        
        fontsize = 18;
    }
    
    //    UIView* captionHolder = [[UIView alloc] initWithFrame:CGRectMake(10, 111, 301, 60)];
    //    captionHolder.frame = IS_IPHONE_5?CGRectMake(10, 111, 301, 60):CGRectMake(10, 111, 367, 60);
    captionHolder.frame = frameCaptionHolder;
    
    //    captionHolder.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleTopMargin|UIViewAutoresizingFlexibleRightMargin|UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
    [captionHolder setBackgroundColor:[UIColor clearColor]];
    [captionHolder setDraggable:YES];
    captionHolder.tag = 1232;
    captionHolder.userInteractionEnabled = YES;
    
    //Create Caption BG View
    //    captionHolder.bgImageView = [[UIImageView alloc] initWithFrame:IS_IPHONE_5?CGRectMake(0, 0, 280, 33):CGRectMake(0, 0, 345, 40)];
    
    captionHolder.bgImageView = [[UIImageView alloc] initWithFrame:frameBGImageView];
    
    captionHolder.bgImageView.autoresizingMask = UIViewAutoresizingFlexibleRightMargin|UIViewAutoresizingFlexibleWidth;
    [captionHolder setBackgroundColor:[UIColor clearColor]];
    [captionHolder.bgImageView setImage:[UIImage imageNamed:@"CaptionBgImage"]];
    captionHolder.bgImageView.tag = 1234;
    
    //Create TextView
    //   captionHolder.txtCaption = [[UITextView alloc] initWithFrame:IS_IPHONE_5?CGRectMake(0, -2, 270, 30) :CGRectMake(0, -2, 300, 35) ];
    
    captionHolder.txtCaption = [[UITextView alloc] initWithFrame:frameTxtCaption];
    
    //    captionHolder.txtCaption = [[CaptionTextField alloc] initWithFrame:IS_IPHONE_5?CGRectMake(0, 0, 270, 30) :CGRectMake(0, -2, 280, 35) ];
    //    captionHolder.txtCaption.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleTopMargin|UIViewAutoresizingFlexibleRightMargin|UIViewAutoresizingFlexibleWidth;
    
    
    
    captionHolder.txtCaption.font = [UIFont fontWithName:@"MYRIADPRO-REGULAR" size:fontsize];
    //    captionHolder.txtCaption.delegate = self;
    [captionHolder.txtCaption setBackgroundColor:[UIColor clearColor]];
    captionHolder.txtCaption.textAlignment = NSTextAlignmentCenter;
    [captionHolder.txtCaption becomeFirstResponder];
    captionHolder.txtCaption.text = @"";
    captionHolder.txtCaption.textColor = [UIColor whiteColor];
    captionHolder.txtCaption.tag = CaptionViewTextViewTag;
    captionHolder.txtCaption.tintColor = [UIColor whiteColor];
    //    [captionHolder addSubview:captionHolder.txtCaption];
    
    //Create + Button
    //  captionHolder.plusButton = [[UIButton alloc] initWithFrame:IS_IPHONE_5?CGRectMake(249, 2, 30, 30):CGRectMake(300, 2, 30, 30)];
    
    captionHolder.plusButton = [[UIButton alloc] initWithFrame:framePlusButton];
    
    
    //  captionHolder.plusButton.autoresizingMask = UIViewAutoresizingFlexibleRightMargin|UIViewAutoresizingFlexibleWidth;
    [captionHolder.plusButton setImage:[UIImage imageNamed:@"addColour"] forState:UIControlStateNormal];
    [captionHolder.plusButton addTarget:self action:@selector(colourListButtonClick:) forControlEvents:UIControlEventTouchUpInside];
    captionHolder.plusButton.tag = 1235;
    //    [captionHolder addSubview:captionHolder.plusButton];
    
    //Create Dots Holder
    captionHolder.dotHolder = [[UIView alloc] initWithFrame:CGRectMake(19, 34, 239, 26)];
    captionHolder.dotHolder.autoresizingMask = UIViewAutoresizingFlexibleRightMargin|UIViewAutoresizingFlexibleWidth;
    captionHolder.dotHolder.tag = 1236;
    
    return  captionHolder;
}

-(void)openCaptionView{
    
    [[GoogleAnalytics sharedGoogleAnalytics] logUserEvent:@"Caption" Action:@"AddCaption" Label:@""];
    
    ComicItemCaption* captionView = [self createCaptionView];
    captionView.clipsToBounds = NO;
    captionView.center = captionView.center;
    
    [self addComicItem:captionView ItemImage:nil];
    
    
    //Animation
    UIImageView* tempCaptionBgImageview = [captionView viewWithTag:1234];
    UIButton* temBtnAddColor = [captionView viewWithTag:1235];
    
    CGRect temFrame = captionFrameMain;
    temFrame.size.width = 10;
    temFrame.origin.x = (captionFrameMain.size.width/2) - temFrame.size.width;
    tempCaptionBgImageview.frame = temFrame;
    
    [UIView animateWithDuration:1
                          delay:0.8
                        options:UIViewAnimationOptionCurveEaseIn
                     animations:^{
                         CGRect temFrame = captionFrameMain;
                         temFrame.origin.x = (captionFrameMain.size.width/2) - temFrame.size.width;
                         tempCaptionBgImageview.frame = temFrame;
                     } completion:^(BOOL finished) {
                         [temBtnAddColor setAlpha:0.6];
                     }];
    
    [UIView animateWithDuration:1
                          delay:0.8
                        options:UIViewAnimationOptionCurveEaseIn
                     animations:^{
                         CGRect temFrame = captionFrameMain;
                         temFrame.size.width = captionFrameMain.size.width;
                         tempCaptionBgImageview.frame = temFrame;
                     } completion:^(BOOL finished) {
                         [temBtnAddColor setAlpha:0.6];
                     }];
    
    //End
    
    [self doAutoSave:captionView];
}

-(void)closeCaptionViewWithOutAnimation:(UIView*)holderView{
    [self doRemoveItem:holderView];
    [UIView animateWithDuration:0.5
                          delay:0.2
                        options:UIViewAnimationOptionCurveEaseOut
                     animations:^{
                         [holderView setAlpha:0];
                         [holderView removeFromSuperview];
                     } completion:^(BOOL finished) {
                     }];
}

#pragma mark - Caption TextView

-(void)handleBubbleText:(UITextView*)textView{
    NSMutableParagraphStyle *paragraphStyle = NSMutableParagraphStyle.new;
    paragraphStyle.alignment                = NSTextAlignmentCenter;
    
    NSMutableAttributedString *attibute = [[NSMutableAttributedString alloc] initWithString:textView.text];
    
    [attibute addAttribute:NSParagraphStyleAttributeName value:paragraphStyle range:NSMakeRange(0, textView.text.length)];
    if (textView && ![textView.text isEqualToString:@""] && textView.text.length <= 7) {
        [attibute addAttribute:NSFontAttributeName
                         value:[UIFont fontWithName:@"ArialRoundedMTBold" size:24.0f]
                         range:NSMakeRange(0, textView.text.length)];
    }else{
        
        [attibute addAttribute:NSFontAttributeName
                         value:[UIFont fontWithName:@"ArialRoundedMTBold" size:16.0f]
                         range:NSMakeRange(0, textView.text.length)];
    }
    
    [textView setAttributedText:attibute];
    attibute = nil;
}
-(void)handleCaptionHeight:(UITextView*)textView{
    
    CGRect txtRect_text = textView.frame;
    BOOL isDouble = (txtRect_text.size.height <= CaptionTextViewMinRect.size.height)?YES : NO;
    //Handle Text view
    txtRect_text.size.height = isDouble?txtRect_text.size.height *2 : txtRect_text.size.height/2;
    textView.frame = txtRect_text;
    
    UIView* vw = [textView  superview];
    
    if ([vw viewWithTag:1234])
    {
        CGRect txtRect_Image = [vw viewWithTag:1234].frame;
        txtRect_Image.size.height = isDouble?txtRect_Image.size.height*2:txtRect_Image.size.height/2;
        
        [UIView animateWithDuration:0.5 delay:0.5
                            options:UIViewAnimationOptionCurveEaseInOut
                         animations:^
         {
             [vw viewWithTag:1234].frame = txtRect_Image;
             
         } completion:^(BOOL finished)
         {
             if ([vw viewWithTag:1236]) {
                 CGRect rect_dots = [vw viewWithTag:1236].frame;
                 rect_dots.origin.y = isDouble? rect_dots.origin.y *2:rect_dots.origin.y /2 ;
                 [vw viewWithTag:1236].frame = rect_dots;
             }
             if ([vw viewWithTag:1232]) {
                 CGRect rect_Holder = [vw viewWithTag:1232].frame;
                 rect_Holder.size.height = isDouble?rect_Holder.size.height*2:rect_Holder.size.height/2;
                 [vw viewWithTag:1232].frame = rect_Holder;
             }
         }];
    }
}

#pragma mark - Bubble TextView Events
-(void)textViewDidBeginEditing:(UITextView *)textView
{
    textView.textContainerInset = UIEdgeInsetsZero;
    textView.textContainer.lineFragmentPadding = 0;
    
}
- (BOOL)textViewShouldEndEditing:(UITextView *)textView
{
    if (textView.tag == CaptionViewTextViewTag)
    {
        [textView resignFirstResponder];
        [self doAutoSave:nil];
        return YES;
    }
    else
    {
        // open slide D Instruction
        dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.3 * NSEC_PER_SEC));
        dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
            NSLog(@"Do some work");
            
            if ([InstructionView getBoolValueForSlide:kInstructionSlideD] == NO)
            {
                InstructionView *instView = [[InstructionView alloc] initWithFrame:self.view.bounds];
                instView.delegate = self;
                [instView showInstructionWithSlideNumber:SlideNumberD withType:InstructionBubbleType];
                [instView setTrueForSlide:kInstructionSlideD];
                
                [self.view addSubview:instView];
            }
        });
        
    }
    
    [self handleBubbleText:textView];
    [self doAutoSave:nil];
    
    return YES;
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
    
    if (textView.tag == CaptionViewTextViewTag)
    {
        int limit = 60;
        
        //  NSUInteger newLength = (textView.text.length - range.length) + text.length;
        
        NSString *newString = [textView.text stringByReplacingCharactersInRange:range withString:text];
        
        
        if (textView.text.length > 29)
        {
            if (_captionHeightSmall == YES)
            {
                _captionHeightSmall = NO;
                [self handleCaptionHeight:textView];
            }
            //            else
            //            {
            //                _captionHeightSmall = YES;
            //            }
        }
        else if (textView.text.length > 0 || textView.text.length <= 28)
        {
            if (_captionHeightSmall == NO)
            {
                [self handleCaptionHeight:textView];
                
                _captionHeightSmall = YES;
            }
        }
        
        if (textView.text.length == 29)
        {
            textView.text = [[NSString alloc] initWithFormat:@"%@\n",newString];
            [textView becomeFirstResponder];
        }
        
        if([text isEqualToString:@"\n"] && textView.text.length != 29)
        {
            [textView resignFirstResponder];
            return NO;
        }
        
        if (textView.text.length == 1) {
            //NSTimer calling Method B, as long the audio file is playing, every 1 seconds.
            [NSTimer scheduledTimerWithTimeInterval:1.0f
                                             target:self selector:@selector(colourListButtonClick:) userInfo:nil repeats:NO];
        }
        
        return !([textView.text length]>= limit && [text length] >= range.length);
        
    }
    else
    {
        //disable Long presss
        for (UIGestureRecognizer *recognizer in textView.gestureRecognizers)
        {
            if ([recognizer isKindOfClass:[UILongPressGestureRecognizer class]]){
                recognizer.enabled = NO;
            }
        }
        [self handleBubbleText:textView];
        if([text isEqualToString:@"\n"]) {
            [textView resignFirstResponder];
            return NO;
        }
        
        int limit = 30;
        return !([textView.text length]>= limit && [text length] >= range.length);
    }
    
    return YES;
}

#pragma mark Caption - TextField Events

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    return YES;
}

- (BOOL)textFieldShouldEndEditing:(UITextField *)textField
{
    return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    
    [self doAutoSave:[imgvComic viewWithTag:1232]];
    
    return YES;
}

-(BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    
    if (string.length == 1) {
        //NSTimer calling Method B, as long the audio file is playing, every 1 seconds.
        [NSTimer scheduledTimerWithTimeInterval:1.0f
                                         target:self selector:@selector(colourListButtonClick:) userInfo:nil repeats:NO];
    }
    
    //limit the size :
    int limit = 48;
    return !([textField.text length]>= limit && [string length] >= range.length);
}

-(void)showCaptionTextColurButton{
    
    if (colourBoxTimer) {
        [colourBoxTimer invalidate];
    }
    colourBoxTimer = [NSTimer scheduledTimerWithTimeInterval:6.0f
                                                      target:self selector:@selector(hideColourList) userInfo:nil repeats:NO];
    
    [UIView animateWithDuration:1 delay:0.5
         usingSpringWithDamping:100
          initialSpringVelocity:0
                        options:UIViewAnimationOptionCurveEaseInOut
                     animations:^{
                         if ([imgvComic viewWithTag:1232]) {
                             UIView* tempDotHolder = [[imgvComic viewWithTag:1232] viewWithTag:1236];
                             for (UIButton* btn in [tempDotHolder subviews]) {
                                 [btn setAlpha:1];
                             }
                         }
                     } completion:^(BOOL finished) {
                         //                         [self doAutoSave:[imgvComic viewWithTag:1232]];
                     }];
}

-(void)hideCaptionTextColurButton{
    [colourBoxTimer invalidate];
    [UIView animateWithDuration:1 delay:0.5
         usingSpringWithDamping:100
          initialSpringVelocity:0
                        options:UIViewAnimationOptionCurveEaseInOut
                     animations:^{
                         if ([imgvComic viewWithTag:1232]) {
                             UIView* tempDotHolder = [[imgvComic viewWithTag:1232] viewWithTag:1236];
                             for (UIButton* btn in [tempDotHolder subviews]) {
                                 [btn setAlpha:0];
                             }
                         }
                         
                     } completion:^(BOOL finished) {
                         //                         [self doAutoSave:[imgvComic viewWithTag:1232]];
                     }];
}
#pragma Caption Events

- (IBAction)captionColourButtonClick:(id)sender {
    
    UIButton* btn = ((UIButton*)sender);
    int tagValue = -1;
    if (btn) {
        tagValue = (int)btn.tag - 100;
        NSString* selectedColourString = [captionTextColourArray objectAtIndex:tagValue];
        UIColor* selectedColour = [UIColor colorWithHexStr:selectedColourString];
        
        [[GoogleAnalytics sharedGoogleAnalytics] logUserEvent:@"CaptionColour" Action:[selectedColour description] Label:@""];
        [[GoogleAnalytics sharedGoogleAnalytics] logUserEvent:@"CaptionColourHex" Action:selectedColourString Label:@""];
        
        if ([imgvComic viewWithTag:1232]) {
            UIImageView* tempImageView = [[imgvComic viewWithTag:1232] viewWithTag:1234];
            if (tempImageView) {
                UIImage* imgTemp = tempImageView.image;
                tempImageView.image = [imgTemp imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
                tempImageView.tintColor = selectedColour;
                ComicItemCaption* holder = (ComicItemCaption*)[imgvComic viewWithTag:1232];
                holder.tintColourString = selectedColourString;
            }
            
            [self doAutoSave:[imgvComic viewWithTag:1232]];
        }
    }
}

- (void)hideColourList{
    [self hideCaptionTextColurButton];
}

- (IBAction)colourListButtonClick:(id)sender {
    [self showCaptionTextColurButton];
}

//// END /////

#pragma mark ComicItems Events

//- (void)addStickerWithImageView:(UIImageView *)imageView ComicItemImage:(UIImage*)itemImage rectValue:(CGRect)rect
//{
//
//    if (!CGRectEqualToRect(rect,CGRectZero)) {
//        imageView.frame = rect;
//    }
//    imageView.image = imageView.image;
//    imageView.userInteractionEnabled = YES;
//
//    imageView.contentMode = UIViewContentModeScaleAspectFit;
//    imageView.userInteractionEnabled = YES;
//    imageView.clipsToBounds = NO;
//    [imageView setBackgroundColor:[UIColor clearColor]];
//
//    UIRotationGestureRecognizer *rotationGesture = [[UIRotationGestureRecognizer alloc] initWithTarget:self action:@selector(rotatePiece:)];
//    [imageView addGestureRecognizer:rotationGesture];
//
//    UIPinchGestureRecognizer *pinchGesture = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(scalePiece:)];
//    [pinchGesture setDelegate:self];
//    [imageView addGestureRecognizer:pinchGesture];
//
//    UIPanGestureRecognizer *panGestureRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panGestureDetected:)];
//    [panGestureRecognizer setDelegate:self];
//    [imageView addGestureRecognizer:panGestureRecognizer];
//
//
//    UITapGestureRecognizer *tapImgvEdit = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleImgvEditTap:)];
//    tapImgvEdit.cancelsTouchesInView = YES;
//    tapImgvEdit.numberOfTapsRequired = 1;
//    tapImgvEdit.delegate = self;
//    [imageView addGestureRecognizer:tapImgvEdit];
//
//    imgvComic.userInteractionEnabled = YES;
//    imgvComic.clipsToBounds = YES;
//
//    [imgvComic addSubview:imageView];
//}

CGAffineTransform makeTransform(CGFloat xScale, CGFloat yScale,
                                CGFloat theta, CGFloat tx, CGFloat ty)
{
    CGAffineTransform transform = CGAffineTransformIdentity;
    
    transform.a = xScale * cos(theta);
    transform.b = yScale * sin(theta);
    transform.c = xScale * -sin(theta);
    transform.d = yScale * cos(theta);
    transform.tx = tx;
    transform.ty = ty;
    
    return transform;
}

- (void)addStickerWithImageView:(UIImageView *)imageView ComicItemImage:(UIImage*)itemImage rectValue:(CGRect)rect Tranform:(CGAffineTransform)tranformData
{
    CGAffineTransform transform ;
    if (!CGRectEqualToRect(rect,CGRectZero)) {
        if ([imageView isKindOfClass:[ComicItemSticker class]])
        {
            imageView.contentMode = UIViewContentModeScaleAspectFit;
            CGFloat angle = ((ComicItemSticker*)imageView).angle;
            CGFloat scaleValueX = ((ComicItemSticker*)imageView).scaleValueX;
            CGFloat scaleValueY = ((ComicItemSticker*)imageView).scaleValueY;
            CGFloat tX = ((ComicItemSticker*)imageView).tX;
            CGFloat tY = ((ComicItemSticker*)imageView).tY;
            transform = makeTransform(scaleValueX,scaleValueY,angle,tX,tY);
            imageView.transform =transform;
            
        }else if ([imageView isKindOfClass:[ComicItemExclamation class]])
        {
            imageView.contentMode = UIViewContentModeScaleAspectFit;
            CGFloat angle = ((ComicItemExclamation*)imageView).angle;
            CGFloat scaleValueX = ((ComicItemExclamation*)imageView).scaleValueX;
            CGFloat scaleValueY = ((ComicItemExclamation*)imageView).scaleValueY;
            CGFloat tX = ((ComicItemExclamation*)imageView).tX;
            CGFloat tY = ((ComicItemExclamation*)imageView).tY;
            
            transform = makeTransform(scaleValueX,scaleValueY,angle,tX,tY);
            imageView.transform =transform;
        }
    }else{
        imageView.contentMode = UIViewContentModeScaleAspectFit;
        imageView.image = imageView.image;
    }
    imageView.userInteractionEnabled = YES;
    imageView.userInteractionEnabled = YES;
    imageView.clipsToBounds = NO;
    [imageView setBackgroundColor:[UIColor clearColor]];
    
    UIRotationGestureRecognizer *rotationGesture = [[UIRotationGestureRecognizer alloc] initWithTarget:self action:@selector(rotatePiece:)];
    [imageView addGestureRecognizer:rotationGesture];
    
    UIPinchGestureRecognizer *pinchGesture = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(scalePiece:)];
    [pinchGesture setDelegate:self];
    [imageView addGestureRecognizer:pinchGesture];
    
    UIPanGestureRecognizer *panGestureRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panGestureDetected:)];
    [panGestureRecognizer setDelegate:self];
    [imageView addGestureRecognizer:panGestureRecognizer];
    
    imgvComic.userInteractionEnabled = YES;
    imgvComic.clipsToBounds = YES;
    
    UIImage* imgWithOutAlpha = [imageView.image imageByTrimmingTransparentPixelsRequiringFullOpacity:NO];
    imageView.image = nil;
    imageView.image = imgWithOutAlpha;
    
    [imgvComic addSubview:imageView];
}

- (void)addAnimatedImageView:(ComicItemAnimatedSticker *)imageView
              ComicItemImage:(UIImage*)itemImage
                   rectValue:(CGRect)rect
                    Tranform:(CGAffineTransform)tranformData
{
    /* CGAffineTransform transform ;
     if (!CGRectEqualToRect(rect,CGRectZero)) {
     if ([imageView isKindOfClass:[ComicItemAnimatedSticker class]])
     {
     imageView.contentMode = UIViewContentModeScaleAspectFit;
     CGFloat angle = ((ComicItemAnimatedSticker*)imageView).angle;
     CGFloat scaleValueX = ((ComicItemAnimatedSticker*)imageView).scaleValueX;
     CGFloat scaleValueY = ((ComicItemAnimatedSticker*)imageView).scaleValueY;
     CGFloat tX = ((ComicItemAnimatedSticker*)imageView).tX;
     CGFloat tY = ((ComicItemAnimatedSticker*)imageView).tY;
     transform = makeTransform(scaleValueX,scaleValueY,angle,tX,tY);
     imageView.transform =transform;
     }
     }else{*/
    imageView.contentMode = UIViewContentModeScaleAspectFit;
    //}
    
    //[imageView performSelector:@selector(setImage:) withObject:[UIImage sd_animatedGIFNamed:((ComicItemAnimatedSticker*)imageView).animatedStickerName] afterDelay:((ComicItemAnimatedSticker*)imageView).startDelay];
    
    
    // imageView.image = [UIImage sd_animatedGIFNamed:((ComicItemAnimatedSticker*)imageView).animatedStickerName];
    imageView.userInteractionEnabled = YES;
    imageView.clipsToBounds = NO;
    [imageView setBackgroundColor:[UIColor clearColor]];
    
    /*  UIRotationGestureRecognizer *rotationGesture = [[UIRotationGestureRecognizer alloc] initWithTarget:self action:@selector(rotatePiece:)];
     [imageView addGestureRecognizer:rotationGesture];*/
    
    if (!CGRectEqualToRect(imageView.objFrame,CGRectZero)) {
        imageView.frame = imageView.objFrame;
    }
//    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(singleTapAnimation:)];
//    tapGesture.numberOfTapsRequired = 1;
//    [imageView addGestureRecognizer:tapGesture];
    
    UIRotationGestureRecognizer *rotationGesture = [[UIRotationGestureRecognizer alloc] initWithTarget:self action:@selector(rotatePiece:)];
    [imageView addGestureRecognizer:rotationGesture];
    
    UIPinchGestureRecognizer *pinchGesture = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(scalePiece:)];
    [pinchGesture setDelegate:self];
    [imageView addGestureRecognizer:pinchGesture];
    
    UIPanGestureRecognizer *panGestureRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panGestureDetected:)];
    [panGestureRecognizer setDelegate:self];
    [imageView addGestureRecognizer:panGestureRecognizer];
    
    
    imgvComic.userInteractionEnabled = YES;
    imgvComic.clipsToBounds = YES;
    
    haveAnimationOnPage = YES;
    imageView.objFrame = imageView.frame;
    
//    NSURL *MyURL = [[NSBundle mainBundle] URLForResource:@"" withExtension:@"gif"];
//    
//    [imageView initWithAnimationAtURL:MyURL startImmediately:YES];
    
//    ((ComicItemAnimatedSticker*)imageView).image = [YYImage imageNamed:imageView.combineAnimationFileName];
//    NSString *animationPath = [[NSBundle mainBundle] pathForResource:@"OMG" ofType:@"gif"];
    imageView.image =  [UIImage sd_animatedGIFNamed:imageView.combineAnimationFileName];//  [YYImage imageWithContentsOfFile:animationPath];
//    ((ComicItemAnimatedSticker*)imageView).image = [YYImage imageWithContentsOfFile:animationPath];
    
    //    if (imageView.combineAnimationFileName) {
    //        //it had image,
    //        NSString *animationPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    //        animationPath = [[animationPath stringByAppendingPathComponent:((ComicItemAnimatedSticker*)imageView).combineAnimationFileName] stringByAppendingString:@".gif"];
    //
    ////        animationPath = [animationPath stringByAppendingPathComponent:((ComicItemAnimatedSticker*)imageView).combineAnimationFileName];
    //
    ////        YYImage *image = [YYImage imageNamed:@"Animation_Curious_CC_02"];
    //        ((ComicItemAnimatedSticker*)imageView).image = [YYImage imageWithContentsOfFile:animationPath];
    ////        imageView.image = [YYImage imageWithContentsOfFile:animationPath];;
    ////        [imageView startAnimating];
    //
    ////        NSData *imgData = [[NSData alloc] initWithContentsOfURL:[NSURL fileURLWithPath:animationPath]];
    ////        imageView.image = [[UIImage alloc] initWithData:imgData];
    ////        imageView.image = [YYImage imageWithData:imgData];
    //
    //        refAnimatedSticker = (ComicItemAnimatedComponent*)[imageView.animatedComponentArray lastObject];
    //    }else{
    ////        refAnimatedSticker = (ComicItemAnimatedSticker *)imageView;
    //        if (currentTapIndex==0)
    //        {
    ////            arrOfActiveAnimations = [[NSMutableArray alloc]init];
    //        }
    ////        [arrOfActiveAnimations addObject:((ComicItemAnimatedSticker*)imageView)];
    //        if (currentTapIndex==[[currentWorkingAnimation valueForKey:@"resources"] count]-1)
    //        {
    //            if ([currentWorkingAnimation valueForKey:@"isMovable"])
    //            {
    //                [self addPanEventWithIndexFor:imageView];
    //            }
    //            [self createOneGifInBackgroundFromCurrentArray:((ComicItemAnimatedSticker*)imageView).animatedComponentArray
    //                                  ComicItemAnimatedSticker:((ComicItemAnimatedSticker*)imageView)];
    //            [self startAnimatingAfterDelay];
    //        }
    //    }
    
    //    [self.view insertSubview:imageView atIndex:currentTapIndex+0];
    //    [self.view bringSubviewToFront:imageView];
    /*imgvComic.userInteractionEnabled = YES;
     imgvComic.clipsToBounds = YES;
     
     [imgvComic addSubview:imageView];
     [imgvComic bringSubviewToFront:imageView];*/
    //    if([self getAnimatesStickerFromComic] == nil){
    [imgvComic addSubview:imageView];
    [imgvComic bringSubviewToFront:imageView];
    
    [self.btnPlayAnimation setHidden:NO];
    
//    [self.view addSubview:imageView];
//    [self.view bringSubviewToFront:imageView];
   // // [imgvComic bringSubviewToFront:imageView];
    //    }
}

- (void)addBubbleWithImage:(ComicItemBubble *)bubbleHolderView ComicItemImage:(UIImage*)itemImage rectValue:(CGRect)rect
{
    CGAffineTransform transform ;
    if (!CGRectEqualToRect(rect,CGRectZero)) {
        bubbleHolderView.frame = rect;
        bubbleHolderView.contentMode = UIViewContentModeScaleAspectFit;
        CGFloat angle = ((ComicItemSticker*)bubbleHolderView).angle;
        CGFloat scaleValueX = ((ComicItemSticker*)bubbleHolderView).scaleValueX;
        CGFloat scaleValueY = ((ComicItemSticker*)bubbleHolderView).scaleValueY;
        CGFloat tX = ((ComicItemSticker*)bubbleHolderView).tX;
        CGFloat tY = ((ComicItemSticker*)bubbleHolderView).tY;
        transform = makeTransform(scaleValueX,scaleValueY,angle,tX,tY);
        bubbleHolderView.transform =transform;
    }
    
    bubbleHolderView.clipsToBounds = NO;
    [bubbleHolderView setBackgroundColor:[UIColor clearColor]];
    
    UIPanGestureRecognizer *panGestureRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panGestureBubbleDetected:)];
    [panGestureRecognizer setDelegate:self];
    [bubbleHolderView addGestureRecognizer:panGestureRecognizer];
    
    //Adding Bubble image
    for (id imgView in [bubbleHolderView subviews]) {
        if ([imgView isKindOfClass:[UIImageView class]]) {
            UIImageView* imgViewObj = (UIImageView*)imgView;
            imgViewObj.contentMode = UIViewContentModeScaleAspectFit;
        }else if([imgView isKindOfClass:[UIButton class]]){
            UIButton* imagebtn = (UIButton*)imgView;
            imagebtn.property = bubbleHolderView.bubbleString;
        }
    }
    
    if (bubbleHolderView.imageView.image == nil) {
        bubbleHolderView.imageView.image = [UIImage imageNamed:bubbleHolderView.bubbleString];
    }
    
    bubbleHolderView.imageView.contentMode = UIViewContentModeScaleAspectFill;
    bubbleHolderView.imageView.tag = 2020;
    
    bubbleHolderView.txtBuble.delegate = self;
    //    [bubbleHolderView.txtBuble setBackgroundColor:[UIColor clearColor]];
    bubbleHolderView.txtBuble.font = [UIFont fontWithName:@"ARLRDBD" size:20];
    bubbleHolderView.txtBuble.textColor = [UIColor blackColor];
    bubbleHolderView.txtBuble.returnKeyType = UIReturnKeyDone;
    bubbleHolderView.txtBuble.opaque = YES;
    bubbleHolderView.txtBuble.textAlignment = NSTextAlignmentCenter;
    CGFloat centerLeftValue = bubbleHolderView.txtBuble.frame.size.width/2;
    CGFloat centerTopValue = bubbleHolderView.txtBuble.frame.size.height/2;
    
    bubbleHolderView.txtBuble.contentInset = UIEdgeInsetsMake(centerTopValue - 10,centerLeftValue,0,0.0);
    bubbleHolderView.txtBuble.scrollEnabled = NO;
    bubbleHolderView.txtBuble.autocorrectionType = UITextAutocorrectionTypeNo;
    if (![bubbleHolderView.txtBuble.text isEqualToString:@""]) {
        [self textViewShouldEndEditing:bubbleHolderView.txtBuble];
    }
    
    for (UIGestureRecognizer *recognizer in bubbleHolderView.txtBuble.gestureRecognizers) {
        if ([recognizer isKindOfClass:[UILongPressGestureRecognizer class]]){
            recognizer.enabled = NO;
        }
    }
    
    //Add Bubble audio
    bubbleHolderView.audioImageButton.contentMode = UIViewContentModeScaleAspectFit;
    [bubbleHolderView.audioImageButton setImage:[UIImage imageNamed:@"bubbleAudioPlay"] forState:UIControlStateNormal];
    if ([bubbleHolderView isPlayVoice]) {
        [bubbleHolderView.audioImageButton setAlpha:1];
    }else{
        [bubbleHolderView.audioImageButton setAlpha:0];
    }
    
    //Adding Long Press event
    UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(handleLongPressBubbleGestures:)];
    longPress.minimumPressDuration = 0.5f;
    [bubbleHolderView addGestureRecognizer:longPress];
    
    UIPinchGestureRecognizer *pinchRecognizer = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(handlePinchGesture:)];
    [pinchRecognizer setDelegate:self];
    [bubbleHolderView addGestureRecognizer:pinchRecognizer];
    
    //Adding controller to holder
    [bubbleHolderView addSubview:bubbleHolderView.imageView];
    [bubbleHolderView addSubview:bubbleHolderView.imagebtn];
    [bubbleHolderView addSubview:bubbleHolderView.audioImageButton];
    [bubbleHolderView addSubview:bubbleHolderView.txtBuble];
    
    imgvComic.userInteractionEnabled = YES;
    imgvComic.clipsToBounds = YES;
    
    [imgvComic addSubview:bubbleHolderView];
    
    bubbleHolderView.center = bubbleHolderView.center;
}

- (void)addCaptionView:(ComicItemCaption *)captionHolder rectValue:(CGRect)rect
{
    
    if (!CGRectEqualToRect(rect,CGRectZero)) {
        captionHolder.frame = rect;
    }
    
    [captionHolder setDraggable:YES];
    captionHolder.tag = 1232;
    captionHolder.userInteractionEnabled = YES;
    
    
    //Create Caption BG View
    [captionHolder setBackgroundColor:[UIColor clearColor]];
    captionHolder.bgImageView.tag = 1234;
    if (captionHolder.tintColourString && ![captionHolder.tintColourString isEqualToString:@""]) {
        //        captionHolder.bgImageView = nil;
        //            captionHolder.bgImageView = [[UIImageView alloc] initWithFrame:IS_IPHONE_5?CGRectMake(0, 0, 280, 33):CGRectMake(0, 0, 345, 40)];
        //        captionHolder.bgImageView = [[UIImageView alloc] initWithFrame:IS_IPHONE_5?CGRectMake(0, 0, 280, 33):CGRectMake(0, 0, 345, 40)];
        captionHolder.bgImageView.autoresizingMask = UIViewAutoresizingFlexibleRightMargin|UIViewAutoresizingFlexibleWidth;
        [captionHolder setBackgroundColor:[UIColor clearColor]];
        [captionHolder.bgImageView setImage:[UIImage imageNamed:@"CaptionBgImage"]];
        captionHolder.bgImageView.tag = 1234;
        captionHolder.bgImageView.image = [captionHolder.bgImageView.image imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
        captionHolder.bgImageView.tintColor = [UIColor colorWithHexStr:captionHolder.tintColourString];
    }else{
        [captionHolder.bgImageView setImage:[UIImage imageNamed:@"CaptionBgImage"]];
    }
    
    [captionHolder addSubview:captionHolder.bgImageView];
    
    
    CGRect frameCaptionHolder;
    CGRect frameBGImageView;
    CGRect frameTxtCaption;
    CGRect framePlusButton;
    
    CGFloat fontsize;
    
    if (IS_IPHONE_5)
    {
        frameCaptionHolder = CGRectMake(10, 111, 310, 60);
        frameBGImageView = CGRectMake(0, 0, 300, 33);
        frameTxtCaption = CGRectMake(0, 2, 270, 30);
        framePlusButton = CGRectMake(265, 0, 30, 30);
        fontsize = 17;
    }
    else if (IS_IPHONE_6)
    {
        frameCaptionHolder = CGRectMake(10, 111, 367, 60);
        frameBGImageView = CGRectMake(0, 0, 345, 40);
        frameTxtCaption = CGRectMake(0, 2, 320, 35);
        framePlusButton = CGRectMake(310, 2, 30, 30);
        
        fontsize = 20;
        
    }
    else if (IS_IPHONE_6P)
    {
        frameCaptionHolder = CGRectMake(10, 111, 410, 60);
        frameBGImageView = CGRectMake(0, 0, 380, 40);
        frameTxtCaption = CGRectMake(0, 2, 340, 35);
        framePlusButton = CGRectMake(340, 2, 30, 30);
        
        fontsize = 22;
    }
    else
    {
        frameCaptionHolder = CGRectMake(10, 111, 301, 60);
        frameBGImageView = CGRectMake(0, 0, 280, 33);
        frameTxtCaption = CGRectMake(0, 2, 270, 30);
        framePlusButton = CGRectMake(272, 2, 30, 30);
        
        fontsize = 18;
    }
    
    captionHolder.txtCaption.font = [UIFont fontWithName:@"MYRIADPRO-REGULAR" size:fontsize];
    
    captionHolder.txtCaption.delegate = self;
    //    captionHolder.txtCaption.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleTopMargin|UIViewAutoresizingFlexibleRightMargin|UIViewAutoresizingFlexibleWidth;
    [captionHolder.txtCaption setBackgroundColor:[UIColor clearColor]];
    captionHolder.txtCaption.textAlignment = NSTextAlignmentCenter;
    captionHolder.txtCaption.textColor = [UIColor whiteColor];
    //    captionHolder.txtCaption.center = CGPointMake(captionHolder.bgImageView.frame.size.width  / 2,
    //                                     captionHolder.bgImageView.frame.size.height / 2);
    //    captionHolder.txtCaption
    
    captionHolder.txtCaption.textContainer.maximumNumberOfLines = 2;
    captionHolder.txtCaption.textContainer.lineBreakMode = NSLineBreakByTruncatingTail;
    captionHolder.txtCaption.scrollEnabled = NO;
    captionHolder.txtCaption.autocorrectionType = UITextAutocorrectionTypeNo;
    captionHolder.txtCaption.returnKeyType = UIReturnKeyDone;
    CaptionTextViewMinRect = IS_IPHONE_5?CGRectMake(0, 0, 270, 30) :CGRectMake(0, -2, 300, 35);
    
    [captionHolder addSubview:captionHolder.txtCaption];
    
    //Create + Button
    captionHolder.plusButton.frame = framePlusButton;
    captionHolder.plusButton.autoresizingMask = UIViewAutoresizingFlexibleRightMargin|UIViewAutoresizingFlexibleWidth;
    [captionHolder.plusButton setImage:[UIImage imageNamed:@"addColour"] forState:UIControlStateNormal];
    [captionHolder.plusButton removeTarget:self action:nil forControlEvents:UIControlEventTouchUpInside];
    [captionHolder.plusButton addTarget:self action:@selector(colourListButtonClick:) forControlEvents:UIControlEventTouchUpInside];
    captionHolder.plusButton.tag = 1235;
    [captionHolder.plusButton setUserInteractionEnabled:YES];
    [captionHolder.plusButton setBackgroundColor:[UIColor clearColor]];
    [captionHolder addSubview:captionHolder.plusButton];
    
    //Create Dots Holder
    captionHolder.dotHolder.tag = 1236;
    for (UIView *subView in [captionHolder.dotHolder subviews])
    {
        [subView removeFromSuperview];
    }
    
    // Create UIbutton Dots
    float padding = 31;
    float xVale = 66.5;
    for (int i =0 ; i< [captionTextColourArray count]; i++) {
        if (i != 0) {
            xVale = xVale + padding;
        }
        
        UIButton* btn = [[UIButton alloc] initWithFrame:CGRectMake(xVale, 2, 16, 16)];
        btn.autoresizingMask = UIViewAutoresizingFlexibleRightMargin|UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
        
        btn.layer.cornerRadius = btn.frame.size.width/2;
        [btn setImage:[UIImage imageNamed:[NSString stringWithFormat:@"Dot_%d",i+1]]
             forState:UIControlStateNormal];
        btn.tag = 100 + i;
        [btn addTarget:self action:@selector(captionColourButtonClick:) forControlEvents:UIControlEventTouchUpInside];
        [btn setAlpha:0];
        xVale = btn.frame.origin.x;
        
        BOOL isAdded = NO;
        for (UIButton* btnDot in [captionHolder.dotHolder subviews]) {
            if (btnDot.tag == btn.tag) {
                [btnDot addTarget:self action:@selector(captionColourButtonClick:) forControlEvents:UIControlEventTouchUpInside];
                isAdded = YES;
                break;
            }
        }
        //        if (isAdded == NO) {
        [captionHolder.dotHolder addSubview:btn];
        //        }
    }
    
    [captionHolder addSubview:captionHolder.dotHolder];
    
    for (id imgBgView in [captionHolder subviews]) {
        if ([imgBgView isKindOfClass:[UIImageView class]]) {
            UIImageView* imgObj = (UIImageView*)imgBgView;
            captionFrameMain = imgObj.frame;
        }
    }
    
    captionHolderViewFrame = captionHolder.frame;
    
    UIPanGestureRecognizer *panGestureRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panGestureDetected:)];
    [panGestureRecognizer setDelegate:self];
    [captionHolder addGestureRecognizer:panGestureRecognizer];
    
    [captionHolder setUserInteractionEnabled:YES];
    
    captionHolder.clipsToBounds = NO;
    [imgvComic addSubview:captionHolder];
    
    imgvComic.userInteractionEnabled = YES;
    imgvComic.clipsToBounds = YES;
    //    [captionHolder setBackgroundColor:[UIColor redColor]];
}

#pragma mark Button Events

- (IBAction)btnComicSendButtonClick:(id)sender {
    [self sendComic];
}

-(NSMutableDictionary*)setPutParamets :(NSString*)shareUserId ReplyTypeValue:(ReplyType)type ComicShareId:(NSString*)comic_id{
    NSMutableDictionary* dataDic = [[NSMutableDictionary alloc] init];
    NSMutableDictionary* userDic = [[NSMutableDictionary alloc] init];
    [userDic setObject:comic_id forKey:@"comic_id"];
    [userDic setObject:[AppHelper getCurrentLoginId] forKey:@"user_id"];
    NSMutableArray* arrayObj = [[NSMutableArray alloc] init];
    NSMutableDictionary* dict = [[NSMutableDictionary alloc] init];
    if(type == FriendReply){
        [dict setValue:shareUserId forKey:@"friend_id"];
        [dict setValue:@"1" forKey:@"status"];
        
        [arrayObj addObject:dict];
        [userDic setObject:arrayObj forKey:@"friendShares"];
        
        arrayObj = nil;
        dict = nil;
    }
    else if(type == GroupReply){
        
        [dict setValue:shareUserId forKey:@"group_id"];
        [dict setValue:@"1" forKey:@"status"];
        
        [arrayObj addObject:dict];
        
        
        [userDic setObject:arrayObj forKey:@"groupShares"];
        
        arrayObj = nil;
        dict = nil;
    }
    
    [dataDic setObject:userDic forKey:@"data"];
    return dataDic;
}

-(void)sendComic{
    
    [self.delegate comicMakingViewControllerWithEditingDone:self
                                              withImageView:imgvComic
                                            withPrintScreen:printScreen
                                               gifLayerPath:self.gifLayerPath
                                               withNewSlide:isNewSlide
                                                withPopView:NO withIsWideSlide:isWideSlide];
    
    
    
    //Desable the image view intactin
    [self.view setUserInteractionEnabled:NO];
    NSMutableArray* comicSlides = [self getDataFromFile];
    NSMutableArray* paramArray = [[NSMutableArray alloc] init];
    for (NSData* data in comicSlides) {
        
        NSMutableDictionary* dataDic = [[NSMutableDictionary alloc] init];
        ComicPage* cmPage = [NSKeyedUnarchiver unarchiveObjectWithData:data];
        NSData *imageData = UIImagePNGRepresentation([AppHelper getImageFile:cmPage.printScreenPath]);//UIImageJPEGRepresentation([AppHelper getImageFile:cmPage.printScreenPath], 1);
        
        [dataDic setObject:imageData forKey:@"SlideImage"];
        
        NSData* slideTypeData = [@"slideImage" dataUsingEncoding:NSUTF8StringEncoding];
        
        [dataDic setObject:slideTypeData forKey:@"SlideImageType"];
        
        [paramArray addObject:dataDic];
    }
    NSLog(@"Start uploading");
    if(self.replyType == FriendReply) {
        [[NSNotificationCenter defaultCenter] postNotificationName:@"StartFriendReplyComicAnimation" object:nil];
    } else if(self.replyType == GroupReply) {
        [[NSNotificationCenter defaultCenter] postNotificationName:@"StartGroupReplyComicAnimation" object:nil];
    }
    
    ComicNetworking* cmNetWorking = [ComicNetworking sharedComicNetworking];
    [cmNetWorking UploadComicImage:paramArray completeBlock:^(id json, id jsonResponse) {
        
        [cmNetWorking postComicCreation:[self createSendParams:[json objectForKey:@"slides"] comicSlides:comicSlides]
                                     Id:nil completion:^(id json,id jsonResposeHeader) {
                                         
                                         [AppHelper setCurrentcomicId:[json objectForKey:@"data"]];
                                         [self.view setUserInteractionEnabled:YES];
                                         if(self.comicType != ReplyComic) {
                                             isNewSlide = NO;
                                             UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:@"Main" bundle: nil];
                                             SendPageViewController *controller = (SendPageViewController *)[mainStoryboard instantiateViewControllerWithIdentifier:@"SendPage"];
                                             controller.comicSlideFileName = self.fileNameToSave;
                                             
                                             [self.navigationController pushViewController:controller animated:YES];
                                         } else {
                                             [cmNetWorking shareComicImage:[self setPutParamets:self.friendOrGroupId
                                                                                 ReplyTypeValue:self.replyType
                                                                                   ComicShareId:[json objectForKey:@"data"]]
                                                                        Id:[json objectForKey:@"data"] completion:^(id json, id jsonResponse) {
                                                                            
                                                                            if (json) {
                                                                                if(self.replyType == FriendReply) {
                                                                                    [[NSNotificationCenter defaultCenter] postNotificationName:@"UpdateFriendComics" object:nil];
                                                                                    [[NSNotificationCenter defaultCenter] postNotificationName:@"StopFriendReplyComicAnimation" object:nil];
                                                                                    [self dismissViewControllerAnimated:YES completion:^{}];
                                                                                } else if(self.replyType == GroupReply) {
                                                                                    [[NSNotificationCenter defaultCenter] postNotificationName:@"UpdateGroupComics" object:nil];
                                                                                    [[NSNotificationCenter defaultCenter] postNotificationName:@"StopGroupReplyComicAnimation" object:nil];
                                                                                    [self dismissViewControllerAnimated:YES completion:^{}];
                                                                                }
                                                                                if (self.fileNameToSave) {
                                                                                    [AppHelper deleteSlideFile:self.fileNameToSave];
                                                                                }
                                                                            }else{
                                                                                [AppHelper showErrorDropDownMessage:@"something went wrong !" mesage:@""];
                                                                            }
                                                                            
                                                                        } ErrorBlock:^(JSONModelError *error) {
                                                                            
                                                                        }];
                                         }
                                         
                                     } ErrorBlock:^(JSONModelError *error) {
                                         NSLog(@"completion %@",error);
                                         [self.view setUserInteractionEnabled:YES];
                                         if(self.replyType == FriendReply) {
                                             [[NSNotificationCenter defaultCenter] postNotificationName:@"StopFriendReplyComicAnimation" object:nil];
                                             [self dismissViewControllerAnimated:YES completion:^{}];
                                         } else if(self.replyType == GroupReply) {
                                             [[NSNotificationCenter defaultCenter] postNotificationName:@"StopGroupReplyComicAnimation" object:nil];
                                             [self dismissViewControllerAnimated:YES completion:^{}];
                                         }
                                     }];
        
    } ErrorBlock:^(JSONModelError *error) {
        [self.view setUserInteractionEnabled:YES];
        if(self.replyType == FriendReply) {
            [[NSNotificationCenter defaultCenter] postNotificationName:@"StopFriendReplyComicAnimation" object:nil];
            [self dismissViewControllerAnimated:YES completion:^{}];
        } else if(self.replyType == GroupReply) {
            [[NSNotificationCenter defaultCenter] postNotificationName:@"StopGroupReplyComicAnimation" object:nil];
            [self dismissViewControllerAnimated:YES completion:^{}];
        }
    }];
    
    
    //    [AppHelper showWarningDropDownMessage:@"" mesage:@"Please wait .. Creating your comic"];
    
}

-(NSMutableDictionary*)createSendParams :(NSMutableArray*)slideArray comicSlides :(NSMutableArray*) comicSlides{
    
    if (slideArray == nil && [slideArray count] > 0)
        return nil;
    
    NSMutableDictionary* dataDic = [[NSMutableDictionary alloc] init];
    NSMutableDictionary* comicMakeDic = [[NSMutableDictionary alloc] init];
    
    [comicMakeDic setObject:[AppHelper getCurrentLoginId] forKey:@"user_id"]; // Hardcoded now
    [comicMakeDic setObject:@"" forKey:@"comic_title"];
    
    if(self.comicType == ReplyComic) {
        [comicMakeDic setObject:@"CS" forKey:@"comic_type"];
        [comicMakeDic setObject:(self.shareId == nil ?@"0":self.shareId) forKey:@"share_id"];
    } else {
        [comicMakeDic setObject:@"CM" forKey:@"comic_type"]; // COMIC MAKING
    }
    
    [comicMakeDic setObject:@"0" forKey:@"conversation_id"];
    [comicMakeDic setObject:@"1" forKey:@"status"];
    
    //Slide Array
    NSMutableArray* slides = [[NSMutableArray alloc] init];
    
    for (int i=0; i< [comicSlides count]; i++)
    {
        NSData* data = [comicSlides objectAtIndex:i];
        ComicPage* cmPage = [NSKeyedUnarchiver unarchiveObjectWithData:data];
        
        if (i == 0 && cmPage.titleString && cmPage.titleString.length >0) {
            [comicMakeDic setObject:cmPage.titleString forKey:@"comic_title"];
        }
        
        //ComicSlides Object
        NSMutableDictionary* cmSlide = [[NSMutableDictionary alloc] init];
        
        //Comic Slide image url obj
        NSDictionary* urlSlides = [slideArray objectAtIndex:i];
        
        //ComicSlides Object
        [cmSlide setObject:[urlSlides valueForKeyPath:@"url.slide_image"] forKey:@"slide_image"];
        [cmSlide setObject:[urlSlides valueForKeyPath:@"url.slide_thumb"] forKey:@"slide_thumb"];
        [cmSlide setObject:@"" forKey:@"slide_text"];
        [cmSlide setObject:@"url" forKey:@"slide_image_type"];
        
        NSMutableArray* enhancements = [[NSMutableArray alloc] init];
        //Check is AUD is avalilabe
        
        for (int i = 0; i < cmPage.subviews.count; i ++)
        {
            id imageView = cmPage.subviews[i];
            CGRect myRect = [cmPage.subviewData[i] CGRectValue];
            //Check is ComicItemBubble
            if([imageView isKindOfClass:[ComicItemBubble class]])
            {
                if ([((ComicItemBubble*)imageView) isPlayVoice]) {
                    //Yes there is a Audio
                    //ComicSlides Object
                    NSMutableDictionary* cmEng = [[NSMutableDictionary alloc] init];
                    [cmEng setObject:@"AUD" forKey:@"enhancement_type"];
                    [cmEng setObject:@"1" forKey:@"enhancement_type_id"];
                    [cmEng setObject:@"1" forKey:@"is_custom"];
                    [cmEng setObject:@"" forKey:@"enhancement_text"];
                    NSData* audioData = [[NSData alloc] initWithContentsOfFile:((ComicItemBubble*)imageView).recorderFilePath];
                    [cmEng setObject:[audioData base64EncodedStringWithOptions:NSDataBase64Encoding64CharacterLineLength]
                              forKey:@"enhancement_file"];
                    [cmEng setObject:@"mp3" forKey:@"enhancement_file_type"];
                    
                    CGFloat midPointX = myRect.origin.x + (myRect.size.width/2);
                    CGFloat midPointY = myRect.origin.y + (myRect.size.height/2);
                    
                    [cmEng setObject:[NSString stringWithFormat:@"%f",midPointY] forKey:@"position_top"];
                    [cmEng setObject:[NSString stringWithFormat:@"%f",midPointX] forKey:@"position_left"];
                    [cmEng setObject:[NSString stringWithFormat:@"%.02f",myRect.size.width] forKey:@"width"];
                    [cmEng setObject:[NSString stringWithFormat:@"%.02f",myRect.size.height] forKey:@"height"];
                    [cmEng setObject:@"1" forKey:@"z_index"];
                    
                    [enhancements addObject:cmEng];
                }
            }
            if([imageView isKindOfClass:[ComicItemAnimatedSticker class]])
            {
                //                if ([((ComicItemBubble*)imageView) isPlayVoice]) {
                //Yes there is a Audio
                //ComicSlides Object
                NSMutableDictionary* cmEng = [[NSMutableDictionary alloc] init];
                [cmEng setObject:@"GIF" forKey:@"enhancement_type"];
                [cmEng setObject:@"1" forKey:@"enhancement_type_id"];
                [cmEng setObject:@"1" forKey:@"is_custom"];
                [cmEng setObject:@"" forKey:@"enhancement_text"];
                
                // UIImage* imgGif = [UIImage sd_animatedGIFNamed:((ComicItemAnimatedSticker*)imageView).animatedStickerName];
                
                //CGDataProviderRef provider = CGImageGetDataProvider(imgGif.CGImage);
                //NSData* gifData = (id)CFBridgingRelease(CGDataProviderCopyData(provider));
                
                if (((ComicItemAnimatedSticker*)imageView).combineAnimationFileName) {
                    //it had image,
                    NSString *animationPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
                    animationPath = [[animationPath stringByAppendingPathComponent:((ComicItemAnimatedSticker*)imageView).combineAnimationFileName] stringByAppendingString:@".gif"];
                    
                    NSData *gifData = [NSData dataWithContentsOfFile:animationPath];
                    
                    [cmEng setObject:[gifData base64EncodedStringWithOptions:NSDataBase64Encoding64CharacterLineLength]
                              forKey:@"enhancement_file"];
                    [cmEng setObject:@"gif" forKey:@"enhancement_file_type"];
                    
                }
                
                
                CGFloat midPointX = myRect.origin.x;
                CGFloat midPointY = myRect.origin.y;
                
                [cmEng setObject:[NSString stringWithFormat:@"%f",midPointY] forKey:@"position_top"];
                [cmEng setObject:[NSString stringWithFormat:@"%f",midPointX] forKey:@"position_left"];
                [cmEng setObject:[NSString stringWithFormat:@"%.02f",myRect.size.width] forKey:@"width"];
                [cmEng setObject:[NSString stringWithFormat:@"%.02f",myRect.size.height] forKey:@"height"];
                [cmEng setObject:@"1" forKey:@"z_index"];
                
                [enhancements addObject:cmEng];
                //                }
            }
            if (enhancements && [enhancements count] > 0) {
                [cmSlide setObject:enhancements forKey:@"enhancements"];
            }
        }
        
        if ([cmPage.slideType isEqualToString:slideTypeWide])
        {
            [cmSlide setObject:@"1" forKey:@"slide_type"];
            
        }
        else
        {
            [cmSlide setObject:@"0" forKey:@"slide_type"];
            
        }
        
        
        
        [slides addObject:cmSlide];
        cmPage = nil;
        cmSlide = nil;
    }
    [comicMakeDic setObject:[NSString stringWithFormat:@"%lu", (unsigned long)[slides count]]
                     forKey:@"slide_count"];
    [comicMakeDic setObject:slides forKey:@"slides"];
    [dataDic setObject:comicMakeDic forKey:@"data"];
    
    return dataDic;
}

#pragma mark ComicItem methods

-(void)doAutoSave :(id)comicItemObj
{
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_group_t group = dispatch_group_create();
    
    // Add a task to the group
    dispatch_group_async(group, queue, ^{
        [self doPrintScreen:^(bool isOutOfFrame)
         {
             if (comicItemObj != nil)
             {
                 if (isNewSlide)
                 {
                     isNewSlide = NO;
                 }
                 [self.delegate comicMakingItemSave:comicPage
                                      withImageView:comicItemObj
                                    withPrintScreen:printScreen
                                         withRemove:NO
                                      withImageView:imgvComic];
             }
             
         }];
    });
}

-(void)doPrintScreen
{
    [self doPrintScreen:^(bool isOutOfFrame) {}];
}

-(void)doPrintScreen :(void (^)(bool isOutOfFrame))handler
{
    [imgvComic setFrame:temImagFrame];
    
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_group_t group = dispatch_group_create();
    
    dispatch_group_async(group, queue, ^{
        @try {
//            UIImageView * viewCopy = [imgvComic copy];
//            for (id subview in [viewCopy subviews]) {
//                if ([subview isKindOfClass:[ComicItemAnimatedSticker class]]) {
//                    [subview removeFromSuperview];
//                }
//            }
            
            printScreen = [UIImage imageWithView:imgvComic paque:NO];
            handler(YES);
        } @catch (NSException *exception) {
            
        } @finally {
            
        }
    });
}

- (UIImage *)imageByCroppingImage:(UIImage *)image toSize:(CGSize)size
{
    // not equivalent to image.size (which depends on the imageOrientation)!
    double refWidth = CGImageGetWidth(image.CGImage);
    double refHeight = CGImageGetHeight(image.CGImage);
    
    double x = (refWidth - size.width) / 2.0;
    double y = (refHeight - size.height) / 2.0;
    
    CGRect cropRect = CGRectMake(x, y, size.height, size.width);
    CGImageRef imageRef = CGImageCreateWithImageInRect([image CGImage], cropRect);
    
    UIImage *cropped = [UIImage imageWithCGImage:imageRef scale:0.0 orientation:image.imageOrientation];
    CGImageRelease(imageRef);
    
    return cropped;
}


-(void)doRemoveAllItem :(id)comicItemObj{
    //    if (comicItemObj == nil)
    //        return;
    
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_group_t group = dispatch_group_create();
    
    // Add a task to the group
    dispatch_group_async(group, queue, ^{
        [self.delegate  comicMakingItemRemoveAll:comicPage removeAll:YES];
        //        [self.delegate comicMakingItemSave:comicPage withImageView:comicItemObj withPrintScreen:printScreen withRemove:YES];
    });
}

-(void)doRemoveItem :(id)comicItemObj{
    if (comicItemObj == nil)
        return;
    
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_group_t group = dispatch_group_create();
    
    // Add a task to the group
    dispatch_group_async(group, queue, ^{
        
        [self.delegate comicMakingItemSave:comicPage withImageView:comicItemObj withPrintScreen:printScreen withRemove:YES withImageView:imgvComic];
        
    });
    [self doPrintScreen];
}

- (void)addComicItem:(id)comicItemView ItemImage:(UIImage*)itemImage rectValue:(CGRect)rect TranformData:(CGAffineTransform)tranformData
{
    if ([comicItemView isKindOfClass:[ComicItemSticker class]] ||
        [comicItemView isKindOfClass:[ComicItemExclamation class]])
    {
        [self addStickerWithImageView:comicItemView ComicItemImage:itemImage rectValue:rect Tranform:tranformData];
    }else if([comicItemView isKindOfClass:[ComicItemBubble class]])
    {
        [self addBubbleWithImage:comicItemView ComicItemImage:itemImage rectValue:rect];
    }
    else if([comicItemView isKindOfClass:[ComicItemCaption class]])
    {
        [self addCaptionView:comicItemView rectValue:rect];
    }
    else if([comicItemView isKindOfClass:[ComicItemAnimatedSticker class]])
    {
        [self addAnimatedImageView:comicItemView ComicItemImage:itemImage rectValue:rect Tranform:tranformData];
    }
}
- (void)addComicItem:(id)comicItemView ItemImage:(UIImage*)itemImage
{
    [self addComicItem:comicItemView ItemImage:itemImage rectValue:CGRectZero TranformData:CGAffineTransformMake(0, 0, 0, 0, 0, 0)];
}

- (id)getComicItems:(ComicItemType)type
{
    switch (type) {
        case ComicSticker:
        {
            return [[ComicItemSticker alloc] init] ;
        }
        case ComicExclamation:
        {
            return [[ComicItemExclamation alloc] init];
        }
        case ComicBubble:
        {
            return [[ComicItemBubble alloc] init];
        }
        case ComicCaption:
        {
            return [[ComicItemCaption alloc] init];
        }
        case ComicAnimatedSticker:
        {
            return [[ComicItemAnimatedSticker alloc] init];
        }
        case ComicAnimatedComponent:
        {
            return [[ComicItemAnimatedComponent alloc] init];
        }
    }
    return nil;
}

- (void)isEndOfPan:(UIView*)currectView
           success:(void (^)(bool isOutOfFrame))handler{
    
    //    UIImageView *imageView = nil;
    
    BOOL moved = NO;
    CGRect newPoint = currectView.frame;
    
    // If off screen left
    if (newPoint.origin.x < - (currectView.frame.size.width/2)){
        //    if (newPoint.origin.x < 0.0f){
        newPoint.origin.x *= -1.0;
        moved = YES;
    }
    
    // if off screen up
    if (newPoint.origin.y < -(currectView.frame.size.height/2)){
        newPoint.origin.y *= -1.0;
        moved = YES;
    }
    
    // if off screen right
    
    CGFloat howFarOffRight = (newPoint.origin.x + newPoint.size.width) - self.view.frame.size.width;
    if (howFarOffRight > (currectView.frame.size.width/2))
    {
        newPoint.origin.x -= howFarOffRight * 2;
        moved = YES;
    }
    
    // if off screen bottom
    
    CGFloat howFarOffBottom = (newPoint.origin.y + newPoint.size.height) - self.view.frame.size.height;
    if (howFarOffBottom > +(currectView.frame.size.height/2))
    {
        newPoint.origin.y -= howFarOffBottom * 2;
        moved = YES;
    }
    
    handler(moved);
}


#pragma mark DB Methods

-(void)saveDataToFile:(NSMutableArray*)slideObj
{
    
    [AppHelper saveDataToFile:slideObj fileName:self.fileNameToSave];
    //
    //    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    //    NSString *documentsDirectory = [paths objectAtIndex:0];
    //    NSString *filePath = [documentsDirectory stringByAppendingString:@"/ComicSlide.sav"];
    //    [slideObj writeToFile:filePath atomically:YES];
}

-(NSMutableArray*)getDataFromFile{
    
    return [AppHelper getDataFromFile:self.fileNameToSave];
    
    //    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    //    NSString *documentsDirectory = [paths objectAtIndex:0];
    //    NSString *filePath = [documentsDirectory stringByAppendingString:@"/ComicSlide.sav"];
    //    return [NSMutableArray arrayWithContentsOfFile:filePath];
}

#pragma mark mainpageAction

- (IBAction)btnComicBoyClick:(id)sender {
    
    [AppHelper openMainPageviewController:self];
    
}

#pragma mark - InstructionViewDelegate Methods
-(void)didCloseInstructionViewWith:(InstructionView *)view withClosedSlideNumber:(SlideNumber)number
{
    [view removeFromSuperview];
    
    if(number == SlideNumber1)
    {
        // open slide 2 Instruction
        dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0 * NSEC_PER_SEC));
        dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
            NSLog(@"Do some work");
            
            if ([InstructionView getBoolValueForSlide:kInstructionSlide2] == NO)
            {
                InstructionView *instView = [[InstructionView alloc] initWithFrame:self.view.bounds];
                instView.delegate = self;
                [instView showInstructionWithSlideNumber:SlideNumber2 withType:InstructionBubbleType];
                [instView setTrueForSlide:kInstructionSlide2];
                
                [self.view addSubview:instView];
            }
        });
        
    }
    else if (number == SlideNumber10)
    {
        // open slide 12 Instruction
        dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(6 * NSEC_PER_SEC));
        dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
            NSLog(@"Do some work");
            
            if ([InstructionView getBoolValueForSlide:kInstructionSlide12] == NO)
            {
                InstructionView *instView = [[InstructionView alloc] initWithFrame:self.view.bounds];
                instView.delegate = self;
                [instView showInstructionWithSlideNumber:SlideNumber12 withType:InstructionGIFType];
                [instView setTrueForSlide:kInstructionSlide12];
                
                [self.view addSubview:instView];
            }
        });
    }
    else if (number == SlideNumber15)
    {
        
        
    }
}

#pragma mark - Crop Methods
- (UIImage *)croppedImage:(UIImage *)imageToCrop withImageView:(UIImageView *)imageView WithFrame:(CGRect)currentCropRect
{
    CGSize imageSize = imageToCrop.size;
    CGSize scaledImageSize = [self imageFrameFromImageViewWithAspectFitMode:imageView].size;
    CGFloat widthFactor = scaledImageSize.width / imageSize.width;
    CGFloat heightFactor = scaledImageSize.height / imageSize.height;
    
    // CGRect currentCropRect = rect;
    CGRect actualCropRect = CGRectMake(
                                       roundf(currentCropRect.origin.x / widthFactor),
                                       roundf(currentCropRect.origin.y / heightFactor),
                                       roundf(currentCropRect.size.width / widthFactor),
                                       roundf(currentCropRect.size.height / heightFactor)
                                       );
    UIImage *outputImage = nil;
    
    CGImageRef imageRef = CGImageCreateWithImageInRect(imageToCrop.CGImage, actualCropRect);
    outputImage = [UIImage imageWithCGImage:imageRef];
    CGImageRelease(imageRef);
    
    return outputImage;
}

- (CGRect)imageFrameFromImageViewWithAspectFitMode:(UIImageView *)theImageView
{
    if (theImageView.image == nil) {
        return CGRectMake(0, 0, 0, 0);
    }
    
    CGSize imageSize = CGSizeAbsolute2([self sizeForRotatedImage:theImageView.image]);
    
    float imageRatio = imageSize.width / imageSize.height;
    float viewRatio = theImageView.frame.size.width / theImageView.frame.size.height;
    
    if (imageRatio < viewRatio)
    {
        float scale = theImageView.frame.size.height / imageSize.height;
        float width = scale * imageSize.width;
        float topLeftX = .5 * (theImageView.frame.size.width - width);
        return CGRectMake(topLeftX, 0, width, theImageView.frame.size.height);
    }
    else
    {
        float scale = theImageView.frame.size.width / imageSize.width;
        float height = scale * imageSize.height;
        float topLeftY = .5 * (theImageView.frame.size.height - height);
        return CGRectMake(0, topLeftY, theImageView.frame.size.width, height);
    }
}

- (CGSize)sizeForRotatedImage:(UIImage *)imageToRotate
{
    if (imageToRotate == nil) {
        return CGSizeMake(0, 0);
    }
    
    CGFloat rotationAngle = 0 * M_PI / 2;
    
    CGSize imageSize = imageToRotate.size;
    // Image size after the transformation
    CGSize outputSize = CGSizeApplyAffineTransform(imageSize, CGAffineTransformMakeRotation(rotationAngle));
    
    return outputSize;
}
#pragma mark - Handle Animation Customization
-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (alertView.tag == 101)
    {
        if (buttonIndex == 0)
        {
            [refAnimatedSticker setUserInteractionEnabled:NO];
            [refAnimatedSticker removeFromSuperview];
            
            dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
            dispatch_group_t group = dispatch_group_create();
            
            // Add a task to the group
            dispatch_group_async(group, queue, ^{
                [self.delegate comicMakingItemSave:comicPage withImageView:refAnimatedSticker withPrintScreen:printScreen withRemove:YES withImageView:imgvComic];
            });
            [self doPrintScreen];
            haveAnimationOnPage = NO;
            refAnimatedSticker = nil;
            
        }
    }
    else if (alertView.tag == 301)
    {
        if (buttonIndex == 0)
        {
            NSLog(@"Left");
            [self proceedAgainForTheAnsweredFaceisLeft:YES ForPoints:tempTouchPointForFace AndIndex:tempIndexForFace];
        }
        else
        {
            NSLog(@"Right");
            [self proceedAgainForTheAnsweredFaceisLeft:NO ForPoints:tempTouchPointForFace AndIndex:tempIndexForFace];
        }
    }
}
//- (void)addBubbleListViewController
//{
//    // Get storyboard
//    UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:@"Main" bundle:[NSBundle mainBundle]];
//    UICollectionViewController *bubbleList  = [storyBoard instantiateViewControllerWithIdentifier:@"bubblelistVC"];
//    
//    // lets add it to container view
//    [self.bubbleContainerView addSubview:bubbleList.view];
//    [self addChildViewController:bubbleList];
//    //[viewController didMoveToParentViewController:self];
//    // keep reference of viewController which may be useful when you need to remove it from container view, lets consider you have a property name as containerViewController
//    //self.containerViewController = viewController;
//}
- (void)addStickerListViewController
{
    // Get storyboard
    UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:@"Main" bundle:[NSBundle mainBundle]];
    UICollectionViewController *stickerlist  = [storyBoard instantiateViewControllerWithIdentifier:@"stickerlistVC"];
    
    // lets add it to container view
    [self.stickerlistContainerView addSubview:stickerlist.view];
    [self addChildViewController:stickerlist];
    //[viewController didMoveToParentViewController:self];
    // keep reference of viewController which may be useful when you need to remove it from container view, lets consider you have a property name as containerViewController
    //self.containerViewController = viewController;
}
- (void)addAnimationListViewController
{
    // Get storyboard
    UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:@"Main" bundle:[NSBundle mainBundle]];
    UICollectionViewController *animationlist  = [storyBoard instantiateViewControllerWithIdentifier:@"animationListVC"];
    
    // lets add it to container view
    [self.animationContainerView addSubview:animationlist.view];
    [self addChildViewController:animationlist];
    //[viewController didMoveToParentViewController:self];
    // keep reference of viewController which may be useful when you need to remove it from container view, lets consider you have a property name as containerViewController
    //self.containerViewController = viewController;
}
-(CGRect)rectOntheBasisOfScreen:(CGRect)rect
{
    // Default value of in json is of iPhone 6 so we will find rect for iphone 5 and 6p
    CGFloat widthOf6 = 375;
    CGFloat heightOf6 = 667;
    // CGFloat x,y,width,height;
    CGFloat xFactor = [UIScreen mainScreen].bounds.size.width/widthOf6;
    CGFloat yFactor = [UIScreen mainScreen].bounds.size.height/heightOf6;
    return CGRectMake(rect.origin.x*xFactor, rect.origin.y*yFactor, rect.size.width*xFactor, rect.size.height*xFactor);
}
-(CGPoint)pointFromAnimationsRealPoint:(CGPoint)point fromCenterX:(CGFloat)centerX  fromCenterY:(CGFloat)centerY
{
    CGFloat widthOf6 = 375;
    CGFloat heightOf6 = 667;
    // CGFloat x,y,width,height;
    CGFloat xFactor = [UIScreen mainScreen].bounds.size.width/widthOf6;
    CGFloat yFactor = [UIScreen mainScreen].bounds.size.height/heightOf6;
    //[[[[animation valueForKey:@"resources"] objectAtIndex:0] valueForKey:@"animationCenterPointX"] floatValue]
    //[[[[animation valueForKey:@"resources"] objectAtIndex:0] valueForKey:@"animationCenterPointY"] floatValue]
    return CGPointMake(point.x-(centerX*xFactor),point.y-(centerY*yFactor));
};
-(CGPoint)pointFromAnimations2RealPoint:(CGPoint)point fromCenterX:(CGFloat)centerX  fromCenterY:(CGFloat)centerY
{
    CGFloat widthOf6 = 375;
    CGFloat heightOf6 = 667;
    // CGFloat x,y,width,height;
    CGFloat xFactor = [UIScreen mainScreen].bounds.size.width/widthOf6;
    CGFloat yFactor = [UIScreen mainScreen].bounds.size.height/heightOf6;
    //[[[[animation valueForKey:@"resources"] objectAtIndex:0] valueForKey:@"animationCenterPointX"] floatValue]
    //[[[[animation valueForKey:@"resources"] objectAtIndex:0] valueForKey:@"animationCenterPointY"] floatValue]
    return CGPointMake(point.x-(centerX*xFactor),point.y-(centerY*yFactor));
};
-(CGFloat)DifferenceInXAxisFromPoint:(CGFloat)boundry
{
    CGFloat widthOf6 = 375;
    CGFloat xFactor = [UIScreen mainScreen].bounds.size.width/widthOf6;
    return boundry*xFactor;
}
-(CGFloat)DifferenceInYAxisFromPoint:(CGFloat)boundry
{
    CGFloat heightOf6 = 667;
    CGFloat yFactor = [UIScreen mainScreen].bounds.size.height/heightOf6;
    return boundry*yFactor;
}
-(void)removeExstingAnimatedStickerFromComicPage
{
    [animationCollection hideGarbageBin];
    [UIView animateWithDuration:1 animations:^ {
        [refToCombineAnimatedSticker setUserInteractionEnabled:NO];
        refToCombineAnimatedSticker.transform = CGAffineTransformMakeScale(0.0f, 0.0f);
    } completion:^(BOOL finished) {
        [refToCombineAnimatedSticker removeFromSuperview];
    }];
    /*[refAnimatedSticker setUserInteractionEnabled:NO];
     [refAnimatedSticker removeFromSuperview];*/
    
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_group_t group = dispatch_group_create();
    
    // Add a task to the group
    dispatch_group_async(group, queue, ^{
        [self.delegate comicMakingItemSave:comicPage withImageView:refToCombineAnimatedSticker withPrintScreen:printScreen withRemove:YES withImageView:imgvComic];
    });
    [self doPrintScreen];
    haveAnimationOnPage = NO;
    refAnimatedSticker = nil;
}
-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"animationSticker"])
    {
        animationCollection = (AnimationCollectionVC *)[segue destinationViewController];
    }
}
-(void)notifyParentForCompletionOfInterval
{
    if ([self.view.gestureRecognizers containsObject:currentAnimationInstructionTap])
    {
        [currentAnimInstSubView removeFromSuperview];
        [self.view removeGestureRecognizer:currentAnimationInstructionTap];
    }
    haveAnimationOnPage = NO;
    refAnimatedSticker = nil;
    
}

-(void)startAnimatingAfterDelay
{
    /***New Code By Ramesh**/
    ComicItemAnimatedSticker* animatedSticker = [self getAnimatesStickerFromComic];
    NSArray* activeAnimations = [self getAnimatedComponentCollection];
    CGFloat maxDuration = 0.0;
    for (int j=0; j< activeAnimations.count; j++)
    {
        ComicItemAnimatedComponent *imageView = [activeAnimations objectAtIndex:j];
        YYImage *image = [YYImage imageNamed:imageView.animatedStickerName];
        imageView.image = image;
        NSString* path= [[NSBundle mainBundle] pathForResource:imageView.animatedStickerName ofType:@"gif"];
        NSData *data = [[NSFileManager defaultManager] contentsAtPath:path];
        UIImage *im =  [UIImage animatedImageWithAnimatedGIFData:data];
        imageView.hidden = NO;
        
        [imageView stopAnimating];
        CGFloat duration = im.duration;//*2.5;
        data = nil;
        im = nil;
        if (maxDuration<duration+imageView.startDelay)
        {
            maxDuration = duration+imageView.startDelay;
            NSLog(@"majored index %ld",(long)indexMaxRun);
        }
        
        [imageView stopAnimating];
        [animatedSticker addSubview:imageView];
        
        [self performSelector:@selector(startImageView:) withObject:imageView afterDelay:imageView.startDelay];
        [self performSelector:@selector(stopImageViewWithArray:)
                   withObject:@[imageView,[NSNumber numberWithInt:j]]
                   afterDelay:imageView.startDelay+duration];
    }
    
    indexMaxRun = activeAnimations.count;
    
    /*** Old Code By Sanjay
     
     ComicItemAnimatedSticker *imageView;
     CGFloat maxDuration = 0.0;
     for (int j=0; j<arrOfActiveAnimations.count; j++)
     {
     imageView = [arrOfActiveAnimations objectAtIndex:j];
     //UIImage *newImage = [UIImage sd_animatedGIFNamed:imageView.animatedStickerName];
     YLGIFImage   *imgin = [YLGIFImage imageNamed:[NSString stringWithFormat:@"%@.gif",imageView.animatedStickerName]];
     imageView.image = imgin;
     imageView.hidden = NO;
     [imageView stopAnimating];
     CGFloat duration = imgin.duration*2.5;
     
     if (maxDuration<duration+imageView.startDelay)
     {
     maxDuration = duration+imageView.startDelay;
     indexMaxRun = j;
     NSLog(@"majored index %ld",(long)indexMaxRun);
     }
     
     [self performSelector:@selector(startImageView:) withObject:imageView afterDelay:imageView.startDelay];
     [self performSelector:@selector(stopImageViewWithArray:) withObject:@[imageView,[NSNumber numberWithInt:j]] afterDelay:imageView.startDelay+duration];
     }
     **/
    
}
-(void)createOneGifInBackgroundFromCurrentArray:(NSMutableArray *)array ComicItemAnimatedSticker:(ComicItemAnimatedSticker*)animatedSticker
{
    NSMutableArray *passingArray = [[NSMutableArray alloc]init];
    for (int i=0; i<array.count; i++)
    {
        ComicItemAnimatedComponent *imageView = [array objectAtIndex:i];
        NSMutableDictionary* tempDict = [[NSMutableDictionary alloc] init];
        NSString *path= @"";
        NSData *data = nil;
        path=[[NSBundle mainBundle] pathForResource:[NSString stringWithFormat:@"%@",imageView.animatedStickerName] ofType:@"gif"];
        data = [[NSFileManager defaultManager] contentsAtPath:path];
        [tempDict setObject:data forKey:@"GifData"];
        [tempDict setObject:[NSString stringWithFormat:@"%f",imageView.startDelay] forKey:@"StartTime"];
        [tempDict setObject:NSStringFromCGPoint([self convertedPointsForCurrentPoints:imageView.frame.origin]) forKey:@"Position"];
        [passingArray addObject:tempDict];
    }
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        // No explicit autorelease pool needed here.
        // The code runs in background, not strangling
        // the main run loop.
        CombineGifImages* cg = [[CombineGifImages alloc] init];
        //        dispatch_sync(dispatch_get_main_queue(), ^{
        // This will be called on the main thread, so that
        // you can update the UI, for example.
        NSString* gifFileName = [[NSUUID UUID] UUIDString];
        if (animatedSticker.combineAnimationFileName) {
            gifFileName = animatedSticker.combineAnimationFileName;
        }
        [cg doImageCombine:passingArray SavedFileName:gifFileName completion:^(BOOL finished, UIImage *outImage, NSString *outSavedPath) {
            if (finished)
            {
                animatedSticker.combineAnimationFileName = gifFileName;
                haveCreateMainGif = YES;
                //                    mainAnimationGifView.hidden = YES;
                //                    mainAnimationGifView.image = outImage;
                refToCombineAnimatedSticker = animatedSticker;
                [self doAutoSave:nil];
            }
        }];
        
        //        });
    });
}
-(void)stopArrayOfGifInLoopAndRemoveExtraGifs
{
    NSArray* animationList = [self getAnimatedComponentCollection];
    
    for (int j=0; j<animationList.count; j++)
    {
        ComicItemAnimatedComponent *imageView = [animationList objectAtIndex:j];
        [imageView removeFromSuperview];
    }
    
}
-(CGPoint)convertedPointsForCurrentPoints:(CGPoint)currentPoint
{
    CGFloat xFactor = 1242/[UIScreen mainScreen].bounds.size.width;
    CGFloat yFactor = 2208/[UIScreen mainScreen].bounds.size.height;
    CGFloat diffy = -9*yFactor;
    CGFloat diffx = -4*xFactor;
    
    CGFloat xPoint = currentPoint.x*xFactor;
    CGFloat yPoint = currentPoint.y*yFactor;
    
    return  CGPointMake(xPoint+diffx,yPoint+diffy);
}
-(void)stopImageViewWithArray:(NSArray *)objects
{
    ComicItemAnimatedComponent *imageview =(ComicItemAnimatedComponent *)[objects firstObject];
    NSNumber *index = (NSNumber *)[objects objectAtIndex:1];
    // NSLog(@"stopped %@ gifName",imageview.animatedStickerName);
    [imageview stopAnimating];
    // imageview.hidden = YES;
    int ind = [index intValue] + 1;
    if (ind==indexMaxRun && haveAnimationOnPage && pauseAnimation == NO)
    {
        //        mainAnimationGifView.hidden = NO;
        [self stopArrayOfGifInLoopAndRemoveExtraGifs];
        [self startAnimatingAfterDelay];
    }
}

-(void)startImageView:(ComicItemAnimatedComponent *)imageview
{
    //NSLog(@"started %@ gifName",imageview.animatedStickerName);
    [imageview startAnimating];
}

- (IBAction)btnPlayPauseAnimationClick:(id)sender {
    [self payPauseAnimation];
}


@end
