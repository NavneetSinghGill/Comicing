//
//  CombineGifImages.m
//  CombineGif
//
//  Created by Ramesh on 05/10/16.
//  Copyright © 2016 Trellisys. All rights reserved.
//

#import "CombineGifImages.h"
#import <AssetsLibrary/AssetsLibrary.h>
#import "AnimatedGIFImageSerialization.h"
#import "UIImage+resize.h"
#import "AnimatedGIFImageSerialization.h"
#import "UIImage+animatedGIF.h"

@implementation CombineGifImages
{
    NSTimeInterval total_d;
    
    NSMutableArray* dirty_Images;
    NSMutableArray* combined_Images;
    NSTimeInterval combined_duration;
    
    
    NSTimeInterval total_Loop_duration;
    NSTimeInterval lest_FPS;
}

#pragma mark Public Methods
-(BOOL)isStartTimeMeetCombineTime:(NSDictionary*)dictCollecction{
    BOOL isMeet = NO;
        NSTimeInterval startTime = [[dictCollecction objectForKey:@"StartTime"] doubleValue];
        if ( combined_duration >= startTime) {
            isMeet = YES;
        }
    return isMeet;
}

- (void)doImageCombine:(NSArray*)gifCollections SavedFileName:(NSString*)savedFileName
                completion:(void (^)(BOOL finished,UIImage* outImage,NSString* outSavedPath))completion{
    
    @try {
        if (savedFileName == nil || [savedFileName isEqualToString:@""]) {
            savedFileName = [[NSUUID UUID] UUIDString];
        }
        combined_Images = [[NSMutableArray alloc] init];
        dirty_Images = [[NSMutableArray alloc] init];
        
        NSMutableArray* arrayList = [[NSMutableArray alloc] init];
        
        for (NSDictionary* dictCollecction in gifCollections) {
            NSData* dictData = [dictCollecction objectForKey:@"GifData"];
            [self animatedGIFWithDuration:dictData StartTime:[[dictCollecction objectForKey:@"StartTime"] doubleValue] OutArray:&arrayList];
        }
        
        int index =0;
        for(NSTimeInterval i = 0.0 ; i<total_Loop_duration ; i = i+lest_FPS)
        {
            int j =0;
            for (NSDictionary* dictCollecction in gifCollections) {
                NSTimeInterval startTime = [[dictCollecction objectForKey:@"StartTime"] doubleValue];
                NSArray *gifs = [[arrayList objectAtIndex:j] objectForKey:@"images"];
                NSMutableDictionary* mDict = [[NSMutableDictionary alloc]init];
                
                if (i < startTime) {
                }else{
                    if (i >= startTime && [gifs count] > index) {
                        [mDict setObject:gifs[index] forKey:@"imgObj"];
                        [mDict setObject:[dictCollecction objectForKey:@"Position"] forKey:@"Position"];
                        [dirty_Images addObject:mDict];
                    }else if([gifs count] > index){
                        [combined_Images addObject:[self combineImageAndPosition:gifs[index] Position: CGPointFromString([dictCollecction objectForKey:@"Position"])]];
                    }
                }
                gifs = nil;
                mDict = nil;
                j = j + 1;
            }
            if ([dirty_Images count] > 1) {
                [combined_Images addObject:[self clearDirtyImages]];
                [dirty_Images removeAllObjects];
            }
            
            index = index + 1;
        }
        
        combined_duration = total_Loop_duration;
        
        UIImage *image = [UIImage animatedImageWithImages:combined_Images duration:combined_duration];
        
        // Adnan Logic
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *documentsDirectory = [paths objectAtIndex:0];
        NSString *appFile = [documentsDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.gif",savedFileName]];
        
        NSLog(@"appFile %@",appFile);
        
        if([[NSFileManager defaultManager] fileExistsAtPath:appFile])
        {
            [[NSFileManager defaultManager] removeItemAtPath:appFile error:nil];
        }
        
        @autoreleasepool {
            NSError* error;
            NSData *gifdata = [AnimatedGIFImageSerialization animatedGIFDataWithImage:image
                                                                             duration:combined_duration
                                                                            loopCount:0
                                                                                error:&error];
            
            
            [gifdata writeToFile:appFile atomically:YES];
            gifdata = nil;
        }
        completion(YES,image,appFile);
        
    } @catch (NSException *exception) {
        completion(NO,nil,nil);
    } @finally {
    }
}

-(UIImage*)clearDirtyImages{
    
    if ([dirty_Images count]==0) {
        return nil;
    }else {
        return [self blendImages:dirty_Images];
    }
    
    
}

#pragma mark Private Methods

-(UIImage *)blendImages:(NSMutableArray *)array{
    @autoreleasepool {
        UIImage *img= [[array objectAtIndex:0] objectForKey:@"imgObj"];
        CGSize size = img.size;
        UIGraphicsBeginImageContext(size);
        
        for (int i=0; i<array.count; i++) {
            UIImage* uiimage = [[array objectAtIndex:i] objectForKey:@"imgObj"];
            CGPoint ppoint = CGPointFromString([[array objectAtIndex:i] objectForKey:@"Position"]);
            [uiimage drawAtPoint:ppoint blendMode:kCGBlendModeNormal alpha:1.0];
        }
        UIImage * newImage =  UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        img = nil;
        return newImage;
    }
}

-(UIImage*)combineImageAndPosition:(UIImage*)img_1 Position:(CGPoint)imgPoint{
    //    CGSize newSize = CGSizeMake(MAX(img_1.size.width,img_2.size.width) * [UIScreen mainScreen].scale, MAX(img_1.size.height,img_2.size.height)* [UIScreen mainScreen].scale);
    CGSize newSize = img_1.size;
    
    UIView* viewObj = [[UIView alloc] initWithFrame:CGRectMake(imgPoint.x, imgPoint.y, newSize.width, newSize.height)];
    viewObj.backgroundColor = [UIColor clearColor];
    
    UIImageView* imgView = [[UIImageView alloc] initWithImage:img_1];
    imgView.backgroundColor = [UIColor clearColor];
    imgView.frame = viewObj.frame;
    imgView.contentMode = UIViewContentModeScaleAspectFit;
    
    [viewObj addSubview:imgView];
    
//    UIImageView* imgView_2 = [[UIImageView alloc] initWithImage:img_2];
//    imgView_2.backgroundColor = [UIColor clearColor];
//    imgView_2.frame = viewObj.frame;
//    imgView_2.contentMode = UIViewContentModeScaleAspectFit;
//    
//    [viewObj addSubview:imgView_2];
    
    UIGraphicsBeginImageContext(viewObj.frame.size);
    [viewObj.layer renderInContext:UIGraphicsGetCurrentContext()];
    
    UIImage * newImage = UIGraphicsGetImageFromCurrentImageContext();
    viewObj =nil;
    imgView.image = nil;
    imgView = nil;
//    imgView_2.image = nil;
//    imgView_2 = nil;
    UIGraphicsEndImageContext();
    
    return newImage;
}
//
//-(UIImage*)combineImages:(UIImage*)img_1 Image2:(UIImage*)img_2{
////    CGSize newSize = CGSizeMake(MAX(img_1.size.width,img_2.size.width) * [UIScreen mainScreen].scale, MAX(img_1.size.height,img_2.size.height)* [UIScreen mainScreen].scale);
//    
//    CGSize newSize = CGSizeMake(MAX(img_1.size.width,img_2.size.width), MAX(img_1.size.height,img_2.size.height));
//    
//    UIView* viewObj = [[UIView alloc] initWithFrame:CGRectMake(0, 0, newSize.width, newSize.height)];
//    viewObj.backgroundColor = [UIColor clearColor];
//
//    UIImageView* imgView = [[UIImageView alloc] initWithImage:img_1];
//    imgView.backgroundColor = [UIColor clearColor];
//    imgView.frame = viewObj.frame;
//    imgView.contentMode = UIViewContentModeScaleAspectFit;
//    
//    [viewObj addSubview:imgView];
//    
//    UIImageView* imgView_2 = [[UIImageView alloc] initWithImage:img_2];
//    imgView_2.backgroundColor = [UIColor clearColor];
//    imgView_2.frame = viewObj.frame;
//    imgView_2.contentMode = UIViewContentModeScaleAspectFit;
//    
//    [viewObj addSubview:imgView_2];
//    
//    UIGraphicsBeginImageContext(viewObj.frame.size);
//    [viewObj.layer renderInContext:UIGraphicsGetCurrentContext()];
//    
//    UIImage * newImage = UIGraphicsGetImageFromCurrentImageContext();
//    viewObj =nil;
//    imgView.image = nil;
//    imgView = nil;
//    imgView_2.image = nil;
//    imgView_2 = nil;
//    UIGraphicsEndImageContext();
//    
//    return newImage;
//}
int count_i =0;
- (void)animatedGIFWithDuration:(NSData *)data
                      StartTime:(NSTimeInterval)startTime
                       OutArray:(NSMutableArray**)outArray{
    
    NSMutableDictionary *imgDict = [[NSMutableDictionary alloc] init];
    
    UIImage *im =  [UIImage animatedImageWithAnimatedGIFData:data];
    NSArray *gifs = im.images;
    NSTimeInterval duration = im.duration/gifs.count;
    
    [imgDict setObject:gifs forKey:@"images"];
    [imgDict setObject:[NSString stringWithFormat:@"%f",duration] forKey:@"duration"];
    [imgDict setObject:[NSString stringWithFormat:@"%f",duration + startTime] forKey:@"TotalDuration"];
    
    if(total_Loop_duration < (im.duration + startTime))
    {
        total_Loop_duration = im.duration + startTime;
    }
    if (lest_FPS < (total_Loop_duration/gifs.count)) {
        lest_FPS = (total_Loop_duration/gifs.count);
    }
    [*outArray addObject:imgDict];
    
}
- (float)frameDurationAtIndex:(NSUInteger)index source:(CGImageSourceRef)source {
    float frameDuration = 0.1f;
    CFDictionaryRef cfFrameProperties = CGImageSourceCopyPropertiesAtIndex(source, index, nil);
    NSDictionary *frameProperties = (__bridge NSDictionary *)cfFrameProperties;
    NSDictionary *gifProperties = frameProperties[(NSString *)kCGImagePropertyGIFDictionary];
    
    NSNumber *delayTimeUnclampedProp = gifProperties[(NSString *)kCGImagePropertyGIFUnclampedDelayTime];
    if (delayTimeUnclampedProp) {
        frameDuration = [delayTimeUnclampedProp floatValue];
    }
    else {
        
        NSNumber *delayTimeProp = gifProperties[(NSString *)kCGImagePropertyGIFDelayTime];
        if (delayTimeProp) {
            frameDuration = [delayTimeProp floatValue];
        }
    }
    
    // Many annoying ads specify a 0 duration to make an image flash as quickly as possible.
    // We follow Firefox's behavior and use a duration of 100 ms for any frames that specify
    // a duration of <= 10 ms. See <rdar://problem/7689300> and <http://webkit.org/b/36082>
    // for more information.
    
    if (frameDuration < 0.011f) {
        frameDuration = 0.100f;
    }
    
    CFRelease(cfFrameProperties);
    return frameDuration;
}

@end
