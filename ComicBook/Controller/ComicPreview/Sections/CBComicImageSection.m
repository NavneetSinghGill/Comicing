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
    CBComicItemModel* model= [self.dataArray objectAtIndex:indexPath.row];
    if(model.imageOrientation == COMIC_IMAGE_ORIENTATION_LANDSCAPE){
        return CGSizeMake(screenSize.width, 100.0f);
    }else if(model.imageOrientation == COMIC_IMAGE_ORIENTATION_PORTRAIT_HALF){
        return CGSizeMake(screenSize.width/2, screenSize.width);
    }else {
        return CGSizeMake(screenSize.width, screenSize.width);
    }
}
@end
