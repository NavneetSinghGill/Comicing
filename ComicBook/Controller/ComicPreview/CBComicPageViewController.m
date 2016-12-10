//
//  CBComicPageViewController.m
//  ComicBook
//
//  Created by Atul Khatri on 07/12/16.
//  Copyright © 2016 Comic Book. All rights reserved.
//

#import "CBComicPageViewController.h"

#define kMaxCellCount 100000
#define kMaxItemsInComic 4

@interface CBComicPageViewController () <CBComicPageCollectionDelegate>

@end

@implementation CBComicPageViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.dataArray= [NSMutableArray new];
    
//    [self setupPageViewController];
    self.viewControllers= [NSMutableArray new];
}

- (void)addComicItem:(CBComicItemModel*)comicItem{
    [self.dataArray addObject:comicItem];
    
    if(self.dataArray.count%kMaxItemsInComic == 1){
        // Add a new page
        CBComicPageCollectionVC* vc= [[CBComicPageCollectionVC alloc] initWithNibName:@"CBComicPageCollectionVC" bundle:nil];
        vc.delegate= self;
        [self addViewControllers:@[vc]];
        [self changePageToIndex:self.viewControllers.count-1];
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5f * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [vc addComicItem:comicItem];
        });
    }else{
        // Add item in last page
        CBComicPageCollectionVC* vc= [self.viewControllers lastObject];
        if(self.currentIndex != self.viewControllers.count-1){
            [self changePageToIndex:self.viewControllers.count-1];
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5f * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [vc addComicItem:comicItem];
            });
        }else{
            [vc addComicItem:comicItem];
        }
    }
    if(!self.pageController){
        [self reloadPageViewController];
    }
}

- (void)setupPageViewController{
    NSInteger pageCount= self.dataArray.count/kMaxItemsInComic;
    if(self.viewControllers.count>pageCount){
        [self.viewControllers removeObjectsInRange:NSMakeRange((pageCount+1), self.viewControllers.count-(pageCount+1))];
        if(self.currentIndex > pageCount){
            [self changePageToIndex:pageCount];
        }
    }
    
    self.viewControllers= [NSMutableArray new];
    [self.viewControllers addObject:[[CBComicPageCollectionVC alloc] initWithNibName:@"CBComicPageCollectionVC" bundle:nil]];
    [self.viewControllers addObject:[[CBComicPageCollectionVC alloc] initWithNibName:@"CBComicPageCollectionVC" bundle:nil]];
    
    [self reloadPageViewController];
}

- (IBAction)horizontalButtonTapped:(id)sender {
    CBComicItemModel* model= [[CBComicItemModel alloc] initWithTimestamp:[self currentTimestmap] image:[UIImage imageNamed:@"hor_image.jpg"] orientation:COMIC_ITEM_ORIENTATION_LANDSCAPE];
}

- (IBAction)verticalButtonTapped:(id)sender {
    CBComicItemModel* model= [[CBComicItemModel alloc] initWithTimestamp:[self currentTimestmap] image:[UIImage imageNamed:@"ver_image.jpg"] orientation:COMIC_ITEM_ORIENTATION_PORTRAIT];
}

- (NSNumber*)currentTimestmap{
    return @([[NSDate date] timeIntervalSince1970]);
}

#pragma mark- CBComicPageCollectionDelegate method
- (void)didDeleteComicItem:(CBComicItemModel *)comicItem inComicPage:(CBComicPageCollectionVC *)comicPage{
    [self.dataArray removeObject:comicItem];
    if(self.delegate && [self.delegate conformsToProtocol:@protocol(CBComicPageViewControllerDelegate)]){
        if([self.delegate respondsToSelector:@selector(didDeleteComicItemInPage:)]){
            [self.delegate didDeleteComicItemInPage:comicPage];
        }
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
