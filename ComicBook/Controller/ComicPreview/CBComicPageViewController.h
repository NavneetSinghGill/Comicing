//
//  CBComicPageViewController.h
//  ComicBook
//
//  Created by Atul Khatri on 08/12/16.
//  Copyright © 2016 Providence. All rights reserved.
//

#import "CBBasePageViewController.h"
#import "CBComicPageCollectionVC.h"
#import "CBComicItemModel.h"

@protocol CBComicPageViewControllerDelegate <NSObject>
- (void)didDeleteComicItemInPage:(CBComicPageCollectionVC*)pageVC;
@end

@interface CBComicPageViewController : CBBasePageViewController
@property (nonatomic, weak) id <CBComicPageViewControllerDelegate> delegate;
- (void)addComicItem:(CBComicItemModel*)comicItem;
@end
