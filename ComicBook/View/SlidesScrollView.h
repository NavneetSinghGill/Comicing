//
//  SlidesScrollView.h
//  ComicMakingPage
//
//  Created by ADNAN THATHIYA on 23/01/16.
//  Copyright © 2016 ADNAN THATHIYA. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ComicPage.h"

@class SlidesScrollView;

@protocol SlidesScrollViewDelegate <NSObject>

- (void)slidesScrollView:(SlidesScrollView *)scrollview didSelectAtIndexPath:(NSInteger)index withView:(UIView *)view;
- (void)slidesScrollView:(SlidesScrollView *)scrollview didSelectAddButtonAtIndex:(NSInteger)index withView:(UIView *)view;
- (void)slidesScrollView:(SlidesScrollView *)scrollview didSelectAddButtonAtIndex:(NSInteger)index withView:(UIView *)view pusWithAnimation:(BOOL)isPushAnimation;
- (void)slidesScrollView:(SlidesScrollView *)scrollview didRemovedAtIndexPath:(NSInteger)index;
- (void)returnAddedView:(UIView *)view;

@end

@interface SlidesScrollView : UIScrollView<UIScrollViewDelegate,UIGestureRecognizerDelegate>

//@property (strong, nonatomic) IBOutlet UIView *view;
@property (strong, nonatomic) UIView *slideView;
@property NSUInteger maximumComicCount;
@property NSInteger setAddButtonIndex;
@property (nonatomic, strong) UIButton *btnAddSlide;
@property (strong, nonatomic) NSMutableArray *allSlidesView;
@property (strong, nonatomic) NSMutableArray *timelineTimeArray;
@property (strong, nonatomic) NSMutableArray *timelineBubbleArray;
@property (nonatomic, strong) UIView *timelineView;

- (void)addViewAtIndex:(NSInteger)index withComicSlide:(ComicPage *)comicSlide;
- (void)reloadComicAtIndex:(NSInteger)index withComicSlide:(ComicPage *)comicSlide;
- (void)reloadComicImageAtIndex:(NSInteger)index withComicSlide:(UIImage *)printScreen;
- (void)addSlideButtonAtIndex:(NSInteger)index;
- (void)btnAddSlideTap:(UIButton *)sender;
- (void)pushAddSlideTap:(UIButton *)sender animation:(BOOL)isPushWithAnimation;
-(void)addTimeLineView;
- (void)setAddButtonFrame:(UIButton *)sender ButtonIndex:(int)btnIndex;
- (void)setScrollViewContectSizeByLastIndex:(NSInteger)index;

@property (nonatomic, weak) id<SlidesScrollViewDelegate> slidesScrollViewDelegate;


@end
