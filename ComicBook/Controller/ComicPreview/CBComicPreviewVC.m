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
        height= [self maxPageHeight];
    }
    if ([cell isKindOfClass:[CBPreviewHeaderCell class]]) {
        height = 110;
    }
    return height;
}

#pragma mark- 

- (void)didTapHorizontalButton{
    if (self.dataArray.count == 8) {
        return;
    }
    
    // Show Comic Making for Horizontal image
    CBComicItemModel* model= [[CBComicItemModel alloc] initWithTimestamp:[self currentTimestmap] image:[UIImage imageNamed:@"hor_image.jpg"] orientation:COMIC_ITEM_ORIENTATION_LANDSCAPE];
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
    CBComicItemModel* model= [[CBComicItemModel alloc] initWithTimestamp:[self currentTimestmap] image:[UIImage imageNamed:@"ver_image.jpg"] orientation:COMIC_ITEM_ORIENTATION_PORTRAIT];
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
    textField.text = [self freeFromNewLine:gestureLabel.text];
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
    
    NSString *textFieldText = [self freeFromNewLine:textField.text];
    if (textFieldText.length > 20) {
        headerTitleLabel.text = [textFieldText stringByReplacingCharactersInRange:NSMakeRange(20, 0) withString:@"\n"];
    } else {
        headerTitleLabel.text = textField.text;
    }
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

#pragma mark - TitleFontDelegate methods

- (void)getSelectedFontName:(NSString *)fontName andTitle:(NSString *)title {
    titleFontName = fontName;
    comicTitle = title;
    [self.tableView reloadData];
}

#pragma mark- CBComicPageViewControllerDelegate method
- (void)didDeleteComicItem:(CBComicItemModel *)comicItem inPage:(CBComicPageCollectionVC *)pageVC{
    [self.dataArray removeObject:comicItem];
    [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:1] withRowAnimation:UITableViewRowAnimationFade];
}

#pragma mark - ComicBookColorCBViewControllerDelegate method

- (void)getSelectedColor:(UIColor *)color {
    comicBackgroundColor = color;
    if ([self.previewVC viewControllers].count != 0) {
        [((CBComicPageCollectionVC *)[[self.previewVC viewControllers] lastObject]).collectionView setBackgroundColor:color];
    }
    [self.tableView reloadData];
}

- (NSString *)freeFromNewLine:(NSString *)text {
    return [text stringByReplacingOccurrencesOfString:@"\n" withString:@""];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
