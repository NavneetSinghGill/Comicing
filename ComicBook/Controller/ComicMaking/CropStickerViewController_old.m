//
//  CropStickerViewController.m
//  CommicMakingPage
//
//  Created by ADNAN THATHIYA on 06/12/15.
//  Copyright (c) 2015 jistin. All rights reserved.
//

#import "CropStickerViewController.h"
#import "MZCroppableView.h"
#import "AVCamPreviewView.h"
#import <AVFoundation/AVFoundation.h>
#import <CoreAudio/CoreAudioTypes.h>
#import <QuartzCore/QuartzCore.h>
#import <AVFoundation/AVFoundation.h>
#import <AssetsLibrary/AssetsLibrary.h>
#import "UIImage+Image.h"
#import "CropRegisterViewController.h"

#define IS_IPHONE (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)
#define SCREEN_WIDTH ([[UIScreen mainScreen] bounds].size.width)
#define SCREEN_HEIGHT ([[UIScreen mainScreen] bounds].size.height)
#define SCREEN_MAX_LENGTH (MAX(SCREEN_WIDTH, SCREEN_HEIGHT))
#define SCREEN_MIN_LENGTH (MIN(SCREEN_WIDTH, SCREEN_HEIGHT))
#define IS_IPHONE_5 (IS_IPHONE && SCREEN_MAX_LENGTH == 568.0)
#define IS_IPHONE_6 (IS_IPHONE && SCREEN_MAX_LENGTH == 667.0)
#define IS_IPHONE_6P (IS_IPHONE && SCREEN_MAX_LENGTH == 736.0)

//NSString *const SKeySticker = @"Sticker";

#define IS_IOS8     ([[UIDevice currentDevice].systemVersion compare:@"8.0" options:NSNumericSearch] != NSOrderedAscending)

static void * CapturingStillImageContext = &CapturingStillImageContext;
static void * RecordingContext = &RecordingContext;
static void * SessionRunningAndDeviceAuthorizedContext = &SessionRunningAndDeviceAuthorizedContext;


@interface CropStickerViewController ()
<UIImagePickerControllerDelegate,
UINavigationControllerDelegate>

@property (weak, nonatomic) IBOutlet UIButton *btnCrop;
@property (weak, nonatomic) IBOutlet UIImageView *imgvCrop;
@property (weak, nonatomic) IBOutlet UIView *viewCrop;

@property (weak, nonatomic) IBOutlet AVCamPreviewView *cameraPreview;
@property (weak, nonatomic) IBOutlet UIButton *btnUndo;
@property (weak, nonatomic) IBOutlet UIButton *btnCamera;
@property (weak, nonatomic) IBOutlet UIButton *btnBack;
@property (weak, nonatomic) IBOutlet UIButton *btnImagePicker;
@property (weak, nonatomic) IBOutlet UIButton *btnDoneCroping;
@property (weak, nonatomic) IBOutlet UIButton *btnCameraReverse;

@property (strong, nonatomic) MZCroppableView *mzCroppableView;

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

@property CGPoint imgvCropCenter;

@property (nonatomic) BOOL isTakePicture;

@end

@implementation CropStickerViewController

@synthesize imgvCrop,btnCrop,mzCroppableView,cameraPreview,deviceAuthorized,sessionQueue,viewCrop,imgvCropCenter;

@synthesize btnBack,btnCamera,btnDoneCroping,btnImagePicker,btnUndo,btnCameraReverse, isTakePicture;

#pragma mark - UIViewController Methods
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self preparView];
}

-(void)viewWillAppear:(BOOL)animated
{
    dispatch_async([self sessionQueue], ^
                   {
                       [self addObserver:self forKeyPath:@"sessionRunningAndDeviceAuthorized" options:(NSKeyValueObservingOptionOld | NSKeyValueObservingOptionNew) context:SessionRunningAndDeviceAuthorizedContext];
                       [self addObserver:self forKeyPath:@"stillImageOutput.capturingStillImage" options:(NSKeyValueObservingOptionOld | NSKeyValueObservingOptionNew) context:CapturingStillImageContext];
                       [self addObserver:self forKeyPath:@"movieFileOutput.recording" options:(NSKeyValueObservingOptionOld | NSKeyValueObservingOptionNew) context:RecordingContext];
                       [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(subjectAreaDidChange:) name:AVCaptureDeviceSubjectAreaDidChangeNotification object:[[self videoDeviceInput] device]];
                       
                       __weak CropStickerViewController *weakSelf = self;
                       
                       [self setRuntimeErrorHandlingObserver:[[NSNotificationCenter defaultCenter] addObserverForName:AVCaptureSessionRuntimeErrorNotification object:[self session] queue:nil usingBlock:^(NSNotification *note) {
                           CropStickerViewController *strongSelf = weakSelf;
                           dispatch_async([strongSelf sessionQueue], ^{
                               // Manually restarting the session since it must have been stopped due to an error.
                               [[strongSelf session] startRunning];
                           });
                           
                       }]];
                       
                       [[self session] startRunning];
                   });
    
}

- (void)viewDidDisappear:(BOOL)animated
{
    dispatch_async([self sessionQueue], ^{
        [[self session] stopRunning];
        
        [[NSNotificationCenter defaultCenter] removeObserver:self name:AVCaptureDeviceSubjectAreaDidChangeNotification object:[[self videoDeviceInput] device]];
        [[NSNotificationCenter defaultCenter] removeObserver:[self runtimeErrorHandlingObserver]];
        
        [self removeObserver:self forKeyPath:@"sessionRunningAndDeviceAuthorized" context:SessionRunningAndDeviceAuthorizedContext];
        [self removeObserver:self forKeyPath:@"stillImageOutput.capturingStillImage" context:CapturingStillImageContext];
        [self removeObserver:self forKeyPath:@"movieFileOutput.recording" context:RecordingContext];
    });
}

#pragma mark - Config screens
-(void)configScreens
{
    [self.imgCropBackground setHidden:YES];
}

#pragma mark - UIView Methods
- (void)preparView
{
    imgvCropCenter = imgvCrop.center;
    
    btnUndo.enabled = NO;
    btnCrop.enabled = NO;
    btnDoneCroping.enabled = NO;
    
    cameraPreview.transform = CGAffineTransformScale(CGAffineTransformIdentity, 1.18, 1.0);
    
    [self prepareCameraView];
}

- (void)prepareCameraView
{
    // Create the AVCaptureSession
    AVCaptureSession *session = [[AVCaptureSession alloc] init];
    [self setSession:session];
    
    // Setup the preview view
    [cameraPreview setSession:session];
    
    // Check for device authorization
    [self checkDeviceAuthorizationStatus];
    
    dispatch_queue_t sessionQueue1 = dispatch_queue_create("session queue", DISPATCH_QUEUE_SERIAL);
    [self setSessionQueue:sessionQueue1];
    
   // [session setSessionPreset:AVCaptureSessionPresetMedium];
    
    dispatch_async(sessionQueue1, ^{
        [self setBackgroundRecordingID:UIBackgroundTaskInvalid];
        
        NSError *error = nil;
        
        AVCaptureDevice *videoDevice = [CropStickerViewController deviceWithMediaType:AVMediaTypeVideo preferringPosition:AVCaptureDevicePositionBack];
        
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
                
                [[(AVCaptureVideoPreviewLayer *)[cameraPreview layer] connection] setVideoOrientation:(AVCaptureVideoOrientation)[self interfaceOrientation]];
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
        
        AVCaptureMovieFileOutput *movieFileOutput = [[AVCaptureMovieFileOutput alloc] init];
        
        if ([session canAddOutput:movieFileOutput])
        {
            [session addOutput:movieFileOutput];
            
            AVCaptureConnection *connection = [movieFileOutput connectionWithMediaType:AVMediaTypeVideo];
            if ([connection isVideoStabilizationSupported])
                [connection setEnablesVideoStabilizationWhenAvailable:YES];
            
            [self setMovieFileOutput:movieFileOutput];
        }
        
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
    [[(AVCaptureVideoPreviewLayer *)[cameraPreview layer] connection] setVideoOrientation:(AVCaptureVideoOrientation)toInterfaceOrientation];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
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
- (void)runStillImageCaptureAnimation
{
    dispatch_async(dispatch_get_main_queue(), ^
                   {
                       [[cameraPreview layer] setOpacity:0.0];
                       
                       [UIView animateWithDuration:.25 animations:^{
                           [[cameraPreview layer] setOpacity:1.0];
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


#pragma mark - UIImagePickerControllerDelegate Method
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    [self dismissViewControllerAnimated:YES completion:^
     {
         UIImage *selectedImage = info[UIImagePickerControllerOriginalImage];
         
       //  CGFloat width = selectedImage.size.width / 3;
       //  CGFloat height = selectedImage.size.height / 3;
         
       //  UIImage *compressImage = [selectedImage compressWithMaxSize:CGSizeMake(width, height) andQuality:1];
         
         imgvCrop.image =  [self compressImage:selectedImage];
         
         imgvCrop.layer.shouldRasterize = YES;
         imgvCrop.layer.rasterizationScale = 2;
         
         cameraPreview.hidden = YES;
         btnCrop.enabled = YES;
         btnCameraReverse.hidden = YES;
         btnCamera.selected = YES;
         
         [self setImageViewSize];
     }];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)setImageViewSize
{
    float widthRatio = self.imgvCrop.bounds.size.width / self.imgvCrop.image.size.width;
    float heightRatio = self.imgvCrop.bounds.size.height / self.imgvCrop.image.size.height;
    float scale = MIN(widthRatio, heightRatio);
    float imageWidth = scale * self.imgvCrop.image.size.width;
    float imageHeight = scale * self.imgvCrop.image.size.height;
    
    self.imgvCrop.frame = CGRectMake(0, 0, imageWidth, imageHeight);
    self.imgvCrop.center = imgvCropCenter;
}

#pragma mark - Events Methods
- (IBAction)btnCropTap:(id)sender
{
    imgvCrop.hidden = NO;
    btnUndo.enabled = YES;
    btnDoneCroping.enabled = YES;
    btnCrop.userInteractionEnabled = YES;
    
    [btnCrop setImage:[UIImage imageNamed:@"scissors-icon-gray"] forState:UIControlStateNormal];
    
    CGRect rect1 = CGRectMake(0, 0, imgvCrop.image.size.width, imgvCrop.image.size.height);
    
    CGRect rect2 = imgvCrop.frame;
    
    [[NSUserDefaults standardUserDefaults]setObject:@"yes" forKey:@"tappEnder"];
    [[NSUserDefaults standardUserDefaults]synchronize];
    
    [imgvCrop setFrame:[MZCroppableView scaleRespectAspectFromRect1:rect1 toRect2:rect2 ]];


    [mzCroppableView removeFromSuperview];
    mzCroppableView = [[MZCroppableView alloc] initWithImageView:imgvCrop];

    [self.view addSubview:mzCroppableView];
    
    [self bringToFrontAllButtons];
}

- (IBAction)btnCameraTap:(id)sender
{
    if (btnCamera.isSelected)
    {
        btnCamera.selected = NO;
        
        imgvCrop.image = nil;
        cameraPreview.hidden = NO;
        btnCameraReverse.hidden = NO;
        
        [mzCroppableView removeFromSuperview];
        
        btnUndo.enabled = NO;
        btnCrop.enabled = NO;
        btnDoneCroping.enabled = NO;
    }
    else
    {
        btnCamera.selected = YES;
        
        dispatch_async([self sessionQueue], ^{
            // Update the orientation on the still image output video connection before capturing.
            [[[self stillImageOutput] connectionWithMediaType:AVMediaTypeVideo] setVideoOrientation:[[(AVCaptureVideoPreviewLayer *)[cameraPreview layer] connection] videoOrientation]];
            
            // Flash set to Auto for Still Capture
            [CropStickerViewController setFlashMode:AVCaptureFlashModeAuto forDevice:[[self videoDeviceInput] device]];
            
            // Capture a still image.
            [[self stillImageOutput] captureStillImageAsynchronouslyFromConnection:[[self stillImageOutput] connectionWithMediaType:AVMediaTypeVideo] completionHandler:^(CMSampleBufferRef imageDataSampleBuffer, NSError *error) {
                
                if (imageDataSampleBuffer)
                {
                    cameraPreview.hidden = YES;
                    btnCrop.enabled = YES;
                    btnCameraReverse.hidden = YES;
                    
                    NSData *imageData = [AVCaptureStillImageOutput jpegStillImageNSDataRepresentation:imageDataSampleBuffer];
                   
                    UIImage *image = [[UIImage alloc] initWithData:imageData];
                    
                    imgvCrop.image = [self compressImage:image];
                 
                }
            }];
            
        });
    }
}

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
                                    break;
                                case AVCaptureDevicePositionBack:
                                    preferredPosition = AVCaptureDevicePositionFront;
                                    break;
                                case AVCaptureDevicePositionFront:
                                    preferredPosition = AVCaptureDevicePositionBack;
                                    break;
                            }
                            
                            AVCaptureDevice *videoDevice = [CropStickerViewController deviceWithMediaType:AVMediaTypeVideo preferringPosition:preferredPosition];
                            AVCaptureDeviceInput *videoDeviceInput = [AVCaptureDeviceInput deviceInputWithDevice:videoDevice error:nil];
                            
                            [[self session] beginConfiguration];
                            
                            [[self session] removeInput:[self videoDeviceInput]];
                            if ([[self session] canAddInput:videoDeviceInput])
                            {
                                [[NSNotificationCenter defaultCenter] removeObserver:self name:AVCaptureDeviceSubjectAreaDidChangeNotification object:currentVideoDevice];
                                
                                [CropStickerViewController setFlashMode:AVCaptureFlashModeAuto forDevice:videoDevice];
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

- (IBAction)btnImagePickerTap:(id)sender
{
    UIImagePickerController * picker = [[UIImagePickerController alloc] init];
    picker.delegate=self;
    [picker setSourceType:(UIImagePickerControllerSourceTypePhotoLibrary)];
    [self presentViewController:picker animated:YES completion:Nil];
}

- (IBAction)btnBackTap:(id)sender
{
    //[self dismissViewControllerAnimated:NO completion:nil];
    
    [self.delegate cropStickerViewControllerWithCropCancel:nil];
}

- (IBAction)btnUndoTap:(id)sender
{
    if (mzCroppableView != nil)
    {
        [mzCroppableView removeFromSuperview];
    }
    
    btnCrop.userInteractionEnabled = YES;
    
    [btnCrop setImage:[UIImage imageNamed:@"scissors-icon-white"] forState:UIControlStateNormal];
    
    btnUndo.enabled = NO;
    btnDoneCroping.enabled = NO;
}

- (IBAction)btnCropDoneTap:(id)sender
{
   // btnCrop.userInteractionEnabled = YES;
    
  //  [btnCrop setImage:[UIImage imageNamed:@"scissors-icon-white"] forState:UIControlStateNormal];
    
    if (mzCroppableView != nil)
    {
        UIImage *cropedImage  = [mzCroppableView deleteBackgroundOfImage:imgvCrop];
        
        if (cropedImage)
        {
            // save sticker here....
            
            UIImageView *imageView = [[UIImageView alloc] init];
            
            if (IS_IPHONE_5)
            {
                imageView.frame = CGRectMake(0, 0, 400, 400);
            }
            else if (IS_IPHONE_6)
            {
                imageView.frame = CGRectMake(0, 0, 600, 600);
            }
            else if (IS_IPHONE_6P)
            {
                imageView.frame = CGRectMake(0, 0, 800, 800);
            }
            else
            {
                imageView.frame = CGRectMake(0, 0, 400, 400);
            }
            
            imageView.image = cropedImage;
            
            imageView.contentMode = UIViewContentModeScaleAspectFit;
            
            float widthRatio = imageView.bounds.size.width / imageView.image.size.width;
            float heightRatio = imageView.bounds.size.height / imageView.image.size.height;
            float scale = MIN(widthRatio, heightRatio);
            float imageWidth = scale * imageView.image.size.width;
            float imageHeight = scale * imageView.image.size.height;
            
            imageView.frame = CGRectMake(0, 0, imageWidth, imageHeight);
            imageView.center = imgvCropCenter;
            
            if (self.delegate == nil) {
                if (self.parentViewController != nil) {
                    [self.parentViewController cropStickerViewController_:nil didSelectDoneWithImage:imageView];
                }
            }else{
            [self.delegate cropStickerViewController:nil didSelectDoneWithImage:imageView];
            }
            //[self btnBackTap:nil];
        }

    }
}

#pragma mark - Helper Methods
- (void)bringToFrontAllButtons
{
    [self.view bringSubviewToFront:btnDoneCroping];
    [self.view bringSubviewToFront:btnCamera];
    [self.view bringSubviewToFront:btnBack];
    [self.view bringSubviewToFront:btnCrop];
    [self.view bringSubviewToFront:btnDoneCroping];
    [self.view bringSubviewToFront:btnImagePicker];
    [self.view bringSubviewToFront:btnUndo];
}

- (UIImage*)imageWithImage: (UIImage*) sourceImage scaledToWidth: (float) i_width
{
    float oldWidth = sourceImage.size.width;
    float scaleFactor = i_width / oldWidth;
    
    float newHeight = sourceImage.size.height * scaleFactor;
    float newWidth = oldWidth * scaleFactor;
    
    UIGraphicsBeginImageContext(CGSizeMake(newWidth, newHeight));
    [sourceImage drawInRect:CGRectMake(0, 0, newWidth, newHeight)];
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newImage;
}

- (UIImage *)compressImage:(UIImage *)image
{
    float actualHeight = image.size.height;
    float actualWidth = image.size.width;
    float maxHeight = 800.0; //new max. height for image
    float maxWidth = 600.0; //new max. width for image
    
    float imgRatio = actualWidth/actualHeight;
    float maxRatio = maxWidth/maxHeight;
    float compressionQuality = 1; //50 percent compression
    
    if (actualHeight > maxHeight || actualWidth > maxWidth){
        if(imgRatio < maxRatio){
            //adjust width according to maxHeight
            imgRatio = maxHeight / actualHeight;
            actualWidth = imgRatio * actualWidth;
            actualHeight = maxHeight;
        }
        else if(imgRatio > maxRatio){
            //adjust height according to maxWidth
            imgRatio = maxWidth / actualWidth;
            actualHeight = imgRatio * actualHeight;
            actualWidth = maxWidth;
        }
        else{
            actualHeight = maxHeight;
            actualWidth = maxWidth;
        }
    }
    
    
    NSLog(@"Actual height : %f and Width : %f",actualHeight,actualWidth);
    CGRect rect = CGRectMake(0.0, 0.0, actualWidth, actualHeight);
    UIGraphicsBeginImageContext(rect.size);
    [image drawInRect:rect];
    UIImage *img = UIGraphicsGetImageFromCurrentImageContext();
    NSData *imageData = UIImageJPEGRepresentation(img, compressionQuality);
    UIGraphicsEndImageContext();
    
    return [UIImage imageWithData:imageData];
}


@end
