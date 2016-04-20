//
//  ViewController.m
//  ShareSticker
//
//  Created by Ramesh on 09/01/16.
//  Copyright © 2016 comicapp. All rights reserved.
//

#import "StickerShareViewController.h"
#import "UIImage+Trim.h"

@interface StickerShareViewController ()

@end

@implementation StickerShareViewController

- (void)viewDidLoad {
    [self prepareView];
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma methods

-(void)prepareView{
    self.btnTextStickers.layer.cornerRadius = 10; // this value vary as per your desire
    self.btnTextStickers.clipsToBounds = YES;
    [self.btnTextStickers.titleLabel setFont:[UIFont fontWithName:@"MYRIADPRO-REGULAR" size:20.0f]];
}

-(void)addShareSticker:(UIImage*)imgSticker{
    self.imgSelectedSticker = imgSticker;
}

-(UIImage*)createImageWithLogo:(UIImage*)imgActualImage{
    
    //Image with out topbottom transpancey
    UIImage* imgWithOutAlpha = [imgActualImage imageByTrimmingTransparentPixels];
    
    //Selected image adding to imageview
    UIImageView *imageViewSticker = [[UIImageView alloc] initWithImage:imgActualImage];

    //get logo
    UIImage* imgStickerLogo = [UIImage imageNamed:@"ShareStickerLogo"];
    CGSize logoSize =  CGSizeMake(imgStickerLogo.size.width*2,imgStickerLogo.size.height*2);
    
    //Selected image adding to imageview
    UIImageView *imageViewStLogo = [[UIImageView alloc] initWithImage:imgStickerLogo];
    imageViewStLogo.frame = CGRectMake(0, imgWithOutAlpha.size.height + 10, logoSize.width,logoSize.height);
    
    //Calculating Framesize
    CGFloat shareImageHeight = imgActualImage.size.height + 10 + logoSize.height;
    UIView* viewHolder = [[UIView alloc] initWithFrame:CGRectMake(0, 0,
                                                                  (imgActualImage.size.width > logoSize.width?imgActualImage.size.width:logoSize.width), shareImageHeight)];
    
    imageViewStLogo.center = CGPointMake(CGRectGetMidX(viewHolder.bounds), imageViewStLogo.center.y);
    [viewHolder setBackgroundColor:[UIColor clearColor]];
    [viewHolder addSubview:imageViewSticker];
    [viewHolder addSubview:imageViewStLogo];
    
    //Generating image
    UIImage* imgShareTo = [UIImage imageWithView:viewHolder paque:NO];
    
    
//    UIImageWriteToSavedPhotosAlbum(imgShareTo, nil, nil, nil);
    
    viewHolder = nil;
    imageViewSticker = nil;
    
    return imgShareTo;
}

-(UIImage*)getnewImage :(UIImage*)wholeTemplate{
    
    // check if there is alpha channel
    CGImageAlphaInfo alpha = CGImageGetAlphaInfo(wholeTemplate.CGImage);
    if (alpha == kCGImageAlphaPremultipliedLast || alpha == kCGImageAlphaPremultipliedFirst ||
        alpha == kCGImageAlphaLast || alpha == kCGImageAlphaFirst || alpha == kCGImageAlphaOnly)
    {
        // create the context with information from the original image
        CGContextRef bitmapContext = CGBitmapContextCreate((__bridge void * _Nullable)(UIImagePNGRepresentation(wholeTemplate)),
                                                           wholeTemplate.size.width,
                                                           wholeTemplate.size.height,
                                                           CGImageGetBitsPerComponent(wholeTemplate.CGImage),
                                                           CGImageGetBytesPerRow(wholeTemplate.CGImage),
                                                           CGImageGetColorSpace(wholeTemplate.CGImage),
                                                           CGImageGetBitmapInfo(wholeTemplate.CGImage)
                                                           );
        
        // draw white rect as background
        CGContextSetFillColorWithColor(bitmapContext, [UIColor whiteColor].CGColor);
        CGContextFillRect(bitmapContext, CGRectMake(0, 0, wholeTemplate.size.width, wholeTemplate.size.height));
        
        // draw the image
        CGContextDrawImage(bitmapContext, CGRectMake(0, 0, wholeTemplate.size.width, wholeTemplate.size.height), wholeTemplate.CGImage);
        CGImageRef resultNoTransparency = CGBitmapContextCreateImage(bitmapContext);
        
        // get the image back
        wholeTemplate = [UIImage imageWithCGImage:resultNoTransparency];
        
        // do not forget to release..
//        CGImageRelease(resultNoAlpha);
        CGContextRelease(bitmapContext);
    }
    
    return wholeTemplate;
}
-(void)doShareTo :(ShapeType)type ShareImage:(UIImage*)imgShareto{
    
//    UIImage* imgProcessShareImage = [self createImageWithLogo:imgShareto];

    imgShareto = [self createImageWithLogo:imgShareto];
    
//    NSData *imageData = UIImagePNGRepresentation(imgShareto);
//    UIImage *image =[UIImage imageWithData:imageData];

//    UIImage* img = [self getnewImage:image];
    //Just to test
    
//    UIBezierPath *path = [UIBezierPath bezierPath];
//        UIGraphicsBeginImageContextWithOptions([image size], YES, [image scale]);
//        
//        [image drawAtPoint:CGPointZero];
//        
//        CGContextRef ctx = UIGraphicsGetCurrentContext();
//        CGContextSetBlendMode(ctx, kCGBlendModeNormal);
//        [path fill];
//        
//        
//        UIImage *final = UIGraphicsGetImageFromCurrentImageContext();
//        UIGraphicsEndImageContext();

//        UIImageWriteToSavedPhotosAlbum(imgShareto, nil, nil, nil);
//        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
//        NSString *documentsPath = [paths objectAtIndex:0]; //Get the docs directory
//        NSString *filePath = [documentsPath stringByAppendingPathComponent:@"image.png"]; //Add the file name
//        [imageData writeToFile:filePath atomically:YES]; //Write the file
//        UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil);
//        NSLog(@"File Path :%@",filePath);
    
    /* Commented for testing*/
    ShareHelper* sHelper = [ShareHelper shareHelperInit];
    sHelper.parentviewcontroller = self;
    [sHelper shareAction:type ShareText:@""
              ShareImage:imgShareto
              completion:^(BOOL status) {
    }];
    
}
#pragma mark - Action 

- (IBAction)btnBackClick:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)btnTextClick:(id)sender {
    if(!self.imgSelectedSticker)
        return;
    
    [self doShareTo:MESSAGE ShareImage:self.imgSelectedSticker];
}
- (IBAction)btnWhatsAppClick:(id)sender {
    if(!self.imgSelectedSticker)
        return;
    
    [self doShareTo:WHATSAPP ShareImage:self.imgSelectedSticker];
    
}
- (IBAction)btnFbClick:(id)sender {
    if(!self.imgSelectedSticker)
        return;
    
    [self doShareTo:FACEBOOKMESSANGER ShareImage:self.imgSelectedSticker];
}

@end
