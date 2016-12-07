//
//  CBComicPreviewVC.m
//  ComicBook
//
//  Created by Atul Khatri on 02/12/16.
//  Copyright © 2016 Comic Book. All rights reserved.
//

#import "CBComicPreviewVC.h"
#import "CBComicItemModel.h"
#import "CBComicPreviewItemVC.h"

#define kMaxCellCount 100000

@interface CBComicPreviewVC ()
@property (nonatomic, strong) NSIndexPath * selectedIndexPath;
@end

@implementation CBComicPreviewVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.dataArray= [NSMutableArray new];

    [self setupPageViewController];
    
}

- (void)setupPageViewController{
    self.viewControllers= [NSMutableArray new];
    [self.viewControllers addObject:[[CBComicPreviewItemVC alloc] initWithNibName:@"CBComicPreviewItemVC" bundle:nil]];
    [self.viewControllers addObject:[[CBComicPreviewItemVC alloc] initWithNibName:@"CBComicPreviewItemVC" bundle:nil]];
    
    [self reloadPageViewController];
}

- (IBAction)horizontalButtonTapped:(id)sender {
    CBComicItemModel* model= [[CBComicItemModel alloc] initWithTimestamp:[self currentTimestmap] image:[UIImage imageNamed:@"hor_image.jpg"] orientation:COMIC_ITEM_ORIENTATION_LANDSCAPE];
}

- (IBAction)verticalButtonTapped:(id)sender {
    CBComicItemModel* model= [[CBComicItemModel alloc] initWithTimestamp:[self currentTimestmap] image:[UIImage imageNamed:@"ver_image.jpg"] orientation:COMIC_ITEM_ORIENTATION_PORTRAIT];
}

- (NSNumber*)currentTimestmap{
    return @([[NSDate date] timeIntervalSince1970]);
}

#pragma mark-

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
