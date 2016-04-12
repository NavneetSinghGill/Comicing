//
//  ComicImageListViewController.m
//  ComicApp
//
//  Created by Ramesh on 02/12/15.
//  Copyright © 2015 Ramesh. All rights reserved.
//

#import "ComicImageListView.h"
#import "UIColor+colorWithHexString.h"

@implementation ComicImageListView

-(id)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if(self)
    {
    }
    return self;
}

-(id)initWithCoder:(NSCoder *)aDecoder{
    self = [super initWithCoder:aDecoder];
    if(self)
    {
        //Load from xib
        [[NSBundle mainBundle] loadNibNamed:@"ComicImageListView" owner:self options:nil];
        
        [self addSubview:self.view];
        [self configSection];
    }
    return self;
}
-(void)configSection{
    
    [self.view setBackgroundColor:[UIColor colorWithHexStr:@"231f20"]];
    
    [self.comicImageCollectionView registerClass:[ComicImageCollectionCell class] forCellWithReuseIdentifier:@"tabCell"];
    self.comicImageCollectionView.delegate = self;
}

-(void)refeshList:(NSMutableArray*)array{
    self.comicImageCollection = array;
    [self.comicImageCollectionView reloadData];
}

#pragma mark - UICollectionView Datasource

- (NSInteger)collectionView:(UICollectionView *)view numberOfItemsInSection:(NSInteger)section {
    return self.comicImageCollection.count;
}

- (NSInteger)numberOfSectionsInCollectionView: (UICollectionView *)collectionView {
    return 1;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)cv cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    ComicImageCollectionCell *cell = (ComicImageCollectionCell*)[cv dequeueReusableCellWithReuseIdentifier:@"tabCell" forIndexPath:indexPath];
    cell.backgroundColor = [UIColor clearColor];
    
    [cell.ComicImage setImage:[self.comicImageCollection objectAtIndex:indexPath.row]];
    
    return cell;
    
}


/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
