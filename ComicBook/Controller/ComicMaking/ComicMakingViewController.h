//
//  ComicMakingViewController.h
//  ComicMakingPage
//
//  Created by ADNAN THATHIYA on 23/12/15.
//  Copyright © 2015 ADNAN THATHIYA. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "JTAlertView.h"
#import "ComicPage.h"
#import "BaseModel.h"
#import "AppHelper.h"

@class ComicMakingViewController;
@class GlideScrollViewController;
@protocol ComicMakingViewControllerDelegate <NSObject>

- (void)comicMakingViewControllerWithEditingDone:(ComicMakingViewController *)controll withComicPage:(ComicPage *)comicPage withNewSlide:(BOOL)newSlide withAnimationSpeed:(CGFloat)speed;

- (void)comicMakingViewControllerWithEditingDone:(ComicMakingViewController *)controll withImageView:(UIImageView *)imageView withPrintScreen:(UIImage *)printScreen withNewSlide:(BOOL)newslide
 withPopView:(BOOL)isPopView;


- (void)comicMakingItemSave:(ComicPage *)comicPage
              withImageView:(id)comicItemData
            withPrintScreen:(UIImage *)printScreen
                 withRemove:(BOOL)remove;

- (void)comicMakingViewControllerWithEditingDone:(ComicMakingViewController *)controll
                                    ComicPageObj:(ComicPage *)comicPage
                                   withImageView:(UIImageView *)imageView
                                 withPrintScreen:(UIImage *)printScreen
                                    withNewSlide:(BOOL)newslide;

- (void)comicMakingItemRemoveAll:(ComicPage *)comicPage removeAll:(BOOL)isRemoveAll;

@end

@interface ComicMakingViewController : UIViewController
{
    
}
- (void)btnCameraTap:(UIButton *)sender;
- (void)closeStickerList;
- (void)openStickerList;
- (void)startDrawing;
- (void)stopDrawing;
- (void)drawingColorTapEventWithColor:(NSString *)colorName;
- (void)drawingUndoTap;
- (void)showCropViewController;
- (void)addStickerWithImage:(UIImage *)sticker;
- (void)openBlackBoard;
- (void)closeBlackBoard;
- (void)closeCamera;
-(void)openCaptionView;
//Ramesh - Bubble
- (void)addDeactiveDeleteMode;
- (void)deactiveDeleteMode:(UIButton *)sender;
-(void)openBubbleList;
-(void)closeBubbleList;
//- (void)addBubbleWithImage:(NSString *)bubbleImageString;
- (void)addBubbleWithImage:(NSString *)bubbleImageString TextFiledRect:(CGRect)textViewSize;
-(void)openComicEditMode:(BOOL)isAddnew;
//End

- (void)closeBlackBoardColors;
- (void)openBlackBoardColors;
- (void)changeColorOfBackboardWithColor:(UIColor *)color;

/*Ramesh */
//Handle Exclamation
- (void)openExclamationList;
- (void)closeExclamationList;
- (void)addExclamationListImage:(NSString *)exclamationImageString;
//END

- (JTAlertView *)showAlertView:(NSString*)message image:(UIImage *)image height:(CGFloat)height;

//Ramesh
//// Start/////

- (IBAction)captionColourButtonClick:(id)sender;
- (IBAction)colourListButtonClick:(id)sender;

//// END //////

@property (strong, nonatomic) ComicPage *comicPage;

@property (nonatomic) BOOL isNewSlide;
@property (strong, nonatomic) IBOutlet UIImageView *imgvComic;
@property (nonatomic, weak) id<ComicMakingViewControllerDelegate> delegate;
@property (strong,nonatomic) GlideScrollViewController *glideScrollView;

@end

