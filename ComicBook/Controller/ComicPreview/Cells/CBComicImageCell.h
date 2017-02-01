//
//  CBComicImageCell.h
//  ComicBook
//
//  Created by Atul Khatri on 04/12/16.
//  Copyright © 2016 Comic Book. All rights reserved.
//

#import "CBBaseCollectionViewCell.h"
#import "ComicItem.h"

@interface CBComicImageCell : CBBaseCollectionViewCell
@property (weak, nonatomic) IBOutlet ComicItemAnimatedSticker *animatedImageView;
@property (weak, nonatomic) IBOutlet UIImageView *staticImageView;

@property(assign, nonatomic) ComicSlideLayerType comicSlideLayerType;

@end
