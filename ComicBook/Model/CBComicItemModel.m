//
//  CBComicItemModel.m
//  ComicBook
//
//  Created by Atul Khatri on 04/12/16.
//  Copyright © 2016 Comic Book. All rights reserved.
//

#import "CBComicItemModel.h"

@implementation CBComicItemModel
- (instancetype)initWithTimestamp:(NSNumber*)timestamp image:(UIImage*)image orientation:(ComicItemOrientation)orientation{
    self = [super init];
    if (self) {
        _timestamp= timestamp;
        _image= image;
        _itemOrientation= orientation;
    }
    return self;
}
@end
