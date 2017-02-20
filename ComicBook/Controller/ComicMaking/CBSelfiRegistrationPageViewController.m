//
//  CBSelfiRegistrationPageViewController.m
//  ComicBook
//
//  Created by Sandeep Kumar Lall on 28/01/17.
//  Copyright © 2017 Providence. All rights reserved.
//

#import "CBSelfiRegistrationPageViewController.h"
#import "MZCroppableView.h"
#import "AVCamPreviewView.h"
#import <AVFoundation/AVFoundation.h>
#import <CoreAudio/CoreAudioTypes.h>
#import <QuartzCore/QuartzCore.h>
#import <AVFoundation/AVFoundation.h>
#import <AssetsLibrary/AssetsLibrary.h>
#import "UIImage+Image.h"
#import "CropRegisterViewController.h"
#import "UIImage+resize.h"
#import "UIImage+Image.h"
#import "UIBezierPath-Points.h"
#import "UIImage+ImageCompress.h"
#import "UIImage+Trim.h"
#import "AppConstants.h"
#import "InstructionView.h"
#import "CBDrawingColor.h"
#import "RowButtonsViewController.h"
#import "ACEDrawingView.h"
#import "UIColor+Color.h"
#import "CBR2ScreenViewController.h"


static void * CapturingStillImageContext = &CapturingStillImageContext;
static void * RecordingContext = &RecordingContext;
static void * SessionRunningAndDeviceAuthorizedContext = &SessionRunningAndDeviceAuthorizedContext;



@interface CBSelfiRegistrationPageViewController ()<UIImagePickerControllerDelegate,
UINavigationControllerDelegate,
InstructionViewDelegate,
MZCroppableViewDelegate,CBDrawingColorDelegate>

@property (weak, nonatomic) IBOutlet UIView *viewCamera;
@property (weak, nonatomic) IBOutlet UIButton *btnCrop;
@property (weak, nonatomic) IBOutlet UIImageView *imgvCrop;
@property (weak, nonatomic) IBOutlet UIView *viewCrop;

@property (weak, nonatomic) IBOutlet UIView *viewBlackBackground;
@property (weak, nonatomic) IBOutlet UIButton *btnUndo;
@property (weak, nonatomic) IBOutlet UIButton *btnBack;
@property (weak, nonatomic) IBOutlet UIButton *btnImagePicker;
@property (weak, nonatomic) IBOutlet UIButton *btnDoneCroping;
@property (weak, nonatomic) IBOutlet UIButton *btnCameraReverse;

@property (strong, nonatomic) MZCroppableView *mzCroppableView;
@property (nonatomic) BOOL isFrontCameraOn;
@property (strong, nonatomic) UIPinchGestureRecognizer *pinchGesture;
@property (nonatomic) CGFloat lastScale;

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
@property (nonatomic, strong) CropRegisterViewController *parentViewController;
@property (nonatomic, strong) UIBezierPath *drawLinePath;

@property CGPoint imgvCropCenter;

@property (nonatomic) BOOL isTakePicture;
@property (nonatomic) CGRect frameImgvCrop;


@property (nonatomic) CGRect cropRectForImage;
@property (nonatomic,strong) UIBezierPath *apath;
@property (nonatomic,strong) CAShapeLayer *circleLayer;

// R2 screen controller

@property (nonatomic,strong) IBOutlet UIView *backGroundBlackView;
@property (nonatomic,strong) IBOutlet UIImage *croppedImg;
@property (nonatomic,strong) IBOutlet UIView *croppedView;
@property (nonatomic,strong) IBOutlet UIImageView *croppedImageShown;
@property (nonatomic) BOOL isShowBlackBG;
@property (strong, nonatomic) ACEDrawingView *drawView;
@property (nonatomic) UIColor *onColor;
@property (nonatomic) BOOL isAlreadyDoubleDrawColor;
@property (nonatomic,strong) IBOutlet UIButton *penBtn;
@property (strong,nonatomic) NSMutableArray *allPointsForRedFace;
@property (strong,nonatomic) UIColor *selectedColor;
@property (strong,nonatomic) UIView *lineDrawView;
@property (strong,nonatomic) NSMutableArray *pathDrawArray,*pathColorArray;
@property (strong,nonatomic) IBOutlet UIButton *tickButton;
@property (nonatomic, strong) NSMutableArray * paths;
@property (nonatomic, strong) UIImageView *circularLineImage;
@property (nonatomic, strong) UIImageView *cameraBtnImg;

@end

@implementation CBSelfiRegistrationPageViewController

@synthesize imgvCrop,btnCrop,mzCroppableView,cameraPreview,deviceAuthorized,sessionQueue,viewCrop,imgvCropCenter,isFrontCameraOn;

@synthesize btnBack,btnCamera,btnDoneCroping,btnImagePicker,btnUndo,btnCameraReverse, isTakePicture,viewBlackBackground,drawView,onColor,isAlreadyDoubleDrawColor,allPointsForRedFace,paths,pathColorArray;



#pragma mark - UIViewController Methods
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // adding black BG view for R2 screen
    
    [self setUpR2View];
    
}
-(void)viewWillAppear:(BOOL)animated
{
    if (self.parentViewController)
    {
#if TARGET_OS_SIMULATOR
        self.isRegView = NO;
#else
        self.isRegView = YES;
#endif
    }
    [self preparView];
    
    dispatch_async([self sessionQueue], ^
                   {
//                       [self addObserver:self forKeyPath:@"sessionRunningAndDeviceAuthorized" options:(NSKeyValueObservingOptionOld | NSKeyValueObservingOptionNew) context:SessionRunningAndDeviceAuthorizedContext];
//                       [self addObserver:self forKeyPath:@"stillImageOutput.capturingStillImage" options:(NSKeyValueObservingOptionOld | NSKeyValueObservingOptionNew) context:CapturingStillImageContext];
//                       [self addObserver:self forKeyPath:@"movieFileOutput.recording" options:(NSKeyValueObservingOptionOld | NSKeyValueObservingOptionNew) context:RecordingContext];
//                       [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(subjectAreaDidChange:) name:AVCaptureDeviceSubjectAreaDidChangeNotification object:[[self videoDeviceInput] device]];
                       
                       __weak CBSelfiRegistrationPageViewController *weakSelf = self;
                       
                       [self setRuntimeErrorHandlingObserver:[[NSNotificationCenter defaultCenter] addObserverForName:AVCaptureSessionRuntimeErrorNotification object:[self session] queue:nil usingBlock:^(NSNotification *note) {
                           CBSelfiRegistrationPageViewController *strongSelf = weakSelf;
                           dispatch_async([strongSelf sessionQueue], ^{
                               // Manually restarting the session since it must have been stopped due to an error.
                               [[strongSelf session] startRunning];
                           });
                           
                       }]];
                       
                       [[self session] startRunning];
                   });
    
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    if (self.isRegView == NO)
    {
        // open slide 5 Instruction
        dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0 * NSEC_PER_SEC));
        dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
            NSLog(@"Do some work");
            
            if ([InstructionView getBoolValueForSlide:kInstructionSlide5] == NO)
            {
//                InstructionView *instView = [[InstructionView alloc] initWithFrame:self.view.bounds];
//                instView.delegate = self;
//                [instView showInstructionWithSlideNumber:SlideNumber5 withType:InstructionBubbleType];
//                [instView setTrueForSlide:kInstructionSlide5];
//                
//                [self.view addSubview:instView];
            }
        });
        
    }
    
}

- (void)viewDidDisappear:(BOOL)animated
{
    dispatch_async([self sessionQueue], ^{
        [[self session] stopRunning];
        
        [[NSNotificationCenter defaultCenter] removeObserver:self name:AVCaptureDeviceSubjectAreaDidChangeNotification object:[[self videoDeviceInput] device]];
        [[NSNotificationCenter defaultCenter] removeObserver:[self runtimeErrorHandlingObserver]];
        
//        [self removeObserver:self forKeyPath:@"sessionRunningAndDeviceAuthorized" context:SessionRunningAndDeviceAuthorizedContext];
//        [self removeObserver:self forKeyPath:@"stillImageOutput.capturingStillImage" context:CapturingStillImageContext];
//        [self removeObserver:self forKeyPath:@"movieFileOutput.recording" context:RecordingContext];
    });
    
    
    
}

#pragma mark - UIView Methods
- (void)preparView
{
    imgvCropCenter = imgvCrop.center;
    
    btnUndo.enabled = NO;
    btnCrop.enabled = NO;
    btnDoneCroping.enabled = NO;
    
    //   cameraPreview.transform = CGAffineTransformScale(CGAffineTransformIdentity, 1.8, 1.0);
    if (!self.isRegView)
    {
        if (IS_IPHONE_5)
        {
            imgvCrop.frame = CGRectMake(6, 41, 307, 458);
            viewBlackBackground.layer.cornerRadius = 21;
        }
        else if (IS_IPHONE_6)
        {
            imgvCrop.frame = CGRectMake(6, 48, 362, 538);
            viewBlackBackground.layer.cornerRadius = 26;
        }
        else if (IS_IPHONE_6P)
        {
            imgvCrop.frame = CGRectMake(7.5, 52.95, 398.5, 593);
            viewBlackBackground.layer.cornerRadius = 28;
        }
        
        self.frameImgvCrop = imgvCrop.frame;
        viewBlackBackground.frame = imgvCrop.frame;
        cameraPreview.frame = imgvCrop.frame;
        [self prepareCameraView];
    }
    else
    {
        self.frameImgvCrop = imgvCrop.frame;
        
        // open slide F Instruction
        dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC));
        dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
            
            if ([InstructionView getBoolValueForSlide:kInstructionSlideF] == NO)
            {
//                InstructionView *instView = [[InstructionView alloc] initWithFrame:self.view.bounds];
//                instView.delegate = self;
//                [instView showInstructionWithSlideNumber:SlideNumber7 withType:InstructionGIFType];
//                [instView setTrueForSlide:kInstructionSlideF];
//                [self.view addSubview:instView];
            }
            
        });
        
        
        [self prepareCameraView];
#if !(TARGET_OS_SIMULATOR)
        [self btnCameraReverseTap:nil];
#endif
    }
    
    [self drawCircularCrop];
}

-(void)drawCircularCrop {
    
        self.circleLayer = [CAShapeLayer layer];
        self.apath=[UIBezierPath bezierPathWithOvalInRect:CGRectMake(([UIScreen mainScreen].bounds.origin.x+[UIScreen mainScreen].bounds.size.width)/2-150, 70, 300, 300)];

        [self.circleLayer setPath:[self.apath CGPath]];
        [[self.view layer] addSublayer:self.circleLayer];
        self.cropRectForImage=CGRectMake(([UIScreen mainScreen].bounds.origin.x+[UIScreen mainScreen].bounds.size.width)/2-150, 70, 300, 300);
        [self.circleLayer setStrokeColor:[[UIColor clearColor] CGColor]];
        [self.circleLayer setFillColor:[[UIColor clearColor] CGColor]];
        self.circleLayer.lineWidth   = 6.0;
        [self.circleLayer setLineDashPattern:[NSArray arrayWithObjects:[NSNumber numberWithInt:10],[NSNumber numberWithInt:10],nil]];
    
    self.circularLineImage=[[UIImageView alloc] initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height)];
    [self.view addSubview:self.circularLineImage];
    [self.circularLineImage setImage:[UIImage imageNamed:@"white-dotted-circle.png"]];
    
    
    // camera button create
    
    self.cameraBtnImg=[[UIImageView alloc] initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height)];
    [self.view addSubview:self.cameraBtnImg];
    [self.cameraBtnImg setImage:[UIImage imageNamed:@"blue-circle.png"]];

}

- (void)addPinchGesture
{
    self.pinchGesture = [[UIPinchGestureRecognizer alloc]initWithTarget:self action:@selector(pinchDone:)];
    cameraPreview.userInteractionEnabled = YES;
    [cameraPreview addGestureRecognizer:self.pinchGesture];
}

- (IBAction)pinchDone:(UIPinchGestureRecognizer *)gestureRecognizer
{
    if([gestureRecognizer state] == UIGestureRecognizerStateBegan)
    {
        // Reset the last scale, necessary if there are multiple objects with different scales
        _lastScale = [gestureRecognizer scale];
    }
    
    if ([gestureRecognizer state] == UIGestureRecognizerStateBegan ||
        
        [gestureRecognizer state] == UIGestureRecognizerStateChanged)
    {
        
        CGFloat currentScale = [[[gestureRecognizer view].layer valueForKeyPath:@"transform.scale"] floatValue];
        
        // Constants to adjust the max/min values of zoom
        const CGFloat kMaxScale = 2.0;
        const CGFloat kMinScale = 1.0;
        
        CGFloat newScale = 1 -  (_lastScale - [gestureRecognizer scale]);
        
        newScale = MIN(newScale, kMaxScale / currentScale);
        newScale = MAX(newScale, kMinScale / currentScale);
        
        CGAffineTransform transform = CGAffineTransformScale([[gestureRecognizer view] transform], newScale, newScale);
        
        [gestureRecognizer view].transform = transform;
        
        _lastScale = [gestureRecognizer scale];  // Store the previous scale factor for the next pinch gesture call
    }
}
- (void)prepareCameraView
{
    [self addPinchGesture];
    
    // Create the AVCaptureSession
    AVCaptureSession *session = [[AVCaptureSession alloc] init];
    [self setSession:session];
    
    // Setup the preview view
    [cameraPreview setSession:session];
    
    // Check for device authorization
    [self checkDeviceAuthorizationStatus];
    
    dispatch_queue_t sessionQueue1 = dispatch_queue_create("session queue", DISPATCH_QUEUE_SERIAL);
    [self setSessionQueue:sessionQueue1];
    
    dispatch_async(sessionQueue1, ^{
        [self setBackgroundRecordingID:UIBackgroundTaskInvalid];
        
        NSError *error = nil;
        
        AVCaptureDevice *videoDevice = [CBSelfiRegistrationPageViewController deviceWithMediaTypeForPics:AVMediaTypeVideo preferringPosition:AVCaptureDevicePositionBack];
        
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
                
                [(AVCaptureVideoPreviewLayer *)[cameraPreview layer] setVideoGravity:AVLayerVideoGravityResizeAspectFill];
                //                [captureVideoPreviewLayer setVideoGravity:AVLayerVideoGravityResizeAspectFill];
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
         connection.preferredVideoStabilizationMode = AVCaptureVideoStabilizationModeStandard;
         
         [self setMovieFileOutput:movieFileOutput];
         }*/
        
        AVCaptureStillImageOutput *stillImageOutput = [[AVCaptureStillImageOutput alloc] init];
        if ([session canAddOutput:stillImageOutput])
        {
            [stillImageOutput setOutputSettings:@{AVVideoCodecKey : AVVideoCodecJPEG}];
            
            //stillImageOutput.highResolutionStillImageOutputEnabled = NO;
            
            [session addOutput:stillImageOutput];
            
            
            
            [self setStillImageOutput:stillImageOutput];
        }
    });
    
}
//
//#pragma mark - Camera Methods
//- (BOOL)isSessionRunningAndDeviceAuthorized
//{
//    return [[self session] isRunning] && [self isDeviceAuthorized];
//}
//
//+ (NSSet *)keyPathsForValuesAffectingSessionRunningAndDeviceAuthorized
//{
//    return [NSSet setWithObjects:@"session.running", @"deviceAuthorized", nil];
//}
//
//- (BOOL)prefersStatusBarHidden
//{
//    return YES;
//}
//
//- (BOOL)shouldAutorotate
//{
//    // Disable autorotation of the interface when recording is in progress.
//    return ![self lockInterfaceRotation];
//}
//
//- (NSUInteger)supportedInterfaceOrientations
//{
//    return UIInterfaceOrientationMaskAll;
//}
//
//- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
//{
//    [[(AVCaptureVideoPreviewLayer *)[cameraPreview layer] connection] setVideoOrientation:(AVCaptureVideoOrientation)toInterfaceOrientation];
//}
//
//- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
//{
//    if (context == CapturingStillImageContext)
//    {
//        BOOL isCapturingStillImage = [change[NSKeyValueChangeNewKey] boolValue];
//        
//        if (isCapturingStillImage)
//        {
//            [self runStillImageCaptureAnimation];
//        }
//    }
//    else if (context == SessionRunningAndDeviceAuthorizedContext)
//    {
//        BOOL isRunning = [change[NSKeyValueChangeNewKey] boolValue];
//        
//        
//        
//    }
//    else
//    {
//        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
//    }
//}
- (void)subjectAreaDidChange:(NSNotification *)notification
{
    CGPoint devicePoint = CGPointMake(.5, .5);
    
    [self focusWithMode:AVCaptureFocusModeContinuousAutoFocus exposeWithMode:AVCaptureExposureModeContinuousAutoExposure atDevicePoint:devicePoint monitorSubjectAreaChange:NO];
}

//#pragma mark - Camera File Output Delegate
//- (void)captureOutput:(AVCaptureFileOutput *)captureOutput didFinishRecordingToOutputFileAtURL:(NSURL *)outputFileURL fromConnections:(NSArray *)connections error:(NSError *)error
//{
//    if (error)
//        NSLog(@"%@", error);
//    
//    [self setLockInterfaceRotation:NO];
//    
//    // Note the backgroundRecordingID for use in the ALAssetsLibrary completion handler to end the background task associated with this recording. This allows a new recording to be started, associated with a new UIBackgroundTaskIdentifier, once the movie file output's -isRecording is back to NO — which happens sometime after this method returns.
//    UIBackgroundTaskIdentifier backgroundRecordingID = [self backgroundRecordingID];
//    [self setBackgroundRecordingID:UIBackgroundTaskInvalid];
//    
//    [[[ALAssetsLibrary alloc] init] writeVideoAtPathToSavedPhotosAlbum:outputFileURL completionBlock:^(NSURL *assetURL, NSError *error)
//     {
//         if (error)
//             NSLog(@"%@", error);
//         
//         [[NSFileManager defaultManager] removeItemAtURL:outputFileURL error:nil];
//         
//         if (backgroundRecordingID != UIBackgroundTaskInvalid)
//             [[UIApplication sharedApplication] endBackgroundTask:backgroundRecordingID];
//     }];
//}
//
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

+ (AVCaptureDevice *)deviceWithMediaTypeForPics:(NSString *)mediaType preferringPosition:(AVCaptureDevicePosition)position
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
//
//#pragma mark - Camera UI
//- (void)runStillImageCaptureAnimation
//{
//    dispatch_async(dispatch_get_main_queue(), ^
//                   {
//                       [[cameraPreview layer] setOpacity:0.0];
//                       
//                       [UIView animateWithDuration:.25 animations:^{
//                           [[cameraPreview layer] setOpacity:1.0];
//                       }];
//                   });
//}
//
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


#pragma mark - UIImagePickerControllerDelegate Method
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    [[GoogleAnalytics sharedGoogleAnalytics] logUserEvent:@"CropSticker" Action:@"UploadPicture" Label:@""];
    
    [self dismissViewControllerAnimated:YES completion:^
     {
         UIImage *selectedImage = info[UIImagePickerControllerOriginalImage];
         
         //  CGFloat width = selectedImage.size.width / 3;
         //  CGFloat height = selectedImage.size.height / 3;
         
         //  UIImage *compressImage = [selectedImage compressWithMaxSize:CGSizeMake(width, height) andQuality:1];
         
         //         NSData *imageData = UIImageJPEGR epresentation(selectedImage, 0);
         
         //     imgvCrop.image =  [self compressImage:selectedImage];
         //      imgvCrop.image = selectedImage;
         //         imgvCrop.contentMode = UIViewContentModeScaleAspectFit;
         //         UIImage *image = [[UIImage alloc] initWithData:imageData];;
         //
         //         UIImage *small = [UIImage imageWithCGImage:image.CGImage scale:0 orientation:image.imageOrientation];
         
         //  UIImage *compressImage = [self compressImage:selectedImage compressRatio:0 maxCompressRatio:0];
         
         imgvCrop.image = selectedImage;
         cameraPreview.hidden = YES;
         btnCrop.enabled = YES;
         btnCameraReverse.hidden = YES;
         btnCamera.selected = YES;
         btnDoneCroping.enabled = self.isRegView?YES:NO;
       //  [self setImageViewSize];
     }];
}
- (UIImage *)compressImage:(UIImage *)image compressRatio:(CGFloat)ratio maxCompressRatio:(CGFloat)maxRatio
{
    
    //We define the max and min resolutions to shrink to
    int MIN_UPLOAD_RESOLUTION = 1136 * 640;
    int MAX_UPLOAD_SIZE = 300;
    
    float factor;
    float currentResolution = image.size.height * image.size.width;
    
    //We first shrink the image a little bit in order to compress it a little bit more
    if (currentResolution > MIN_UPLOAD_RESOLUTION) {
        factor = sqrt(currentResolution / MIN_UPLOAD_RESOLUTION) * 2;
        //image = [self scaleDown:image withSize:CGSizeMake(image.size.width / factor, image.size.height / factor)];
    }
    
    //Compression settings
    CGFloat compression = ratio;
    CGFloat maxCompression = maxRatio;
    
    //We loop into the image data to compress accordingly to the compression ratio
    NSData *imageData = UIImageJPEGRepresentation(image, compression);
    while ([imageData length] > MAX_UPLOAD_SIZE && compression > maxCompression) {
        compression -= 0.10;
        imageData = UIImageJPEGRepresentation(image, compression);
    }
    
    //Retuns the compressed image
    return [[UIImage alloc] initWithData:imageData];
}
//- (UIImage*)scaleDown:(UIImage*)image withSize:(CGSize)newSize
//{
//    
//    //We prepare a bitmap with the new size
//    UIGraphicsBeginImageContextWithOptions(newSize, YES, 0.0);
//    
//    //Draws a rect for the image
//    [image drawInRect:CGRectMake(0, 0, newSize.width, newSize.height)];
//    
//    //We set the scaled image from the context
//    UIImage* scaledImage = UIGraphicsGetImageFromCurrentImageContext();
//    UIGraphicsEndImageContext();
//    
//    return scaledImage;
//}
//- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
//{
//    [self dismissViewControllerAnimated:YES completion:nil];
//}
//
//- (void)setImageViewSize
//{
//    float widthRatio = self.imgvCrop.bounds.size.width / self.imgvCrop.image.size.width;
//    float heightRatio = self.imgvCrop.bounds.size.height / self.imgvCrop.image.size.height;
//    float scale = MIN(widthRatio, heightRatio);
//    float imageWidth = scale * self.imgvCrop.image.size.width;
//    float imageHeight = scale * self.imgvCrop.image.size.height;
//    
//    self.imgvCrop.frame = CGRectMake(0, 0, imageWidth, imageHeight);
//    self.imgvCrop.center = imgvCropCenter;
//}
//
#pragma mark - Events Methods
- (IBAction)btnCropTap:(id)sender
{
    imgvCrop.hidden = NO;
    btnUndo.enabled = YES;
    btnDoneCroping.enabled = YES;
    btnCrop.userInteractionEnabled = YES;
    btnImagePicker.enabled = NO;
    [btnCrop setImage:[UIImage imageNamed:@"scissors-icon-gray"] forState:UIControlStateNormal];
    
    CGRect rect1 = CGRectMake(0, 0, imgvCrop.image.size.width, imgvCrop.image.size.height);
    
    CGRect rect2 = imgvCrop.frame;
    
    [[NSUserDefaults standardUserDefaults]setObject:@"yes" forKey:@"tappEnder"];
    [[NSUserDefaults standardUserDefaults]synchronize];
    
    [imgvCrop setFrame:[MZCroppableView scaleRespectAspectFromRect1:rect1 toRect2:rect2 ]];
    
    
    [mzCroppableView removeFromSuperview];
    mzCroppableView = [[MZCroppableView alloc] initWithImageView:imgvCrop];
    mzCroppableView.delegate = self;
    [self.view addSubview:mzCroppableView];
    
   // [self bringToFrontAllButtons];
}

- (IBAction)btnCameraTap:(id)sender
{
    [[GoogleAnalytics sharedGoogleAnalytics] logUserEvent:@"CropSticker" Action:@"Camera" Label:@""];
    
    if (btnCamera.isSelected)
    {
        btnCamera.selected = NO;
        
        imgvCrop.image = nil;
        cameraPreview.hidden = NO;
        btnCameraReverse.hidden = NO;
        
        imgvCrop.frame = self.frameImgvCrop;
        
        cameraPreview.transform = CGAffineTransformIdentity;
        cameraPreview.frame = imgvCrop.frame;
        
        [mzCroppableView removeFromSuperview];
        
        btnUndo.enabled = NO;
        btnCrop.enabled = NO;
        btnDoneCroping.enabled = self.isRegView?YES:NO;
    }
    else
    {
        //btnCamera.selected = YES;
        btnDoneCroping.enabled = self.isRegView?YES:NO;
        dispatch_async([self sessionQueue], ^{
            // Update the orientation on the still image output video connection before capturing.
            [[[self stillImageOutput] connectionWithMediaType:AVMediaTypeVideo] setVideoOrientation:[[(AVCaptureVideoPreviewLayer *)[cameraPreview layer] connection] videoOrientation]];
            
            // Flash set to Auto for Still Capture
            [CBSelfiRegistrationPageViewController setFlashMode:AVCaptureFlashModeAuto forDevice:[[self videoDeviceInput] device]];
            
            // Capture a still image.
            [[self stillImageOutput] captureStillImageAsynchronouslyFromConnection:[[self stillImageOutput] connectionWithMediaType:AVMediaTypeVideo] completionHandler:^(CMSampleBufferRef imageDataSampleBuffer, NSError *error) {
                
                if (imageDataSampleBuffer)
                {
                    NSData *imageData = [AVCaptureStillImageOutput jpegStillImageNSDataRepresentation:imageDataSampleBuffer];
                    
                    UIImage *image = [[UIImage alloc] initWithData:imageData];
                    UIImage *imageToDisplay=[self removeRotationForImage:image];
                    UIImage *finalImage = [UIImage imageWithCGImage:imageToDisplay.CGImage scale:2.0 orientation:imageToDisplay.imageOrientation];

                    [self.capturedImage setHidden:NO];
                    self.capturedImage.image=finalImage;
                    [self.cameraPreview setHidden:YES];
                    
                    CGRect frame=self.cropRectForImage;
                    frame.size.height=self.cropRectForImage.size.height*2;
                    frame.size.width=self.cropRectForImage.size.width*2;
                    self.cropRectForImage=frame;
                    
                    CGImageRef imageRef = CGImageCreateWithImageInRect([finalImage CGImage], self.cropRectForImage);
                    // or use the UIImage wherever you like
                    UIImage *croppedImage;
                    croppedImage=[UIImage imageWithCGImage:imageRef];
                    CGImageRelease(imageRef);
                    
                    [self performSelectorOnMainThread:@selector(setUpR2ScreenWithImage:) withObject:croppedImage waitUntilDone:NO];

      /*
                    
//                    if (self.isRegView)
//                    {
//                        CGRect cropRects = [imgvCrop convertRect:CGRectMake(0, 40, CGRectGetWidth(imgvCrop.frame), CGRectGetHeight(imgvCrop.frame)) toView:cameraPreview];
//                        CGFloat factor = (image.size.width * image.scale) / CGRectGetWidth(self.view.frame);
//                        
//                        cropRects.origin.x *= factor;
//                        cropRects.origin.y *= factor;
//                        
//                        cropRects.size.width  *= factor;
//                        cropRects.size.height *= factor;
//                        
//                        UIImage *cropedImage = [image cropedImagewithCropRect:cropRects];
//                        NSLog(@"%ld",(long)cropedImage.imageOrientation);
//                        
//                        if (isFrontCameraOn)
//                        {
//                            UIImage *flippedImage = [UIImage imageWithCGImage:cropedImage.CGImage
//                                                                        scale:cropedImage.scale
//                                                                  orientation:UIImageOrientationUpMirrored];
//                            
//                            imgvCrop.image =  flippedImage;
//                            
//                        }
//                        else
//                        {
//                            imgvCrop.image = cropedImage;
//                        }
//                        
//                        //  imgvCrop.image = [UIImage ScaletoFill:image toSize:imgvCrop.frame.size];
//                        
//                        imgvCrop.contentMode = UIViewContentModeScaleAspectFit;
//                        
//                    }
//                    else
//                    {
//                        if (isFrontCameraOn)
//                        {
//                            CGRect cropRects = [imgvCrop convertRect:imgvCrop.frame toView:cameraPreview];
//                            
//                            CGFloat factor = (image.size.width * image.scale) / CGRectGetWidth(self.view.frame);
//                            
//                            cropRects.origin.x *= factor;
//                            cropRects.origin.y *= factor;
//                            
//                            cropRects.size.width  *= factor;
//                            cropRects.size.height *= factor;
//                            
//                            UIImage *cropedImage = [image cropedImagewithCropRect:cropRects];
//                            
//                            
//                            UIImage *flippedImage = [UIImage imageWithCGImage:cropedImage.CGImage
//                                                                        scale:cropedImage.scale
//                                                                  orientation:UIImageOrientationUpMirrored];
//                            
//                            imgvCrop.image =  flippedImage;
//                            imgvCrop.contentMode = UIViewContentModeScaleToFill;
//                        }
//                        else
//                        {
//                            CGRect cropRects = [imgvCrop convertRect:imgvCrop.frame toView:cameraPreview];
//                            
//                            CGFloat factor = (image.size.width * image.scale) / CGRectGetWidth(self.view.frame);
//                            
//                            cropRects.origin.x *= factor;
//                            cropRects.origin.y *= factor;
//                            
//                            cropRects.size.width  *= factor;
//                            cropRects.size.height *= factor;
//                            
//                            UIImage *cropedImage = [image cropedImagewithCropRect:cropRects];
//                            
//                            imgvCrop.image = cropedImage;
//                            imgvCrop.contentMode = UIViewContentModeScaleAspectFill;
//                            imgvCrop.clipsToBounds = YES;
//                            
//                            
//                        }
//                    }
//                    
//                    
//                    cameraPreview.hidden = YES;
//                    btnCrop.enabled = YES;
//                    btnCameraReverse.hidden = YES;
//                    
//                    
//                    if (self.isRegView == NO)
//                    {
//                        // open slide 6 Instruction
//                        dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC));
//                        dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
//                            NSLog(@"Do some work");
//                            
//                            if ([InstructionView getBoolValueForSlide:kInstructionSlide6] == NO)
//                            {
//                                InstructionView *instView = [[InstructionView alloc] initWithFrame:self.view.bounds];
//                                instView.delegate = self;
//                                [instView showInstructionWithSlideNumber:SlideNumber6 withType:InstructionBubbleType];
//                                [instView setTrueForSlide:kInstructionSlide6];
//                                
//                                [self.view addSubview:instView];
//                            }
//                        });
//                    }
       */
                }
            }];
            
        });
    }
}

#pragma mark- setUp R2 Screen

-(void)setUpR2View {
    
    self.backGroundBlackView=[[UIView alloc] initWithFrame:CGRectMake(0, -([UIScreen mainScreen].bounds.size.height), [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height)];
// //    [self.view addSubview:self.backGroundBlackView];
//   // [self.backGroundBlackView setBackgroundColor:[[UIColor blackColor] colorWithAlphaComponent:0.8]];
    
    
    
   // [self.backGroundBlackView setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"black_screen_R2.png"] ]];
    //[self.backGroundBlackView setBackgroundColor:[[UIColor colorWithPatternImage:[UIImage imageNamed:@"black_screen_R2.png"]] colorWithAlphaComponent:0.8]];
}

-(void)setUpR2ScreenWithImage:(UIImage *)croppedImage {
    
//    [self hideControllers:YES];
//    [self animatedBlackBGForR2Screen];
//    [self createCroppedViewWithImage:croppedImage];
    
    
    NSString * storyboardName = @"Main";
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:storyboardName bundle: nil];
    CBR2ScreenViewController * CBR2ScreenVCObj = (CBR2ScreenViewController *)[storyboard instantiateViewControllerWithIdentifier:@"CBR2ScreenVC"];
    CBR2ScreenVCObj.croppedImg=croppedImage;
    [self presentViewController:CBR2ScreenVCObj animated:YES completion:nil];
    
    //[self performSegueWithIdentifier:@"CBR2ScreenSegue" sender:self];

}

#pragma mark- setUp cropped Image view

-(void)createCroppedViewWithImage:(UIImage *)_croppedImage {
    
    self.croppedView=[[UIView alloc] initWithFrame:CGRectMake(([UIScreen mainScreen].bounds.origin.x+[UIScreen mainScreen].bounds.size.width)/2-150, 20, 300, 300)];
    [self.backGroundBlackView addSubview:self.croppedView];
    self.croppedView.layer.borderWidth=6.0;
    self.croppedView.layer.borderColor=[UIColor whiteColor].CGColor;
    self.croppedView.layer.cornerRadius=150;
    self.croppedView.layer.masksToBounds=YES;
 // //   [self.croppedView setBackgroundColor:[UIColor blackColor]];
    [self.croppedView setAlpha:1.0];
    
    self.croppedImageShown=[[UIImageView alloc] initWithFrame:CGRectMake(0, 0, self.croppedView.frame.size.width, self.croppedView.frame.size.height)];
    [self.croppedView addSubview:self.croppedImageShown];
    [self.croppedImageShown setImage:_croppedImage];
    self.croppedImageShown.layer.cornerRadius=150;
    self.croppedImageShown.layer.masksToBounds=YES;
// //    [self.croppedImageShown setBackgroundColor:[UIColor blackColor]];
    [self.croppedImageShown setAlpha:1.0];
    
    
    // lineDrwan View
    
    self.lineDrawView=[[UIView alloc] init];
    self.lineDrawView.frame=self.croppedImageShown.frame;
    [self.croppedView addSubview:self.lineDrawView];
    [self.lineDrawView setBackgroundColor:[UIColor clearColor]];
    [self.croppedView bringSubviewToFront:self.lineDrawView];
    
    [self addDrawingView];
    
}

#pragma mark- set up circle color view 

- (void)addDrawingView
{
    
    CBDrawingColor *CBDrawingColorObj=[[CBDrawingColor alloc] init];
    [CBDrawingColorObj setFrame:CGRectMake(40, self.croppedView.frame.origin.y+self.croppedView.frame.size.height+50, [UIScreen mainScreen].bounds.size.width-40, 30)];
    [CBDrawingColorObj setColorButtonsSize];
    [CBDrawingColorObj setDelegate:self];
    [CBDrawingColorObj setBackgroundColor:[UIColor clearColor]];
    [self.backGroundBlackView addSubview:CBDrawingColorObj];
    [self drawingColorTapEventWithColor:@"red"];
    
    // pen button
    
    self.penBtn=[UIButton buttonWithType:UIButtonTypeCustom];
    [self.penBtn setFrame:CGRectMake(10, self.croppedView.frame.origin.y+self.croppedView.frame.size.height+50, 20, 20)];
    [self.backGroundBlackView addSubview:self.penBtn];
    [self.penBtn setImage:[UIImage imageNamed:@"pen-icon-red.png"] forState:UIControlStateNormal];
    
    
    self.drawLinePath = [[UIBezierPath alloc] init];
    [self.drawLinePath setLineWidth:5.0];
    [self.drawLinePath setLineJoinStyle:kCGLineJoinRound];
   // [self drawRect:self.lineDrawView.frame];
    
    self.pathDrawArray=[[NSMutableArray alloc] init];
    paths=[[NSMutableArray alloc] init];
    pathColorArray=[[NSMutableArray alloc] init];
    
    
    /// tick button create
    
    self.tickButton=[UIButton buttonWithType:UIButtonTypeCustom];
    
    
    
}

-(void)drawnImageCropped {
    
    // UIColor *lineColor = <the color of the line>
    
    UIGraphicsBeginImageContext(self.croppedImageShown.image.size);
    
    // Pass 1: Draw the original image as the background
    [self.croppedImageShown.image drawAtPoint:CGPointMake(0,0)];
    
    // Pass 2: Draw the line on top of original image
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetLineWidth(context, 1.0);
    CGContextMoveToPoint(context, 0, 0);
    CGContextAddLineToPoint(context, self.croppedImageShown.image.size.width, 0);
    CGContextSetStrokeColorWithColor(context, self.selectedColor.CGColor);
    CGContextStrokePath(context);
    
    // Create new image
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    
    // Tidy up
    UIGraphicsEndImageContext();

}

- (void)drawRect:(CGRect)rect {
    
   
    //UIColor *fillColor = self.selectedColor;
    UIColor *fillColor = [UIColor redColor];
    [fillColor setFill];
    //UIColor *strokeColor = self.selectedColor;
    UIColor *strokeColor = [UIColor redColor];
    [strokeColor setStroke];
    // [self.drawLinePath closePath];
    //[self.drawLinePath fill];
    [self.drawLinePath stroke];
    
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
          //  [self.backGroundBlackView addSubview:rowController.view];
            
        }
    }
    if ([colorName isEqualToString:@"white"])
    {
        [rowController.btnPen setImage:[UIImage imageNamed:@"pen-icon-white.png"] forState:UIControlStateNormal];
        
        drawView.lineColor = [UIColor drawingColorWhite];
        [self.penBtn setImage:[UIImage imageNamed:@"pen-icon-white.png"] forState:UIControlStateNormal];
        self.selectedColor=[UIColor whiteColor];
    }
    else if ([colorName isEqualToString:@"black"])
    {;
        [rowController.btnPen setImage:[UIImage imageNamed:@"pen-icon-black.png"] forState:UIControlStateNormal];
        
        drawView.lineColor = [UIColor blackColor];
        [self.penBtn setImage:[UIImage imageNamed:@"pen-icon-black.png"] forState:UIControlStateNormal];
        self.selectedColor=[UIColor blackColor];
    }
    else if ([colorName isEqualToString:@"blue"])
    {
        [rowController.btnPen setImage:[UIImage imageNamed:@"pen-icon-blue.png"] forState:UIControlStateNormal];
        
        drawView.lineColor = [UIColor drawingColorBlue];
        [self.penBtn setImage:[UIImage imageNamed:@"pen-icon-blue.png"] forState:UIControlStateNormal];
        self.selectedColor=[UIColor blueColor];
        
    }
    else if ([colorName isEqualToString:@"red"])
    {
        [rowController.btnPen setImage:[UIImage imageNamed:@"pen-icon-red.png"] forState:UIControlStateNormal];
        
        drawView.lineColor = [UIColor drawingColorRed];
        [self.penBtn setImage:[UIImage imageNamed:@"pen-icon-red.png"] forState:UIControlStateNormal];
        self.selectedColor=[UIColor redColor];
        
    }
    else if ([colorName isEqualToString:@"yellow"])
    {
        [rowController.btnPen setImage:[UIImage imageNamed:@"pen-icon-yellow.png"] forState:UIControlStateNormal];
        
        drawView.lineColor = [UIColor drawingColorYellow];
        [self.penBtn setImage:[UIImage imageNamed:@"pen-icon-yellow.png"] forState:UIControlStateNormal];
        self.selectedColor=[UIColor yellowColor];
    }
    else if ([colorName isEqualToString:@"brown"])
    {
        [rowController.btnPen setImage:[UIImage imageNamed:@"pen-icon-brown.png"] forState:UIControlStateNormal];
        
        drawView.lineColor = [UIColor drawingColorBrown];
        [self.penBtn setImage:[UIImage imageNamed:@"pen-icon-brown.png"] forState:UIControlStateNormal];
        self.selectedColor=[UIColor brownColor];
    }
    else if ([colorName isEqualToString:@"green"])
    {
        [rowController.btnPen setImage:[UIImage imageNamed:@"pen-icon-green.png"] forState:UIControlStateNormal];
        [self.penBtn setImage:[UIImage imageNamed:@"pen-icon-green.png"] forState:UIControlStateNormal];
        
        drawView.lineColor = [UIColor drawingColorGreen];
        self.selectedColor=[UIColor greenColor];
    }
    else if ([colorName isEqualToString:@"pink"])
    {
        [rowController.btnPen setImage:[UIImage imageNamed:@"pen-icon-pink.png"] forState:UIControlStateNormal];
        [self.penBtn setImage:[UIImage imageNamed:@"pen-icon-pink.png"] forState:UIControlStateNormal];
        
        drawView.lineColor = [UIColor drawingColorPink];
        self.selectedColor=[UIColor pinkColor];
    }
    else if ([colorName isEqualToString:@"purple"])
    {
        [rowController.btnPen setImage:[UIImage imageNamed:@"pen-icon-purple.png"] forState:UIControlStateNormal];
        [self.penBtn setImage:[UIImage imageNamed:@"pen-icon-purple.png"] forState:UIControlStateNormal];
        
        drawView.lineColor = [UIColor drawingColorPurple];
        self.selectedColor=[UIColor purpleColor];
    }
    else if ([colorName isEqualToString:@"orange"])
    {
        [rowController.btnPen setImage:[UIImage imageNamed:@"pen-icon-orange.png"] forState:UIControlStateNormal];
        [self.penBtn setImage:[UIImage imageNamed:@"pen-icon-orange.png"] forState:UIControlStateNormal];
        
        drawView.lineColor = [UIColor drawingColorOrange];
        self.selectedColor=[UIColor orangeColor];
    }
    else if ([colorName isEqualToString:@"cyan"])
    {
        [rowController.btnPen setImage:[UIImage imageNamed:@"pen-icon-cyan.png"] forState:UIControlStateNormal];
        [self.penBtn setImage:[UIImage imageNamed:@"pen-icon-cyan.png"] forState:UIControlStateNormal];
        drawView.lineColor = [UIColor drawingColorCyan];
        self.selectedColor=[UIColor cyanColor];
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


#pragma mark- hide controllers 

-(void)hideControllers:(BOOL)_value {
    
    if(_value) {
        
        [self.circleLayer setHidden:YES];
        [self.btnCamera setHidden:YES];
        [self.btnFace setHidden:YES];
        [self.drawingController setHidden:NO];
        [self.circularLineImage setHidden:YES];
    }
    else {
        [self.circleLayer setHidden:NO];
        [self.btnCamera setHidden:NO];
        [self.btnFace setHidden:NO];
        [self.drawingController setHidden:YES];
    }
}

#pragma mark- Animating and showing black BG view

-(void)animatedBlackBGForR2Screen {
    
    if(!self.isShowBlackBG) {
        
        self.isShowBlackBG=YES;
        
        [self.view bringSubviewToFront:self.backGroundBlackView];
        [UIView animateWithDuration:0.5
                              delay:0.1
                            options: UIViewAnimationCurveEaseOut
                         animations:^
         {
             CGRect frame = self.backGroundBlackView.frame;
             frame.origin.y = 50;
             frame.origin.x = 0;
             self.backGroundBlackView.frame = frame;
         }
                         completion:^(BOOL finished)
         {
             NSLog(@"Completed");
             
         }];

    }
    else {
        
        self.isShowBlackBG=NO;
        [UIView animateWithDuration:0.5
                              delay:0.1
                            options: UIViewAnimationCurveEaseOut
                         animations:^
         {
             CGRect frame = self.backGroundBlackView.frame;
             frame.origin.y = -([UIScreen mainScreen].bounds.size.height);
             frame.origin.x = 0;
             self.backGroundBlackView.frame = frame;
         }
                         completion:^(BOOL finished)
         {
             NSLog(@"Completed");
             
         }];
    }
}

//- (UIImage *)imageFromLayer:(CALayer *)layer
//{
//    UIGraphicsBeginImageContextWithOptions(layer.frame.size, NO, 0);
//    
//    [layer renderInContext:UIGraphicsGetCurrentContext()];
//    UIImage *outputImage = UIGraphicsGetImageFromCurrentImageContext();
//    
//    UIGraphicsEndImageContext();
//    
//    return outputImage;
//}

- (UIImage *)removeRotationForImage:(UIImage*)image {
    if (image.imageOrientation == UIImageOrientationUp) return image;
    
    UIGraphicsBeginImageContextWithOptions(image.size, NO, image.scale);
    [image drawInRect:(CGRect){0, 0, image.size}];
    UIImage *normalizedImage =  UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return normalizedImage;
}

//UIImageOrientation mirroredImageOrientation(UIImageOrientation orientation) {
//    switch(orientation) {
//        case UIImageOrientationUp: return UIImageOrientationUpMirrored;
//        case UIImageOrientationDown: return UIImageOrientationDownMirrored;
//        case UIImageOrientationLeft: return UIImageOrientationLeftMirrored;
//        case UIImageOrientationRight: return UIImageOrientationRightMirrored;
//        case UIImageOrientationUpMirrored: return UIImageOrientationUp;
//        case UIImageOrientationDownMirrored: return UIImageOrientationDown;
//        case UIImageOrientationLeftMirrored: return UIImageOrientationLeft;
//        case UIImageOrientationRightMirrored: return UIImageOrientationRight;
//        default: return orientation;
//    }
//}
//
//-(CGRect)frameForImage:(UIImage*)image inImageViewAspectFit:(UIView*)imageView
//{
//    float imageRatio = image.size.width / image.size.height;
//    
//    float viewRatio = imageView.frame.size.width / imageView.frame.size.height;
//    
//    if(imageRatio < viewRatio)
//    {
//        float scale = imageView.frame.size.height / image.size.height;
//        
//        float width = scale * image.size.width;
//        
//        float topLeftX = (imageView.frame.size.width - width) * 0.5;
//        
//        return CGRectMake(topLeftX, 0, width, imageView.frame.size.height);
//    }
//    else
//    {
//        float scale = imageView.frame.size.width / image.size.width;
//        
//        float height = scale * image.size.height;
//        
//        float topLeftY = (imageView.frame.size.height - height) * 0.5;
//        
//        return CGRectMake(0, topLeftY, imageView.frame.size.width, height);
//    }
//}
- (IBAction)btnCameraReverseTap:(id)sender
{
    [UIView transitionWithView:cameraPreview
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
                                    isFrontCameraOn = NO;
                                    break;
                                case AVCaptureDevicePositionBack:
                                    preferredPosition = AVCaptureDevicePositionFront;
                                    isFrontCameraOn = YES;
                                    break;
                                case AVCaptureDevicePositionFront:
                                    preferredPosition = AVCaptureDevicePositionBack;
                                    isFrontCameraOn = NO;
                                    break;
                            }
                            
                            AVCaptureDevice *videoDevice = [CBSelfiRegistrationPageViewController deviceWithMediaTypeForPics:AVMediaTypeVideo preferringPosition:preferredPosition];
                            AVCaptureDeviceInput *videoDeviceInput = [AVCaptureDeviceInput deviceInputWithDevice:videoDevice error:nil];
                            
                            [[self session] beginConfiguration];
                            
                            [[self session] removeInput:[self videoDeviceInput]];
                            if ([[self session] canAddInput:videoDeviceInput])
                            {
                                [[NSNotificationCenter defaultCenter] removeObserver:self name:AVCaptureDeviceSubjectAreaDidChangeNotification object:currentVideoDevice];
                                
                                [CBSelfiRegistrationPageViewController setFlashMode:AVCaptureFlashModeAuto forDevice:videoDevice];
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
//
//- (IBAction)btnImagePickerTap:(id)sender
//{
//    UIImagePickerController * picker = [[UIImagePickerController alloc] init];
//    picker.delegate=self;
//    [picker setSourceType:(UIImagePickerControllerSourceTypePhotoLibrary)];
//    [self presentViewController:picker animated:YES completion:Nil];
//}
//
////- (IBAction)btnBackTap:(id)sender
////{
////    //[self dismissViewControllerAnimated:NO completion:nil];
////    if (self.isRegView)
////    {
////        [self.navigationController popViewControllerAnimated:YES];
////    }
////    else
////    {
////        [self.delegate cropStickerViewControllerWithCropCancel:nil];
////        
////        if (self.delegate == nil && btnCamera.isSelected) {
////            if (self.parentViewController != nil) {
////                [self btnCameraTap:nil];
////            }
////        }
////    }
////}
//
//- (IBAction)btnUndoTap:(id)sender
//{
//    if (mzCroppableView != nil)
//    {
//        [mzCroppableView removeFromSuperview];
//    }
//    
//    btnCrop.userInteractionEnabled = YES;
//    
//    [btnCrop setImage:[UIImage imageNamed:@"scissors-icon-white"] forState:UIControlStateNormal];
//    
//    btnUndo.enabled = NO;
//    btnDoneCroping.enabled = NO;
//    btnImagePicker.enabled = YES;
//}
//
- (IBAction)btnCropDoneTap:(id)sender
{
    if (mzCroppableView != nil && [[mzCroppableView.croppingPath points] count]  > 0)
    {
        mzCroppableView.camImageView = imgvCrop;
        
        // add this lines
        NSLog(@"==1");
        
        [AppHelper showHUDLoader:YES];
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            //Call your function or whatever work that needs to be done
            //Code in this part is run on a background thread
            dispatch_async(dispatch_get_main_queue(), ^(void) {
                //Stop your activity indicator or anything else with the GUI
                //Code here is run on the main thread
                
                //Not sure is correct logic.. But sorry no other option
                //                if (imgvCrop.image.size.width > 1080) {
                //                    //Just just rezie it
                //                    NSData* data = UIImageJPEGRepresentation(imgvCrop.image,0.2);
                //                    UIImage *compressedimage = [[UIImage alloc] initWithData:data];
                //                    imgvCrop.image = [UIImage ScaletoFill:compressedimage toSize:CGSizeMake(1080, 1440)];
                //                }
                
                UIImageView* temImageView = imgvCrop;
                temImageView.image = [UIImage fixrotation:temImageView.image];
                UIImage *cropedImageWithoutBorder = [[UIImage alloc] init];
                UIImage *cropedImageWithBorder = [mzCroppableView deleteBackgroundOfImageWithBorder:temImageView withOutBorderImage:&cropedImageWithoutBorder];
                UIImage *cropedImage  = [self imageWithShadowForImage:cropedImageWithBorder];
                cropedImage =  [cropedImage imageByTrimmingTransparentPixelsRequiringFullOpacity:NO trimTop:YES];
                cropedImageWithoutBorder = [cropedImageWithoutBorder imageByTrimmingTransparentPixelsRequiringFullOpacity:NO trimTop:YES];
                [AppHelper showHUDLoader:NO];
                
                if (cropedImageWithoutBorder)
                {
                    // save sticker here....
                    
                    UIImageView *imageView = [[UIImageView alloc] init];
                    
                    if (IS_IPHONE_5)
                    {
                        imageView.frame = CGRectMake(0, 0, 320, 320);
                    }
                    else if (IS_IPHONE_6)
                    {
                        imageView.frame = CGRectMake(0, 0, 375, 375);
                    }
                    else if (IS_IPHONE_6P)
                    {
                        imageView.frame = CGRectMake(0, 0, 414, 414);
                    }
                    else
                    {
                        imageView.frame = CGRectMake(0, 0, 320, 320);
                    }
                    
                    imageView.image = cropedImageWithoutBorder;
                    
                    imageView.contentMode = UIViewContentModeScaleAspectFill;
                    
                    //                    float widthRatio = imageView.bounds.size.width / imageView.image.size.width;
                    //                    float heightRatio = imageView.bounds.size.height / imageView.image.size.height;
                    //                    float scale = MIN(widthRatio, heightRatio);
                    //                    float imageWidth = scale * imageView.image.size.width;
                    //                    float imageHeight = scale * imageView.image.size.height;
                    
                    //                    imageView.frame = CGRectMake(0, 0, imageWidth, imageHeight);
                    imageView.center = self.view.center;
                    NSLog(@"==19");
                    
                    if (self.delegate == nil)
                    {
                        if (self.parentViewController != nil)
                        {
                            
                          // //  [self.parentViewController cropStickerViewController_:nil didSelectDoneWithImage:imageView];
                        }
                    }
                    else
                    {
                      // //  [self.delegate cropStickerViewController:nil didSelectDoneWithImage:imageView withBorderImage:cropedImage];
                    }
                    NSLog(@"==20");
                    NSLog(@"btnCropDoneTap END");
                }
            });
        });
    }
    else if(self.isRegView)
    {
        UIImage* reSizeImage = [UIImage ScaletoFill:imgvCrop.image toSize:CGSizeMake(112, 112)];
        UIImage* imgRounded = [UIImage makeRoundedImage:reSizeImage radius:112/2];
        UIImageView *imageView = [[UIImageView alloc] init];
        imageView.frame = CGRectMake(0, 0, 112, 112);
        
        imageView.image = imgRounded;
        
        imageView.contentMode = UIViewContentModeScaleAspectFit;
        
        if (self.delegate == nil) {
            if (self.parentViewController != nil) {
               // // [self.parentViewController cropStickerViewController_:nil didSelectDoneWithImage:imageView];
            }
        }
    }
}

//#pragma mark - Helper Methods
//
//- (UIImage*)imageWithShadow:(UIImage*)originalImage BlurSize:(float)blurSize {
//    
//    CGColorSpaceRef colourSpace = CGColorSpaceCreateDeviceRGB();
//    CGContextRef shadowContext = CGBitmapContextCreate(NULL, originalImage.size.width + (blurSize*2), originalImage.size.height + (blurSize*2), CGImageGetBitsPerComponent(originalImage.CGImage), 0, colourSpace, kCGImageAlphaPremultipliedLast);
//    CGColorSpaceRelease(colourSpace);
//    
//    CGContextSetShadowWithColor(shadowContext, CGSizeMake(0, 0), blurSize, [UIColor blackColor].CGColor);
//    CGContextDrawImage(shadowContext, CGRectMake(blurSize, blurSize, originalImage.size.width, originalImage.size.height), originalImage.CGImage);
//    
//    CGImageRef shadowedCGImage = CGBitmapContextCreateImage(shadowContext);
//    CGContextRelease(shadowContext);
//    
//    UIImage * shadowedImage = [UIImage imageWithCGImage:shadowedCGImage];
//    CGImageRelease(shadowedCGImage);
//    
//    return shadowedImage;
//}
//
-(UIImage*)imageWithShadowForImage:(UIImage *)initialImage {
    
    CGFloat blur;
    
    if (IS_IPHONE_5)
    {
        blur = 50;
    }
    else if (IS_IPHONE_6)
    {
        blur = 60;
    }
    else if (IS_IPHONE_6P)
    {
        blur = 80;
    }
    else
    {
        blur = 50;
    }
    
    blur = 10;
    
    CGColorSpaceRef colourSpace = CGColorSpaceCreateDeviceRGB();
    CGContextRef shadowContext = CGBitmapContextCreate(NULL, initialImage.size.width + 10, initialImage.size.height + 10, CGImageGetBitsPerComponent(initialImage.CGImage), 0, colourSpace, kCGImageAlphaPremultipliedLast);
    CGColorSpaceRelease(colourSpace);
    
    CGContextSetShadowWithColor(shadowContext, CGSizeMake(0,0), blur, [UIColor blackColor].CGColor);
    CGContextDrawImage(shadowContext, CGRectMake(0, 0, initialImage.size.width, initialImage.size.height), initialImage.CGImage);
    
    CGImageRef shadowedCGImage = CGBitmapContextCreateImage(shadowContext);
    CGContextRelease(shadowContext);
    
    UIImage * shadowedImage = [UIImage imageWithCGImage:shadowedCGImage];
    CGImageRelease(shadowedCGImage);
    return shadowedImage;
}


- (UIImage *)makeIconStroke:(UIImage *)image
{
    CGImageRef originalImage = [image CGImage];
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    CGContextRef bitmapContext = CGBitmapContextCreate(NULL,
                                                       CGImageGetWidth(originalImage),
                                                       CGImageGetHeight(originalImage),
                                                       8,
                                                       CGImageGetWidth(originalImage)*4,
                                                       colorSpace,
                                                       kCGImageAlphaPremultipliedLast);
    
    CGContextDrawImage(bitmapContext, CGRectMake(0, 0, CGBitmapContextGetWidth(bitmapContext), CGBitmapContextGetHeight(bitmapContext)), originalImage);
    
    CGImageRef finalMaskImage = [self createMaskWithImageAlpha:bitmapContext];
    
    UIImage *result = [UIImage imageWithCGImage:finalMaskImage];
    
    CGContextRelease(bitmapContext);
    CGImageRelease(finalMaskImage);
    
    // begin a new image context, to draw our colored image onto
    UIGraphicsBeginImageContext(result.size);
    
    // get a reference to that context we created
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    // set the fill color
    [[UIColor whiteColor] setFill];
    
    // translate/flip the graphics context (for transforming from CG* coords to UI* coords
    CGContextTranslateCTM(context, 0, result.size.height);
    CGContextScaleCTM(context, 1.0, -1.0);
    
    // set the blend mode to color burn, and the original image
    CGContextSetBlendMode(context, kCGBlendModeColorBurn);
    CGRect rect = CGRectMake(0, 0, result.size.width, result.size.height);
    CGContextDrawImage(context, rect, result.CGImage);
    
    // set a mask that matches the shape of the image, then draw (color burn) a colored rectangle
    CGContextClipToMask(context, rect, result.CGImage);
    CGContextAddRect(context, rect);
    CGContextDrawPath(context,kCGPathFill);
    
    // generate a new UIImage from the graphics context we drew onto
    UIImage *coloredImg = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    //return the color-burned image
    return coloredImg;
    
}

- (CGImageRef)createMaskWithImageAlpha:(CGContextRef)originalImageContext {
    
    UInt8 *data = (UInt8 *)CGBitmapContextGetData(originalImageContext);
    
    float width = CGBitmapContextGetBytesPerRow(originalImageContext) / 4;
    float height = CGBitmapContextGetHeight(originalImageContext);
    
    int strideLength = ceil(width * 1);
    unsigned char * alphaData = (unsigned char * )calloc(strideLength * height, 1);
    CGContextRef alphaOnlyContext = CGBitmapContextCreate(alphaData,
                                                          width,
                                                          height,
                                                          8,
                                                          strideLength,
                                                          NULL,
                                                          kCGImageAlphaOnly);
    
    for (int y = 0; y < height; y++) {
        for (int x = 0; x < width; x++) {
            unsigned char val = data[y*(int)width*4 + x*4 + 3];
            val = 255 - val;
            alphaData[y*strideLength + x] = val;
        }
    }
    
    CGImageRef alphaMaskImage = CGBitmapContextCreateImage(alphaOnlyContext);
    CGContextRelease(alphaOnlyContext);
    free(alphaData);
    
    // Make a mask
    CGImageRef finalMaskImage = CGImageMaskCreate(CGImageGetWidth(alphaMaskImage),
                                                  CGImageGetHeight(alphaMaskImage),
                                                  CGImageGetBitsPerComponent(alphaMaskImage),
                                                  CGImageGetBitsPerPixel(alphaMaskImage),
                                                  CGImageGetBytesPerRow(alphaMaskImage),
                                                  CGImageGetDataProvider(alphaMaskImage),     NULL, false);
    CGImageRelease(alphaMaskImage);
    
    return finalMaskImage;
}

//- (UIImage*) maskImage:(UIImage *)image withMask:(UIImage *)maskImage {
//    
//    CGImageRef maskRef = maskImage.CGImage;
//    
//    CGImageRef mask = CGImageMaskCreate(CGImageGetWidth(maskRef),
//                                        CGImageGetHeight(maskRef),
//                                        CGImageGetBitsPerComponent(maskRef),
//                                        CGImageGetBitsPerPixel(maskRef),
//                                        CGImageGetBytesPerRow(maskRef),
//                                        CGImageGetDataProvider(maskRef), NULL, false);
//    
//    CGImageRef maskedImageRef = CGImageCreateWithMask([image CGImage], mask);
//    UIImage *maskedImage = [UIImage imageWithCGImage:maskedImageRef];
//    
//    CGImageRelease(mask);
//    CGImageRelease(maskedImageRef);
//    
//    // returns new image with mask applied
//    return maskedImage;
//}
//
//- (UIImage*)mergeImage:(UIImage*)first withImage:(UIImage*)second
//{
//    // get size of the second image
//    CGImageRef secondImageRef = second.CGImage;
//    CGFloat secondWidth = CGImageGetWidth(secondImageRef);
//    CGFloat secondHeight = CGImageGetHeight(secondImageRef);
//    
//    float offsetwt,offsetht,offset;
//    
//    offset=20;
//    if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)
//    {
//        offset=offset/2;
//    }
//    offsetht=(secondHeight   * (secondWidth+offset)) /secondWidth;
//    offsetwt=secondWidth+offset;
//    
//    // build merged size
//    CGSize mergedSize = CGSizeMake(offsetwt,offsetht);
//    
//    // capture image context ref
//    UIGraphicsBeginImageContext(mergedSize);
//    
//    //Draw images onto the context
//    [first drawInRect:CGRectMake(0, 0, offsetwt, offsetht)];
//    [second drawInRect:CGRectMake(offset/2, offset/2, secondWidth, secondHeight) blendMode:kCGBlendModeNormal alpha:1.0];
//    
//    // assign context to new UIImage
//    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
//    
//    // end context
//    UIGraphicsEndImageContext();
//    
//    return  newImage;
//}
//
//- (void)bringToFrontAllButtons
//{
//    [self.view bringSubviewToFront:btnDoneCroping];
//    [self.view bringSubviewToFront:btnCamera];
//    [self.view bringSubviewToFront:btnBack];
//    [self.view bringSubviewToFront:btnCrop];
//    [self.view bringSubviewToFront:btnDoneCroping];
//    [self.view bringSubviewToFront:btnImagePicker];
//    [self.view bringSubviewToFront:btnUndo];
//}
//
//- (UIImage*)imageWithImage: (UIImage*) sourceImage scaledToWidth: (float) i_width
//{
//    float oldWidth = sourceImage.size.width;
//    float scaleFactor = i_width / oldWidth;
//    
//    float newHeight = sourceImage.size.height * scaleFactor;
//    float newWidth = oldWidth * scaleFactor;
//    
//    UIGraphicsBeginImageContext(CGSizeMake(newWidth, newHeight));
//    [sourceImage drawInRect:CGRectMake(0, 0, newWidth, newHeight)];
//    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
//    UIGraphicsEndImageContext();
//    return newImage;
//}
//
//- (UIImage *)compressImage:(UIImage *)image
//{
//    float actualHeight = image.size.height;
//    float actualWidth = image.size.width;
//    
//    float maxHeight = 1136; //new max. height for image
//    float maxWidth = 640; //new max. width for image
//    
//    
//    float imgRatio = actualWidth/actualHeight;
//    float maxRatio = maxWidth/maxHeight;
//    float compressionQuality = 1; //50 percent compression
//    
//    if (actualHeight > maxHeight || actualWidth > maxWidth){
//        if(imgRatio < maxRatio){
//            //adjust width according to maxHeight
//            imgRatio = maxHeight / actualHeight;
//            actualWidth = imgRatio * actualWidth;
//            actualHeight = maxHeight;
//        }
//        else if(imgRatio > maxRatio){
//            //adjust height according to maxWidth
//            imgRatio = maxWidth / actualWidth;
//            actualHeight = imgRatio * actualHeight;
//            actualWidth = maxWidth;
//        }
//        else{
//            actualHeight = maxHeight;
//            actualWidth = maxWidth;
//        }
//    }
//    
//    
//    NSLog(@"Actual height : %f and Width : %f",actualHeight,actualWidth);
//    CGRect rect = CGRectMake(0.0, 0.0, actualWidth, actualHeight);
//    UIGraphicsBeginImageContext(rect.size);
//    [image drawInRect:rect];
//    UIImage *img = UIGraphicsGetImageFromCurrentImageContext();
//    NSData *imageData = UIImageJPEGRepresentation(img, compressionQuality);
//    UIGraphicsEndImageContext();
//    
//    return [UIImage imageWithData:imageData];
//}
//-(UIImage*)rotateUIImage:(UIImage*)src {
//    
//    // No-op if the orientation is already correct
//    if (src.imageOrientation == UIImageOrientationUp) return src ;
//    
//    // We need to calculate the proper transformation to make the image upright.
//    // We do it in 2 steps: Rotate if Left/Right/Down, and then flip if Mirrored.
//    CGAffineTransform transform = CGAffineTransformIdentity;
//    
//    switch (src.imageOrientation) {
//        case UIImageOrientationDown:
//        case UIImageOrientationDownMirrored:
//            transform = CGAffineTransformTranslate(transform, src.size.width, src.size.height);
//            transform = CGAffineTransformRotate(transform, M_PI);
//            break;
//            
//        case UIImageOrientationLeft:
//        case UIImageOrientationLeftMirrored:
//            transform = CGAffineTransformTranslate(transform, src.size.width, 0);
//            transform = CGAffineTransformRotate(transform, M_PI_2);
//            break;
//            
//        case UIImageOrientationRight:
//        case UIImageOrientationRightMirrored:
//            transform = CGAffineTransformTranslate(transform, 0, src.size.height);
//            transform = CGAffineTransformRotate(transform, -M_PI_2);
//            break;
//        case UIImageOrientationUp:
//        case UIImageOrientationUpMirrored:
//            break;
//    }
//    
//    switch (src.imageOrientation) {
//        case UIImageOrientationUpMirrored:
//        case UIImageOrientationDownMirrored:
//            transform = CGAffineTransformTranslate(transform, src.size.width, 0);
//            transform = CGAffineTransformScale(transform, -1, 1);
//            break;
//            
//        case UIImageOrientationLeftMirrored:
//        case UIImageOrientationRightMirrored:
//            transform = CGAffineTransformTranslate(transform, src.size.height, 0);
//            transform = CGAffineTransformScale(transform, -1, 1);
//            break;
//        case UIImageOrientationUp:
//        case UIImageOrientationDown:
//        case UIImageOrientationLeft:
//        case UIImageOrientationRight:
//            break;
//    }
//    
//    // Now we draw the underlying CGImage into a new context, applying the transform
//    // calculated above.
//    CGContextRef ctx = CGBitmapContextCreate(NULL, src.size.width, src.size.height,
//                                             CGImageGetBitsPerComponent(src.CGImage), 0,
//                                             CGImageGetColorSpace(src.CGImage),
//                                             CGImageGetBitmapInfo(src.CGImage));
//    CGContextConcatCTM(ctx, transform);
//    switch (src.imageOrientation) {
//        case UIImageOrientationLeft:
//        case UIImageOrientationLeftMirrored:
//        case UIImageOrientationRight:
//        case UIImageOrientationRightMirrored:
//            // Grr...
//            CGContextDrawImage(ctx, CGRectMake(0,0,src.size.height,src.size.width), src.CGImage);
//            break;
//            
//        default:
//            CGContextDrawImage(ctx, CGRectMake(0,0,src.size.width,src.size.height), src.CGImage);
//            break;
//    }
//    
//    // And now we just create a new UIImage from the drawing context
//    CGImageRef cgimg = CGBitmapContextCreateImage(ctx);
//    UIImage *img = [UIImage imageWithCGImage:cgimg];
//    CGContextRelease(ctx);
//    CGImageRelease(cgimg);
//    return img;
//}
//
//#pragma mark - InstructionViewDelegate Methods
//- (void)didCloseInstructionViewWith:(InstructionView *)view withClosedSlideNumber:(SlideNumber)number
//{
//    [view removeFromSuperview];
//    
//    if (number == SlideNumber6)
//    {
//        // open slide 7 Instruction
//        dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC));
//        dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
//            NSLog(@"Do some work");
//            
//            if ([InstructionView getBoolValueForSlide:kInstructionSlide7] == NO)
//            {
//                InstructionView *instView = [[InstructionView alloc] initWithFrame:self.view.bounds];
//                instView.delegate = self;
//                [instView showInstructionWithSlideNumber:SlideNumber7 withType:InstructionGIFType];
//                [instView setTrueForSlide:kInstructionSlide7];
//                
//                [self.view addSubview:instView];
//            }
//        });
//        
//    }
//}
//
//#pragma mark - MZCroppableView Methods
//-(void)didFinishedTouch
//{
//    if (_isRegView == NO)
//    {
//        // open slide 8 Instruction
//        dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0 * NSEC_PER_SEC));
//        dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
//            NSLog(@"Do some work");
//            
//            if ([InstructionView getBoolValueForSlide:kInstructionSlide8] == NO)
//            {
//                InstructionView *instView = [[InstructionView alloc] initWithFrame:self.view.bounds];
//                instView.delegate = self;
//                [instView showInstructionWithSlideNumber:SlideNumber8 withType:InstructionBubbleType];
//                [instView setTrueForSlide:kInstructionSlide8];
//                
//                [self.view addSubview:instView];
//            }
//        });
//        
//    }
//}
//




- (void) updateDrawingBoard {
    
        UIGraphicsBeginImageContext(self.croppedImageShown.bounds.size);
        [self.croppedImageShown.layer renderInContext:UIGraphicsGetCurrentContext()];
        
        UIBezierPath *nPath=[self.pathDrawArray objectAtIndex:[self.pathDrawArray count]-1];
        
        if(self.selectedColor) {
            
            [self.selectedColor setStroke];
            [self.selectedColor setFill];
        }
        else
            [[UIColor blackColor] setStroke];
        
        [nPath stroke];
        
        if([paths count]) {
            
            for (int i=0;i<[paths count];i++ ) {
                
                UIBezierPath * bezierPath=[paths objectAtIndex:i];
                
                if([pathColorArray count]>i) {
                    
                    UIColor *pathColor=[pathColorArray objectAtIndex:i];
                    [pathColor setStroke];
                    [bezierPath stroke];
                }
            }
        }
    
        
        UIImage *croppedImg = UIGraphicsGetImageFromCurrentImageContext();
        self.croppedImageShown.image=croppedImg;
        UIGraphicsEndImageContext();
    
    
}


- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    
    CGPoint locationPoint = [[touches anyObject] locationInView:self.croppedView];
    UIView* viewNeedToDraw = [self.croppedView hitTest:locationPoint withEvent:event];
    
    if(viewNeedToDraw== self.lineDrawView) {
        
        self.drawLinePath = [UIBezierPath bezierPath] ;
        self.drawLinePath.lineCapStyle = kCGLineCapRound;
        self.drawLinePath.lineWidth = 2;
        [self.pathDrawArray addObject:self.drawLinePath];
        [self.lineDrawView setBackgroundColor:[UIColor clearColor]];
        
        UITouch *mytouch=[[touches allObjects] objectAtIndex:0];
        [self.drawLinePath moveToPoint:[mytouch locationInView:self.lineDrawView]];
        [self updateDrawingBoard];
        
        
        
        if (allPointsForRedFace == nil)
        {
            allPointsForRedFace = [[NSMutableArray alloc]init];
        }
        [allPointsForRedFace addObject:[NSValue valueWithCGPoint:[mytouch locationInView:self.lineDrawView]]];
    }
    else {
        
        [super touchesBegan:touches withEvent:event];
    }
}
- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
    
    CGPoint locationPoint = [[touches anyObject] locationInView:self.croppedView];
    UIView* viewNeedToDraw = [self.croppedView hitTest:locationPoint withEvent:event];

    if(viewNeedToDraw== self.lineDrawView) {
        
        UITouch *mytouch=[[touches allObjects] objectAtIndex:0];
    
        CGPoint touchLocation = [mytouch locationInView:self.lineDrawView];
    
    // move the image view
        self.drawLinePath=[self.pathDrawArray objectAtIndex:[self.pathDrawArray count]-1];
        [self.drawLinePath addLineToPoint:touchLocation];
        [paths addObject:self.drawLinePath];
        [allPointsForRedFace addObject:[NSValue valueWithCGPoint:[mytouch locationInView:self.lineDrawView]]];
        [pathColorArray addObject:self.selectedColor];
        [self updateDrawingBoard];
        
    }
    
    
}
- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    
//    CGPoint locationPoint = [[touches anyObject] locationInView:self.croppedView];
//    UIView* viewNeedToDraw = [self.croppedView hitTest:locationPoint withEvent:event];
    
}
















    



//-(void)drawLineFrom:(CGPoint)from endPoint:(CGPoint)to
//{
//    
//    UIGraphicsBeginImageContext(drawImage.frame.size);
//    [drawImage.image drawInRect:CGRectMake(0, 0, drawImage.frame.size.width, drawImage.frame.size.height)];
//    [[UIColor greenColor] set];
//    CGContextSetLineWidth(UIGraphicsGetCurrentContext(), 5.0f);
//    CGContextMoveToPoint(UIGraphicsGetCurrentContext(), from.x, from.y);
//    CGContextAddLineToPoint(UIGraphicsGetCurrentContext(), to.x , to.y);
//    
//    CGContextStrokePath(UIGraphicsGetCurrentContext());
//    
//    drawImage.image = UIGraphicsGetImageFromCurrentImageContext();
//    UIGraphicsEndImageContext();
//}


@end
