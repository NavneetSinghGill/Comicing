//
//  ComicCropView2.h
//  DemoCrop
//
//  Created by ADNAN THATHIYA on 06/08/16.
//  Copyright © 2016 ADNAN THATHIYA. All rights reserved.
//

#import <UIKit/UIKit.h>

extern CGFloat wideBoxHeight;

enum
{
    MovementTypeVertically,
    MovementTypeHorizontally
};

typedef NSUInteger MovementType;

@class ComicCropView;

@protocol ComicCropViewDelegate <NSObject>

@optional

- (void)didTapOnComicCropView:(ComicCropView *)view;

@end


@interface ComicCropView : UIView
{
    UIPanGestureRecognizer *panGestureRecognizer;
    UITapGestureRecognizer *tapGestureRecognizer;

    CGFloat ratio;
    MovementType ratioViewMovementType;
}

@property (nonatomic, assign) id<ComicCropViewDelegate> delegate;

@property (strong, nonatomic) UIImageView *imageView;
@property (strong, nonatomic) UIImage *image;
@property (nonatomic, retain) UIView *ratioView;

- (UIImage *)croppedImage:(UIImage *)imageToCrop;

- (UIImage *)outputImage;

- (void)updateAllFrames;

- (UIImage *)cropImageFromImageView:(UIImageView *)imageView withRect:(CGRect)rect;

@end
