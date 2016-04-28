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

static void * CapturingStillImageContext = &CapturingStillImageContext;
static void * RecordingContext = &RecordingContext;
static void * SessionRunningAndDeviceAuthorizedContext = &SessionRunningAndDeviceAuthorizedContext;
static int CaptionViewTextViewTag = 9191;
static CGRect CaptionTextViewMinRect;

@interface ComicMakingViewController ()<ACEDrawingViewDelegate,CropStickerViewControllerDelegate, UIGestureRecognizerDelegate,UITextFieldDelegate,AVAudioRecorderDelegate,UITextViewDelegate,ZoomTransitionProtocol,UINavigationControllerDelegate,UIImagePickerControllerDelegate>
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
//    CGRect temButtonFrame;
//    CGRect temChatButtonFrame;
//    CGRect temUploadButtonFrame;
    //END//
}

@property (weak, nonatomic) IBOutlet UIView *viewCamera;
@property (weak, nonatomic) IBOutlet AVCamPreviewView *viewCameraPreview;

@property (weak, nonatomic) IBOutlet UIView *viewRowButtons;

@property (weak, nonatomic) IBOutlet UIButton *chatIcon;
@property (weak, nonatomic) IBOutlet UIButton *uploadIcon;

@property (weak, nonatomic) IBOutlet UIView *viewStickerList;
@property (weak, nonatomic) IBOutlet UIView *viewDrawing;
@property (weak, nonatomic) IBOutlet UIButton *btnClose;
@property (weak, nonatomic) IBOutlet UIView *glideViewHolder;

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

@property BOOL captionHeightSmall;

@end

@implementation ComicMakingViewController

@synthesize viewCameraPreview, viewCamera, imgvComic, uploadIcon, viewStickerList, viewRowButtons;
@synthesize drawingColor,viewDrawing,frameDrawingView, drawView, centerImgvComic,lastScale, btnClose,bubbleListView,exclamationListView,shrinkHeight,viewFrame, shrinkCount, previousTimestamp, isNewSlide,viewBlackBoard,frameBlackboardView;
@synthesize comicPage,printScreen, isSlideShrink,frameImgvComic,pinchGesture;

#pragma mark - UIViewController Methods
- (void)viewDidLoad
{
    [super viewDidLoad];
    _captionHeightSmall = YES;

    frameImgvComic = imgvComic.frame;
    frameBlackboardView = viewBlackBoard.frame;
    
    frameDrawingView = viewDrawing.frame;
    centerImgvComic = imgvComic.center;
    viewRowButtons.alpha = 0;
    
    [[GoogleAnalytics sharedGoogleAnalytics] logScreenEvent:@"ComicMaking" Attributes:nil];
    
    // set up the filename to save based on the friend/group id.
    if(self.comicType == ReplyComic && self.replyType == FriendReply) {
        self.fileNameToSave = [NSString stringWithFormat:@"ComicSlide_F%@", self.friendOrGroupId];
    } else if(self.comicType == ReplyComic && self.replyType == GroupReply) {
        self.fileNameToSave = [NSString stringWithFormat:@"ComicSlide_G%@", self.friendOrGroupId];
    } else {
        self.fileNameToSave = @"ComicSlide";
    }
    
    [self prepareGlideView];
    
    [self prepareCaptionView];
    [self prepareView];
    [self prepareVoiceView];
    
}

-(void)viewWillAppear:(BOOL)animated
{
    [self addNotificationCenter];
}

-(void)viewDidAppear:(BOOL)animated
{
//    AppHelper* apHelper = [[AppHelper alloc] init];
//    [apHelper AddToMainView:self];
//    [AppHelper addSwipeDownGesture:self];
    
    //Reseting Print Screen
    [self doAutoSave:nil];
    [super viewDidAppear:animated];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [self removeNotificationCenter];
    if (self.isMovingFromParentViewController || self.isBeingDismissed) {
        imgvComic.image = nil;
        imgvComic = nil;
        
        self.ImgvComic2.image = nil;
        self.ImgvComic2 = nil;
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
    return (isSlideShrink ? self.ImgvComic2: imgvComic);
}


#pragma mark - UIView Methods

- (void)prepareView
{
    [self prepareCameraView];
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
        self.rowButton.isNewSlide = YES;
        [self.btnSend setEnabled:NO];
    }
    else
    {
        imgvComic.hidden = NO;
        btnClose.hidden = NO;
        viewCamera.hidden = YES;
        [self.mSendComicButton setHidden:NO];//dinesh
        self.rowButton.isNewSlide = NO;
        
        imgvComic.image = [AppHelper getImageFile:comicPage.containerImagePath]; //[UIImage imageWithData:comicPage.containerImage];

//        NSLog(@"************* SUBVIEW ***************");
//        NSLog(@"%@",comicPage.subviews);
//        NSLog(@"************* SUBVIEW ***************");
        
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
    [self setSession:session];
    
    // Setup the preview view
    [viewCameraPreview setSession:session];
    
    // Check for device authorization
    [self checkDeviceAuthorizationStatus];
    
    dispatch_queue_t sessionQueue = dispatch_queue_create("session queue", DISPATCH_QUEUE_SERIAL);
    [self setSessionQueue:sessionQueue];
    
    dispatch_async(sessionQueue, ^{

        
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
                       [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(subjectAreaDidChange:) name:AVCaptureDeviceSubjectAreaDidChangeNotification object:[[self videoDeviceInput] device]];
                       
                       __weak ComicMakingViewController *weakSelf = self;
                       
                       [self setRuntimeErrorHandlingObserver:[[NSNotificationCenter defaultCenter] addObserverForName:AVCaptureSessionRuntimeErrorNotification object:[self session] queue:nil usingBlock:^(NSNotification *note) {
                           ComicMakingViewController *strongSelf = weakSelf;
                           dispatch_async([strongSelf sessionQueue], ^{
                               // Manually restarting the session since it must have been stopped due to an error.
                               [[strongSelf session] startRunning];
                           });
                           
                       }]];
                       
                       [[self session] startRunning];
                   });
    
}

-(void)removeNotificationCenter{
    
    dispatch_async([self sessionQueue], ^{
        [[self session] stopRunning];
        
        [[NSNotificationCenter defaultCenter] removeObserver:self name:AVCaptureDeviceSubjectAreaDidChangeNotification object:[[self videoDeviceInput] device]];
        [[NSNotificationCenter defaultCenter] removeObserver:[self runtimeErrorHandlingObserver]];
        
        [self removeObserver:self forKeyPath:@"sessionRunningAndDeviceAuthorized" context:SessionRunningAndDeviceAuthorizedContext];
        [self removeObserver:self forKeyPath:@"stillImageOutput.capturingStillImage" context:CapturingStillImageContext];
        [self removeObserver:self forKeyPath:@"movieFileOutput.recording" context:RecordingContext];
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
    
    GlobalObject.isTakePhoto = NO;
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
    [self.mSendComicButton setHidden:NO];//dinesh
    [imgvComic setImage:[UIImage imageNamed:@"cat-demo"]];
    imgvComic.hidden = NO;
    GlobalObject.isTakePhoto = YES;
    btnClose.hidden = NO;
    [self setComicImageViewSize];
    [self doAutoSave:nil];
    
#else
    dispatch_async([self sessionQueue], ^{
        // Update the orientation on the still image output video connection before capturing.
        [[[self stillImageOutput] connectionWithMediaType:AVMediaTypeVideo] setVideoOrientation:[[(AVCaptureVideoPreviewLayer *)[viewCameraPreview layer] connection] videoOrientation]];
        
        // Flash set to Auto for Still Capture
        [ComicMakingViewController setFlashMode:AVCaptureFlashModeAuto forDevice:[[self videoDeviceInput] device]];
        
        // Capture a still image.
        [[self stillImageOutput] captureStillImageAsynchronouslyFromConnection:[[self stillImageOutput] connectionWithMediaType:AVMediaTypeVideo] completionHandler:^(CMSampleBufferRef imageDataSampleBuffer, NSError *error) {
            
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
                imgvComic.hidden = NO;
                
                GlobalObject.isTakePhoto = YES;
                
                btnClose.hidden = NO;
                [self setComicImageViewSize];
                [self doAutoSave:nil];
            }
        }];
    });
#endif
}

- (void)setComicImageViewSize
{
    float widthRatio = imgvComic.bounds.size.width / imgvComic.image.size.width;
    float heightRatio = imgvComic.bounds.size.height / imgvComic.image.size.height;
    float scale = MIN(widthRatio, heightRatio);
    float imageWidth = scale * imgvComic.image.size.width;
    float imageHeight = scale * imgvComic.image.size.height;
    
    imgvComic.frame = CGRectMake(0, 0, imageWidth, imageHeight);
    
    imgvComic.center = centerImgvComic;
    
//    temImagFrame = imgvComic.frame;
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
         [self setComicImageViewSize];
         [self doAutoSave:nil];
         
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
         
         //dinesh
         [self.mSendComicButton setHidden:NO];
     }];
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
        viewRowButtons.center = CGPointMake(backupToolCenter.x-100, backupToolCenter.y );
        viewRowButtons.alpha = 0;
    } completion:^(BOOL finished) {
        
    }];
    
    viewStickerList.alpha = 0;
    
    [UIView animateWithDuration:.8 delay:.2 usingSpringWithDamping:80 initialSpringVelocity:10 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        
        viewStickerList.center = CGPointMake(backupOtherViewCenter.x -viewStickerList.bounds.size.width, backupOtherViewCenter.y );
        viewStickerList.alpha = 1;
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
//    sticker = nil;
}

#pragma mark Exclamation

/*Ramesh */
//Handle Exclamation
- (void)openExclamationList
{
    backupToolCenter = viewRowButtons.center;
    backupOtherViewCenter = exclamationListView.center;
    
    [UIView animateWithDuration:.6 delay:0 usingSpringWithDamping:100 initialSpringVelocity:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        btnClose.alpha = 0;
        viewRowButtons.center = CGPointMake(backupToolCenter.x-100, backupToolCenter.y );
        viewRowButtons.alpha = 0;
    } completion:^(BOOL finished) {
        
    }];
    
    exclamationListView.alpha = 0;
    
    [UIView animateWithDuration:.8 delay:.2 usingSpringWithDamping:80 initialSpringVelocity:10 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        
        exclamationListView.center = CGPointMake(backupOtherViewCenter.x -viewStickerList.bounds.size.width, backupOtherViewCenter.y );
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
    [UIView animateWithDuration:.6 delay:0 usingSpringWithDamping:100 initialSpringVelocity:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        
        exclamationListView.center = CGPointMake(backupOtherViewCenter.x, backupOtherViewCenter.y );
        
        exclamationListView.alpha = 0;
        
        btnClose.alpha = 1;
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
//    imageView.center = imgvComic.center;
    
    [self addComicItem:imageView ItemImage:exclamationImage];
    
    imageView.center = imageView.center;
    [self doAutoSave:imageView];
}

//END

/*Ramesh */
//Handle Bubble Methods
#pragma mark - Bubble Methods
- (void)openBubbleList
{
    backupToolCenter = viewRowButtons.center;
    backupOtherViewCenter = bubbleListView.center;
    
    [UIView animateWithDuration:.6 delay:0 usingSpringWithDamping:100 initialSpringVelocity:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        btnClose.alpha = 0;
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
    ComicItemBubble* bubbleHolderView = [self getComicItems:ComicBubble];
    
    bubbleHolderView.bubbleString = bubbleImageString;
    UIImage* bubbleImage = [UIImage imageNamed:bubbleImageString];
//    BubbleViewItem* bubbleHolderView =  [[BubbleViewItem alloc] initWithFrame:CGRectMake(50, 50, 150, 150)];
    bubbleHolderView.frame = CGRectMake(50, 50, 150, 150);
    bubbleHolderView.clipsToBounds = NO;
    
    //Adding Bubble image
    bubbleHolderView.imageView = [[UIImageView alloc] initWithFrame:CGRectMake(15, 15, 120, 120)];
    bubbleHolderView.imageView.image = bubbleImage;
    bubbleHolderView.imageView.contentMode = UIViewContentModeScaleAspectFit;
    bubbleHolderView.imagebtn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 150, 150)];
    //End Bubble image
    
    //Adding bubble Text
//    bubbleHolderView.txtBuble = [[UITextView alloc] initWithFrame:CGRectMake(0, 20, bubbleImage.size.width - 20, bubbleImage.size.height - 20)];
    bubbleHolderView.txtBuble = [[UITextView alloc] initWithFrame:textViewSize];
    //adnan
    bubbleHolderView.txtBuble.textAlignment = NSTextAlignmentCenter;
    //End bubble Text
    
    //Add Bubble audio
    bubbleHolderView.audioImageButton = [[UIButton alloc] initWithFrame:CGRectMake(bubbleImage.size.width - 20, bubbleImage.size.height - 20, 16, 16)];
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
        
        if ([bbView isPlayVoice]) {
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
    
//    bubbleHolderView.frame.origin;
    NSLog(@"%@", NSStringFromCGPoint(bubbleHolderView.center));
    CGPoint location = bubbleHolderView.frame.origin;
    if ((location.x + bubbleHolderView.frame.size.width/2) <= self.view.center.x && location.y <= (self.view.center.y - bubbleListView.frame.size.height)) {
        NSLog(@"BOTTOMRIGHT");
        [self updateTailImage:bubbleHolderView imageName:[NSString stringWithFormat:@"%@%@",bubbleImageString,BOTTOMRIGHT]];
    }else if ((location.x + bubbleHolderView.frame.size.width/2) >= self.view.center.x && location.y <= (self.view.center.y - bubbleListView.frame.size.height)) {
        NSLog(@"%@", NSStringFromCGPoint(self.view.center));
        NSLog(@"%@", NSStringFromCGPoint(location));
        NSLog(@"BOTTOMLEFT");
        [self updateTailImage:bubbleHolderView imageName:[NSString stringWithFormat:@"%@_%@",bubbleImageString,BOTTOMLEFT]];
    }else if (location.x <= self.view.center.x && location.y >= (self.view.center.y - bubbleListView.frame.size.height)) {
        NSLog(@"TOPRIGHT");
        [self updateTailImage:bubbleHolderView imageName:[NSString stringWithFormat:@"%@_%@",bubbleImageString,TOPRIGHT]];
    }else if (location.x >= self.view.center.x && location.y >= (self.view.center.y - bubbleListView.frame.size.height)) {
        NSLog(@"TOPLEFT");
        [self updateTailImage:bubbleHolderView imageName:[NSString stringWithFormat:@"%@_%@",bubbleImageString,TOPLEFT]];
    }
    else{
        NSLog(@"BOTTOMRIGHT");
        [self updateTailImage:bubbleHolderView imageName:[NSString stringWithFormat:@"%@%@",bubbleImageString,BOTTOMRIGHT]];
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
        
        lastScale = [gestureRecognizer scale];  // Store the previous scale factor for the next pinch gesture call
    }
    
    if ([gestureRecognizer state] == UIGestureRecognizerStateEnded){
        [self doAutoSave:gestureRecognizer.view];
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

- (void)adjustAnchorPointForGestureRecognizer:(UIGestureRecognizer *)gestureRecognizer {
    if (gestureRecognizer.state == UIGestureRecognizerStateBegan) {
        UIView *piece = gestureRecognizer.view;
        CGPoint locationInView = [gestureRecognizer locationInView:piece];
        CGPoint locationInSuperview = [gestureRecognizer locationInView:piece.superview];
        
        piece.layer.anchorPoint = CGPointMake(locationInView.x / piece.bounds.size.width, locationInView.y / piece.bounds.size.height);
        piece.center = locationInSuperview;
    }
}

#pragma mark - Tocuh Events

-(NSInteger)getShrinkValue{
    return [self getSpeedLength];
}
-(NSInteger)getGlideItemHight{
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
    
    if (touch.view == self.view || touch.view == imgvComic)
    {
        isSlideShrink = NO;
        
        [self.view exchangeSubviewAtIndex:0 withSubviewAtIndex:1];
        
        self.previousTimestamp = event.timestamp;
        shinkLimit = [touch locationInView:self.view];
    }
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    UITouch *touch = [touches anyObject];
    CGPoint location = [touch locationInView:self.view];
    
//    NSLog(@"location : %@", NSStringFromCGPoint(location));
//    NSLog(@"shinkLimit : %@", NSStringFromCGPoint(shinkLimit));
//    NSLog(@"location : %@", NSStringFromCGPoint(self.ImgvComic2.frame.origin));
    
    if ((touch.view == self.view || touch.view == imgvComic) &&
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
        
        CGRect comicFrame = CGRectMake(CGRectGetMinX(self.ImgvComic2.frame) + speedX,
                                       CGRectGetMinY(self.ImgvComic2.frame) + speedY ,
                                       CGRectGetWidth(self.ImgvComic2.frame) - speedWidth,
                                       CGRectGetHeight(self.ImgvComic2.frame) - speedHeight);
        
        if (comicFrame.size.height > [self getGlideItemHight]) {
            self.ImgvComic2.frame = CGRectMake(CGRectGetMinX(self.ImgvComic2.frame) + speedX,
                                               CGRectGetMinY(self.ImgvComic2.frame) + speedY ,
                                               CGRectGetWidth(self.ImgvComic2.frame) - speedWidth,
                                               CGRectGetHeight(self.ImgvComic2.frame) - speedHeight);
            
            self.ImgvComic2.image = printScreen;
            imgvComic.frame = self.ImgvComic2.frame;
        }
        
//        CGPoint centerPoint = CGPointMake([[UIScreen mainScreen] bounds].size.width/2, [[UIScreen mainScreen] bounds].size.height/2);
//        self.view.center = centerPoint;
        
//        if (self.ImgvComic2.frame.size.height < shrinkHeight && isSlideShrink == NO)
//        {
//        }
    }
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    UITouch *touch = [touches anyObject];
    
    if (touch.view == self.view || touch.view == imgvComic)
    {
        if (self.ImgvComic2.frame.size.height < shrinkHeight && isSlideShrink == NO)
        {
            isSlideShrink = YES;
            [self.delegate comicMakingViewControllerWithEditingDone:self
                                                      withImageView:imgvComic
                                                    withPrintScreen:printScreen
                                                       withNewSlide:isNewSlide
                                                        withPopView:YES];
            
        }
        else
        {
            [self.view exchangeSubviewAtIndex:1 withSubviewAtIndex:0];
            imgvComic.frame = viewFrame;
            self.ImgvComic2.frame = imgvComic.frame;
        }
    }
}

#pragma mark - CropStickerViewControllerDelegate Methods
- (void)cropStickerViewController:(CropStickerViewController *)controll didSelectDoneWithImage:(UIImageView *)stickerImageView withBorderImage:(UIImage *)imageWithBorder
{
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
         }completion:nil];
    }];
}

- (void)cropStickerViewControllerWithCropCancel:(CropStickerViewController *)controll
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - Blackboard Methods
- (void)openBlackBoard
{
    viewBlackBoard.alpha = 0;
    viewCamera.hidden = YES;
    [self.mSendComicButton setHidden:NO];//dinesh
    btnClose.hidden = YES;
    
    imgvComic.hidden = NO;
    imgvComic.frame =  frameImgvComic;
    
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
    
    drawView = [[ACEDrawingView alloc] init];
    drawView.delegate = self;
    
    drawView.frame = CGRectMake(0, 0, CGRectGetWidth(imgvComic.frame),CGRectGetHeight(imgvComic.frame));
    
    [UIView animateWithDuration:.6 delay:0 usingSpringWithDamping:100 initialSpringVelocity:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        
        viewDrawing.frame = frameDrawingView;
        
        viewDrawing.alpha = 1;
        
    } completion:^(BOOL finished)
     {
         [self addDrawingView];
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
    [UIView setAnimationDuration: 0.2f];
    drawingController.btnRed.transform = CGAffineTransformMakeScale(2,2);
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
    
    UIGraphicsBeginImageContextWithOptions(size, YES,0);
    
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
        frameTxtCaption = CGRectMake(0, -2, 270, 30);
        framePlusButton = CGRectMake(265, -4, 30, 30);
        fontsize = 17;
        
    }
    else if (IS_IPHONE_6)
    {
        frameCaptionHolder = CGRectMake(10, 111, 367, 60);
        frameBGImageView = CGRectMake(0, 0, 345, 40);
        frameTxtCaption = CGRectMake(0, -2, 320, 35);
        framePlusButton = CGRectMake(310, 2, 30, 30);
        
        fontsize = 20;
    }
    else if (IS_IPHONE_6P)
    {
        frameCaptionHolder = CGRectMake(10, 111, 410, 60);
        frameBGImageView = CGRectMake(0, 0, 380, 40);
        frameTxtCaption = CGRectMake(0, -2, 340, 35);
        framePlusButton = CGRectMake(340, 2, 30, 30);
        
        fontsize = 22;
    }
    else
    {
        frameCaptionHolder = CGRectMake(10, 111, 301, 60);
        frameBGImageView = CGRectMake(0, 0, 280, 33);
        frameTxtCaption = CGRectMake(0, -2, 270, 30);
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
                         value:[UIFont fontWithName:@"MYRIADPRO-BOLD" size:24.0f]
                         range:NSMakeRange(0, textView.text.length)];
    }else{
        
        [attibute addAttribute:NSFontAttributeName
                         value:[UIFont fontWithName:@"MYRIADPRO-BOLD" size:16.0f]
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

- (void)addStickerWithImageView:(UIImageView *)imageView ComicItemImage:(UIImage*)itemImage rectValue:(CGRect)rect Tranform:(CGAffineTransform)tranformData
{
    if (!CGRectEqualToRect(rect,CGRectZero)) {
//        if (tranformData != nil) {
        imageView.frame = rect;
//            NSLog(@"Transform value %@",tranformData);
//            CGFloat angle = atan2f(CGAffineTransformFromString(tranformData).b, CGAffineTransformFromString(tranformData).a);
//            CGFloat degrees = angle * (180 / M_PI);
//            imageView.transform = CGAffineTransformRotate(CGAffineTransformFromString(tranformData), angle);
            imageView.transform =  tranformData;
        
        NSLog(@"After value set %@",[NSValue valueWithCGAffineTransform:imageView.transform]);
//        }
    }else{
        imageView.image = imageView.image;
    }
//    NSLog(@"addStickerWithImageView %f",(imageView.contentScaleFactor));
    
    imageView.userInteractionEnabled = YES;
    
    imageView.contentMode = UIViewContentModeScaleAspectFit;
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
    
    
//    UITapGestureRecognizer *tapImgvEdit = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleImgvEditTap:)];
//    tapImgvEdit.cancelsTouchesInView = YES;
//    tapImgvEdit.numberOfTapsRequired = 1;
//    tapImgvEdit.delegate = self;
//    [imageView addGestureRecognizer:tapImgvEdit];
    
    imgvComic.userInteractionEnabled = YES;
    imgvComic.clipsToBounds = YES;
    
    UIImage* imgWithOutAlpha = [imageView.image imageByTrimmingTransparentPixelsRequiringFullOpacity:NO];
    imageView.image = nil;
    imageView.image = imgWithOutAlpha;
    
//    float widthRatio = imageView.bounds.size.width / imgWithOutAlpha.size.width;
//    float heightRatio = imageView.bounds.size.height / imgWithOutAlpha.size.height;
//    float scale = MIN(widthRatio, heightRatio);
//    float imageWidth = scale * imgWithOutAlpha.size.width;
//    float imageHeight = scale * imgWithOutAlpha.size.height;
    
//    imageView.frame = CGRectMake(CGRectGetMinX(imageView.frame), CGRectGetMinY(imageView.frame), imageWidth, imageHeight);
//    CGAffineTransform tt_1 = imageView.transform;
//    
//    NSString * nn =  @"[1, 0, 0, 1, 0, 0]";
//    CGAffineTransform tt= CGAffineTransformFromString(nn);
//    imageView.transform = tt;
    
    [imgvComic addSubview:imageView];
    
//    imageView.transform = tt_1;
    
}

- (void)addBubbleWithImage:(ComicItemBubble *)bubbleHolderView ComicItemImage:(UIImage*)itemImage rectValue:(CGRect)rect
{    

    if (!CGRectEqualToRect(rect,CGRectZero)) {
        bubbleHolderView.frame = rect;
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
    [bubbleHolderView.txtBuble setBackgroundColor:[UIColor clearColor]];
    bubbleHolderView.txtBuble.font = [UIFont fontWithName:@"MYRIADPRO-REGULAR" size:20];
    bubbleHolderView.txtBuble.textColor = [UIColor blackColor];
    bubbleHolderView.txtBuble.returnKeyType = UIReturnKeyDone;
    bubbleHolderView.txtBuble.opaque = YES;
//    [bubbleHolderView.txtBuble addObserver:self forKeyPath:@"contentSize" options:(NSKeyValueObservingOptionNew) context:NULL];
    bubbleHolderView.txtBuble.textAlignment = NSTextAlignmentCenter;
    CGFloat centerLeftValue = bubbleHolderView.txtBuble.frame.size.width/2;
    CGFloat centerTopValue = bubbleHolderView.txtBuble.frame.size.height/2;
    
    bubbleHolderView.txtBuble.contentInset = UIEdgeInsetsMake(centerTopValue - 10,centerLeftValue,0,0.0);
    bubbleHolderView.txtBuble.scrollEnabled = NO;
    bubbleHolderView.txtBuble.autocorrectionType = UITextAutocorrectionTypeNo;
    if (![bubbleHolderView.txtBuble.text isEqualToString:@""]) {
        [self textViewShouldEndEditing:bubbleHolderView.txtBuble];
    }

//    [bubbleHolderView.txtBuble setBackgroundColor:[UIColor yellowColor]];
    
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
//    [bubbleHolderView.imageView addSubview:bubbleHolderView.txtBuble];
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
        frameTxtCaption = CGRectMake(0, -2, 270, 30);
        framePlusButton = CGRectMake(265, 0, 30, 30);
        fontsize = 17;
    }
    else if (IS_IPHONE_6)
    {
        frameCaptionHolder = CGRectMake(10, 111, 367, 60);
        frameBGImageView = CGRectMake(0, 0, 345, 40);
        frameTxtCaption = CGRectMake(0, -2, 320, 35);
        framePlusButton = CGRectMake(310, 2, 30, 30);
        
        fontsize = 20;
        
    }
    else if (IS_IPHONE_6P)
    {
        frameCaptionHolder = CGRectMake(10, 111, 410, 60);
        frameBGImageView = CGRectMake(0, 0, 380, 40);
        frameTxtCaption = CGRectMake(0, -2, 340, 35);
        framePlusButton = CGRectMake(340, 2, 30, 30);
        
        fontsize = 22;
    }
    else
    {
        frameCaptionHolder = CGRectMake(10, 111, 301, 60);
        frameBGImageView = CGRectMake(0, 0, 280, 33);
        frameTxtCaption = CGRectMake(0, -2, 270, 30);
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

-(void)sendComic{
    
    [self.delegate comicMakingViewControllerWithEditingDone:self
                                              withImageView:imgvComic
                                            withPrintScreen:printScreen
                                               withNewSlide:isNewSlide
                                                withPopView:NO];
    
//    UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:@"Main" bundle: nil];
//    SendPageViewController *controller = (SendPageViewController *)[mainStoryboard instantiateViewControllerWithIdentifier:@"SendPage"];
//    [self.navigationController pushViewController:controller animated:NO];
//    
//    
//    //Removing current View
//        NSMutableArray *navigationArray = [[NSMutableArray alloc] initWithArray: self.navigationController.viewControllers];
//        [navigationArray removeObjectAtIndex: navigationArray.count - 2 ];
//        self.navigationController.viewControllers = navigationArray;
//        navigationArray =nil;
//
//    return;
    //Desable the image view intactin
    [self.view setUserInteractionEnabled:NO];
    NSMutableArray* comicSlides = [self getDataFromFile];
    NSMutableArray* paramArray = [[NSMutableArray alloc] init];
    for (NSData* data in comicSlides) {
        
        NSMutableDictionary* dataDic = [[NSMutableDictionary alloc] init];
        ComicPage* cmPage = [NSKeyedUnarchiver unarchiveObjectWithData:data];
        NSData *imageData = UIImageJPEGRepresentation([AppHelper getImageFile:cmPage.printScreenPath], 1);
        
        [dataDic setObject:imageData forKey:@"SlideImage"];
        
        NSData* slideTypeData = [@"slideImage" dataUsingEncoding:NSUTF8StringEncoding];
        
        [dataDic setObject:slideTypeData forKey:@"SlideImageType"];
        
        [paramArray addObject:dataDic];
    }
    NSLog(@"Start uploading");
    ComicNetworking* cmNetWorking = [ComicNetworking sharedComicNetworking];
    [cmNetWorking UploadComicImage:paramArray completeBlock:^(id json, id jsonResponse) {
        
        NSLog(@"Finish Uploading");
        NSLog(@"Start Comic Creation");
        [cmNetWorking postComicCreation:[self createSendParams:[json objectForKey:@"slides"] comicSlides:comicSlides]
                                     Id:nil completion:^(id json,id jsonResposeHeader) {
            
            [AppHelper setCurrentcomicId:[json objectForKey:@"data"]];
            
                                          [self.view setUserInteractionEnabled:YES];
//                                         [self.navigationController popViewControllerAnimated:NO];
                                         
                                         if(self.comicType != ReplyComic) {
                                             UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:@"Main" bundle: nil];
                                             SendPageViewController *controller = (SendPageViewController *)[mainStoryboard instantiateViewControllerWithIdentifier:@"SendPage"];
                                             [self.navigationController pushViewController:controller animated:YES];
                                         } else {
                                             if(self.replyType == FriendReply) {
                                                 [[NSNotificationCenter defaultCenter] postNotificationName:@"UpdateFriendComics" object:nil];
                                             } else if(self.replyType == GroupReply) {
                                                 [[NSNotificationCenter defaultCenter] postNotificationName:@"UpdateGroupComics" object:nil];
                                             }
                                             [self.navigationController dismissViewControllerAnimated:YES completion:nil];
                                         }
            
            //Removing current View
//            NSMutableArray *navigationArray = [[NSMutableArray alloc] initWithArray: self.navigationController.viewControllers];
//            [navigationArray removeObjectAtIndex: navigationArray.count - 2 ];
//            self.navigationController.viewControllers = navigationArray;
//            navigationArray =nil;
            
        } ErrorBlock:^(JSONModelError *error) {
            NSLog(@"completion %@",error);
            [self.view setUserInteractionEnabled:YES];
        }];
        
    } ErrorBlock:^(JSONModelError *error) {
        [self.view setUserInteractionEnabled:YES];
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
        [comicMakeDic setObject:self.shareId forKey:@"share_id"];
    } else {
        [comicMakeDic setObject:@"CM" forKey:@"comic_type"]; // COMIC MAKING
    }
    
    [comicMakeDic setObject:@"0" forKey:@"conversation_id"];
    [comicMakeDic setObject:@"1" forKey:@"status"];
    [comicMakeDic setObject:@"1" forKey:@"is_public"];
    //Slide Array
    NSMutableArray* slides = [[NSMutableArray alloc] init];
    
    
//    NSMutableArray* comicSlides = [self getDataFromFile]; //[[[NSUserDefaults standardUserDefaults] objectForKey:@"comicSlides"] mutableCopy];
    for (int i=0; i< [comicSlides count]; i++) {
//    for (NSData* data in comicSlides) {
        NSData* data = [comicSlides objectAtIndex:i];
        ComicPage* cmPage = [NSKeyedUnarchiver unarchiveObjectWithData:data];
        
        //ComicSlides Object
        NSMutableDictionary* cmSlide = [[NSMutableDictionary alloc] init];
//        [cmSlide setObject:[AppHelper encodeToBase64String:[AppHelper getImageFile:cmPage.printScreenPath]] forKey:@"slide_image"];
//        [cmSlide setObject:@"" forKey:@"slide_text"];
        
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
            id imageView = comicPage.subviews[i];
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
                    
                    [cmEng setObject:[NSString stringWithFormat:@"%f",((ComicItemBubble*)imageView).frame.origin.x] forKey:@"position_top"];
                    [cmEng setObject:[NSString stringWithFormat:@"%f",((ComicItemBubble*)imageView).frame.origin.y] forKey:@"position_left"];
                    [cmEng setObject:@"1" forKey:@"z_index"];
                    
                    [enhancements addObject:cmEng];
                }
            }
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

-(void)doAutoSave :(id)comicItemObj{
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_group_t group = dispatch_group_create();
    
    // Add a task to the group
    dispatch_group_async(group, queue, ^{
        if (comicItemObj != nil) {
            [self.delegate comicMakingItemSave:comicPage
                                        withImageView:comicItemObj
                                      withPrintScreen:printScreen withRemove:NO];
        }
        [self doPrintScreen];
    });
}

-(void)doPrintScreen{
    [imgvComic setFrame:temImagFrame];
    
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_group_t group = dispatch_group_create();
    
    dispatch_group_async(group, queue, ^{
        @try {
            printScreen = [UIImage imageWithView:imgvComic paque:YES];
        } @catch (NSException *exception) {
            
        } @finally {
            
        }
    });
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
        [self.delegate comicMakingItemSave:comicPage withImageView:comicItemObj withPrintScreen:printScreen withRemove:YES];
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
@end
