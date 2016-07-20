//
//  SlidePreviewScrollView.h
//  ComicBook
//
//  Created by Ramesh on 19/07/16.
//  Copyright © 2016 ADNAN THATHIYA. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ComicSlidePreview.h"

@interface SlidePreviewScrollView : UIPageViewController<UIGestureRecognizerDelegate,UIPageViewControllerDelegate,UIPageViewControllerDataSource>

//@property (strong, atomic) UIPageViewController *pageViewController;
//@property (nonatomic, strong) ComicSlidePreview *viewPreviewSlide;
@property (strong, nonatomic) NSArray *allSlideImages;

- (ComicSlidePreview*)getSlideVC:(NSInteger)index withImages:(NSArray *)slides;

- (void)setupBook;
@end
