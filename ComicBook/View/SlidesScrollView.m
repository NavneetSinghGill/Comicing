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

const CGSize viewSizeForIPhone5            = {195, 330};//{214, 378};
const CGSize viewSizeForIPhone6            = {225, 385};//{250, 444};
const CGSize viewSizeForIPhone6Plus        = {250, 425};//{300, 650};

const CGSize viewPreviewSlideSizeForIPhone5            = {195, 330};//{214, 378};
const CGSize viewPreviewSlideSizeForIPhone6            = {225, 385};//{250, 444};
const CGSize viewPreviewSlideSizeForIPhone6Plus        = {250, 425};//{300, 650};

const NSInteger timlineViewTag    = 100;
const NSInteger timlineTextTag    = 200;

const NSInteger viewsInOneRow    = SLIDE_MAXCOUNT + 1;

const NSInteger spaceBetweenSlide = 20;
//const NSInteger spaceFromTop = 140;

@interface SlidesScrollView()

@property (nonatomic) CGSize viewSize;
@property (nonatomic) CGSize viewPreviewSize;

@property (strong,nonatomic) UIImageView *arrowImage;

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

- (CGFloat)getSpaceFromTop
{

    if (IS_IPHONE_5)
    {
        return 145;
    }
    else if (IS_IPHONE_6)
    {
        return 160;

    }
    else if (IS_IPHONE_6P)
    {
        return 190;

    }
    else
    {
        return 145;
    }
}

- (CGRect)frameForPreviewSlide:(NSInteger)index
{
//    NSInteger columnCount = index % viewsInOneRow;
    NSInteger rowCount    = index / viewsInOneRow;
    
 //   CGFloat x = ( spaceBetweenSlide * (columnCount + 1)) + (columnCount * viewSize.width);
    CGFloat y = ( [self getSpaceFromTop] * (rowCount +  1)) + (rowCount * viewSize.width);
    
    return CGRectMake(CGRectGetMaxX(self.arrowImage.frame) + 50, y + 20, viewSize.width + 20, viewSize.height);
}

- (CGRect)frameForPreview3Slide:(NSInteger)index
{
    return CGRectMake(CGRectGetMaxX(self.arrowImage.frame) + 50, 0, viewSize.width + 20, self.frame.size.height - 80);
}

- (CGRect)frameForPreview4Slide:(NSInteger)index
{
    NSInteger rowCount    = index / viewsInOneRow;
    
    CGFloat y = ( [self getSpaceFromTop] * (rowCount +  1)) + (rowCount * viewSize.width);
    
    return CGRectMake(CGRectGetMaxX(self.arrowImage.frame) + 50 , y, viewSize.width, viewSize.height);

}

- (CGRect)frameForPossition:(NSInteger)index
{
    NSInteger columnCount = index % viewsInOneRow;
    NSInteger rowCount    = index / viewsInOneRow;
    
    CGFloat x = ( spaceBetweenSlide * (columnCount + 1)) + (columnCount * viewSize.width);
    CGFloat y = ( [self getSpaceFromTop] * (rowCount +  1)) + (rowCount * viewSize.width);
    
    return CGRectMake(x, y, viewSize.width, viewSize.height);
}

- (CGRect)frameForPossitionPlusButton:(NSInteger)index
{
    NSInteger columnCount = index % viewsInOneRow;
    NSInteger rowCount    = index / viewsInOneRow;
    
    CGFloat x = ( spaceBetweenSlide * (columnCount + 1)) + (columnCount * viewSize.width) - 20;
    CGFloat y = ( [self getSpaceFromTop] * (rowCount +  1)) + (rowCount * viewSize.width) - 20;
    
    /*//-------------------
    if (index > 1)
    {
        CGRect rect = textField.frame;
        rect.size.width = viewSize.width*1.75;//
        
        textField.frame = rect;
        mComicTitle.frame = rect;
    }
    else
    {
        CGRect rect = textField.frame;
        rect.size.width = viewSize.width;
        
        textField.frame = rect;
        mComicTitle.frame = rect;
        
    }
    //-------------------*/
    
    return CGRectMake(x, y, 20, 20);
}

- (CGRect)frmaeForArrowImage:(NSInteger)index
{
 //   NSInteger columnCount = index % viewsInOneRow;
    NSInteger rowCount    = index / viewsInOneRow;
    
 //   CGFloat x = ( spaceBetweenSlide * (columnCount + 1)) + (columnCount * viewSize.width) - 10;
    CGFloat y = ( [self getSpaceFromTop] * (rowCount +  1)) + (rowCount * viewSize.width) - 10;
    
    CGFloat middlePoint = y / 2 + (viewSize.height / 2);
    
    return CGRectMake(CGRectGetMinX(btnPlusSlide.frame) + 70, middlePoint + 10, 45 , 90);
}

- (void)setScrollViewContectSize
{
    self.contentSize = CGSizeMake(CGRectGetMaxX(viewPreviewScrollSlide.view.frame) + spaceBetweenSlide , CGRectGetHeight(viewPreviewScrollSlide.view.frame));
}

- (void)setScrollViewContectSizeForEmptySlide
{
    self.contentSize = CGSizeMake(CGRectGetMaxX(btnPlusSlide.frame) + spaceBetweenSlide , CGRectGetHeight(btnPlusSlide.frame));
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
    subView.frame = [self frameForPossition:index];
    subView.tag = index;
    
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
    if ([self viewWithTag:((index + 1) * timlineTextTag)]) {
        [self viewWithTag:((index + 1) * timlineTextTag)].frame = CGRectMake(((subView.frame.size.width/2)  + subView.frame.origin.x ) - 50,
                                                                             subView.frame.origin.y - 80, 100, 20);
    }
    [self viewWithTag:((index + 1) * timlineTextTag)].tag =  index * timlineTextTag;
    
    return subView;
}

- (CGFloat)listViewTitleFontSize
{
    if(IS_IPHONE_5)
    {
        return 25;
    }
    else if(IS_IPHONE_6)
    {
       return 29;
    }
    else if(IS_IPHONE_6P)
    {
        return 31;
    }
    
    return 27;
}


UITextField* textField;
UILabel *mComicTitle;

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

    //Add time line Bubble
    UIView* viewRound = [[UIView alloc] initWithFrame:CGRectMake(((view.frame.size.width/2) + view.frame.origin.x ) - spaceBetweenSlide ,
                                                                 view.frame.origin.y - 50, 27, 27)];
    viewRound.layer.cornerRadius = viewRound.frame.size.width/2;
    viewRound.layer.masksToBounds = YES;
    
    //dinesh
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"h.mm a"];
    NSDate *orignalDate   =  [dateFormatter dateFromString:comicSlide.timelineString];
    
    [dateFormatter setDateFormat:@"h:mm a"];
    NSString *finalString = [dateFormatter stringFromDate:orignalDate];
    
    
    //Add time line text
    UILabel* lblTimeText = [[UILabel alloc] initWithFrame:CGRectMake(view.frame.origin.x, view.frame.origin.y - [self getSpaceFromTop], view.frame.size.width, 20)];
    lblTimeText.text = finalString;
    lblTimeText.textColor = [UIColor colorWithHexStr:@"26aae1"];//Dinesh : Ref : Bug list : line 307
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
    
    if (index == 0) {
        
        textField = [[UITextField alloc] initWithFrame:CGRectMake(view.frame.origin.x,
                                                                                  view.frame.origin.y - 90 ,
                                                                                  view.frame.size.width, 40)];
        [textField setBackgroundColor:[UIColor clearColor]];
        [textField setBorderStyle:UITextBorderStyleNone];
        
        textField.attributedPlaceholder = [[NSAttributedString alloc] initWithString:@"Comic title"
                                                                             attributes:@{
                                                                                          NSForegroundColorAttributeName:[UIColor colorWithHexStr:@"fdfdfd"],
                                                                                          NSFontAttributeName:[UIFont fontWithName:@"Arial-BoldMT" size:[self listViewTitleFontSize]]
                                                                                          }];
        
        textField.textColor = [UIColor whiteColor];
        textField.delegate = self;
        [textField setFont:[UIFont fontWithName:@"Arial-BoldMT" size:[self listViewTitleFontSize]]];
        textField.returnKeyType = UIReturnKeyDone;
        
        if (self.slideTitleArray == nil) {
            self.slideTitleArray = [[NSMutableArray alloc] init];
        }
        
        [self.slideTitleArray addObject:textField];
        
        
        //DUMMY LABEL
        mComicTitle = [[UILabel alloc] init];
        mComicTitle.lineBreakMode = NSLineBreakByCharWrapping;
        [mComicTitle setFrame:textField.frame];
        [mComicTitle setHidden:NO];
        [mComicTitle setNumberOfLines:2];
        [mComicTitle setTextColor:[UIColor whiteColor]];
        [mComicTitle setFont:[UIFont fontWithName:@"Arial-BoldMT" size:[self listViewTitleFontSize]]];
        [self addSubview:mComicTitle];
        
        if (comicSlide.titleString && comicSlide.titleString.length != 0) {
            textField.text = comicSlide.titleString;
            mComicTitle.text = comicSlide.titleString;
        }
        else
        {
            mComicTitle.text = textField.placeholder;
        }
        
        [textField setHidden:YES];
        [self addSubview:textField];
        
        CGRect rect = textField.frame;
        rect.size.width = viewSize.width*1.75;//
        
        textField.frame = rect;
        mComicTitle.frame = rect;

        
        //add tap gesture
        UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(didtapOnTitle:)];
        [tapGesture setNumberOfTapsRequired:1];
        [mComicTitle setUserInteractionEnabled:YES];
        [mComicTitle addGestureRecognizer:tapGesture];

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

- (void)didtapOnTitle: (UIGestureRecognizer *)recogniser
{
    [mComicTitle setHidden:YES];
    [textField setHidden:NO];
    [textField becomeFirstResponder];
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
    [self addArrowImage:self.btnPlusSlide.tag];
    BOOL isAdd = NO;
    if (viewPreviewScrollSlide == nil)
    {
        viewPreviewScrollSlide = [[SlidePreviewScrollView alloc] init];
        isAdd = YES;
    }
    
    if (slides.count == 3)
    {
        viewPreviewScrollSlide.view.frame = [self frameForPreview3Slide:self.btnPlusSlide.tag];
    }
    else if (slides.count == 4)
    {
        viewPreviewScrollSlide.view.frame = [self frameForPreview4Slide:self.btnPlusSlide.tag];
    }
    else if (slides.count == 1)
    {
        viewPreviewScrollSlide.view.frame = [self frameForPreview4Slide:self.btnPlusSlide.tag];
    }
    else if (slides.count == 2)
    {
        viewPreviewScrollSlide.view.frame = [self frameForPreviewSlide:self.btnPlusSlide.tag];
    }
    else
    {
        viewPreviewScrollSlide.view.frame = [self frameForPreview4Slide:self.btnPlusSlide.tag];
    }
    
    viewPreviewScrollSlide.allSlideImages = slides;
    [viewPreviewScrollSlide setupBook];

    if (isAdd) {
        [self addSubview:viewPreviewScrollSlide.view];
    }
    
    [self.arrowImage setAlpha:1];
    [viewPreviewScrollSlide.view setAlpha:1];
    //Handle empty slide
    if ([slides count] == 0) {
        //fade in
        [UIView animateWithDuration:1.0f animations:^{
            [self.arrowImage setAlpha:0];
            [viewPreviewScrollSlide.view setAlpha:0];
        } completion:^(BOOL finished) {
        }];
        [self setScrollViewContectSizeForEmptySlide];
    }else{
     [self setScrollViewContectSize];
    }
}


-(void)addPlusButton :(NSInteger)index{
    btnPlusSlide = [[UIButton alloc] init];
    btnPlusSlide.frame = [self frameForPossitionPlusButton:index];
    
    
    [btnPlusSlide setImage:[UIImage imageNamed:@"AddCoimicSlide"] forState:UIControlStateNormal];
    
    [btnPlusSlide addTarget:self action:@selector(btnAddSlideTap:) forControlEvents:UIControlEventTouchUpInside];
    
    btnPlusSlide.tag = index;
    
    [self addSubview:btnPlusSlide];
    
}

- (void)addArrowImage:(NSInteger)index
{
    BOOL isAdd = NO;
    if (self.arrowImage == nil) {
        self.arrowImage = [[UIImageView alloc] init];
        isAdd = YES;
    }
    self.arrowImage.frame = [self frmaeForArrowImage:index];
    
    self.arrowImage.image = [UIImage imageNamed:@"forward"];
    
    self.arrowImage.contentMode = UIViewContentModeScaleAspectFit;
    
    if (isAdd) {
        [self addSubview:self.arrowImage];
    }
}

-(void)addTimeLineView
{
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

#pragma mark - UITextField deletegate

#define MAX_LENGTH 25

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    if ([string isEqualToString:@"\n"])
    {
        [textField resignFirstResponder];
        return NO;
    }
    
    if (textField.text.length >= MAX_LENGTH && range.length == 0)
    {
        return NO;
    }
    else
    {
        //[self handleBubbleText:textField];
        return YES;
    }
}

-(void)handleBubbleText:(UITextField*)textView{
    NSMutableParagraphStyle *paragraphStyle = NSMutableParagraphStyle.new;
    paragraphStyle.alignment                = NSTextAlignmentLeft;
    
    NSMutableAttributedString *attibute = [[NSMutableAttributedString alloc] initWithString:textView.text];
    
    [attibute addAttribute:NSParagraphStyleAttributeName value:paragraphStyle range:NSMakeRange(0, textView.text.length)];
    if (textView && ![textView.text isEqualToString:@""] && textView.text.length <= 10) {
        [attibute addAttribute:NSFontAttributeName
                         value:[UIFont fontWithName:@"ArialRoundedMTBold" size:24.0f]
                         range:NSMakeRange(0, textView.text.length)];
    }else{
        
        [attibute addAttribute:NSFontAttributeName
                         value:[UIFont fontWithName:@"ArialRoundedMTBold" size:16.0f]
                         range:NSMakeRange(0, textView.text.length)];
    }
    
    [textView setAttributedText:attibute];
    attibute = nil;
}

- (BOOL)textFieldShouldEndEditing:(UITextField *)textField
{
    [textField resignFirstResponder];
    [self.slidesScrollViewDelegate saveSlideTitle:textField.text slideIndex:0];
    return YES;
}

- (void)textFieldDidBeginEditing:(UITextField *)textField
{

    textField.attributedPlaceholder = [[NSAttributedString alloc] initWithString:@"Comic title"
                                                                      attributes:@{
                                                                                   NSForegroundColorAttributeName:[UIColor clearColor],
                                                                                   NSFontAttributeName:[UIFont fontWithName:@"Arial-BoldMT" size:[self listViewTitleFontSize]]
                                                                                   }];

}

-(void)textFieldDidEndEditing:(UITextField *)textField
{
    textField.attributedPlaceholder = [[NSAttributedString alloc] initWithString:@"Comic title"
                                                                      attributes:@{
                                                                                   NSForegroundColorAttributeName:[UIColor colorWithHexStr:@"fdfdfd"],
                                                                                   NSFontAttributeName:[UIFont fontWithName:@"Arial-BoldMT" size:[self listViewTitleFontSize]]
                                                                                   }];
    
    if (textField.text.length > 0)
    {
        mComicTitle.text = textField.text;
    }
    else
    {
        mComicTitle.text = textField.placeholder;
    }
    
    [mComicTitle setHidden:NO];
    [textField setHidden:YES];
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
    
    if (allSlidesView.count == 0)
    {
        [textField removeFromSuperview];
        [mComicTitle removeFromSuperview];
        
        textField = nil;
        mComicTitle = nil;
    }
    //-------------------
    
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
                             if ([allSlidesView count] == 0 && gestureIndex == 0) {
                                 id txtView = [self.slideTitleArray objectAtIndex:gestureIndex];
                                 if (txtView) {
                                     [txtView removeFromSuperview];
                                 }
                             }
                             
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
                             
                             btnPlusSlide.tag = allSlidesView.count;
                             btnPlusSlide.frame = [self frameForPossitionPlusButton:btnPlusSlide.tag];
                             viewPreviewScrollSlide.view.frame = [self frameForPreviewSlide:btnPlusSlide.tag];
                             [self setScrollViewContectSize];
                             [self refreshPreview:itemIndex withImages:self.listViewImages];
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
    
    //-------------------
    CGSize comicTitleSize = [mComicTitle.text sizeWithAttributes:@{NSFontAttributeName:[mComicTitle font]}];
    
    if (viewSize.width < comicTitleSize.width)
    {
        CGRect rect = textField.frame;
        rect.size.width = comicTitleSize.width;
        
        textField.frame = rect;
        mComicTitle.frame = rect;
    }
    //-------------------
    
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
