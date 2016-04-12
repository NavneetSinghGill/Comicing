//
//  StickerListViewController.m
//  ShareSticker
//
//  Created by Ramesh on 09/01/16.
//  Copyright © 2016 comicapp. All rights reserved.
//

#import "StickerListViewController.h"
#import "AppConstants.h"
#import "AppHelper.h"

#define Sticker_FolderName @"StickerList"

@interface StickerListViewController ()

@end

@implementation StickerListViewController


@synthesize stickers,parentViewController;

static NSString * const reuseIdentifier = @"Cell";

- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations
    self.clearsSelectionOnViewWillAppear = NO;
    
    // Register cell classes
    // [self.collectionView registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:reuseIdentifier];
    
    stickers = [[NSMutableArray alloc] init];
    
    // Do any additional setup after loading the view.
    
    NSMutableArray *allStickers = [self getStickersfromDB]; //[[NSUserDefaults standardUserDefaults] objectForKey:SKeySticker];
    
    for (NSString *path in allStickers)
    {
        NSString* fileName = [NSString stringWithFormat:@"%@/%@.png",Sticker_FolderName,[path lastPathComponent]];
        NSArray *arrayPaths =
        NSSearchPathForDirectoriesInDomains(
                                            NSDocumentDirectory,
                                            NSUserDomainMask,
                                            YES);
        NSString *path = [arrayPaths objectAtIndex:0];
        NSString *stickerPath = [path stringByAppendingPathComponent:fileName];
        
        UIImage *image1=[UIImage imageWithContentsOfFile:stickerPath];
        
        [stickers addObject:image1];
    }
    
    [stickers addObjectsFromArray:@[[UIImage imageNamed:@"st1"],[UIImage imageNamed:@"st2"],[UIImage imageNamed:@"st3"],[UIImage imageNamed:@"st4"],[UIImage imageNamed:@"st5"],[UIImage imageNamed:@"st6"],[UIImage imageNamed:@"st7"],[UIImage imageNamed:@"st8"],[UIImage imageNamed:@"st9"],[UIImage imageNamed:@"st10"],[UIImage imageNamed:@"st11"],]];
    
    [self.collectionView reloadData];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark Methods

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

#pragma mark <UICollectionViewDataSource>
- (CGSize)collectionView:(UICollectionView*)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
//    if (IS_IPHONE_5)
//    {
//        return CGSizeMake(60, 60);
//    }
//    else if (IS_IPHONE_6)
//    {
//        return CGSizeMake(66, 66);
//    }
//    else if (IS_IPHONE_6P)
//    {
//        return CGSizeMake(72, 72);
//    }
//    else
//    {
//        return CGSizeMake(72, 72);
//    }
    
    return CGSizeMake(60, 84);
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return stickers.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
        UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:reuseIdentifier forIndexPath:indexPath];
        
        // Configure the cell
        UIImageView *img = (UIImageView*)[cell viewWithTag:1];
    
        img.image = stickers[indexPath.row];
        
        return cell;
}

#pragma mark <UICollectionViewDelegate>
-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    if (lastSelectedIndexPath && lastSelectedIndexPath != indexPath) {
        UICollectionViewCell *currectCell =[collectionView cellForItemAtIndexPath:lastSelectedIndexPath];
        UIImageView *img = (UIImageView*)[currectCell viewWithTag:2];
        [img setHidden:YES];
    }

    lastSelectedIndexPath = indexPath;
    UICollectionViewCell *currectCell =[collectionView cellForItemAtIndexPath:indexPath];
    
    UIImageView *img = (UIImageView*)[currectCell viewWithTag:2];
    [img setHidden:NO];
    
    [self.parentViewController addShareSticker:stickers[indexPath.row]];
}

#pragma mark Data Methods

-(NSMutableArray*)getStickersfromDB{
    
    // Fetch the devices from persistent data store
    NSManagedObjectContext *context = [[AppHelper initAppHelper] managedObjectContext];
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"stickerImagePath"
                                                                   ascending:NO];
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] initWithEntityName:@"Stickers"];
    NSArray *sortDescriptors = [[NSArray alloc] initWithObjects:sortDescriptor, nil];
    [fetchRequest setSortDescriptors:sortDescriptors];
    
    NSMutableArray* stickersArray = [[context executeFetchRequest:fetchRequest error:nil] mutableCopy];
    
    return [stickersArray valueForKey:@"stickerImagePath"];
}

/*
 // Uncomment this method to specify if the specified item should be highlighted during tracking
 - (BOOL)collectionView:(UICollectionView *)collectionView shouldHighlightItemAtIndexPath:(NSIndexPath *)indexPath {
	return YES;
 }
 */

/*
 // Uncomment this method to specify if the specified item should be selected
 - (BOOL)collectionView:(UICollectionView *)collectionView shouldSelectItemAtIndexPath:(NSIndexPath *)indexPath {
 return YES;
 }
 */

/*
 // Uncomment these methods to specify if an action menu should be displayed for the specified item, and react to actions performed on the item
 - (BOOL)collectionView:(UICollectionView *)collectionView shouldShowMenuForItemAtIndexPath:(NSIndexPath *)indexPath {
	return NO;
 }
 
 - (BOOL)collectionView:(UICollectionView *)collectionView canPerformAction:(SEL)action forItemAtIndexPath:(NSIndexPath *)indexPath withSender:(id)sender {
	return NO;
 }
 
 - (void)collectionView:(UICollectionView *)collectionView performAction:(SEL)action forItemAtIndexPath:(NSIndexPath *)indexPath withSender:(id)sender {
	
 }
 */

@end
