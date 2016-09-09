//
//  ComicCropView2.m
//  DemoCrop
//
//  Created by ADNAN THATHIYA on 06/08/16.
//  Copyright © 2016 ADNAN THATHIYA. All rights reserved.
//

#import "ComicCropView.h"

CGFloat wideBoxHeight = 160;

CGSize CGSizeAbsolute(CGSize size) {
    return (CGSize){fabs(size.width), fabs(size.height)};
}

@interface ComicCropView()

@property (nonatomic, retain) UIView *overlayView;
@property (nonatomic, retain) UIView *ratioControlsView;

//
//  Gestures
//
- (void)panGesture:(UIPanGestureRecognizer *)recognizer;




@end

@implementation ComicCropView

@synthesize overlayView, ratioView, ratioControlsView;

// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}


- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        // Don't display outside this box
        self.clipsToBounds = YES;
        self.autoresizesSubviews = YES;
        
        self.backgroundColor = [UIColor clearColor];
        [self initialize];
        
    }
    
    return self;
}

- (void)setImageViewFrame
{
    float widthRatio = self.imageView.bounds.size.width / self.imageView.image.size.width;
    float heightRatio = self.imageView.bounds.size.height / self.imageView.image.size.height;
    float scale = MIN(widthRatio, heightRatio);
    float imageWidth = scale * self.imageView.image.size.width;
    float imageHeight = scale * self.imageView.image.size.height;
    
    self.imageView.frame = CGRectMake(0, 0, imageWidth, imageHeight);
    
    self.imageView.center = self.center;
    
    self.imageView.backgroundColor = [UIColor redColor];
    
    //  [self updateComicCropFrame:imgvComic.frame];
    
    self.imageView.layer.masksToBounds = YES;
}

- (void)setImage:(UIImage *)image
{
    self.imageView.image = image;
    [self setImageViewFrame];
    ratioControlsView.frame = self.imageView.frame;
    overlayView.frame = CGRectMake(0, 0, CGRectGetWidth(ratioControlsView.frame), CGRectGetHeight(ratioControlsView.frame));
    ratioView.frame = CGRectMake(0, 0, CGRectGetWidth(ratioControlsView.frame), wideBoxHeight);
    self.backgroundColor = [UIColor blackColor];

   // ratioView.center = self.imageView.center;
}

- (void)initialize
{
    // Setup gestures
    panGestureRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panGesture:)];
    panGestureRecognizer.minimumNumberOfTouches = 1;
    
    
    tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapGesture:)];
    tapGestureRecognizer.numberOfTapsRequired = 1;
    
    self.imageView = [[UIImageView alloc] initWithFrame:self.bounds];
    [self addSubview:self.imageView];
    self.imageView.backgroundColor = [UIColor clearColor];
    self.imageView.contentMode = UIViewContentModeScaleAspectFit;
    
    
    ratioControlsView = [[UIView alloc] initWithFrame:self.bounds];
    
    // Ratio Controls View
    
    ratioControlsView.hidden = NO;
    ratioControlsView.autoresizesSubviews = YES;
    ratioControlsView.backgroundColor = [UIColor clearColor];
    
    // Overlay
    overlayView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(ratioControlsView.frame), CGRectGetHeight(ratioControlsView.frame))];
    overlayView.alpha = .8;
    overlayView.backgroundColor = [UIColor blackColor];
    overlayView.userInteractionEnabled = NO;
    overlayView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    [ratioControlsView addSubview:overlayView];
    
    // Ratio view
    ratioView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(ratioControlsView.frame), wideBoxHeight)];
    ratioView.autoresizingMask = UIViewAutoresizingNone;
    [ratioView addGestureRecognizer:panGestureRecognizer];
    [ratioView addGestureRecognizer:tapGestureRecognizer];
    [ratioControlsView addSubview:ratioView];
    ratioView.backgroundColor = [UIColor clearColor];
    
    [self addSubview:ratioControlsView];

   
    [self resetRatioControls];
    
    [self panGesture:self.ratioView.gestureRecognizers[0]];
}

- (void)updateAllFrames
{
    ratioControlsView.frame = self.bounds;
    overlayView.frame = self.ratioControlsView.bounds;
    ratioView.frame = CGRectMake(0, 0, CGRectGetWidth(ratioControlsView.frame), wideBoxHeight);
    
    [self resetRatioControls];
    
    [self panGesture:self.ratioView.gestureRecognizers[0]];
}



- (UIImage *)MLImageCrop_fixOrientation:(UIImage*)image {
    
    if (image.imageOrientation == UIImageOrientationUp) return image;
    
    CGAffineTransform transform = CGAffineTransformIdentity;
    
    UIImageOrientation io = image.imageOrientation;
    if (io == UIImageOrientationDown || io == UIImageOrientationDownMirrored) {
        transform = CGAffineTransformTranslate(transform, image.size.width, image.size.height);
        transform = CGAffineTransformRotate(transform, M_PI);
    }else if (io == UIImageOrientationLeft || io == UIImageOrientationLeftMirrored) {
        transform = CGAffineTransformTranslate(transform, image.size.width, 0);
        transform = CGAffineTransformRotate(transform, M_PI_2);
    }else if (io == UIImageOrientationRight || io == UIImageOrientationRightMirrored) {
        transform = CGAffineTransformTranslate(transform, 0, image.size.height);
        transform = CGAffineTransformRotate(transform, -M_PI_2);
        
    }
    
    if (io == UIImageOrientationUpMirrored || io == UIImageOrientationDownMirrored) {
        transform = CGAffineTransformTranslate(transform, image.size.width, 0);
        transform = CGAffineTransformScale(transform, -1, 1);
    }else if (io == UIImageOrientationLeftMirrored || io == UIImageOrientationRightMirrored) {
        transform = CGAffineTransformTranslate(transform, image.size.height, 0);
        transform = CGAffineTransformScale(transform, -1, 1);
        
    }
    
    CGContextRef ctx = CGBitmapContextCreate(NULL, image.size.width, image.size.height,
                                             CGImageGetBitsPerComponent(image.CGImage), 0,
                                             CGImageGetColorSpace(image.CGImage),
                                             CGImageGetBitmapInfo(image.CGImage));
    CGContextConcatCTM(ctx, transform);
    
    if (io == UIImageOrientationLeft || io == UIImageOrientationLeftMirrored || io == UIImageOrientationRight || io == UIImageOrientationRightMirrored) {
        CGContextDrawImage(ctx, CGRectMake(0,0,image.size.height,image.size.width), image.CGImage);
    }else{
        CGContextDrawImage(ctx, CGRectMake(0,0,image.size.width,image.size.height), image.CGImage);
    }
    
    CGImageRef cgimg = CGBitmapContextCreateImage(ctx);
    UIImage *img = [UIImage imageWithCGImage:cgimg];
    CGContextRelease(ctx);
    CGImageRelease(cgimg);
    return img;
}

- (UIImage*)imageimageimage:(CGRect)targetRect withImage:(UIImage*)image
{
    targetRect.origin.x*=image.scale;
    targetRect.origin.y*=image.scale;
    targetRect.size.width*=image.scale;
    targetRect.size.height*=image.scale;
    
    if (targetRect.origin.x<0)
    {
        targetRect.origin.x = 0;
    }
    if (targetRect.origin.y<0)
    {
        targetRect.origin.y = 0;
    }
    
    //宽度高度过界就删去
    CGFloat cgWidth = CGImageGetWidth(image.CGImage);
    CGFloat cgHeight = CGImageGetHeight(image.CGImage);
    if (CGRectGetMaxX(targetRect)>cgWidth) {
        targetRect.size.width = cgWidth-targetRect.origin.x;
    }
    if (CGRectGetMaxY(targetRect)>cgHeight) {
        targetRect.size.height = cgHeight-targetRect.origin.y;
    }
    
    CGImageRef imageRef = CGImageCreateWithImageInRect(image.CGImage, targetRect);
    UIImage *resultImage=[UIImage imageWithCGImage:imageRef];
    CGImageRelease(imageRef);
    
    //修正回原scale和方向
    resultImage = [UIImage imageWithCGImage:resultImage.CGImage scale:image.scale orientation:image.imageOrientation];
    
    return resultImage;
}


#pragma mark - Gestures

- (void)tapGesture : (UITapGestureRecognizer *)recognizer
{
    [self.delegate didTapOnComicCropView:self];
}

- (void)panGesture:(UIPanGestureRecognizer *)recognizer
{
    CGPoint translation = [recognizer translationInView:self.ratioView];
    CGPoint center = CGPointMake(0, 0);
    
    if (ratioViewMovementType == MovementTypeHorizontally)
    {
        // Superview's width minus half of ratio view's width
        CGFloat maxXCenter = self.ratioControlsView.frame.size.width - (self.ratioView.frame.size.width * .5);
        // Half of ratio view's width
        CGFloat minXCenter = (self.ratioView.frame.size.width * .5);
        CGFloat computedXCenter = recognizer.view.center.x + translation.x;
        
        if (computedXCenter < minXCenter) {
            computedXCenter = minXCenter;
        } else if (computedXCenter > maxXCenter) {
            computedXCenter = maxXCenter;
        }
        
        center = CGPointMake(computedXCenter, recognizer.view.center.y);
    }
    else if (ratioViewMovementType == MovementTypeVertically)
    {
        // Superview's height minus half of ratio view's height
        CGFloat maxYCenter = self.ratioControlsView.frame.size.height - (self.ratioView.frame.size.height * .5);
        // Half of ratio view's height
        CGFloat minYCenter = (self.ratioView.frame.size.height * .5);
        CGFloat computedYCenter = recognizer.view.center.y + translation.y;
        
        if (computedYCenter < minYCenter) {
            computedYCenter = minYCenter;
        } else if (computedYCenter > maxYCenter) {
            computedYCenter = maxYCenter;
        }
        
        center = CGPointMake(recognizer.view.center.x, computedYCenter);
    }
    
    [recognizer setTranslation:CGPointMake(0, 0) inView:self.ratioView];
    [recognizer.view setCenter:center];
    
    // Notification
//    if (self.didChangeCropRectBlock)
//        self.didChangeCropRectBlock(self.ratioView.frame);
    
    // Reset overlay clipping
    [self overlayClipping];
}

- (void)overlayClipping
{
    CAShapeLayer *maskLayer = [[CAShapeLayer alloc] init];
    CGMutablePathRef path = CGPathCreateMutable();
    
    // Left side of the ratio view
    CGPathAddRect(path, nil, CGRectMake(0,
                                        0,
                                        self.ratioView.frame.origin.x,
                                        self.overlayView.frame.size.height));
    // Right side of the ratio view
    CGPathAddRect(path, nil, CGRectMake(
                                        self.ratioView.frame.origin.x + self.ratioView.frame.size.width,
                                        0,
                                        self.overlayView.frame.size.width - self.ratioView.frame.origin.x - self.ratioView.frame.size.width,
                                        self.overlayView.frame.size.height));
    // Top side of the ratio view
    CGPathAddRect(path, nil, CGRectMake(0,
                                        0,
                                        self.overlayView.frame.size.width,
                                        self.ratioView.frame.origin.y));
    // Bottom side of the ratio view
    CGPathAddRect(path, nil, CGRectMake(0,
                                        self.ratioView.frame.origin.y + self.ratioView.frame.size.height,
                                        self.overlayView.frame.size.width,
                                        self.overlayView.frame.size.height - self.ratioView.frame.origin.y + self.ratioView.frame.size.height));
    maskLayer.path = path;
    
    self.overlayView.layer.mask = maskLayer;
    CGPathRelease(path);
}

- (void)resetRatioControls
{
    CGRect actualImageRect = [self imageFrameFromImageViewWithAspectFitMode:self.imageView];
    CGSize imageSizeAfterRotation = CGSizeAbsolute([self sizeForRotatedImage:self.imageView.image]);
    
    if (CGRectEqualToRect(actualImageRect, CGRectZero))
        return;
    
    CGRect frame = CGRectZero;
    CGFloat imageRatio = imageSizeAfterRotation.width / imageSizeAfterRotation.height;
    if (imageRatio > ratio)
    {
        // Width > Height
        frame = CGRectMake(0, 0, ratio * actualImageRect.size.height, actualImageRect.size.height);
        ratioViewMovementType = MovementTypeHorizontally;
    } else {
        // Height > Width
        frame = CGRectMake(0, 0, actualImageRect.size.width, actualImageRect.size.width / ratio);
        ratioViewMovementType = MovementTypeVertically;
    }
    
    [self.ratioView setFrame:frame];
    [self.ratioControlsView setFrame:actualImageRect];
    [self.overlayView setFrame:ratioControlsView.bounds];
    
    // Reset overlay clipping
    [self overlayClipping];
}

-(CGRect) cropRectForFrame:(CGRect)frame WithImage:(UIImage *)image
{
    NSAssert(self.contentMode == UIViewContentModeScaleAspectFit, @"content mode must be aspect fit");
    
    CGFloat widthScale = self.imageView.bounds.size.width /image.size.width;
    CGFloat heightScale = self.imageView.bounds.size.height / image.size.height;
    
    float x, y, w, h, offset;
    if (widthScale<heightScale)
    {
        offset = (self.bounds.size.height - (image.size.height*widthScale))/2;
        x = frame.origin.x / widthScale;
        y = (frame.origin.y-offset) / widthScale;
        w = frame.size.width / widthScale;
        h = frame.size.height / widthScale;
    }
    else
    {
        offset = (self.bounds.size.width - (image.size.width*heightScale))/2;
        x = (frame.origin.x-offset) / heightScale;
        y = frame.origin.y / heightScale;
        w = frame.size.width / heightScale;
        h = frame.size.height / heightScale;
    }
    return CGRectMake(x, y, w, h);
}

- (UIImage *)croppedImage:(UIImage *)imageToCrop
{
    CGSize imageSize = imageToCrop.size;
    CGSize scaledImageSize = [self imageFrameFromImageViewWithAspectFitMode:self.imageView].size;
    CGFloat widthFactor = scaledImageSize.width / imageSize.width;
    CGFloat heightFactor = scaledImageSize.height / imageSize.height;
    
    CGRect currentCropRect = self.ratioView.frame;
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

- (UIImage *)croppIngimageByImageName:(UIImage *)imageToCrop toRect:(CGRect)rect
{
    //CGRect CropRect = CGRectMake(rect.origin.x, rect.origin.y, rect.size.width, rect.size.height+15);
    
    CGImageRef imageRef = CGImageCreateWithImageInRect([imageToCrop CGImage], rect);
    UIImage *cropped = [UIImage imageWithCGImage:imageRef];
    CGImageRelease(imageRef);
    
    return cropped;
}


- (UIImage *)outputImage
{
    //CGRect cropRect = [self cropRectForFrame:self.imageView.frame WithImage:self.imageView.image];
    
  //  UIImage *image = [self imageimageimage:cropRect withImage:self.imageView.image];
    
    
    UIImage *fixImage = [self fixrotation:self.imageView.image];
    
    UIImage *croppedImage = [self croppedImage:fixImage];

   
    
    return croppedImage;
}

- (UIImage *)cropImageFromImageView:(UIImageView *)imageView withRect:(CGRect)rect;
{
    self.imageView = imageView;
    
    self.imageView.contentMode = UIViewContentModeScaleAspectFit;
    
    UIImage *fixImage = [self fixrotation:self.imageView.image];
    
    UIImage *croppedImage = [self croppedImage:fixImage];
    return croppedImage;
}


#pragma mark - Calculations

- (CGRect)imageFrameFromImageViewWithAspectFitMode:(UIImageView *)theImageView
{
    if (theImageView.image == nil) {
        return CGRectMake(0, 0, 0, 0);
    }
    
    CGSize imageSize = CGSizeAbsolute([self sizeForRotatedImage:self.imageView.image]);
    
    float imageRatio = imageSize.width / imageSize.height;
    float viewRatio = self.frame.size.width / self.frame.size.height;
    
    if (imageRatio < viewRatio)
    {
        float scale = self.frame.size.height / imageSize.height;
        float width = scale * imageSize.width;
        float topLeftX = .5 * (self.frame.size.width - width);
        return CGRectMake(topLeftX, 0, width, self.frame.size.height);
    }
    else
    {
        float scale = self.frame.size.width / imageSize.width;
        float height = scale * imageSize.height;
        float topLeftY = .5 * (self.frame.size.height - height);
        return CGRectMake(0, topLeftY, self.frame.size.width, height);
    }
}

- (UIImage *)fixrotation:(UIImage *)image{
    
    
    if (image.imageOrientation == UIImageOrientationUp) return image;
    CGAffineTransform transform = CGAffineTransformIdentity;
    
    switch (image.imageOrientation) {
        case UIImageOrientationDown:
        case UIImageOrientationDownMirrored:
            transform = CGAffineTransformTranslate(transform, image.size.width, image.size.height);
            transform = CGAffineTransformRotate(transform, M_PI);
            break;
            
        case UIImageOrientationLeft:
        case UIImageOrientationLeftMirrored:
            transform = CGAffineTransformTranslate(transform, image.size.width, 0);
            transform = CGAffineTransformRotate(transform, M_PI_2);
            break;
            
        case UIImageOrientationRight:
        case UIImageOrientationRightMirrored:
            transform = CGAffineTransformTranslate(transform, 0, image.size.height);
            transform = CGAffineTransformRotate(transform, -M_PI_2);
            break;
        case UIImageOrientationUp:
        case UIImageOrientationUpMirrored:
            break;
    }
    
    switch (image.imageOrientation) {
        case UIImageOrientationUpMirrored:
        case UIImageOrientationDownMirrored:
            transform = CGAffineTransformTranslate(transform, image.size.width, 0);
            transform = CGAffineTransformScale(transform, -1, 1);
            break;
            
        case UIImageOrientationLeftMirrored:
        case UIImageOrientationRightMirrored:
            transform = CGAffineTransformTranslate(transform, image.size.height, 0);
            transform = CGAffineTransformScale(transform, -1, 1);
            break;
        case UIImageOrientationUp:
        case UIImageOrientationDown:
        case UIImageOrientationLeft:
        case UIImageOrientationRight:
            break;
    }
    
    // Now we draw the underlying CGImage into a new context, applying the transform
    // calculated above.
    CGContextRef ctx = CGBitmapContextCreate(NULL, image.size.width, image.size.height,
                                             CGImageGetBitsPerComponent(image.CGImage), 0,
                                             CGImageGetColorSpace(image.CGImage),
                                             CGImageGetBitmapInfo(image.CGImage));
    CGContextConcatCTM(ctx, transform);
    switch (image.imageOrientation) {
        case UIImageOrientationLeft:
        case UIImageOrientationLeftMirrored:
        case UIImageOrientationRight:
        case UIImageOrientationRightMirrored:
            // Grr...
            CGContextDrawImage(ctx, CGRectMake(0,0,image.size.height,image.size.width), image.CGImage);
            break;
            
        default:
            CGContextDrawImage(ctx, CGRectMake(0,0,image.size.width,image.size.height), image.CGImage);
            break;
    }
    
    // And now we just create a new UIImage from the drawing context
    CGImageRef cgimg = CGBitmapContextCreateImage(ctx);
    UIImage *img = [UIImage imageWithCGImage:cgimg];
    CGContextRelease(ctx);
    CGImageRelease(cgimg);
    return img;
    
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

@end
