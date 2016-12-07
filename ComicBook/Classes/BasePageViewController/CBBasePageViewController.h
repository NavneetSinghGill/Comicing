//
//  CBBasePageViewController.h
//  ComicBook
//
//  Created by Atul Khatri on 06/12/16.
//  Copyright © 2016 Providence. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CBBaseViewController.h"
#import "CBPageViewController.h"

@interface CBBasePageViewController : CBBaseViewController
@property (strong, nonatomic) CBPageViewController *pageController;
@property (nonatomic, strong) UIView* pageControllerContainerView;
@property (nonatomic, strong) NSMutableArray *viewControllers;
@property (nonatomic, strong) CBBaseViewController* currentViewController;
@property (nonatomic, assign) NSInteger currentIndex;
@property (nonatomic, assign) CGFloat topMargin;
- (void)reloadPageViewController;
- (void)changePageToIndex:(NSInteger)index;
- (void)pageChangedToIndex:(NSInteger)index;
- (BOOL)scrollPageViewToLeft;
- (BOOL)scrollPageViewToRight;
@end
