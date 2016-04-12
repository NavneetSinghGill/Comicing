//
//  otherVC.h
//  Animations
//
//  Created by Subin Kurian on 12/21/15.
//  Copyright © 2015 Subin Kurian. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface StickerList : UICollectionViewController

- (void)addStickerWithSticker:(UIImage *)sticker withBorderImage:(UIImage *)withoutBorderImage;

- (void)deactiveDeleteMode;
- (void)saveImageWithBorder:(UIImage *)borderImage;

@property (nonatomic) BOOL addingSticker;

@end
