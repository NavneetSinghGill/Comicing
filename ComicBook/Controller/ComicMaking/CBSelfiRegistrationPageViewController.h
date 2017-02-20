//
//  CBSelfiRegistrationPageViewController.h
//  ComicBook
//
//  Created by Sandeep Kumar Lall on 28/01/17.
//  Copyright © 2017 Providence. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AVCamPreviewView.h"
#import "DrawingColorsViewController.h"

@class CBSelfiRegistrationPageViewController;

@protocol CBSelfiRegistrationPageViewControllerDelegate <NSObject>

- (void)cropStickerViewController:(CBSelfiRegistrationPageViewController *)controll didSelectDoneWithImage:(UIImageView *)stickerImageView withBorderImage:(UIImage *)image;

- (void)cropStickerViewControllerWithCropCancel:(CBSelfiRegistrationPageViewController *)controll;

- (void)saveStickerWithWhiteBorderImage:(UIImage *)whiteImage;

@end


@interface CBSelfiRegistrationPageViewController : UIViewController

@property (nonatomic, weak) id<CBSelfiRegistrationPageViewControllerDelegate> delegate;

@property (nonatomic,assign) BOOL isRegView;
@property (weak, nonatomic) IBOutlet AVCamPreviewView *cameraPreview;
@property (weak, nonatomic) IBOutlet UIButton *btnCamera;
@property (weak, nonatomic) IBOutlet UIButton *btnFace;
@property (weak, nonatomic) IBOutlet UIImageView *capturedImage;
//@property (weak, nonatomic) IBOutlet DrawingColorsViewController *drawingController;
@property (weak, nonatomic) IBOutlet UIView *drawingController;
@end
