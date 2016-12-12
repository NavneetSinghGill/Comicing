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

- (void)addComicItem:(CBComicItemModel*)comicItem completion:(void (^)(BOOL finished))completion{
    [self.dataArray addObject:comicItem];
    
    if(self.dataArray.count%kMaxItemsInComic == 1){
        // Add a new page
        CBComicPageCollectionVC* vc= [[CBComicPageCollectionVC alloc] initWithNibName:@"CBComicPageCollectionVC" bundle:nil];
        vc.delegate= self;
        [self addViewControllers:@[vc]];
        [self changePageToIndex:self.viewControllers.count-1 completed:^(BOOL success) {
            if(success){
                [vc addComicItem:comicItem];
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.4 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                    completion(YES);
                });
            }
        }];
    }else{
        // Add item in last page
        CBComicPageCollectionVC* vc= [self.viewControllers lastObject];
        if(self.currentIndex != self.viewControllers.count-1){
            [self changePageToIndex:self.viewControllers.count-1 completed:^(BOOL success) {
                if(success){
                    [vc addComicItem:comicItem];
                    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.4 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                        completion(YES);
                    });
                }
            }];
        }else{
            [vc addComicItem:comicItem];
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.4 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                completion(YES);
            });
        }
    }
    if(!self.pageController){
        [self reloadPageViewController];
    }
}

#pragma mark- CBComicPageCollectionDelegate method
- (void)didDeleteComicItem:(CBComicItemModel *)comicItem inComicPage:(CBComicPageCollectionVC *)comicPage{
    [self.dataArray removeObject:comicItem];
    if(self.delegate && [self.delegate conformsToProtocol:@protocol(CBComicPageViewControllerDelegate)]){
        if([self.delegate respondsToSelector:@selector(didDeleteComicItem:inPage:)]){
            [self.delegate didDeleteComicItem:comicItem inPage:comicPage];
        }
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
