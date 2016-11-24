//
//  CombineGifImages.h
//  CombineGif
//
//  Created by Ramesh on 05/10/16.
//  Copyright © 2016 Trellisys. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <ImageIO/ImageIO.h>
#import <MobileCoreServices/MobileCoreServices.h>

@interface CombineGifImages : NSObject

- (void)doImageCombine:(NSArray*)gifCollections SavedFileName:(NSString*)savedFileName
            completion:(void (^)(BOOL finished,UIImage* outImage,NSString* outSavedPath))completion;
@end
