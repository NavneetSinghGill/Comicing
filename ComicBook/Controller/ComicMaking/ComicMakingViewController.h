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
#import "Utilities.h"

@class ComicMakingViewController;
@class GlideScrollViewController;
@protocol ComicMakingViewControllerDelegate <NSObject>

- (void)comicMakingViewControllerWithEditingDone:(ComicMakingViewController *)controll withComicPage:(ComicPage *)comicPage withNewSlide:(BOOL)newSlide withAnimationSpeed:(CGFloat)speed;

- (void)comicMakingViewControllerWithEditingDone:(ComicMakingViewController *)controll
                                   withImageView:(UIImageView *)imageView
                                 withPrintScreen:(UIImage *)printScreen
                                    gifLayerPath:(NSString *)gifLayerPath
                                    withNewSlide:(BOOL)newslide
                                     withPopView:(BOOL)isPopView
                                 withIsWideSlide:(BOOL)isWideSlide;


//- (void)comicMakingItemSave:(ComicPage *)comicPage
//              withImageView:(id)comicItemData
//            withPrintScreen:(UIImage *)printScreen
//                 withRemove:(BOOL)remove;

- (void)comicMakingItemSave:(ComicPage *)comicPage
              withImageView:(id)comicItemData
            withPrintScreen:(UIImage *)printScreen
                 withRemove:(BOOL)remove
              withImageView:(UIImageView *)imageView;

- (void)comicMakingViewControllerWithEditingDone:(ComicMakingViewController *)controll
                                    ComicPageObj:(ComicPage *)comicPage
                                   withImageView:(UIImageView *)imageView
                                 withPrintScreen:(UIImage *)printScreen
                                    withNewSlide:(BOOL)newslide;

- (void)comicMakingItemRemoveAll:(ComicPage *)comicPage removeAll:(BOOL)isRemoveAll;

@end
typedef void (^RowButtonCallBack)(BOOL success);

@interface ComicMakingViewController : UIViewController
{
    
    __weak IBOutlet NSLayoutConstraint *exclamationLeftConstaint;
}
@property (strong,nonatomic) IBOutlet UISlider *switchToToggle;
-(IBAction)switchToToggleButtonClicked:(id)sender;
- (void)btnCameraTap:(UIButton *)sender;
- (void)closeStickerList;
- (void)openStickerList;
- (void)startDrawing;
- (void)stopDrawing;
- (void)drawingColorTapEventWithColor:(NSString *)colorName;
- (void)drawingUndoTap;
- (void)showCropViewController;
- (void)addStickerWithImage:(UIImage *)sticker;
- (void)addStickerWithPath:(NSString *)stickerImageSting;
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
- (void)addAnimatedSticker:(NSString *)exclamationImageString;
-(void)addAnimationWithInstructionForObj:(NSDictionary *)animationObj;
-(void)openComicEditMode:(BOOL)isAddnew;
- (void)addAnimation:(NSString *)gifImageName;
//End

- (void)closeBlackBoardColors;
- (void)openBlackBoardColors;
- (void)changeColorOfBackboardWithColor:(UIColor *)color;

/*Ramesh */
//Handle Exclamation
- (void)openExclamationList :(RowButtonCallBack)completionHandler;
- (void)closeExclamationList;
-(void)removeExstingAnimatedStickerFromComicPage;
- (void)addExclamationListImage:(NSString *)exclamationImageString;
-(void)notifyParentForCompletionOfInterval;

//END

/* Comic slide handle : Ramesh */
-(void)doRemoveAllItem :(id)comicItemObj;
//END
- (JTAlertView *)showAlertView:(NSString*)message image:(UIImage *)image height:(CGFloat)height;

//Ramesh
//// Start/////

- (IBAction)captionColourButtonClick:(id)sender;
- (IBAction)colourListButtonClick:(id)sender;

//// END //////

// Ramesh P ///
//Bubble Method
-(void)addStandardBubbleOnFirstTime;

@property (strong, nonatomic) ComicPage *comicPage;

@property (nonatomic) BOOL isNewSlide;
@property (strong, nonatomic) IBOutlet UIImageView *imgvComic;
@property (nonatomic, weak) id<ComicMakingViewControllerDelegate> delegate;
@property (strong,nonatomic) GlideScrollViewController *glideScrollView;
@property (strong, nonatomic) IBOutlet UIButton *mSendComicButton;
@property (weak, nonatomic) IBOutlet YYAnimatedImageView *imgGifLayer;


@property (nonatomic) ComicType comicType;
@property (nonatomic) ReplyType replyType;
@property (nonatomic) NSString *friendOrGroupId;
@property (nonatomic) NSString *shareId;
@property (strong, nonatomic) NSString *fileNameToSave;
@property (nonatomic) NSTimer* timerAnimation;
@property BOOL isWideSlide;


@end

