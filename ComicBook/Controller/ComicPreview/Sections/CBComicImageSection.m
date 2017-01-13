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

#define kHorizontalMargin 8.0f
#define kVerticalMargin 5.0f

#define kCollectionViewLeftMargin 8.0f
#define kCollectionViewRightMargin 14.0f
#define kCollectionViewMiddleMargin 0.0f

#define kLandscapeCellHeight 106.0f
#define kPortraitCellHeight 228.0f

#define kVerticalCellMultiplier 1.65f

#define kCellIdentifier @"ComicImageCell"

@implementation CBComicImageSection
- (CBBaseCollectionViewCell*)cellForCollectionView:(UICollectionView *)collectionView atIndexPath:(NSIndexPath *)indexPath{
    [super cellForCollectionView:collectionView atIndexPath:indexPath];
    
    CBComicImageCell* cell= [collectionView dequeueReusableCellWithReuseIdentifier:kCellIdentifier forIndexPath:indexPath];
    if(!cell){
        NSArray* nibs= [[NSBundle mainBundle] loadNibNamed:@"CBComicImageCell" owner:self options:nil];
        cell= [nibs firstObject];
    }
    
    CBComicItemModel* model= [self.dataArray objectAtIndex:indexPath.row];
    cell.imageView.image= model.image;
    
    return cell;
}

-(void)registerNibForCollectionView:(UICollectionView *)collectionView
{
    [collectionView registerNib:[UINib nibWithNibName:@"CBComicImageCell" bundle:nil] forCellWithReuseIdentifier:kCellIdentifier];
}

- (CGSize)sizeForItemAtIndexPath:(NSIndexPath *)indexPath{
    CGSize screenSize= [UIScreen mainScreen].bounds.size;
    CGFloat width= floorf(screenSize.width-(kCollectionViewLeftMargin+kCollectionViewRightMargin+ (kHorizontalMargin*2)));
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
    return UIEdgeInsetsMake(kHorizontalMargin, kVerticalMargin, kHorizontalMargin + 3*kHorizontalMargin, kVerticalMargin);
}


@end
