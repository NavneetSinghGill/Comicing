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

#define kPreviewViewTag 12001

@interface CBComicPreviewVC () <CBComicPageViewControllerDelegate, ZoomTransitionProtocol>
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
    return height;
}

#pragma mark- 

- (void)didTapHorizontalButton{
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

- (NSNumber*)currentTimestmap{
    return @([[NSDate date] timeIntervalSince1970]);
}

#pragma mark- CBComicPageViewControllerDelegate method
- (void)didDeleteComicItem:(CBComicItemModel *)comicItem inPage:(CBComicPageCollectionVC *)pageVC{
    [self.dataArray removeObject:comicItem];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
