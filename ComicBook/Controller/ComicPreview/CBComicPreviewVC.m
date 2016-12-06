//
//  CBComicPreviewVC.m
//  ComicBook
//
//  Created by Atul Khatri on 02/12/16.
//  Copyright © 2016 Comic Book. All rights reserved.
//

#import "CBComicPreviewVC.h"
#import "CBComicImageSection.h"
#import "CBComicItemModel.h"
#import "CBComicImageCell.h"
#import "ZoomInteractiveTransition.h"

#define kMaxCellCount 100000

@interface CBComicPreviewVC () <ZoomTransitionProtocol, UIGestureRecognizerDelegate>
@property (nonatomic, strong) ZoomInteractiveTransition * transition;
@property (nonatomic, strong) NSIndexPath * selectedIndexPath;
@property (nonatomic, strong) UILongPressGestureRecognizer* longPressRecognizer;
@end

@implementation CBComicPreviewVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    self.longPressRecognizer= [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(handleLongPress:)];
    self.longPressRecognizer.delegate= self;
    self.longPressRecognizer.delaysTouchesBegan= YES;
    [self.collectionView addGestureRecognizer:self.longPressRecognizer];

    self.dataArray= [NSMutableArray new];
    
    [self setupSections];
}

- (void)setupSections{
    self.sectionArray= [NSMutableArray new];
    CBComicImageSection* section= [CBComicImageSection new];
    section.dataArray= self.dataArray;
    [self.sectionArray addObject:section];
    [self.collectionView reloadData];
}

-(void)handleLongPress:(UILongPressGestureRecognizer *)gestureRecognizer {
    if (gestureRecognizer.state == UIGestureRecognizerStateBegan) {
        CGPoint point = [gestureRecognizer locationInView:self.collectionView];
        NSIndexPath *indexPath = [self.collectionView indexPathForItemAtPoint:point];
        if (indexPath == nil){
            NSLog(@"couldn't find index path");
        } else {
            CBBaseCollectionViewSection* section= [self.sectionArray objectAtIndex:indexPath.section];
            if([section isKindOfClass:[CBComicImageSection class]]){
                self.selectedIndexPath= indexPath;
                // Show alert view
                [self showDeleteAlertForIndexPath:indexPath];
            }
        }
    }
}

- (void)showDeleteAlertForIndexPath:(NSIndexPath*)indexPath{
    UIAlertController* alertController= [UIAlertController alertControllerWithTitle:@"Delete" message:@"Are you sure you want to delete this image?" preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction* deleteAction= [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [self.dataArray removeObjectAtIndex:indexPath.row];
        [self refreshImageOrientation];
        [self.collectionView deleteItemsAtIndexPaths:@[indexPath]];
    }];
    UIAlertAction* cancelAction= [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:nil];
    [alertController addAction:deleteAction];
    [alertController addAction:cancelAction];
    [self presentViewController:alertController animated:YES completion:nil];
}

- (void)refreshImageOrientation{
    for(NSInteger i=0; i < self.dataArray.count; i++){
        CBComicItemModel* currentItem= self.dataArray[i];
        if(currentItem.itemOrientation == COMIC_ITEM_ORIENTATION_LANDSCAPE){
            currentItem.imageOrientation= COMIC_IMAGE_ORIENTATION_LANDSCAPE;
        }else {
            if(i-1 >= 0){
                CBComicItemModel* previousItem= self.dataArray[i-1];
                if(previousItem.itemOrientation == COMIC_ITEM_ORIENTATION_PORTRAIT){
                    if(previousItem.imageOrientation == COMIC_IMAGE_ORIENTATION_PORTRAIT_FULL){
                        previousItem.imageOrientation= COMIC_IMAGE_ORIENTATION_PORTRAIT_HALF;
                        currentItem.imageOrientation= COMIC_IMAGE_ORIENTATION_PORTRAIT_HALF;
                        continue;
                    }
                }
            }
            currentItem.imageOrientation= COMIC_IMAGE_ORIENTATION_PORTRAIT_FULL;
        }
    }
}

- (IBAction)horizontalButtonTapped:(id)sender {
    CBComicItemModel* model= [[CBComicItemModel alloc] initWithTimestamp:[self currentTimestmap] image:[UIImage imageNamed:@"hor_image.jpg"] orientation:COMIC_ITEM_ORIENTATION_LANDSCAPE];
    [self.dataArray addObject:model];
    [self refreshImageOrientation];
    [self.collectionView insertItemsAtIndexPaths:@[[NSIndexPath indexPathForRow:[self.dataArray indexOfObject:model] inSection:0]]];
    [self.collectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForItem:[self.dataArray indexOfObject:model] inSection:0] atScrollPosition:UICollectionViewScrollPositionBottom animated:YES];
}

- (IBAction)verticalButtonTapped:(id)sender {
    CBComicItemModel* model= [[CBComicItemModel alloc] initWithTimestamp:[self currentTimestmap] image:[UIImage imageNamed:@"ver_image.jpg"] orientation:COMIC_ITEM_ORIENTATION_PORTRAIT];
    [self.dataArray addObject:model];
    [self refreshImageOrientation];
    [self.collectionView insertItemsAtIndexPaths:@[[NSIndexPath indexPathForRow:[self.dataArray indexOfObject:model] inSection:0]]];
    [self.collectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForItem:[self.dataArray indexOfObject:model] inSection:0] atScrollPosition:UICollectionViewScrollPositionBottom animated:YES];
}

- (NSNumber*)currentTimestmap{
    return @([[NSDate date] timeIntervalSince1970]);
}

#pragma mark- UICollectionViewDataSource helper methods
- (UICollectionViewCell*)ta_collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    CBBaseCollectionViewSection* section= [self.sectionArray objectAtIndex:indexPath.section];
    UICollectionViewCell* cell= [super ta_collectionView:collectionView cellForItemAtIndexPath:indexPath];
    if([section isKindOfClass:[CBComicImageSection class]]){
        // Do something
    }
    return cell;
}

#pragma mark- ZoomTransitionProtocol method
- (UIView*)viewForZoomTransition:(BOOL)isSource{
    if(self.selectedIndexPath){
        CBComicImageCell * cell = (CBComicImageCell*)[self.collectionView cellForItemAtIndexPath:self.selectedIndexPath];
        return cell.imageView;
    }
    return nil;
}

#pragma mark-

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
