//
//  CropStickerViewController.h
//  CommicMakingPage
//
//  Created by ADNAN THATHIYA on 06/12/15.
//  Copyright (c) 2015 jistin. All rights reserved.
//
#import <UIKit/UIKit.h>

//extern NSString *const SKeySticker;

@class CropStickerViewController;

@protocol CropStickerViewControllerDelegate <NSObject>

- (void)cropStickerViewController:(CropStickerViewController *)controll didSelectDoneWithImage:(UIImageView *)stickerImageView;

- (void)cropStickerViewControllerWithCropCancel:(CropStickerViewController *)controll;

@end

@interface CropStickerViewController : UIViewController

@property (nonatomic, weak) id<CropStickerViewControllerDelegate> delegate;
@property (weak, nonatomic) IBOutlet UIImageView *imgCropBackground;

-(void)configScreens;

@end
