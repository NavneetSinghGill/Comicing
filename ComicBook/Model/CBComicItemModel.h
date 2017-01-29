//
//  CBComicItemModel.h
//  ComicBook
//
//  Created by Atul Khatri on 04/12/16.
//  Copyright © 2016 Comic Book. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

typedef enum {
    COMIC_ITEM_ORIENTATION_PORTRAIT,
    COMIC_ITEM_ORIENTATION_LANDSCAPE
}ComicItemOrientation;

typedef enum {
    COMIC_IMAGE_ORIENTATION_UNKNOWN,
    COMIC_IMAGE_ORIENTATION_PORTRAIT_HALF,
    COMIC_IMAGE_ORIENTATION_PORTRAIT_FULL,
    COMIC_IMAGE_ORIENTATION_LANDSCAPE
}ComicImageOrientation;

@interface CBComicItemModel : NSObject
- (instancetype)initWithTimestamp:(NSNumber*)timestamp image:(UIImage*)image orientation:(ComicItemOrientation)orientation;
@property (nonatomic, strong) NSNumber* timestamp;
@property (nonatomic, strong) UIImage* image;
@property (nonatomic, assign) ComicItemOrientation itemOrientation;
@property (nonatomic, assign) ComicImageOrientation imageOrientation;
@end
