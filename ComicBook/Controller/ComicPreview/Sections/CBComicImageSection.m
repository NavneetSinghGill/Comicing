//
//  CBComicImageSection.m
//  ComicBook
//
//  Created by Atul Khatri on 02/12/16.
//  Copyright © 2016 Comic Book. All rights reserved.
//

#import "CBComicImageSection.h"
#import "CBComicImageCell.h"
#import "CBComicItemModel.h"

#define kHorizontalMargin 0.0f
#define kVerticalMargin 5.0f

#define kCollectionViewLeftMargin 4.5f
#define kCollectionViewRightMargin 4.5f
#define kCollectionViewMiddleMargin 0.0f

#define kLandscapeCellHeight 106.0f
#define kPortraitCellHeight 228.0f

#define kVerticalCellMultiplier 1.68f

#define kCellIdentifier @"ComicImageCell"

@implementation CBComicImageSection
- (CBBaseCollectionViewCell*)cellForCollectionView:(UICollectionView *)collectionView atIndexPath:(NSIndexPath *)indexPath{
    [super cellForCollectionView:collectionView atIndexPath:indexPath];
    self.collectionView = collectionView;
    CBComicImageCell* cell= [collectionView dequeueReusableCellWithReuseIdentifier:kCellIdentifier forIndexPath:indexPath];
    if(!cell){
        NSArray* nibs= [[NSBundle mainBundle] loadNibNamed:@"CBComicImageCell" owner:self options:nil];
        cell= [nibs firstObject];
    }
    
    
    
    _comicItemModel = [self.dataArray objectAtIndex:indexPath.row];
    
    ComicItemAnimatedSticker *st = [ComicItemAnimatedSticker new];
    st.objFrame = CGRectMake(50, 80, 100, 100);
    [st addItemWithImage:[YYImage imageNamed:@"WTF"]];
    _comicItemModel.comicPage.subviews = [NSMutableArray arrayWithObject:st];
//    cell.staticImageView.image = _comicItemModel.baseLayerImage;
//    cell.animatedImageView.image = _comicItemModel.baseLayerGif;
    
    return cell;
}

- (void)createUIForCell:(CBComicImageCell *)cell {
    for (UIView *view in [cell.topLayerView subviews]) {
        [view removeFromSuperview];
    }
    if (_comicItemModel.isBaseLayerGif)
    {
        // NEED to handle 3 layer
        cell.baseLayerImageView.image = [AppHelper getGifFile:_comicItemModel.comicPage.printScreenPath];
        
        //-> Loop subviews and get animation sticker and static image.
        //animation sticker you can check like …
        for (id subview in _comicItemModel.comicPage.subviews) {
            
            if ([subview isKindOfClass:[ComicItemAnimatedSticker class]]) {
                //Handle top layer that is sticker gif
                ComicItemAnimatedSticker *sticker = (ComicItemAnimatedSticker *)subview;
                if (_comicItemModel.imageOrientation == COMIC_IMAGE_ORIENTATION_PORTRAIT_HALF) {
                    sticker.frame = CGRectMake(sticker.objFrame.origin.x/2, sticker.objFrame.origin.y/2, sticker.objFrame.size.width/2, sticker.objFrame.size.height/2);
                } else {
                    sticker.frame = CGRectMake(sticker.objFrame.origin.x, sticker.objFrame.origin.y, sticker.objFrame.size.width, sticker.objFrame.size.height);
                }
                [cell.topLayerView addSubview:sticker];
            }
            
        }
        
        //Handle static Image… here we have to create an abstract class in ComicItem called class name as ComicItemStaticImage
//        for (id subview in _comicItemModel.comicPage.subviews) {
//            if ([subview isKindOfClass:[ComicItemStaticImage class]]) {
//                //Handle middle layer.
//            }
//        }
    } else {
        // This can be 2 layer or single layer
        
        cell.baseLayerImageView.image = [AppHelper getImageFile:_comicItemModel.comicPage.printScreenPath];
        
        //-> Loop subviews and get animation sticker
        //animation sticker you can check like …
        for (id subview in _comicItemModel.comicPage.subviews) {
            if ([subview isKindOfClass:[ComicItemAnimatedSticker class]]) {
                //Handle top layer that is sticker gif
                ComicItemAnimatedSticker *sticker = (ComicItemAnimatedSticker *)subview;
                if (_comicItemModel.imageOrientation == COMIC_IMAGE_ORIENTATION_PORTRAIT_HALF) {
                    sticker.frame = CGRectMake(sticker.objFrame.origin.x/2, sticker.objFrame.origin.y/2, sticker.objFrame.size.width/2, sticker.objFrame.size.height/2);
                } else {
                    sticker.frame = CGRectMake(sticker.objFrame.origin.x, sticker.objFrame.origin.y, sticker.objFrame.size.width, sticker.objFrame.size.height);
                }
                [cell.topLayerView addSubview:sticker];
            }
        }
    }
}

-(void)registerNibForCollectionView:(UICollectionView *)collectionView
{
    [collectionView registerNib:[UINib nibWithNibName:@"CBComicImageCell" bundle:nil] forCellWithReuseIdentifier:kCellIdentifier];
}

- (CGSize)sizeForItemAtIndexPath:(NSIndexPath *)indexPath{
    CGSize collectionViewSize= self.collectionView.frame.size;
    CGFloat width= floorf(collectionViewSize.width-(kCollectionViewLeftMargin+kCollectionViewRightMargin+ (kHorizontalMargin*2)));
    CBComicItemModel* model= [self.dataArray objectAtIndex:indexPath.row];
    if(model.imageOrientation == COMIC_IMAGE_ORIENTATION_LANDSCAPE){
        return CGSizeMake(width, kLandscapeCellHeight);
    }else if(model.imageOrientation == COMIC_IMAGE_ORIENTATION_PORTRAIT_HALF){
        CGFloat cellWidth= floorf((width-kCollectionViewMiddleMargin)/2 -1);
        return CGSizeMake(cellWidth, floorf(cellWidth*kVerticalCellMultiplier));
    }else {
        return CGSizeMake(width, floorf(width*kVerticalCellMultiplier));
    }
}

- (UIEdgeInsets)insetForSection{
    return UIEdgeInsetsMake(kHorizontalMargin, kVerticalMargin, kHorizontalMargin, kVerticalMargin);
}


@end
