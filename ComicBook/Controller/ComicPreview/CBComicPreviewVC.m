//
//  CBComicLandingVC.m
//  ComicBook
//
//  Created by Atul Khatri on 07/12/16.
//  Copyright © 2016 Providence. All rights reserved.
//

#import "CBComicPreviewVC.h"
#import "CBComicPreviewSection.h"
#import "CBPreviewHeaderSection.h"
#import "CBComicPreviewCell.h"
#import "CBPreviewHeaderCell.h"
#import "CBComicPageViewController.h"
#import "UIView+CBConstraints.h"
#import "ZoomInteractiveTransition.h"
#import "ZoomTransitionProtocol.h"
#import "AppDelegate.h"
#import "CBComicTitleFontDropdownViewController.h"
#import "ComicBookColorCBViewController.h"
#import "ShareHelper.h"
#import "UIImage+Image.h"
#import "AppHelper.h"
#import "ComicTagViewController.h"

#define kPreviewViewTag 12001

@interface CBComicPreviewVC () <CBComicPageViewControllerDelegate, ZoomTransitionProtocol, UIGestureRecognizerDelegate, TitleFontDelegate, UITextFieldDelegate, ComicBookColorCBViewControllerDelegate> {
    UILabel *headerTitleLabel;
    NSString *comicTitle;
    NSString *titleFontName;
    UIColor *comicBackgroundColor;
}
@property (nonatomic, strong) CBComicPageViewController* previewVC;
@property (nonatomic, strong) ZoomInteractiveTransition * transition;
@property (strong, nonatomic) UIView *transitionView;
@end

@implementation CBComicPreviewVC

- (void)viewDidLoad {
    [super viewDidLoad];
    self.transition = [[ZoomInteractiveTransition alloc] initWithNavigationController:self.navigationController];
    self.transition.handleEdgePanBackGesture = NO;
    self.transition.transitionDuration = 0.4;

    // Do any additional setup after loading the view.
    self.tableView.backgroundColor= [UIColor blackColor];
    self.tableView.separatorStyle= UITableViewCellSeparatorStyleNone;
    self.dataArray= [NSMutableArray new];
    self.previewVC= [[CBComicPageViewController alloc] initWithNibName:@"CBComicPageViewController" bundle:nil];
    self.previewVC.view.tag= kPreviewViewTag;
    self.previewVC.delegate= self;
    [self setupSections];
    [self.tableView reloadData];
    [self addButtons];
}

#pragma mark - ZoomTransitionProtocol

- (UIView *)viewForZoomTransition:(BOOL)isSource
{
    return self.transitionView;
}

- (void)setupSections{
    self.sectionArray= [NSMutableArray new];
    CBPreviewHeaderSection* headerSection= [CBPreviewHeaderSection new];
    [self.sectionArray addObject:headerSection];
    CBComicPreviewSection* previewSection= [CBComicPreviewSection new];
    [self.sectionArray addObject:previewSection];
}

- (CGFloat)maxPageHeight{
    CGFloat maxHeight= 0.0f;
    for(CBBaseViewController* vc in self.previewVC.viewControllers){
        if(vc.collectionView.collectionViewLayout.collectionViewContentSize.height > maxHeight){
            maxHeight= vc.collectionView.collectionViewLayout.collectionViewContentSize.height;
        }
    }
    return ceilf(maxHeight);
}

#pragma mark- UITableViewDataSource handler methods
- (UITableViewCell*)ta_tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell* cell= [super ta_tableView:tableView cellForRowAtIndexPath:indexPath];
    if([cell isKindOfClass:[CBPreviewHeaderCell class]]){
        CBPreviewHeaderCell* headerCell= (CBPreviewHeaderCell*)cell;
        [headerCell.horizontalAddButton addTarget:self action:@selector(didTapHorizontalButton) forControlEvents:UIControlEventTouchUpInside];
        [headerCell.verticalAddButton addTarget:self action:@selector(didTapVerticalButton) forControlEvents:UIControlEventTouchUpInside];
        [headerCell.rainbowColorCircleButton addTarget:self action:@selector(rainbowCircleTapped:) forControlEvents:UIControlEventTouchUpInside];
        headerCell.titleLabel.text = comicTitle;
        headerTitleLabel = headerCell.titleLabel;
        
        if (titleFontName.length != 0) {
            UIFont *font = [UIFont fontWithName:titleFontName size:30.f];
            [headerCell.titleLabel setFont:font];
        }
        [headerCell.titleLabel setTextColor:[UIColor whiteColor]];
        headerCell.titleLabel.userInteractionEnabled = YES;
        [self addGestureToCellLabel:headerCell.titleLabel];
    }else if([cell isKindOfClass:[CBComicPreviewCell class]]){
        // Add pageViewController view as a subview
        if(![cell.contentView viewWithTag:kPreviewViewTag]){
            [cell.contentView addSubview:self.previewVC.view];
            [self.previewVC.view setTranslatesAutoresizingMaskIntoConstraints:NO];
            [cell.contentView constrainSubviewToAllEdges:self.previewVC.view withMargin:0.0f];
            
            [((CBComicPageCollectionVC *)[self.previewVC.viewControllers lastObject]).rainbowColorCircleButton addTarget:self action:@selector(rainbowCircleTapped:) forControlEvents:UIControlEventTouchUpInside];
            
//            [cell.contentView constrainSubviewToLeftEdge:self.previewVC.view withMargin:8.0f];
//            [cell.contentView constrainSubviewToRightEdge:self.previewVC.view withMargin:20.0f];
//            [cell.contentView constrainSubviewToTopEdge:self.previewVC.view withMargin:8.0f];
//            [cell.contentView constrainSubviewToBottomEdge:self.previewVC.view withMargin:20.0f];
        }
    }
    return cell;
}

- (CGFloat)ta_tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    CGFloat height= [super ta_tableView:tableView heightForRowAtIndexPath:indexPath];
    UITableViewCell* cell= [super ta_tableView:tableView cellForRowAtIndexPath:indexPath];
    if([cell isKindOfClass:[CBComicPreviewCell class]]){
        if (self.previewVC.dataArray.count == 0) {
            height = 0;
        } else {
            height= [self maxPageHeight] + 45;
            //45 is the sum of top and bottom constraint of collectionview in comic page
        }
    }
    if ([cell isKindOfClass:[CBPreviewHeaderCell class]]) {
        height = 105;
        //Same calculation in ComicTitleFontDropDownViewController
        height = IS_IPHONE_5?84: (IS_IPHONE_6?94: (IS_IPHONE_6P?104: 114));
    }
    return height;
}

#pragma mark- 

- (void)didTapHorizontalButton{
    if (self.dataArray.count == 8) {
        return;
    }
    
    // Show Comic Making for Horizontal image
//    CBComicItemModel* model= [[CBComicItemModel alloc] initWithTimestamp:[self currentTimestmap] image:[UIImage imageNamed:@"hor_image.jpg"] orientation:COMIC_ITEM_ORIENTATION_LANDSCAPE];
    NSString *animationPath = [[NSBundle mainBundle] pathForResource:@"OOPPS" ofType:@"gif"];
    CBComicItemModel* model= [[CBComicItemModel alloc] initWithTimestamp:[self currentTimestmap] baseLayer:Gif staticImage:[UIImage imageNamed:@"WOW"] animatedImage:[YYImage imageWithContentsOfFile:animationPath] orientation:COMIC_ITEM_ORIENTATION_LANDSCAPE];
    [self.dataArray addObject:model];
    __block CBComicPreviewVC* weekSelf= self;
    [self.previewVC addComicItem:model completion:^(BOOL finished) {
        if(finished){
            [weekSelf.tableView reloadSections:[NSIndexSet indexSetWithIndex:1] withRowAnimation:UITableViewRowAnimationNone];
        }
    }];
}

- (void)didTapVerticalButton{
    if (self.dataArray.count == 8) {
        return;
    }
    
    // Show Comic Making for Vertical image
//    CBComicItemModel* model= [[CBComicItemModel alloc] initWithTimestamp:[self currentTimestmap] image:[UIImage imageNamed:@"ver_image.jpg"] orientation:COMIC_ITEM_ORIENTATION_PORTRAIT];
    NSString *animationPath = [[NSBundle mainBundle] pathForResource:@"OMG" ofType:@"gif"];
    CBComicItemModel* model= [[CBComicItemModel alloc] initWithTimestamp:[self currentTimestmap] baseLayer:StaticImage staticImage:[UIImage imageNamed:@"StickerSelectionBg"] animatedImage:[YYImage imageWithContentsOfFile:animationPath] orientation:COMIC_ITEM_ORIENTATION_PORTRAIT];
    [self.dataArray addObject:model];
    __block CBComicPreviewVC* weekSelf= self;
    [self.previewVC addComicItem:model completion:^(BOOL finished) {
        if(finished){
            [weekSelf.tableView reloadSections:[NSIndexSet indexSetWithIndex:1] withRowAnimation:UITableViewRowAnimationFade];
        }
    }];
}

- (void)rainbowCircleTapped:(UIButton *)rainbowButton {
    CGRect frameOfRainbowCircle = [rainbowButton convertRect:rainbowButton.frame toView:self.view];
    frameOfRainbowCircle.origin.y+=10;
    UIStoryboard *mainPageStoryBoard = [UIStoryboard storyboardWithName:@"Main_MainPage" bundle:nil];
    ComicBookColorCBViewController *comicBookColorCBViewController = [mainPageStoryBoard instantiateViewControllerWithIdentifier:@"ComicBookColorCBViewController"];
    comicBookColorCBViewController.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
    comicBookColorCBViewController.modalPresentationStyle = UIModalPresentationOverCurrentContext;
    comicBookColorCBViewController.delegate = self;
    comicBookColorCBViewController.frameOfRainbowCircle = frameOfRainbowCircle;
    [self presentViewController:comicBookColorCBViewController animated:NO completion:nil];
}

- (NSNumber*)currentTimestmap{
    return @([[NSDate date] timeIntervalSince1970]);
}

- (void)addGestureToCellLabel:(UILabel *)label {
    UILongPressGestureRecognizer *longPressGesture = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(openFontDropDown:)];
    longPressGesture.delegate = self;
    [label addGestureRecognizer:longPressGesture];
    
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(makeTextFieldAvailable:)];
    tapGesture.delegate = self;
    [label addGestureRecognizer:tapGesture];
}

- (void)openFontDropDown:(UILongPressGestureRecognizer *)gesture {
    
    UILabel *gestureLabel = (UILabel *)gesture.view;
    if (gestureLabel.text.length == 0) {
        return;
    }
    
    UIStoryboard *mainPageStoryBoard = [UIStoryboard storyboardWithName:@"Main_MainPage" bundle:nil];
    CBComicTitleFontDropdownViewController *cbComicTitleFontDropdownViewController = [mainPageStoryBoard instantiateViewControllerWithIdentifier:@"CBComicTitleFontDropdownViewController"];
    cbComicTitleFontDropdownViewController.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
    cbComicTitleFontDropdownViewController.modalPresentationStyle = UIModalPresentationOverCurrentContext;
    cbComicTitleFontDropdownViewController.delegate = self;
    cbComicTitleFontDropdownViewController.titleText = gestureLabel.text;
    [self presentViewController:cbComicTitleFontDropdownViewController animated:NO completion:nil];
}

- (void)makeTextFieldAvailable:(UITapGestureRecognizer *)gesture {
    //Add textfield
    UITextField *textField = [[UITextField alloc]initWithFrame:gesture.view.frame];
    UILabel *gestureLabel = ((UILabel *)gesture.view);
    textField.text = gestureLabel.text;
    textField.font = gestureLabel.font;
    textField.textColor = [UIColor whiteColor];
    textField.returnKeyType = UIReturnKeyDone;
    textField.delegate = self;
    [textField addTarget:self action:@selector(doneTapped:) forControlEvents:UIControlEventEditingDidEndOnExit];
    [textField addTarget:self action:@selector(textFieldValueChanged:) forControlEvents:UIControlEventEditingChanged];
    
    headerTitleLabel.hidden = YES;
    [gestureLabel.superview addSubview:textField];
    [textField becomeFirstResponder];
}

- (void)doneTapped:(UITextField *)textField {
    headerTitleLabel.text = textField.text;
    [textField resignFirstResponder];
    [textField removeFromSuperview];
    textField.delegate = nil;
    headerTitleLabel.hidden = NO;
}

- (void)textFieldValueChanged:(UITextField *)textField {
    headerTitleLabel.text = textField.text;
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    if ([textField.text stringByReplacingCharactersInRange:range withString:string].length >= 29 && ![string isEqualToString:@"\n"]) {
        return NO;
    }
    return YES;
}

- (void)addButtons {
    NSInteger widthHeightOfButtons = 40;
    CGRect viewFrame = self.view.frame;
    
    UIButton *twitterButton = [[UIButton alloc] initWithFrame:CGRectMake(0, viewFrame.size.height - widthHeightOfButtons, widthHeightOfButtons, widthHeightOfButtons)];
    [twitterButton setImage:[UIImage imageNamed:@"twitter"] forState:UIControlStateNormal];
    [twitterButton addTarget:self action:@selector(twitterButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
    
    UIButton *facebookButton = [[UIButton alloc] initWithFrame:CGRectMake(0, twitterButton.frame.origin.y - widthHeightOfButtons, widthHeightOfButtons, widthHeightOfButtons)];
    [facebookButton setImage:[UIImage imageNamed:@"facebook"] forState:UIControlStateNormal];
    [facebookButton addTarget:self action:@selector(facebookButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
    
    UIButton *instagramButton = [[UIButton alloc] initWithFrame:CGRectMake(0, facebookButton.frame.origin.y - widthHeightOfButtons, widthHeightOfButtons, widthHeightOfButtons)];
    [instagramButton setImage:[UIImage imageNamed:@"instagram"] forState:UIControlStateNormal];
    [instagramButton addTarget:self action:@selector(instagramButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
    
    UIButton *tagsButton = [[UIButton alloc] initWithFrame:CGRectMake(0, instagramButton.frame.origin.y - widthHeightOfButtons, widthHeightOfButtons, widthHeightOfButtons)];
    [tagsButton setImage:[UIImage imageNamed:@"tag"] forState:UIControlStateNormal];
    
    UIButton *arrowButton = [[UIButton alloc] initWithFrame:CGRectMake(self.view.frame.size.width - widthHeightOfButtons, self.view.frame.size.height - widthHeightOfButtons, widthHeightOfButtons, widthHeightOfButtons)];
    [arrowButton setImage:[UIImage imageNamed:@"arrow"] forState:UIControlStateNormal];
    
    UIButton *middleButton = [[UIButton alloc] initWithFrame:CGRectMake(self.view.frame.size.width/2 - widthHeightOfButtons/2, self.view.frame.size.height - widthHeightOfButtons, widthHeightOfButtons, widthHeightOfButtons)];
    [middleButton setImage:[UIImage imageNamed:@"baby"] forState:UIControlStateNormal];
    [middleButton addTarget:self action:@selector(openMainScreen) forControlEvents:UIControlEventTouchUpInside];
    
    [self.view addSubview:twitterButton];
    [self.view addSubview:facebookButton];
    [self.view addSubview:instagramButton];
    [self.view addSubview:tagsButton];
    [self.view addSubview:arrowButton];
    [self.view addSubview:middleButton];
}

#pragma mark - TitleFontDelegate methods

- (void)getSelectedFontName:(NSString *)fontName andTitle:(NSString *)title {
    titleFontName = fontName;
    comicTitle = title;
    [self.tableView reloadData];
}

#pragma mark- CBComicPageViewControllerDelegate method
- (void)didDeleteComicItem:(CBComicItemModel *)comicItem inPage:(CBComicPageCollectionVC *)pageVC{
    [self.dataArray removeObject:comicItem];
    [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationFade];
//    if (self.previewVC.dataArray.count == 0 && [self.previewVC viewControllers].count == 1) {
//        self.previewVC.view.hidden = YES;
//    }
}

#pragma mark - ComicBookColorCBViewControllerDelegate method


- (void)getSelectedColor:(UIColor *)color andComicBackgroundImageName:(NSString *)backgroundImageName {
    comicBackgroundColor = color;
    if ([self.previewVC viewControllers].count != 0) {
        [((CBComicPageCollectionVC *)[[self.previewVC viewControllers] lastObject]).collectionView setBackgroundColor:color];
        
        CBComicPageCollectionVC *comicPage = ((CBComicPageCollectionVC *)[[self.previewVC viewControllers] lastObject]);
        comicPage.comicBookBackgroundTop.image = [UIImage imageNamed:[NSString stringWithFormat:@"%@Top",backgroundImageName]];
        comicPage.comicBookBackgroundLeft.image = [UIImage imageNamed:[NSString stringWithFormat:@"%@Left",backgroundImageName]];
        comicPage.comicBookBackgroundRight.image = [UIImage imageNamed:[NSString stringWithFormat:@"%@Right",backgroundImageName]];
        comicPage.comicBookBackgroundBottom.image = [UIImage imageNamed:[NSString stringWithFormat:@"%@Bottom",backgroundImageName]];
    }
    [self.tableView reloadData];
}

#pragma mark - Button actions

- (IBAction)openMainScreen {
    [AppHelper openMainPageviewController:self];
}

- (IBAction)arrowButtonTapped:(id)sender {
    
}

- (IBAction)tagButtonTapped:(id)sender {
    UIStoryboard *mainPageStoryBoard = [UIStoryboard storyboardWithName:@"Main_MainPage" bundle:nil];
    ComicTagViewController *comicTagViewController = [mainPageStoryBoard instantiateViewControllerWithIdentifier:@"ComicTagViewController"];
    comicTagViewController.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
    comicTagViewController.modalPresentationStyle = UIModalPresentationOverCurrentContext;
    [self presentViewController:comicTagViewController animated:YES completion:nil];
}

- (IBAction)twitterButtonTapped:(UIButton *)sender {
    [self doShareTo:TWITTER ShareImage:[UIImage imageNamed:@"comicBookBackground"]];
}

- (IBAction)facebookButtonTapped:(UIButton *)sender {
    [self doShareTo:FACEBOOK ShareImage:[UIImage imageNamed:@"comicBookBackground"]];
}

- (IBAction)instagramButtonTapped:(UIButton *)sender {
    [self doShareTo:INSTAGRAM ShareImage:[UIImage imageNamed:@"comicBookBackground"]];
}

-(void)doShareTo :(ShapeType)type ShareImage:(UIImage*)imgShareto{
    
    //    UIImage* imgProcessShareImage = [self createImageWithLogo:imgShareto];
    
    imgShareto = [self createImageWithLogo:imgShareto];
    
    //    NSData *imageData = UIImagePNGRepresentation(imgShareto);
    //    UIImage *image =[UIImage imageWithData:imageData];
    
    //    UIImage* img = [self getnewImage:image];
    //Just to test
    
    //    UIBezierPath *path = [UIBezierPath bezierPath];
    //        UIGraphicsBeginImageContextWithOptions([image size], YES, [image scale]);
    //
    //        [image drawAtPoint:CGPointZero];
    //
    //        CGContextRef ctx = UIGraphicsGetCurrentContext();
    //        CGContextSetBlendMode(ctx, kCGBlendModeNormal);
    //        [path fill];
    //
    //
    //        UIImage *final = UIGraphicsGetImageFromCurrentImageContext();
    //        UIGraphicsEndImageContext();
    
    //        UIImageWriteToSavedPhotosAlbum(imgShareto, nil, nil, nil);
    //        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    //        NSString *documentsPath = [paths objectAtIndex:0]; //Get the docs directory
    //        NSString *filePath = [documentsPath stringByAppendingPathComponent:@"image.png"]; //Add the file name
    //        [imageData writeToFile:filePath atomically:YES]; //Write the file
    //        UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil);
    //        NSLog(@"File Path :%@",filePath);
    
    /* Commented for testing*/
    ShareHelper* sHelper = [ShareHelper shareHelperInit];
    sHelper.parentviewcontroller = self;
    [sHelper shareAction:type ShareText:@""
              ShareImage:imgShareto
              completion:^(BOOL status) {
              }];
    
}

-(UIImage*)createImageWithLogo:(UIImage*)imgActualImage{
    
    //lets fix the share sticker size
    //w = 110;
    //h = 155;
    
    //Selected image adding to imageview
    UIImageView *imageViewSticker = [[UIImageView alloc] initWithImage:imgActualImage];
    imageViewSticker.frame = CGRectMake(50, 50, 110, 155);
    [imageViewSticker setContentMode:UIViewContentModeScaleAspectFit];
    
    //get logo
    UIImage* imgStickerLogo = [UIImage imageNamed:@"ShareStickerLogo"];
    
    
    //lets fix the share footer logo size
    //w = 133;
    //h = 28;
    
    //Selected image adding to imageview
    UIImageView *imageViewStLogo = [[UIImageView alloc] initWithImage:imgStickerLogo];
    imageViewStLogo.frame = CGRectMake(38, 225, 133, 28);
    [imageViewStLogo setContentMode:UIViewContentModeScaleAspectFit];
    
    //Calculating Framesize
    UIView* viewHolder = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 210, 293)];
    [viewHolder setClipsToBounds:YES];
    
    [viewHolder setBackgroundColor:[UIColor clearColor]];
    [viewHolder addSubview:imageViewSticker];
    [viewHolder addSubview:imageViewStLogo];
    
    //Generating image
    UIImage* imgShareTo = [UIImage imageWithView:viewHolder paque:NO];
    
    viewHolder = nil;
    imageViewSticker = nil;
    
    //---------------------
    //uncomment to check the file type and quality
    /*NSData *pngData = UIImagePNGRepresentation(imgShareTo);
     
     NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
     NSString *documentsPath = [paths objectAtIndex:0]; //Get the docs directory
     NSString *filePath = [documentsPath stringByAppendingPathComponent:@"wa_image.png"]; //Add the file name
     [pngData writeToFile:filePath atomically:YES]; //Write the file*/
    //---------------------
    
    
    return imgShareTo;
}

- (NSString *)freeFromNewLine:(NSString *)text {
    return [text stringByReplacingOccurrencesOfString:@"\n" withString:@""];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
