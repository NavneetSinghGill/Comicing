//
//  GlideScrollViewController.m
//  ComicMakingPage
//
//  Created by ADNAN THATHIYA on 23/01/16.
//  Copyright © 2016 ADNAN THATHIYA. All rights reserved.
//

#import "GlideScrollViewController.h"
#import "ComicItem.h"
#import "ComicNetworking.h"
#import "SendPageViewController.h"
#import "AppDelegate.h"

@interface GlideScrollViewController ()
//
//@property (weak, nonatomic) IBOutlet SlidesScrollView *scrvComicSlide;
//
//@property (nonatomic, strong) ZoomInteractiveTransition * transition;
//@property (strong, nonatomic) NSMutableArray *comicSlides;
//@property (strong, nonatomic) UIView *transitionView;
//
//@property (nonatomic) NSInteger newSlideIndex;
//@property (nonatomic) NSInteger editSlideIndex;
//@property (assign, nonatomic) BOOL isSendPageReload;
//
//@property (nonatomic,strong) NSManagedObjectContext* managedObjectContext;
//@property (nonatomic,strong) ComicPage *comicPageComicItems;
//@property (nonatomic, strong) ComicMakingViewController *parentViewController;
//

@property (strong, nonatomic) NSMutableArray *dirtySubviews;
@property (strong, nonatomic) NSMutableArray *dirtysubviewData;

@end



@implementation GlideScrollViewController

@synthesize scrvComicSlide,comicSlides;
@synthesize transition, transitionView;
@synthesize newSlideIndex,editSlideIndex,parentViewController;

#pragma mark - UIViewController Methods

- (void)viewDidLoad
{
//    [super viewDidLoad];

    [self prepareView];
    
    if (comicSlides == nil || comicSlides.count == 0) {
        [scrvComicSlide pushAddSlideTap:scrvComicSlide.btnAddSlide animation:NO];
    }
}
- (void)viewWillAppear:(BOOL)animated
{
    if(self.isSendPageReload) {
        [self prepareView];
    }
//    [self setComicSendButton];
    [super viewWillAppear:animated];
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (void)viewDidDisappear:(BOOL)animated
{

}

- (void)viewDidUnload {
    [super viewDidUnload];
}

#pragma mark - UIView Methods

-(void)setComicSendButton{
    if (comicSlides && [comicSlides count] > 0)
        [self.btnSend setEnabled:YES];
    else
        [self.btnSend setEnabled:NO];
}

- (void)prepareView
{
    
    scrvComicSlide.slidesScrollViewDelegate = self;
    
    transition = [[ZoomInteractiveTransition alloc] initWithNavigationController:self.navigationController];
    transition.handleEdgePanBackGesture = NO;
    
    transition.transitionDuration = 0.4;
    
//    comicSlides = [[[NSUserDefaults standardUserDefaults] objectForKey:@"comicSlides"] mutableCopy];
    
    comicSlides = [self getDataFromFile];
    
    if (comicSlides.count == 0)
    {
        comicSlides = [[NSMutableArray alloc] init];
        [scrvComicSlide addSlideButtonAtIndex:0];   
    }
    else
    {
        int count = 0;
        for (NSData *data in comicSlides)
        {
            ComicPage *comicPage = [NSKeyedUnarchiver unarchiveObjectWithData:data];
            [scrvComicSlide addViewAtIndex:count withComicSlide:comicPage];
            comicPage = nil;
            count++;
        }
        [scrvComicSlide addSlideButtonAtIndex:count];
        if (comicSlides.count == SLIDE_MAXCOUNT && scrvComicSlide.btnAddSlide) {
            [scrvComicSlide.btnAddSlide setHidden:YES];
            [scrvComicSlide.btnAddSlide removeFromSuperview];
            [scrvComicSlide setScrollViewContectSizeByLastIndex:count-1];
        }
        
    }
    [scrvComicSlide addTimeLineView];
}

#pragma mark - SlidesScrollViewDelegate Methods

- (void)slidesScrollView:(SlidesScrollView *)scrollview didSelectAtIndexPath:(NSInteger)index withView:(UIView *)view
{
    transitionView = view;
    editSlideIndex = index;
    newSlideIndex = (long)index;
    
//    self.comicPageComicItems = nil;
    if (self.comicPageComicItems == nil) {
        NSData *data = comicSlides[index];
        self.comicPageComicItems = [NSKeyedUnarchiver unarchiveObjectWithData:data];
    }
    
    if (self.comicPageComicItems.subviews.count == 0) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 5 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
            
            comicSlides = [self getDataFromFile];
            NSData *data = comicSlides[index];
            self.comicPageComicItems = [NSKeyedUnarchiver unarchiveObjectWithData:data];
            
            ComicMakingViewController *cmv = [self.storyboard instantiateViewControllerWithIdentifier:@"ComicMakingViewController"];
            
            cmv.comicPage = self.comicPageComicItems;
            
            [cmv setDelegate:self];
            cmv.isNewSlide = NO;
            [self.navigationController pushViewController:cmv animated:YES];
        });
    }else{
        ComicMakingViewController *cmv = [self.storyboard instantiateViewControllerWithIdentifier:@"ComicMakingViewController"];
        
        cmv.comicPage = self.comicPageComicItems;
        
        [cmv setDelegate:self];
        cmv.isNewSlide = NO;
        
        self.dirtysubviewData = self.comicPageComicItems.subviewData;
        self.dirtySubviews = self.comicPageComicItems.subviews;
        
        [self.navigationController pushViewController:cmv animated:YES];
    }
    
    NSLog(@"****** Open Slide ******");
}

- (void)slidesScrollView:(SlidesScrollView *)scrollview didSelectAddButtonAtIndex:(NSInteger)index withView:(UIView *)view
{
    [self slidesScrollView:scrollview didSelectAddButtonAtIndex:index withView:view pusWithAnimation:YES];
}

- (void)slidesScrollView:(SlidesScrollView *)scrollview didSelectAddButtonAtIndex:(NSInteger)index withView:(UIView *)view pusWithAnimation:(BOOL)isPushAnimation
{
    // add new slide
    transitionView = view;
    
    newSlideIndex = index;
    
    [scrvComicSlide addViewAtIndex:newSlideIndex withComicSlide:nil];
    
    ComicMakingViewController *cmv = [self.storyboard instantiateViewControllerWithIdentifier:@"ComicMakingViewController"];
    cmv.isNewSlide = YES;
    [cmv setDelegate:self];
    if (self.navigationController == nil) {
        
        self.navigation = [[UINavigationController alloc]initWithRootViewController:self];
        [self.navigation.navigationBar setHidden:YES];
        
//        [AppDelegate application].window.rootViewController = self.navigation;
        
        [self.navigation pushViewController:cmv animated:isPushAnimation];
    }else{
    [self.navigationController pushViewController:cmv animated:isPushAnimation];
    }
    
}

- (void)slidesScrollView:(SlidesScrollView *)scrollview didRemovedAtIndexPath:(NSInteger)index
{
    if (index >= 0) {
        [comicSlides removeObjectAtIndex:index];
        [self saveDataToFile:comicSlides];
//        [[NSUserDefaults standardUserDefaults] setObject:comicSlides forKey:@"comicSlides"];
//        [[NSUserDefaults standardUserDefaults] synchronize];
    }
    [self setComicSendButton];
}

- (void)returnAddedView:(UIView *)view
{
    transitionView = view;
}

#pragma mark - ZoomTransitionProtocol

- (UIView *)viewForZoomTransition:(BOOL)isSource
{
    return transitionView;
}

#pragma mark Button Events

- (IBAction)btnComicSendButtonClick:(id)sender {
    [self sendComic];
}

-(void)sendComic{
    //Desable the image view intactin
    [self.view setUserInteractionEnabled:NO];
    
    NSMutableDictionary* dataDic = [[NSMutableDictionary alloc] init];
    NSMutableDictionary* comicMakeDic = [[NSMutableDictionary alloc] init];
    
    [comicMakeDic setObject:[AppHelper getCurrentLoginId] forKey:@"user_id"]; // Hardcoded now
    [comicMakeDic setObject:@"" forKey:@"comic_title"];
    [comicMakeDic setObject:@"CM" forKey:@"comic_type"]; // COMIC MAKING yes it is hardcoded now
    [comicMakeDic setObject:@"0" forKey:@"conversation_id"]; //it is hardcoded now
    [comicMakeDic setObject:[NSString stringWithFormat:@"%lu", (unsigned long)[comicSlides count]]
                     forKey:@"slide_count"];
    
    [comicMakeDic setObject:@"1" forKey:@"status"];
    [comicMakeDic setObject:@"1" forKey:@"is_public"];
    
    //Slide Array
    NSMutableArray* slides = [[NSMutableArray alloc] init];
    
    
    for (NSData* data in comicSlides) {
        ComicPage* cmPage = [NSKeyedUnarchiver unarchiveObjectWithData:data];
        
        //ComicSlides Object
        NSMutableDictionary* cmSlide = [[NSMutableDictionary alloc] init];
        [cmSlide setObject:[AppHelper encodeToBase64String:[AppHelper getImageFile:cmPage.printScreenPath]] forKey:@"slide_image"];
        [cmSlide setObject:@"" forKey:@"slide_text"];
        
        NSMutableArray* enhancements = [[NSMutableArray alloc] init];
        //Check is AUD is avalilabe
        
        for (int i = 0; i < cmPage.subviews.count; i ++)
        {
            id imageView = self.comicPageComicItems.subviews[i];
            //Check is ComicItemBubble
            if([imageView isKindOfClass:[ComicItemBubble class]])
            {
                if ([((ComicItemBubble*)imageView) isPlayVoice]) {
                    //Yes there is a Audio
                    //ComicSlides Object
                    NSMutableDictionary* cmEng = [[NSMutableDictionary alloc] init];
                    [cmEng setObject:@"AUD" forKey:@"enhancement_type"];
                    [cmEng setObject:@"1" forKey:@"enhancement_type_id"];
                    [cmEng setObject:@"1" forKey:@"is_custom"];
                    [cmEng setObject:@"" forKey:@"enhancement_text"];
                    NSData* audioData = [[NSData alloc] initWithContentsOfFile:((ComicItemBubble*)imageView).recorderFilePath];
                    [cmEng setObject:[audioData base64EncodedStringWithOptions:NSDataBase64Encoding64CharacterLineLength]
                              forKey:@"enhancement_file"];
                    
                    [cmEng setObject:[NSString stringWithFormat:@"%f",((ComicItemBubble*)imageView).frame.origin.x] forKey:@"position_top"];
                    [cmEng setObject:[NSString stringWithFormat:@"%f",((ComicItemBubble*)imageView).frame.origin.y] forKey:@"position_left"];
                    [cmEng setObject:@"1" forKey:@"z_index"];
                    
                    [enhancements addObject:cmEng];
                }
            }
        }
        [slides addObject:cmSlide];
        cmPage = nil;
        cmSlide = nil;
    }
    [comicMakeDic setObject:slides forKey:@"slides"];
    [dataDic setObject:comicMakeDic forKey:@"data"];
    
    [AppHelper showWarningDropDownMessage:@"" mesage:@"Please wait .. Creating your comic"];
    ComicNetworking* cmNetWorking = [ComicNetworking sharedComicNetworking];
    NSLog(@"Start");
    [cmNetWorking postComicCreation:dataDic Id:nil completion:^(id json,id jsonResposeHeader) {
        
        [AppHelper setCurrentcomicId:[json objectForKey:@"data"]];
    
        NSLog(@"END");
        //Desable the image view intactin
        [self.view setUserInteractionEnabled:YES];
        
        UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:@"Main" bundle: nil];
        SendPageViewController *controller = (SendPageViewController *)[mainStoryboard instantiateViewControllerWithIdentifier:@"SendPage"];
        [self.navigationController pushViewController:controller animated:YES];
        
        
    } ErrorBlock:^(JSONModelError *error) {
        NSLog(@"completion %@",error);
        //Desable the image view intactin
        [self.view setUserInteractionEnabled:YES];
    }];
}

#pragma mark - ComicMakingViewControllerDelegate

- (void)comicMakingItemRemoveAll:(ComicPage *)comicPage removeAll:(BOOL)isRemoveAll{
   
    if (self.comicPageComicItems != nil) {
        //Remove subviews
        [self.comicPageComicItems.subviews removeAllObjects];
        [self.comicPageComicItems.subviewData removeAllObjects];
    }
    
}
- (void)comicMakingItemSave:(ComicPage *)comicPage
              withImageView:(id)comicItemData
            withPrintScreen:(UIImage *)printScreen
               withRemove:(BOOL)remove
               withNewSlide:(BOOL)newslide
{
    
    if (self.comicPageComicItems == nil) {
        self.comicPageComicItems = [[ComicPage alloc] init];
    }
    
    //
    dispatch_queue_t autoSaveCurrentDrawQueue  = dispatch_queue_create("comicItem_AutoSave", NULL);
    dispatch_async( autoSaveCurrentDrawQueue ,
                   ^ {
                       @try {
                           
                           NSLog(@"Start comicMakingItemSave");
                           
                           //Removing existign data
                           if (self.comicPageComicItems.subviews == nil) {
                               self.comicPageComicItems.subviews = [[NSMutableArray alloc] init];
                           }
                           if (self.comicPageComicItems.subviewData == nil) {
                               self.comicPageComicItems.subviewData = [[NSMutableArray alloc] init];
                           }

                           if (remove) {
                               if ([self.comicPageComicItems.subviews containsObject:comicItemData]) {
                                   
                                   NSInteger anIndex = [self.comicPageComicItems.subviews indexOfObject:comicItemData];
                                   if ([self.comicPageComicItems.subviewData count] > anIndex) {
                                       [self.comicPageComicItems.subviewData removeObjectAtIndex:anIndex];
                                   }
                                   [self.comicPageComicItems.subviews removeObject:comicItemData];
                               }
                           }else{
                               
                               if ([self.comicPageComicItems.subviews containsObject:comicItemData]) {
                                   
                                   NSInteger anIndex = [self.comicPageComicItems.subviews indexOfObject:comicItemData];
                                   if ([self.comicPageComicItems.subviewData count] > anIndex) {
                                       [self.comicPageComicItems.subviewData removeObjectAtIndex:anIndex];
                                   }
                                   [self.comicPageComicItems.subviews removeObject:comicItemData];
                               }
                               
                               [self.comicPageComicItems.subviews addObject:comicItemData];
                               [self.comicPageComicItems.subviewData addObject:[NSValue valueWithCGRect:((UIView*)comicItemData).frame]];
                               
                               self.dirtysubviewData  =  self.comicPageComicItems.subviewData;
                               self.dirtySubviews = self.comicPageComicItems.subviews;
                               
                               [self setComicSendButton];
                           }
//                           if (self.comicPageComicItems != nil) {
//                               NSData *data = [NSKeyedArchiver archivedDataWithRootObject:self.comicPageComicItems];
//                               if (newslide)
//                               {
//                                   [comicSlides addObject:data];
//                                   [self saveDataToFile:comicSlides];
//                               }
//                               else
//                               {
//                                   [comicSlides replaceObjectAtIndex:editSlideIndex withObject:data];
//                                   [self saveDataToFile:comicSlides];
//                               }
//                           }
                           
                           NSLog(@"Finish comicMakingItemSave");
                       }
                       @catch (NSException *exception) {
                       }
                       @finally {
                       }
                   });
    
}

- (void)comicMakingViewControllerWithEditingDone:(ComicMakingViewController *)controll
                                   withImageView:(UIImageView *)imageView
                                 withPrintScreen:(UIImage *)printScreen
                                    withNewSlide:(BOOL)newslide
                                     withPopView:(BOOL)isPopView
{
    if (isPopView) {
        [self.navigationController popViewControllerAnimated:YES];
        [scrvComicSlide reloadComicImageAtIndex:newSlideIndex withComicSlide:printScreen];
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            //Do background work
            @try {
                
                @autoreleasepool {
                    if (self.comicPageComicItems == nil) {
                        self.comicPageComicItems = [[ComicPage alloc] init];
                        
                        self.comicPageComicItems.subviews = self.dirtySubviews;
                        self.comicPageComicItems.subviewData = self.dirtysubviewData;
                    }
                    
                    self.comicPageComicItems.containerImagePath =  [self SaveImageFile:UIImageJPEGRepresentation(imageView.image,1) type:@"jpg"];
                    self.comicPageComicItems.printScreenPath = [self SaveImageFile:UIImageJPEGRepresentation(printScreen, 1) type:@"jpg"];
                    
                    //Add time line
                    NSDate *now = [NSDate date];
                    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
                    dateFormatter.dateFormat = @"h.mm a";
                    [dateFormatter setTimeZone:[NSTimeZone systemTimeZone]];
                    self.comicPageComicItems.timelineString = [dateFormatter stringFromDate:now];
                    dateFormatter = nil;
                    
                    NSData *data = [NSKeyedArchiver archivedDataWithRootObject:self.comicPageComicItems];
                    self.comicPageComicItems = nil;
                    
                    if (newslide)
                    {
                        [comicSlides addObject:data];
//                        [[NSUserDefaults standardUserDefaults] setObject:comicSlides forKey:@"comicSlides"];
//                         [self saveComicSlides:comicSlides];
                        [self saveDataToFile:comicSlides];
                    }
                    else
                    {
                        [comicSlides replaceObjectAtIndex:editSlideIndex withObject:data];
//                        [[NSUserDefaults standardUserDefaults] setObject:comicSlides forKey:@"comicSlides"];
//                         [self saveComicSlides:comicSlides];
                        [self saveDataToFile:comicSlides];
                    }
                    data = nil;
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [self setComicSendButton];
                    });
                }
            }
            @catch (NSException *exception) {
            }
            @finally {
            }
        });
    }
    else{
        //Doing main thread
        [scrvComicSlide reloadComicImageAtIndex:newSlideIndex withComicSlide:printScreen];
        @try {
            
            @autoreleasepool {
                if (self.comicPageComicItems == nil) {
                    self.comicPageComicItems = [[ComicPage alloc] init];
                }
                
                self.comicPageComicItems.containerImagePath =  [self SaveImageFile:UIImageJPEGRepresentation(imageView.image,1) type:@"jpg"];
                self.comicPageComicItems.printScreenPath = [self SaveImageFile:UIImageJPEGRepresentation(printScreen, 1) type:@"jpg"];
                
                //Add time line
                NSDate *now = [NSDate date];
                NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
                dateFormatter.dateFormat = @"h.mm a";
                [dateFormatter setTimeZone:[NSTimeZone systemTimeZone]];
                self.comicPageComicItems.timelineString = [dateFormatter stringFromDate:now];
                dateFormatter = nil;
                
                NSData *data = [NSKeyedArchiver archivedDataWithRootObject:self.comicPageComicItems];
                
                if (newslide)
                {
                    [comicSlides addObject:data];
//                    [[NSUserDefaults standardUserDefaults] setObject:comicSlides forKey:@"comicSlides"];
//                    [self saveComicSlides:comicSlides];
                    [self saveDataToFile:comicSlides];
                }
                else
                {
                    [comicSlides replaceObjectAtIndex:editSlideIndex withObject:data];
//                    [[NSUserDefaults standardUserDefaults] setObject:comicSlides forKey:@"comicSlides"];
//                    [self saveComicSlides:comicSlides];
                    [self saveDataToFile:comicSlides];
                }
                
                self.comicPageComicItems = nil;
                data = nil;
                self.isSendPageReload = YES;
                [self setComicSendButton];
            }
        }
        @catch (NSException *exception) {
        }
        @finally {
        }
    }
}

#pragma mark DB Methods

-(void)saveDataToFile:(NSMutableArray*)slideObj
{
    [AppHelper saveDataToFile:slideObj fileName:@"ComicSlide"];
//    [[NSUserDefaults standardUserDefaults] setObject:comicSlides forKey:@"comicSlides"];
//    NSLog(@"****** saveDataToFile ******");
}

-(NSMutableArray*)getDataFromFile{
    return [AppHelper getDataFromFile:@"ComicSlide"];
}

//-(void)saveComicSlides:(NSMutableArray*)slidesObj{
//    
//    NSManagedObjectContext *context = [[AppHelper initAppHelper] managedObjectContext];
//    
//    NSManagedObject *stickersList = [NSEntityDescription insertNewObjectForEntityForName:@"ComicSlidesData" inManagedObjectContext:context];
//    [stickersList setValue:slidesObj forKey:@"comicSlide"];
//    
//    NSError *error = nil;
//    if (![context save:&error]) {
//        NSLog(@"Can't Save! %@ %@", error, [error localizedDescription]);
//    }
//}
//
//-(NSMutableArray*)getComicSlides{
//    
//    // Fetch the devices from persistent data store
//    NSManagedObjectContext *context = [[AppHelper initAppHelper] managedObjectContext];
//    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] initWithEntityName:@"ComicSlidesData"];
//    NSMutableArray* stickersArray = [[context executeFetchRequest:fetchRequest error:nil] mutableCopy];
//    
//    return [stickersArray valueForKey:@"comicSlide"];
//}

#pragma mark - Methods

-(NSString*)SaveImageFile:(NSData*)imageDataObj type:(NSString*)fileType{
    NSString *UUID = [[NSUUID UUID] UUIDString];
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsPath = [paths objectAtIndex:0]; //Get the docs directory
    NSString *filePath = [documentsPath stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.%@",UUID,fileType] ]; //Add the file name
    [imageDataObj writeToFile:filePath atomically:YES]; //Write the file
//    UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil);
//    NSLog(@"File Path :%@",filePath);
    imageDataObj = nil;
    return [NSString stringWithFormat:@"%@.%@",UUID,fileType];
}

#pragma mark mainpageAction

- (IBAction)btnComicBoyClick:(id)sender {
    
    [AppHelper openMainPageviewController:self];
    
}


@end
