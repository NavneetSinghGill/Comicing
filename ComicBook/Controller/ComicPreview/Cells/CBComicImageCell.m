//
//  CBComicImageCell.m
//  ComicBook
//
//  Created by Atul Khatri on 04/12/16.
//  Copyright © 2016 Comic Book. All rights reserved.
//

#import "CBComicImageCell.h"

@implementation CBComicImageCell

- (void)awakeFromNib{
    [super awakeFromNib];
    self.staticImageView.clipsToBounds = self.animatedImageView.clipsToBounds= YES;
    self.staticImageView.layer.borderColor = self.animatedImageView.layer.borderColor = [UIColor blackColor].CGColor;
    self.staticImageView.layer.borderWidth = self.animatedImageView.layer.borderWidth = 3.0f;
    
    [self.contentView bringSubviewToFront:(self.comicSlideLayerType == Gif? self.staticImageView: self.animatedImageView)];
}

@end
