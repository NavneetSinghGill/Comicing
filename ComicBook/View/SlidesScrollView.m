//
//  SlidesScrollView.m
//  ComicMakingPage
//
//  Created by ADNAN THATHIYA on 23/01/16.
//  Copyright © 2016 ADNAN THATHIYA. All rights reserved.
//

#import "SlidesScrollView.h"
#import "AppConstants.h"
#import "UIImage+Image.h"
#import "UIColor+colorWithHexString.h"

const CGSize viewSizeForIPhone5            = {214, 378};
const CGSize viewSizeForIPhone6            = {250, 444};
const CGSize viewSizeForIPhone6Plus        = {276, 490};

const CGSize viewPreviewSlideSizeForIPhone5            = {214, 378};
const CGSize viewPreviewSlideSizeForIPhone6            = {250, 444};
const CGSize viewPreviewSlideSizeForIPhone6Plus        = {300, 650};

const NSInteger timlineViewTag    = 100;
const NSInteger timlineTextTag    = 200;

const NSInteger viewsInOneRow    = SLIDE_MAXCOUNT + 1;

const NSInteger spaceBetweenSlide = 20;
const NSInteger spaceFromTop = 75;

@interface SlidesScrollView()

@property (nonatomic) CGSize viewSize;
@property (nonatomic) CGSize viewPreviewSize;
@end

@implementation SlidesScrollView

@synthesize slideView;
@synthesize setAddButtonIndex, allSlidesView, viewSize,viewPreviewSize,btnPlusSlide,viewPreviewScrollSlide;
@synthesize listViewImages;
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}

#pragma mark - init method
- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    
    if (self)
    {
        allSlidesView = [[NSMutableArray alloc] init];
        listViewImages = [[NSMutableArray alloc] init];
        if (IS_IPHONE_5)
        {
            viewSize = viewSizeForIPhone5;
            viewPreviewSize = viewPreviewSlideSizeForIPhone5;
        }
        else if (IS_IPHONE_6)
        {
            viewSize = viewSizeForIPhone6;
            viewPreviewSize = viewPreviewSlideSizeForIPhone6;
        }
        else if (IS_IPHONE_6P)
        {
            viewSize = viewSizeForIPhone6Plus;
            viewPreviewSize = viewPreviewSlideSizeForIPhone6Plus;
        }
        else
        {
            viewSize = viewSizeForIPhone5;
            viewPreviewSize = viewSizeForIPhone5;
        }
    }
    
    
    self.delegate = self;
    
    return self;
}


#pragma mark - Helper method

- (CGRect)frameForPreviewSlide:(NSInteger)index
{
    NSInteger columnCount = index % viewsInOneRow;
    NSInteger rowCount    = index / viewsInOneRow;
    
    CGFloat x = ( 50 * (columnCount + 1)) + (columnCount * viewSize.width);
    CGFloat y = ( 18 * (rowCount +  1)) + (rowCount * viewSize.width);
    
    return CGRectMake(x, y, viewPreviewSize.width + 70, viewPreviewSize.height);
}

- (CGRect)frameForPossition:(NSInteger)index
{
    NSInteger columnCount = index % viewsInOneRow;
    NSInteger rowCount    = index / viewsInOneRow;
    
    CGFloat x = ( spaceBetweenSlide * (columnCount + 1)) + (columnCount * viewSize.width);
    CGFloat y = ( spaceFromTop * (rowCount +  1)) + (rowCount * viewSize.width);
    
    return CGRectMake(x, y, viewSize.width, viewSize.height);
}

- (CGRect)frameForPossitionPlusButton:(NSInteger)index
{
    NSInteger columnCount = index % viewsInOneRow;
    NSInteger rowCount    = index / viewsInOneRow;
    
    CGFloat x = ( spaceBetweenSlide * (columnCount + 1)) + (columnCount * viewSize.width) - 20;
    CGFloat y = ( spaceFromTop * (rowCount +  1)) + (rowCount * viewSize.width) - 20;
    
    return CGRectMake(x, y, 20, 20);
}

- (void)setScrollViewContectSize
{
    self.contentSize = CGSizeMake(CGRectGetMaxX(viewPreviewScrollSlide.view.frame) + spaceBetweenSlide , CGRectGetHeight(viewPreviewScrollSlide.view.frame));
}

- (void)setScrollViewContectSizeByLastIndex:(NSInteger)index
{
    CGRect rectSize = [self frameForPossition:index];
    self.contentSize = CGSizeMake(CGRectGetMaxX(rectSize) + spaceBetweenSlide , CGRectGetHeight(rectSize));
}


#pragma mark Scrollviewdelegate

//- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
//{
//}
//
//- (void)scrollViewDidScroll:(UIScrollView *)scrollView
//{
//    if ([scrollView isKindOfClass:[UIScrollView class]]) {
//    }
//}

#pragma mark - make slideview methods
- (UIView*)reloadSlideViewForIndex:(NSInteger)index mainView:(UIView*)subView
{
//    NSLog(@"1 subView %@", subView);
    subView.frame = [self frameForPossition:index];
    subView.tag = index;
//    NSLog(@" subView index %ld", (long)index);
//    NSLog(@"2 subView %@", subView);
    
    for (id objId in [subView subviews]) {
        if ([objId isKindOfClass:[UIImageView class]]) {
            UIImageView *imgvComic = (UIImageView*)objId;
            imgvComic.tag = index;
        }else if ([objId isKindOfClass:[UIButton class]]) {
            UIButton *slideButton = (UIButton*)objId;
            slideButton.tag = index;
        }
    }
    
    //Adject timeline time text
//    if ([self viewWithTag:((index + 1) * timlineViewTag)]) {
//        [self viewWithTag:((index + 1) * timlineViewTag)].frame = CGRectMake(((subView.frame.size.width/2) + subView.frame.origin.x ) - spaceBetweenSlide ,
//                                                                       subView.frame.origin.y - 50, 27, 27);
//    }

    if ([self viewWithTag:((index + 1) * timlineTextTag)]) {
//        UIView* viewRound = [self viewWithTag:((index + 1) * timlineViewTag)];
//        [self viewWithTag:((index + 1) * timlineTextTag)].frame = CGRectMake(viewRound.frame.origin.x - 27, viewRound.frame.origin.y - 20, 100, 20);
        
        [self viewWithTag:((index + 1) * timlineTextTag)].frame = CGRectMake(((subView.frame.size.width/2)  + subView.frame.origin.x ) - 50,
                                                                             subView.frame.origin.y - 30, 100, 20);
    }
    
//    [self viewWithTag:((index + 1) * timlineViewTag)].tag =  index * timlineViewTag;
    [self viewWithTag:((index + 1) * timlineTextTag)].tag =  index * timlineTextTag;
    
    return subView;
}

- (UIView *)makeSlideViewForIndex:(NSInteger)index andComicSlide:(ComicPage *)comicSlide
{
    UIView *view = [[UIView alloc] initWithFrame:[self frameForPossition:index]];
    
    UIImageView *imgvComic = [[UIImageView alloc] initWithFrame:view.bounds];
    
    imgvComic.image =  [self getImageFile:comicSlide.printScreenPath];
    imgvComic.image = [UIImage ScaletoFill:imgvComic.image toSize:view.frame.size];
    imgvComic.contentMode = UIViewContentModeScaleAspectFit;
    
    UIButton *slideButton = [[UIButton alloc] initWithFrame:view.bounds];
    
    view.tag = index;
    imgvComic.tag = index;
    slideButton.tag = index;
    [view setBackgroundColor:[UIColor clearColor]];
    
    [allSlidesView addObject:view];
    
    
//    [slideButton addTarget:self action:@selector(clickedOnSlide:) forControlEvents:UIControlEventTouchUpInside];
    
    UITapGestureRecognizer* tapbutton = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(clickedOnSlide:)];
    tapbutton.numberOfTapsRequired = 1;
    [view addGestureRecognizer:tapbutton];
    tapbutton = nil;
    
    
    [slideButton setBackgroundColor:[UIColor clearColor]];
    
    
    UISwipeGestureRecognizer* swipeUpGestureRecognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self
                                                                                                   action:@selector(handleSwipeUpFrom:)];
    swipeUpGestureRecognizer.direction = UISwipeGestureRecognizerDirectionUp;
    [view addGestureRecognizer:swipeUpGestureRecognizer];
    
    [view addSubview:imgvComic];
//    [view addSubview:slideButton];
    
    //Add time line Bubble
    UIView* viewRound = [[UIView alloc] initWithFrame:CGRectMake(((view.frame.size.width/2) + view.frame.origin.x ) - spaceBetweenSlide ,
                                                                 view.frame.origin.y - 50, 27, 27)];
    viewRound.layer.cornerRadius = viewRound.frame.size.width/2;
    viewRound.layer.masksToBounds = YES;
    //[viewRound setBackgroundColor:[UIColor colorWithHexStr:@"26aae1"]];//Dinesh : Ref : Bug list : line 307
//    viewRound.tag = timlineViewTag * index;
    
    //dinesh
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"h.mm a"];
    NSDate *orignalDate   =  [dateFormatter dateFromString:comicSlide.timelineString];
    
    [dateFormatter setDateFormat:@"h:mm a"];
    NSString *finalString = [dateFormatter stringFromDate:orignalDate];
    
    
    //Add time line text
    //UILabel* lblTimeText = [[UILabel alloc] initWithFrame:CGRectMake(viewRound.frame.origin.x - 27, viewRound.frame.origin.y - 20, 80, 20)];
    UILabel* lblTimeText = [[UILabel alloc] initWithFrame:CGRectMake(view.frame.origin.x, view.frame.origin.y - 30, view.frame.size.width, 20)];
    lblTimeText.text = finalString;
    lblTimeText.textColor = [UIColor colorWithHexStr:@"26aae1"];//Dinesh : Ref : Bug list : line 307
//    lblTimeText.font = [UIFont fontWithName:@"digital-7" size:15];
    lblTimeText.font = [UIFont fontWithName:@"Arial" size:15];
    lblTimeText.textAlignment = NSTextAlignmentCenter;
    lblTimeText.tag = timlineTextTag * index;
    if (comicSlide.timelineString == nil ||
        [comicSlide.timelineString isEqualToString:@""]) {
        //Add time line
        NSDate *now = [NSDate date];
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        dateFormatter.dateFormat = @"h:mm a";
        [dateFormatter setTimeZone:[NSTimeZone systemTimeZone]];
        lblTimeText.text = [dateFormatter stringFromDate:now];
        lblTimeText.textColor = [UIColor colorWithHexStr:@"26aae1"];//Dinesh : Ref : Bug list : line 307
        dateFormatter = nil;
    }
    
    [self addSubview:viewRound];
    [self addSubview:lblTimeText];
    
    //Initialise NSMutableArray
    if (self.timelineTimeArray == nil) {
        self.timelineTimeArray = [[NSMutableArray alloc] init];
    }
    if (self.timelineBubbleArray == nil) {
        self.timelineBubbleArray = [[NSMutableArray alloc] init];
    }
    
    [self.timelineTimeArray addObject:lblTimeText];
    [self.timelineBubbleArray addObject:viewRound];
    
    return view;
}

//- (void)wasDragged:(UIPanGestureRecognizer *)recognizer {
//}

//- (void)wasDragged:(UIPanGestureRecognizer *)recognizer {
//    if ([recognizer.view isKindOfClass:[UIButton class]]) {
////        recognizer.cancelsTouchesInView = YES;
//        UIButton *button = (UIButton *)recognizer.view;
//        CGPoint translation = [recognizer translationInView:button];
//        
//        button.center = CGPointMake(button.center.x + translation.x, button.center.y + translation.y);
//        [recognizer setTranslation:CGPointZero inView:button];
//        
////        [button addTarget:self action:@selector(clickedOnSlide:) forControlEvents:UIControlEventTouchUpInside];
////            recognizer.cancelsTouchesInView = NO;
//    }
//}

//- (IBAction)buttonWasTapped:(id)sender {
//    NSLog(@"%s - button tapped",__FUNCTION__);
//}

#pragma mark - Add & Change methods

- (void)addViewAtIndex:(NSInteger)index withComicSlide:(ComicPage *)comicSlide
{
    slideView = [self makeSlideViewForIndex:index andComicSlide:comicSlide];
    [self addSubview:slideView];
    [self.slidesScrollViewDelegate returnAddedView:slideView];
    [self addTimeLineView];
}

- (void)reloadComicAtIndex:(NSInteger)index withComicSlide:(ComicPage *)comicSlide
{
    UIView *view = allSlidesView[index];
    
    NSArray *subviews = [view subviews];
    
    for (id subview in subviews)
    {
        if ([subview isKindOfClass:[UIImageView class]])
        {
            UIImageView *imgvComic = (UIImageView *)subview;
            imgvComic.contentMode = UIViewContentModeScaleAspectFit;
            imgvComic.image = [self getImageFile:comicSlide.printScreenPath];  //[UIImage imageWithData:comicSlide.printScreen];
            [self updatePrivewListImage:index withComicSlide:imgvComic.image];
            imgvComic.image = [UIImage ScaletoFill:imgvComic.image toSize:view.frame.size];
        }
    }
}

- (void)reloadComicImageAtIndex:(NSInteger)index withComicSlide:(UIImage *)printScreen
{
    UIView *view = allSlidesView[index];
    
    NSArray *subviews = [view subviews];
    
    for (id subview in subviews)
    {
        if ([subview isKindOfClass:[UIImageView class]])
        {
            UIImageView *imgvComic = (UIImageView *)subview;
            imgvComic.contentMode = UIViewContentModeScaleAspectFit;
            imgvComic.image = [UIImage ScaletoFill:printScreen toSize:view.frame.size];
            [self updatePrivewListImage:index withComicSlide:printScreen];
        }
    }
//    [self scrollRectToVisible:view.frame animated:NO];
}

-(void)updatePrivewListImage:(NSInteger)index withComicSlide:(UIImage *)printScreen
{
    if ([self.listViewImages count] > index) {
        [self.listViewImages replaceObjectAtIndex:index withObject:printScreen];
    }else{
        [self.listViewImages addObject:printScreen];
    }
    
    [self refreshPreview:index withImages:self.listViewImages];
}

- (void)refreshPreview:(NSInteger)index withImages:(NSArray *)slides
{
  [self setPreviewForSlidesAtIndex:index withImages:slides];
}

- (void)setPreviewForSlidesAtIndex:(NSInteger)index withImages:(NSArray *)slides
{
    if (viewPreviewScrollSlide == nil) {
        viewPreviewScrollSlide = [[SlidePreviewScrollView alloc] init];
    }
    viewPreviewScrollSlide.view.frame = [self frameForPreviewSlide:self.btnPlusSlide.tag];
    viewPreviewScrollSlide.allSlideImages = slides;
    [viewPreviewScrollSlide setupBook];

    [self addSubview:viewPreviewScrollSlide.view];
    
    [self setScrollViewContectSize];
}


-(void)addPlusButton :(NSInteger)index{
    btnPlusSlide = [[UIButton alloc] init];
    btnPlusSlide.frame = [self frameForPossitionPlusButton:index];
    
    [btnPlusSlide setImage:[UIImage imageNamed:@"AddCoimicSlide"] forState:UIControlStateNormal];
    
    [btnPlusSlide addTarget:self action:@selector(btnAddSlideTap:) forControlEvents:UIControlEventTouchUpInside];
    
    btnPlusSlide.tag = index;
    
    [self addSubview:btnPlusSlide];
    
}
-(void)addTimeLineView{
    [self addTimeLineView:0];
}

-(void)addTimeLineView :(float)removeWidth{
    if (allSlidesView && [allSlidesView count] > 0) {
        if (self.timelineView == nil) {
            self.timelineView = [[UIView alloc] init];
        }
        [self.timelineView removeFromSuperview];
        
        self.timelineView.frame = CGRectMake(0, ((UIView*)allSlidesView[0]).frame.origin.y - 37,
                                             (self.contentSize.width - (spaceBetweenSlide + removeWidth)), 2);
        
        
        //Dinesh : Ref : Bug list : line 307
        //[self.timelineView setBackgroundColor:[UIColor colorWithHexStr:@"26aae1"]];
        [self addSubview:self.timelineView];
    }else{
        if (self.timelineView == nil) {
            self.timelineView = [[UIView alloc] init];
        }
        [self.timelineView removeFromSuperview];
    }
}

#pragma mark - Events Methods

-(void)handleSwipeUpFrom:(UIGestureRecognizer*)gestureRecognizer
{
    UIView* viewGesture = gestureRecognizer.view;
    id itemToRemove = nil;
    int gestureIndex = 0;
    
    gestureIndex = viewGesture.tag;
    itemToRemove = [allSlidesView objectAtIndex:gestureIndex];
    [allSlidesView removeObjectAtIndex:gestureIndex];
    [self.listViewImages removeObjectAtIndex:gestureIndex];
    
    //Adding back the Plus Button
    if ([allSlidesView count] == (SLIDE_MAXCOUNT - 1)) {
        [self addSubview:btnPlusSlide];
    }
    
    if (itemToRemove != nil){
        [UIView animateWithDuration:0.3
                              delay:0.1
                            options:UIViewAnimationOptionCurveEaseOut
                         animations:^{
                             CGRect viewFrame = ((UIView*)itemToRemove).frame;
                             viewFrame.origin.y = - 250;
                             ((UIView*)itemToRemove).frame = viewFrame;
                             
                             //Removing time & round
                             UIView* temItemTimeTextObj = [self.timelineTimeArray objectAtIndex:gestureIndex];
                             [temItemTimeTextObj removeFromSuperview];
                             [self.timelineTimeArray removeObject:temItemTimeTextObj];
                             temItemTimeTextObj = nil;
                             
                             temItemTimeTextObj = [self.timelineBubbleArray objectAtIndex:gestureIndex];
                             [temItemTimeTextObj removeFromSuperview];
                             [self.timelineBubbleArray removeObject:temItemTimeTextObj];
                             temItemTimeTextObj = nil;
                             
                             
                         } completion:^(BOOL finished) {
                             [((UIView*)itemToRemove) removeFromSuperview];
                             
                             //Re-ordering Views
                             int itemIndex = 0;
                             NSArray* temViewArray = [allSlidesView copy];
                             for (UIView * view in temViewArray) {
                                 if (view.tag >= gestureIndex) {
                                     [UIView animateWithDuration:0.1
                                                           delay:0.0
                                                         options:UIViewAnimationOptionCurveEaseOut
                                                      animations:^{
                                                          
                                                          [allSlidesView  replaceObjectAtIndex:itemIndex
                                                                                    withObject:[self reloadSlideViewForIndex:view.tag - 1
                                                                                                                    mainView:[temViewArray objectAtIndex:itemIndex]]];
                                                          
                                                      } completion:^(BOOL finished) {
                                                      }];
                                 }
                                 itemIndex = itemIndex + 1;
                             }
                             
                             //Resetting plus button
//                             if (allSlidesView.count == 0) {
//                                 [self addSlideButtonAtIndex:0];
//                             }else{
                                 btnPlusSlide.tag = allSlidesView.count;
                                btnPlusSlide.frame = [self frameForPossitionPlusButton:btnPlusSlide.tag];
                                viewPreviewScrollSlide.view.frame = [self frameForPreviewSlide:btnPlusSlide.tag];
                                [self setScrollViewContectSize];
                             [self refreshPreview:itemIndex withImages:self.listViewImages];
//                             }
                             [self addTimeLineView: (spaceBetweenSlide + btnPlusSlide.frame.size.width)];
                         }];
        [self.slidesScrollViewDelegate slidesScrollView:self didRemovedAtIndexPath:gestureIndex];
    }
    
}

- (void)buttonDrag:(UIButton *)sender
{
//    NSLog(@"buttonDrag");
    [sender removeTarget:nil action:nil forControlEvents:UIControlEventTouchUpInside];
//    [sender addTarget:self action:@selector(clickedOnSlide:) forControlEvents:UIControlEventTouchUpInside];
}
- (void)buttonDragExit:(UIButton *)sender
{
//    NSLog(@"buttonDragExit");
    [sender addTarget:self action:@selector(clickedOnSlide:) forControlEvents:UIControlEventTouchUpInside];
}
//- (void)clickedOnSlide:(UIButton *)sender
//{
////    UIView *view = sender.superview;
//
//        UIView *view = sender;
//    [self.slidesScrollViewDelegate slidesScrollView:self didSelectAtIndexPath:sender.tag withView:view];
//}
- (void)clickedOnSlide:(UITapGestureRecognizer *)sender
{
    if (self.isStillSaving)
        return;
    
        UIView *view = sender.view;
    
//    UIView *view = sender;
    [self.slidesScrollViewDelegate slidesScrollView:self didSelectAtIndexPath:view.tag withView:view];
}

- (void)setAddButtonFrame:(UIButton *)sender ButtonIndex:(int)btnIndex
{
    
    sender.frame = [self frameForPossition:sender.tag];
    
    NSLog(@"sender count = %ld",(long)sender.tag);
    
    if (btnIndex == SLIDE_MAXCOUNT)
    {
        [btnPlusSlide removeFromSuperview];
    }
    else
    {
        [self setScrollViewContectSize];
    }
}

- (void)btnAddSlideTap:(UIButton *)sender
{
    if (self.isStillSaving)
        return;
    
    NSLog(@"sender count = %ld",(long)sender.tag);
    
    [self.slidesScrollViewDelegate slidesScrollView:self didSelectAddButtonAtIndex:sender.tag withView:sender];

    sender.tag = sender.tag + 1;
    
    sender.frame = [self frameForPossitionPlusButton:sender.tag];
    viewPreviewScrollSlide.view.frame = [self frameForPreviewSlide:sender.tag + 1];
    
    NSLog(@"sender count = %ld",(long)sender.tag);
    
    if (sender.tag == SLIDE_MAXCOUNT)
    {
        [btnPlusSlide removeFromSuperview];
    }
    else
    {
        [self setScrollViewContectSize];
    }
}

- (void)pushAddSlideTap:(UIButton *)sender animation:(BOOL)isPushWithAnimation
{
    if (self.isStillSaving)
        return;
    
    NSLog(@"sender count = %ld",(long)sender.tag);
    
    [self.slidesScrollViewDelegate slidesScrollView:self didSelectAddButtonAtIndex:sender.tag withView:sender pusWithAnimation:NO];
    
    sender.tag = sender.tag + 1;
    sender.frame = [self frameForPossitionPlusButton:sender.tag];
    viewPreviewScrollSlide.view.frame = [self frameForPreviewSlide:sender.tag + 1];
    
    [self setContentOffset:CGPointMake(sender.frame.origin.x,sender.frame.origin.y) animated:YES];
    
    NSLog(@"sender count = %ld",(long)sender.tag);
    
    if (sender.tag == SLIDE_MAXCOUNT)
    {
        [btnPlusSlide removeFromSuperview];
    }
    else
    {
        [self setScrollViewContectSize];
    }
}

-(UIImage*)getImageFile:(NSString*)fileName{
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *filePath = [documentsDirectory stringByAppendingPathComponent:fileName];
    UIImage* imgFinal = [UIImage imageWithContentsOfFile:filePath];
    
    return imgFinal;
}

@end
