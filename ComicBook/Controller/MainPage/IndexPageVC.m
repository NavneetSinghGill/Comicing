//
//  IndexPageVC.m
//  CurlDemo
//
//  Created by Subin Kurian on 10/19/15.
//  Copyright © 2015 Subin Kurian. All rights reserved.
//

#import "IndexPageVC.h"
#import "UIImageView+WebCache.h"
#import "Slides.h"

@interface IndexPageVC ()

@end

@implementation IndexPageVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    /**
     Temperely setting images
     */
    
//    NSMutableArray *tempArray = [[NSMutableArray alloc] init];
//    [tempArray addObject:self.imageArray[0]];
//    [tempArray addObject:self.imageArray[1]];
//    [self.imageArray removeAllObjects];
//    [self.imageArray addObjectsFromArray:tempArray];
//    [self.collectionView reloadData];
    
    if(self.pageNumber==1)
    {
        
       
        
        
        [self.slidesArray removeObjectAtIndex:0];
        [self.slidesArray removeObjectAtIndex:0];
        if(4<self.slidesArray.count)
        {
            [self.slidesArray removeObjectAtIndex:0];
        }
    }
    else if (self.pageNumber==2)
    {
       
        for(int i=0;i<7;i++)
        {
            [self.slidesArray removeObjectAtIndex:0];
        }
        
    }
    
    /**
     *  collectionview with layout
     */
    self.automaticallyAdjustsScrollViewInsets = NO;
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, .03 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
        UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc] init];
        CGRect rect=self.collectionView.bounds;
        CGFloat totalWidth=rect.size.width-2;
        CGFloat totalHeight=rect.size.height-5;
        int possibleHeight=totalHeight/2;
        int possibleNumberOfCell=2;
        CGFloat actualwidth=totalWidth/possibleNumberOfCell;
        [flowLayout setItemSize:CGSizeMake(actualwidth, possibleHeight)];
        flowLayout.sectionInset=UIEdgeInsetsMake(1, 0, 1, 0);
//        flowLayout.sectionInset=UIEdgeInsetsMake(1, .5, 0, 1);
        flowLayout.minimumLineSpacing=2;
        flowLayout.minimumInteritemSpacing=2;
        [self.collectionView setCollectionViewLayout:flowLayout];
        [self.collectionView.collectionViewLayout invalidateLayout];
        
    });
    
    
    
}


#pragma mark <UICollectionViewDataSource>



- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    
    return 1;
}


- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    
    
    return 4;
    
}

-(void)collectionView:(UICollectionView *)collectionView willDisplayCell:(UICollectionViewCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath
{
    
    UIImageView *img=(UIImageView*)[cell viewWithTag:1];
    
    if(self.slidesArray.count == 2) {
        // logic for 2 items
        if(indexPath.row == 0 || indexPath.row == 3) {
            NSLog(@"showww1");
            if(indexPath.row == 0) {
                Slides *slide = [self.slidesArray objectAtIndex:0];
                [img sd_setImageWithURL:[NSURL URLWithString:slide.slideImage] placeholderImage:nil completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
                }];
            } else if(indexPath.row == 3) {
                Slides *slide = [self.slidesArray objectAtIndex:1];
                [img sd_setImageWithURL:[NSURL URLWithString:slide.slideImage] placeholderImage:nil completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
                }];
            }
            
            img.layer.borderWidth=2;
            img.layer.borderColor=[UIColor blackColor].CGColor;
            [img.layer setMasksToBounds:true];
        } else {
            img.image=nil;
            img.layer.borderWidth=0;
            img.layer.borderColor=[UIColor clearColor].CGColor;
            [img.layer setMasksToBounds:true];
        }
        
    } else {
        if(indexPath.row<self.slidesArray.count)
        {
            Slides *slide = [self.slidesArray objectAtIndex:indexPath.row];
            [img sd_setImageWithURL:[NSURL URLWithString:slide.slideImage] placeholderImage:nil completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
            }];
            img.layer.borderWidth=2;
            img.layer.borderColor=[UIColor blackColor].CGColor;
            [img.layer setMasksToBounds:true];
        }
        else
        {
            img.image=nil;
            img.layer.borderWidth=0;
            img.layer.borderColor=[UIColor clearColor].CGColor;
            [img.layer setMasksToBounds:true];
        }
    }
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"Cell" forIndexPath:indexPath];
    
    
    return cell;
}
-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    NSMutableDictionary *dict=[[NSMutableDictionary alloc]init];
    
    
    
    if(self.pageNumber==1)
    {
        [dict setObject:@"1" forKey:@"StartedPage"];
        if(4>=self.slidesArray.count)
        {
            // vishnuvardhan
//             [dict setObject:[NSString stringWithFormat:@"%d",(int)indexPath.item+2] forKey:@"SelectedPageNumber"];
            if(self.slidesArray.count == 2 && indexPath.item == 3) {
                [dict setObject:[NSString stringWithFormat:@"%d",(int)indexPath.item] forKey:@"SelectedPageNumber"];
            } else {
                [dict setObject:[NSString stringWithFormat:@"%d",(int)indexPath.item+2] forKey:@"SelectedPageNumber"];
            }
        }
//        else
//        {
//
//            [dict setObject:[NSString stringWithFormat:@"%d",(int)indexPath.item+3] forKey:@"SelectedPageNumber"];
//        }
        
    }
    else if(self.pageNumber==2)
    {
        [dict setObject:@"2" forKey:@"StartedPage"];
//        [dict setObject:[NSString stringWithFormat:@"%d",(int)indexPath.item+7] forKey:@"SelectedPageNumber"];
        if(self.slidesArray.count == 2 && indexPath.item == 3) {
            [dict setObject:[NSString stringWithFormat:@"%d",(int)indexPath.item+4] forKey:@"SelectedPageNumber"];
        } else {
            [dict setObject:[NSString stringWithFormat:@"%d",(int)indexPath.item+6] forKey:@"SelectedPageNumber"];
        }
    }
    
    [dict setObject:[NSString stringWithFormat:@"%d",TRUE] forKey:@"IndexSelected"];
    
    [dict setObject:[NSString stringWithFormat:@"%d",self.Tag] forKey:@"tag"];

    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"PageChange" object:self userInfo:dict];
    
    
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



@end
