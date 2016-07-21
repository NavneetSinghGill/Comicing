//
//  ComicSlidePreview.m
//  ComicBook
//
//  Created by ADNAN THATHIYA on 17/07/16.
//  Copyright © 2016 ADNAN THATHIYA. All rights reserved.
//

#import "ComicSlidePreview.h"
#import "ComicBookVC.h"
#import "AppConstants.h"

@interface ComicSlidePreview()<BookChangeDelegate>
{
    int TagRecord;
    ComicBookVC *comic;
}

//@property (strong, nonatomic) IBOutlet UIView *view;
@property (weak, nonatomic) IBOutlet UIView *view3Slide;
@property (weak, nonatomic) IBOutlet UIView *view2Slide;
@property (weak, nonatomic) IBOutlet UIView *view1Slide;
@property (weak, nonatomic) IBOutlet UIView *view4Slide;
@property (weak, nonatomic) IBOutlet UIView *viewComic;

//3SlideImageViews
@property (weak, nonatomic) IBOutlet UIImageView *imgv3Slide1;
@property (weak, nonatomic) IBOutlet UIImageView *imgv3Slide2;
@property (weak, nonatomic) IBOutlet UIImageView *imgv3Slide3;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *constTrailingbackground;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *constBottom3Slide;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *constWidth3Slide;

//2SlideImageViews
@property (weak, nonatomic) IBOutlet UIImageView *imgv2Slide1;
@property (weak, nonatomic) IBOutlet UIImageView *imgv2Slide2;

//1SlideImageViews
@property (weak, nonatomic) IBOutlet UIImageView *imgv1Slide;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *constHeight1Slide;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *constWidth1Slide;

//4SlideImageViews
@property (weak, nonatomic) IBOutlet UIImageView *imgv4Slide1;
@property (weak, nonatomic) IBOutlet UIImageView *imgv4Slide2;
@property (weak, nonatomic) IBOutlet UIImageView *imgv4Slide3;
@property (weak, nonatomic) IBOutlet UIImageView *imgv4Slide4;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *constWidth4Slides;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *constHeight4Slides;

// Morethan 4 Slides
@property (weak, nonatomic) IBOutlet UIView *viewComicBook;

@property (strong, nonatomic) NSArray *slides;

@end

@implementation ComicSlidePreview

@synthesize view3Slide, view2Slide, slides, view1Slide, view4Slide;
@synthesize imgv3Slide1, imgv3Slide2, imgv3Slide3;
@synthesize imgv2Slide1, imgv2Slide2;
@synthesize imgv1Slide;
@synthesize imgv4Slide1, imgv4Slide2, imgv4Slide3, imgv4Slide4;
@synthesize viewComicBook;
@synthesize constWidth4Slides, constHeight4Slides;
@synthesize constWidth1Slide, constHeight1Slide;

- (void)viewDidLoad {
    
    [super viewDidLoad];
}
-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}


-(id)initWithFrame:(CGRect)frame
{
    self = [super initWithNibName:@"ComicSlidePreview" bundle:nil];
    if (self) {
        self.view.frame = frame;
        // Do whatever nonsense you'd like to do in init.
    }
    return self;
//    
//    self = [super initWithFrame:frame];
//    
//    if(self)
//    {
//        //Load from xib
//        [[NSBundle mainBundle] loadNibNamed:@"ComicSlidePreview" owner:self options:nil];
//        self.view.frame = self.frame;
//        [self addSubview:self.view];
//        
//        [self setup];
//    }
//    
//    return self;
}


- (void)setup
{
    [self hideAllPreviewViews];
}

- (void)setupComicSlidePreview:(NSArray *)slidesImages
{
    [self setup];
    slides = slidesImages;
    
    if (slides.count == 1)
    {
        [self setup1SlideComicPreview];
    }
    else if (slides.count == 2)
    {
        [self setup2SlideComicPreview];
    }
    else if (slides.count == 3)
    {
        [self setup3SlideComicPreview];
    }
    else if (slides.count == 4)
    {
        [self setup4SlideComicPreview];
    }
    else
    {
        [self setupComicBook];
    }
}

- (void)hideAllPreviewViews
{
    view3Slide.hidden = YES;
    view2Slide.hidden = YES;
    view1Slide.hidden = YES;
    view4Slide.hidden = YES;
    _viewComic.hidden = YES;
}

- (void)setup3SlideComicPreview
{
    if (IS_IPHONE_6P)
    {
        self.constTrailingbackground.constant = 0;
        self.constBottom3Slide.constant = 28;
        self.constWidth3Slide.constant = 0;

    }
    else if (IS_IPHONE_6)
    {
        self.constTrailingbackground.constant = 7;

        self.constBottom3Slide.constant = 25;
        self.constWidth3Slide.constant = -4;

    }
    else if (IS_IPHONE_5)
    {
        self.constBottom3Slide.constant = 22;
        self.constWidth3Slide.constant = -3;

    }
    else
    {
        self.constBottom3Slide.constant = 22;
        self.constWidth3Slide.constant = -3;
    }
    
    
    view3Slide.hidden = NO;
    
    imgv3Slide1.image = slides[0];
    imgv3Slide2.image = slides[1];
    imgv3Slide3.image = slides[2];
    
    imgv3Slide1.layer.borderColor = [UIColor blackColor].CGColor;
    imgv3Slide1.layer.borderWidth = 2;
    
    imgv3Slide2.layer.borderColor = [UIColor blackColor].CGColor;
    imgv3Slide2.layer.borderWidth = 2;
    
    imgv3Slide3.layer.borderColor = [UIColor blackColor].CGColor;
    imgv3Slide3.layer.borderWidth = 2;
    
    
}

- (void)setup2SlideComicPreview
{
    view2Slide.hidden = NO;

    imgv2Slide1.image = slides[0];
    imgv2Slide2.image = slides[1];
    
    imgv2Slide1.layer.borderColor = [UIColor blackColor].CGColor;
    imgv2Slide1.layer.borderWidth = 2;
    
    imgv2Slide2.layer.borderColor = [UIColor blackColor].CGColor;
    imgv2Slide2.layer.borderWidth = 2;

}

- (void)setup1SlideComicPreview
{
    if (IS_IPHONE_6P)
    {
        self.constWidth1Slide.constant = -2;
        constHeight1Slide.constant = 0;
    }
    else if (IS_IPHONE_6)
    {
        self.constWidth1Slide.constant = -9;
        constHeight1Slide.constant = -5;
    }
    else if (IS_IPHONE_5)
    {
        self.constWidth1Slide.constant = -9;
        constHeight1Slide.constant = -5;
    }
    else
    {
        self.constWidth1Slide.constant = -4;
        constHeight1Slide.constant = -3;
        
    }

    
    view1Slide.hidden = NO;
    
    imgv1Slide.image = slides[0];
    
    imgv1Slide.layer.borderColor = [UIColor blackColor].CGColor;
    imgv1Slide.layer.borderWidth = 2;

}

- (void)setup4SlideComicPreview
{
    if (IS_IPHONE_6P)
    {
        self.constWidth4Slides.constant = -2;
        constHeight4Slides.constant = 0;
    }
    else if (IS_IPHONE_6)
    {
        self.constWidth4Slides.constant = -3;
        constHeight4Slides.constant = -2;
    }
    else if (IS_IPHONE_5)
    {
        self.constWidth4Slides.constant = -4;
        constHeight4Slides.constant = -3;
    }
    else
    {
        self.constWidth4Slides.constant = -4;
        constHeight4Slides.constant = -3;

    }

    
    view4Slide.hidden = NO;
    
    imgv4Slide1.layer.borderColor = [UIColor blackColor].CGColor;
    imgv4Slide1.layer.borderWidth = 2;

    imgv4Slide2.layer.borderColor = [UIColor blackColor].CGColor;
    imgv4Slide2.layer.borderWidth = 2;
    
    imgv4Slide3.layer.borderColor = [UIColor blackColor].CGColor;
    imgv4Slide3.layer.borderWidth = 2;
    
    imgv4Slide4.layer.borderColor = [UIColor blackColor].CGColor;
    imgv4Slide4.layer.borderWidth = 2;
    
    imgv4Slide1.image = slides[0];
    imgv4Slide2.image = slides[1];
    imgv4Slide3.image = slides[2];
    imgv4Slide4.image = slides[3];
}

- (void)setupComicBook
{
    _viewComic.hidden = NO;
    
    UIStoryboard *sb = [UIStoryboard storyboardWithName:@"Main_MainPage" bundle:nil];

    comic = [sb instantiateViewControllerWithIdentifier:@"ComicBookVC"];
    comic.delegate = self;
    comic.Tag = 0;
    comic.isSlidesContainImages = YES;
    comic.view.frame = CGRectMake(0, 0, CGRectGetWidth(viewComicBook.frame), CGRectGetHeight(viewComicBook.frame));
    
    [viewComicBook addSubview:comic.view];
    
    // vishnu
//    NSMutableArray *slidesArray = [[NSMutableArray alloc] init];
  //  [slidesArray addObjectsFromArray:comicBook.slides];
    
    // To repeat the cover image again on index page as the first slide.
//    if(slides.count > 1)
//    {
//        [slidesArray insertObject:[slidesArray firstObject] atIndex:1];
//        
//        // Adding a sample slide to array to maintain the logic
//        Slides *slides = [Slides new];
//        [slidesArray insertObject:slides atIndex:1];
//        
//        // vishnuvardhan logic for the second page
//        if(6 < slidesArray.count)
//        {
//            [slidesArray insertObject:[slidesArray firstObject] atIndex:0];
//        }
//    }
    
    [comic setSlidesArray:slides];
    [comic setupBook];
}

#pragma mark - BookChangeDelegate Methods
-(void)bookChanged:(int)Tag
{
    if(TagRecord!=Tag)
    {
        [comic ResetBook];
    }
    
    TagRecord=Tag;
}

@end
