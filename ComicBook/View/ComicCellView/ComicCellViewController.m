//
//  ComicCellViewController.m
//  ComicBook
//
//  Created by ADNAN THATHIYA on 06/10/16.
//  Copyright © 2016 ADNAN THATHIYA. All rights reserved.
//

#import "ComicCellViewController.h"
#import "ComicBookVC.h"
#import "AppConstants.h"
#import "ComicImage.h"
#import "Slides.h"
#import "UIImageView+WebCache.h"
#import "Global.h"

@interface ComicCellViewController ()<BookChangeDelegate>
{
    int TagRecord;
    ComicBookVC *comic;
    CGSize wideSlideSize;
    CGSize normalSlideSize_big;
    CGSize normalSlideSize_small;
    int currentIndex;
}


@property (weak, nonatomic) IBOutlet UIView *viewComic;
@property (weak, nonatomic) IBOutlet UIView *viewComicBook;



@property (strong, nonatomic) NSArray *slides;

// New ComicImage Layout
@property (strong, nonatomic) NSMutableArray *comicImages;
@property(nonatomic,assign) CGRect currentSlideFrame;
@property (nonatomic, strong) UIView * viewSlides;

@property (nonatomic) CGFloat totalHeight;
@property (nonatomic) CGFloat paddingX;
@property (nonatomic) CGFloat paddingY;


@end

@implementation ComicCellViewController
@synthesize slides, viewComicBook, viewComic, viewWhiteBorder;
@synthesize comicImages, currentSlideFrame, viewSlides, totalHeight, paddingX, paddingY;

- (void)viewDidLoad
{
    [super viewDidLoad];
}

-(id)initWithFrame:(CGRect)frame
{
    self = [super initWithNibName:@"ComicCellViewController" bundle:nil];
    if (self)
    {
        self.view.frame = frame;
        
        paddingX = 8;
        paddingY = 6;
        // Do whatever nonsense you'd like to do in init.
    }
    return self;
}

- (void)setupComicSlidePreview:(NSArray *)slidesImages
{
    slides = slidesImages;
    
    currentIndex = 0;
    
    self.currentSlideFrame = CGRectZero;
    
    self.viewSlides = [[UIView alloc] initWithFrame:CGRectZero];
    self.viewWhiteBorder = [[UIView alloc] initWithFrame:CGRectZero];
    
    wideSlideSize = CGSizeMake(self.view.frame.size.width + paddingX, WIDE_SLIDE_HEIGHT_CELL);
    normalSlideSize_big = CGSizeMake(self.view.frame.size.width+ paddingX,TALL_BIG_SLIDE_HEIGHT_CELL);
    normalSlideSize_small = CGSizeMake(self.view.frame.size.width/2 , TALL_SMALL_SLIDE_HEIGHT_CELL);
    
    [self createComicImages];
    [self prepareSlides];
    
    self.viewSlides.frame = CGRectMake(paddingX,0,self.currentSlideFrame.size.width + paddingX,totalHeight + paddingY);
    
    self.viewWhiteBorder.frame = CGRectMake(0, 0, CGRectGetWidth(self.viewSlides.frame) + paddingX + paddingX, totalHeight + paddingY);
    
    self.viewSlides.backgroundColor = [UIColor whiteColor];
    
    [self.viewWhiteBorder addSubview:self.viewSlides];
    
    self.viewWhiteBorder.backgroundColor = [UIColor whiteColor];
    
    [self.view addSubview:self.viewWhiteBorder];
    
    CGRect viewFrame = self.viewWhiteBorder.frame;
    
    self.view.frame = CGRectMake(0, 0, CGRectGetWidth(self.view.frame), CGRectGetHeight(viewFrame));
    
    self.viewWhiteBorder.center = self.view.center;
    self.viewWhiteBorder.tag = 11111;
    
    self.view.backgroundColor = [UIColor yellowColor];
    
    [self.delegate didFrameChange:self withFrame:self.viewWhiteBorder.frame];
}

#pragma mark - ComicImage Layout methods
- (void)createComicImages
{
    comicImages = [[NSMutableArray alloc] init];
    
    NSLog(@"slides Array : %@",slides);
    
    for(Slides *slide in slides)
    {
        ComicImage *obj = [[ComicImage alloc] init];

        obj.imageURL = slide.slideImage;
        
        if( [slide.slideStatus isEqualToString:@"1"])
        {
            obj.comicImageType = WIDE;
        }
        else
        {
            obj.comicImageType = NORMAL;
        }
        
        [comicImages addObject:obj];
    }
    
    
    
//    for (UIImage *img in slides)
//    {
//        ComicImage *obj = [[ComicImage alloc] init];
//        obj.image = img;
//        
//        if (img.size.width > img.size.height)
//        {
//            // wide
//            obj.comicImageType = WIDE;
//        }
//        else
//        {
//            // tall
//            obj.comicImageType = NORMAL;
//        }
//        
//        [comicImages addObject:obj];
//    }
}

-(void)prepareSlides
{
    
    [self addSlide:currentIndex];
    
    if ([self isNextSlideAvailble:currentIndex]) {
        [self prepareSlides];
    }
    
    //Add default Slide
}

-(void)addSlide:(int)indexValue
{
    if([comicImages count] == 0)
        return;
    
    if (indexValue == 0)
        self.currentSlideFrame = CGRectZero;
    
    if (((ComicImage*)comicImages[indexValue]).comicImageType == WIDE)
    {
        ComicImage* comicImage = (ComicImage*)comicImages[indexValue];
        [self.viewSlides addSubview:[self createWideSlide:comicImage.imageURL]];
    }
    else if (((ComicImage*)comicImages[indexValue]).comicImageType == NORMAL &&
             [self isNextSlideAvailble:indexValue + 1]  &&
             ((ComicImage*)comicImages[indexValue + 1]).comicImageType == NORMAL)
    {
        
        ComicImage* comicImage1 = (ComicImage*)comicImages[indexValue];
        ComicImage* comicImage2 = (ComicImage*)comicImages[indexValue + 1];
        
        [self.viewSlides addSubview:[self createSplitSlide:comicImage1.imageURL
                                                    image2:comicImage2.imageURL]];
        
        currentIndex = currentIndex + 1;
    }
    else if (((ComicImage*)comicImages[indexValue]).comicImageType == NORMAL &&
             [self isNextSlideAvailble:indexValue + 1]  &&
             ((ComicImage*)comicImages[indexValue + 1]).comicImageType == WIDE)
    {
        
        ComicImage* comicImage = (ComicImage*)comicImages[indexValue];
        [self.viewSlides addSubview:[self createNormalSlide:comicImage.imageURL]];
    }
    else if (((ComicImage*)comicImages[indexValue]).comicImageType == NORMAL)
    {
        
        ComicImage* comicImage = (ComicImage*)comicImages[indexValue];
        [self.viewSlides addSubview:[self createNormalSlide:comicImage.imageURL]];
        
    }
    
    currentIndex = currentIndex + 1;
}


- (BOOL)isNextSlideAvailble:(int)indexValue
{
    if([comicImages count] > indexValue)
        return YES;
    
    return NO;
}

#pragma mark - ComicSlide Different Layout Methods
-(UIImageView*)createWideSlide :(NSString*)imgWideSilde
{
    UIImageView* imgView = [[UIImageView alloc] initWithFrame:CGRectMake(self.currentSlideFrame.origin.x,
                                                                         self.currentSlideFrame.origin.y + paddingY,
                                                                         wideSlideSize.width, wideSlideSize.height)];
 //   imgView.image = imgWideSilde;
    
    totalHeight = totalHeight + wideSlideSize.height + paddingY;
    
    self.currentSlideFrame = CGRectMake(self.currentSlideFrame.origin.x,
                                        (self.currentSlideFrame.origin.y + wideSlideSize.height + paddingY),
                                        wideSlideSize.width, wideSlideSize.height);
    
    
    [imgView sd_setImageWithURL:[NSURL URLWithString:imgWideSilde]
                     placeholderImage:GlobalObject.placeholder_comic
                              options:SDWebImageHighPriority
                            completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL)
    {

                            }];
    
    
    
    
    
    return imgView;
}

-(UIImageView*)createNormalSlide :(NSString*)imgWideSilde{
    
    UIImageView* imgView = [[UIImageView alloc] initWithFrame:CGRectMake(self.currentSlideFrame.origin.x,
                                                                         self.currentSlideFrame.origin.y + paddingY,
                                                                         normalSlideSize_big.width, normalSlideSize_big.height)];
  //  imgView.image =imgWideSilde;
    
    [imgView sd_setImageWithURL:[NSURL URLWithString:imgWideSilde]
               placeholderImage:GlobalObject.placeholder_comic
                        options:SDWebImageHighPriority
                      completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
                          

                      }];

    
    totalHeight = totalHeight + normalSlideSize_big.height + paddingY;
    
    
    self.currentSlideFrame = CGRectMake(self.currentSlideFrame.origin.x,
                                        (self.currentSlideFrame.origin.y + normalSlideSize_big.height + paddingY),
                                        normalSlideSize_big.width, normalSlideSize_big.height);
    
    return imgView;
}

-(UIView*)createSplitSlide :(NSString*)imgWideSilde1 image2:(NSString*)imgWideSilde2{
    
    UIView* viewHolder = [[UIView alloc] initWithFrame:CGRectMake(self.currentSlideFrame.origin.x,
                                                                  self.currentSlideFrame.origin.y,
                                                                  normalSlideSize_big.width,
                                                                  normalSlideSize_small.height)];
    
    
    UIImageView* imgView_1 = [[UIImageView alloc] initWithFrame:CGRectMake(0,paddingY,
                                                                           normalSlideSize_small.width, normalSlideSize_small.height)];
 //   imgView_1.image =imgWideSilde1;
    [imgView_1 sd_setImageWithURL:[NSURL URLWithString:imgWideSilde1]
               placeholderImage:GlobalObject.placeholder_comic
                        options:SDWebImageHighPriority
                      completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {


                      }];

    
    UIImageView* imgView_2 = [[UIImageView alloc] initWithFrame:CGRectMake(normalSlideSize_small.width + paddingX,paddingY,
                                                                           normalSlideSize_small.width, normalSlideSize_small.height)];

    [imgView_2 sd_setImageWithURL:[NSURL URLWithString:imgWideSilde2]
                 placeholderImage:GlobalObject.placeholder_comic
                          options:SDWebImageHighPriority
                        completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
                            


                        }];

    
    [viewHolder addSubview:imgView_1];
    [viewHolder addSubview:imgView_2];
    
    totalHeight = totalHeight + normalSlideSize_small.height + paddingY;
    
    
    self.currentSlideFrame = CGRectMake(self.currentSlideFrame.origin.x,
                                        (self.currentSlideFrame.origin.y + viewHolder.frame.size.height + paddingY),
                                        wideSlideSize.width, wideSlideSize.height);
    return viewHolder;
}

// ******************************************************************

- (void)setupComicBook
{
    
    UIStoryboard *sb = [UIStoryboard storyboardWithName:@"Main_MainPage" bundle:nil];
    
    comic = [sb instantiateViewControllerWithIdentifier:@"ComicBookVC"];
    comic.delegate = self;
    comic.Tag = 0;
    comic.isSlidesContainImages = NO;
    comic.view.frame = CGRectMake(0, 0, CGRectGetWidth(viewComicBook.frame), CGRectGetHeight(viewComicBook.frame));
    
    [viewComicBook addSubview:comic.view];
    
    [comic setImages:comicImages];
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
