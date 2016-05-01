//
//  otherVC.m
//  Animations
//
//  Created by Subin Kurian on 12/21/15.
//  Copyright © 2015 Subin Kurian. All rights reserved.
//

#import "StickerList.h"
#import "ComicMakingViewController.h"
#import "CropStickerViewController.h"
#import "stickerCell.h"

#define IS_IPHONE (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)
#define SCREEN_WIDTH ([[UIScreen mainScreen] bounds].size.width)
#define SCREEN_HEIGHT ([[UIScreen mainScreen] bounds].size.height)
#define SCREEN_MAX_LENGTH (MAX(SCREEN_WIDTH, SCREEN_HEIGHT))
#define SCREEN_MIN_LENGTH (MIN(SCREEN_WIDTH, SCREEN_HEIGHT))
#define IS_IPHONE_5 (IS_IPHONE && SCREEN_MAX_LENGTH == 568.0)
#define IS_IPHONE_6 (IS_IPHONE && SCREEN_MAX_LENGTH == 667.0)
#define IS_IPHONE_6P (IS_IPHONE && SCREEN_MAX_LENGTH == 736.0)
#define Sticker_FolderName @"StickerList"

static NSString *const SKeyDeleteSticker = @"deleteSticker";

@interface StickerList ()<UIGestureRecognizerDelegate>

@property (nonatomic,strong) NSMutableArray *stickers;
@property (nonatomic, strong) NSMutableArray *stickersWithShadow;
@property (nonatomic, strong) ComicMakingViewController *parentViewController;
@property BOOL isQuivering;
@property NSInteger deleteIndex;
@property BOOL isDeletingCell;

@property (nonatomic, strong) NSString *imageNameWithBorder;
@end

@implementation StickerList

static NSString * const reuseIdentifier = @"Cell";
static NSString * const reuseIdentifier1 = @"Cell1";

@synthesize stickers, parentViewController, addingSticker, stickersWithShadow, deleteIndex,isDeletingCell,imageNameWithBorder;

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self
                                                                                            action:@selector(activateDeletionMode:)];
    longPress.delegate = self;
    [self.collectionView addGestureRecognizer:longPress];
    
//    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(deactiveDeleteMode:)];
//    
//    tapGesture.delegate = self;
//    [self.collectionView addGestureRecognizer:tapGesture];
    
    // Uncomment the following line to preserve selection between presentations
     self.clearsSelectionOnViewWillAppear = NO;
    
    // Register cell classes
   // [self.collectionView registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:reuseIdentifier];
    
    stickers = [[NSMutableArray alloc] init];
    stickersWithShadow = [[NSMutableArray alloc] init];
    // Do any additional setup after loading the view.
    
    [stickers addObjectsFromArray:[self getStickerWithoutShadow]];
    [stickersWithShadow addObjectsFromArray:[self getStickerWithShadow]];
    
    [stickers addObjectsFromArray:[self getDefaultStickers]];
    
    [stickersWithShadow addObjectsFromArray:[self getDefaultStickers]];
    
    [self.collectionView reloadData];
}

- (NSArray *)getDefaultStickers
{
    NSArray *imageNames = @[@"st1",@"st2",@"st3",@"st4",@"st5",@"st6",@"st7",@"st8",@"st9"];
    
    NSMutableArray *array = [[NSMutableArray alloc] init];
    
    NSArray *deleteStickerNames = [[NSUserDefaults standardUserDefaults] objectForKey:SKeyDeleteSticker];
    
    for (NSString *imageName in imageNames)
    {
        if (deleteStickerNames.count > 0)
        {
            if (![deleteStickerNames containsObject:imageName])
            {
                NSDictionary *dict = @{@"stickerImage"  : [UIImage imageNamed:imageName],
                                       @"stickerType"   : @"default",
                                       @"isDeleted"     : @"No",
                                       @"stickerName"   : imageName,
                                       @"stickerPath"   : @"No path"};
                
                
                [array addObject:dict];
            }
        }
        else
        {
            NSDictionary *dict = @{@"stickerImage"  : [UIImage imageNamed:imageName],
                                   @"stickerType"   : @"default",
                                   @"isDeleted"     : @"No",
                                   @"stickerName"   : imageName,
                                   @"stickerPath"   : @"No path"};
            
            
            [array addObject:dict];

        }
    }
    
    return array;
}


- (NSArray *)getStickerWithoutShadow
{
    NSMutableArray *allStickers = [self getStickersfromDB]; // [[NSUserDefaults standardUserDefaults] objectForKey:SKeySticker];
    
    NSMutableArray *array = [[NSMutableArray alloc] init];
    
    for (NSString *imageName in allStickers)
    {
        NSString* fileName = [NSString stringWithFormat:@"%@/%@.png",Sticker_FolderName,[imageName lastPathComponent]];
        NSArray *arrayPaths =
        NSSearchPathForDirectoriesInDomains(
                                            NSDocumentDirectory,
                                            NSUserDomainMask,
                                            YES);
        NSString *path1 = [arrayPaths objectAtIndex:0];
        NSString *stickerPath = [path1 stringByAppendingPathComponent:fileName];
        
        UIImage *image1 = [UIImage imageWithContentsOfFile:stickerPath];
        
        if (image1 != nil)
        {
            NSDictionary *dict = @{@"stickerImage"  : image1,
                                   @"stickerType"   : @"cropped",
                                   @"isDeleted"     : @"No",
                                   @"stickerName"   : fileName,
                                   @"stickerPath"   : stickerPath};
            
            
            [array addObject:dict];
        }
    }

    return array.copy;
}

- (NSArray *)getStickerWithShadow
{
    NSMutableArray *allStickers = [self getStickersfromDB]; //[[NSUserDefaults standardUserDefaults] objectForKey:SKeySticker];
    
    NSMutableArray *array = [[NSMutableArray alloc] init];
    
    for (NSString *imageName in allStickers)
    {
        NSString *fileNameWithBorder = [NSString stringWithFormat:@"%@/%@-withBorder.png",Sticker_FolderName,[imageName lastPathComponent]];
        
        NSArray *arrayPathsWithBorder =
        NSSearchPathForDirectoriesInDomains(
                                            NSDocumentDirectory,
                                            NSUserDomainMask,
                                            YES);
        NSString *pathWithBorder = [arrayPathsWithBorder objectAtIndex:0];
        NSString *stickerPathWithBorder = [pathWithBorder stringByAppendingPathComponent:fileNameWithBorder];
        
        UIImage *imageWithBorder = [UIImage imageWithContentsOfFile:stickerPathWithBorder];
        
        if (imageWithBorder != nil)
        {
            NSDictionary *dict = @{@"stickerImage"  : imageWithBorder,
                                   @"stickerType"   : @"cropped",
                                   @"isDeleted"     : @"No",
                                   @"stickerName"   : fileNameWithBorder,
                                   @"stickerPath"   : stickerPathWithBorder};
            
            [array addObject:dict];

        }
        
       
    }

    return array.copy;
}

#pragma mark <UICollectionViewDataSource>
- (CGSize)collectionView:(UICollectionView*)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    if (IS_IPHONE_5)
    {
        return CGSizeMake(60, 60);
    }
    else if (IS_IPHONE_6)
    {
        return CGSizeMake(68, 68);
    }
    else if (IS_IPHONE_6P)
    {
        return CGSizeMake(76, 76);
    }
    else
    {
        return CGSizeMake(72, 72);
    }
    
    return CGSizeMake(72, 72);
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return stickers.count + 1;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    if(indexPath.item == 0)
    {
        UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:reuseIdentifier1 forIndexPath:indexPath];
        
        //        // Configure the cell
        //        UIImageView*img=(UIImageView*)[cell viewWithTag:1];
        //        img.image=[UIImage imageNamed:[_arr objectAtIndex:indexPath.row]];
        return cell;
    }
    else
    {
        stickerCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:reuseIdentifier forIndexPath:indexPath];
        
//        NSLog(@"indexpath = %ld",(long)indexPath.row);
        
        if (addingSticker == YES && indexPath.row == 1)
        {
            cell.imgvSticker.image = nil;
        }
        else
        {
            NSDictionary *dict = stickers[indexPath.row - 1];
            
//            cell.imgvSticker.image =[UIImage imageWithData:[NSData dataWithContentsOfFile:dict[@"stickerPath"]]];
            cell.imgvSticker.image =    dict[@"stickerImage"];
            cell.imgvSticker.hidden = NO;
            
        }
        
        if (self.isQuivering)
        {
            [cell startQuivering];
            cell.btnDelete.hidden = NO;
        }
        else
        {
            [cell stopQuivering];
            cell.btnDelete.hidden = YES;
        }
        
        cell.btnDelete.tag = indexPath.row;
        
        [cell.btnDelete addTarget:self action:@selector(deleteSticker:) forControlEvents:UIControlEventTouchUpInside];
        
        
        return cell;
    }
}

- (void)deleteSticker:(UIButton *)sender
{
    NSLog(@"sender tag = %ld",(long)sender.tag);
    
    stickerCell *cell = (stickerCell *)[[sender superview] superview];;
    
    NSIndexPath *indexPath = [self.collectionView indexPathForCell:cell];
    
    NSInteger deletingIndex = indexPath.row - 1;
    
    NSDictionary *dictSticker = stickers[deletingIndex];
    NSDictionary *dictStickerWithShadow = stickersWithShadow[deletingIndex];
   
    if ([dictSticker[@"stickerType"] isEqualToString:@"default"])
    {
        NSMutableArray *deleteStickerNames = [[[NSUserDefaults standardUserDefaults] objectForKey:SKeyDeleteSticker] mutableCopy];
        
        if (deleteStickerNames.count == 0)
        {
            deleteStickerNames = [[NSMutableArray alloc] init];
        }
        
        [deleteStickerNames addObject:dictSticker[@"stickerName"]];
        
        [[NSUserDefaults standardUserDefaults] setObject:deleteStickerNames forKey:SKeyDeleteSticker];
        
        [[NSUserDefaults standardUserDefaults]synchronize];
    }
    else
    {
        NSFileManager *fileManager = [NSFileManager defaultManager];
        
        [fileManager removeItemAtPath:dictSticker[@"stickerPath"] error:nil];
        [fileManager removeItemAtPath:dictStickerWithShadow[@"stickerPath"] error:nil];
        
        NSMutableArray *allStickers = [[[NSUserDefaults standardUserDefaults] objectForKey:SKeySticker] mutableCopy];
        [allStickers removeObject:dictSticker[@"stickerName"]];
        
        [[NSUserDefaults standardUserDefaults] setObject:allStickers forKey:SKeySticker];
        
        [[NSUserDefaults standardUserDefaults]synchronize];
    }
    
    //Perform flip animation
    //_AnimationDuration defined in Constant.h
    CGContextRef context = UIGraphicsGetCurrentContext();
    context = UIGraphicsGetCurrentContext();
    [UIView beginAnimations:nil context:context];
    [UIView setAnimationDuration:0.4];
    //   [UIView setAnimationTransition:UIViewAnimationTransitionFlipFromLeft forView:cell cache:YES];
    cell.transform = CGAffineTransformMakeScale(0.1, 0.1);
    
    [UIView commitAnimations];
    
    //Implementation of GCD to delete a flip item
    double delay = 0.4;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delay * NSEC_PER_SEC);
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        //code to be executed on the main queue after delay
//        [clvdemo performBatchUpdates:^{
//            [clvdemo deleteItemsAtIndexPaths:@[_indexPath]];
//        } completion:nil];

        cell.imgvSticker.hidden = YES;
        cell.btnDelete.hidden = YES;
        [self.collectionView performBatchUpdates:^
         {
             [self.collectionView deleteItemsAtIndexPaths:@[indexPath]];
             
         } completion:^(BOOL finished)
         {
             
         }];
    });
    
    [UIView animateWithDuration:0.3 animations:^{
        
        cell.transform = CGAffineTransformMakeScale(0.1, 0.1);
        
    }completion:^(BOOL finished) {
        
        [stickers removeObjectAtIndex:deletingIndex];
        [stickersWithShadow removeObjectAtIndex:deletingIndex];
        
        [UIView animateWithDuration:0 animations:^
        {
        
        }];
    }];
}

#pragma mark <UICollectionViewDelegate>
-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    if (self.isQuivering)
    {
        self.isQuivering = NO;
        [self.collectionView reloadData];
        
        [parentViewController deactiveDeleteMode:nil];
    }
    else
    {
        if(indexPath.item == 0)
        {
            
        }
        else
        {
            NSDictionary *dict = stickersWithShadow[indexPath.row - 1];
            [parentViewController addStickerWithImage:dict[@"stickerImage"]];
//            [parentViewController addStickerWithImage:[UIImage imageWithData:[NSData dataWithContentsOfFile:dict[@"stickerPath"]]]];
//            [parentViewController addStickerWithPath:dict[@"stickerPath"]];
        }

    }
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
#pragma mark Data Methods

-(void)saveStickerPath:(NSString*)stickerPath{
    
    NSManagedObjectContext *context = [[AppHelper initAppHelper] managedObjectContext];
    
    NSManagedObject *stickersList = [NSEntityDescription insertNewObjectForEntityForName:@"Stickers" inManagedObjectContext:context];
    [stickersList setValue:stickerPath forKey:@"stickerImagePath"];
    
    NSError *error = nil;
    if (![context save:&error]) {
        NSLog(@"Can't Save! %@ %@", error, [error localizedDescription]);
    }
}

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

- (void)saveImageWithBorder:(UIImage *)borderImage
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    
    NSString *Image_filePath = [documentsDirectory stringByAppendingPathComponent:imageNameWithBorder];
    
    NSDictionary *dictStickerWithShadow = @{@"stickerImage"  : borderImage,
                                            @"stickerType"   : @"cropped",
                                            @"isDeleted"     : @"No",
                                            @"stickerName"   : imageNameWithBorder,
                                            @"stickerPath"   : Image_filePath};
    
    [stickersWithShadow insertObject:dictStickerWithShadow atIndex:0];

    NSFileManager *fileManager = [NSFileManager defaultManager];
    
    NSData *imagedata = UIImagePNGRepresentation(borderImage);
    
    [fileManager createFileAtPath:[Image_filePath stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding] contents:imagedata attributes:nil];
}

- (void)addStickerWithSticker:(UIImage *)sticker withBorderImage:(UIImage *)withBorderImage
{
    NSIndexPath *indexPathOfInsertedCell = [NSIndexPath indexPathForItem:1 inSection:0];
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat: @"yyyy-MM-ddHH:mm:sszzz"];
    NSString *stickerFileName = [formatter stringFromDate:[NSDate date]];
    
    NSString *stickerFileNameWithoutBorder = [formatter stringFromDate:[NSDate date]];
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    documentsDirectory = [documentsDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"/%@",Sticker_FolderName]];
    
    if (![[NSFileManager defaultManager] fileExistsAtPath:documentsDirectory])
        [[NSFileManager defaultManager] createDirectoryAtPath:documentsDirectory withIntermediateDirectories:NO attributes:nil error:nil];
    
    NSString *str= [NSString stringWithFormat:@"%@-withBorder.png",stickerFileName];

    imageNameWithBorder = str;
    
    //save whiteborder
    
  //  NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
  //  NSString *documentsDirectory = [paths objectAtIndex:0];
    
    NSString *Image_filePath = [documentsDirectory stringByAppendingPathComponent:imageNameWithBorder];
    
    NSDictionary *dictStickerWithShadow = @{@"stickerImage"  : withBorderImage,
                                            @"stickerType"   : @"cropped",
                                            @"isDeleted"     : @"No",
                                            @"stickerName"   : imageNameWithBorder,
                                            @"stickerPath"   : Image_filePath};
    
    [stickersWithShadow insertObject:dictStickerWithShadow atIndex:0];
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    
    NSData *imagedata = UIImagePNGRepresentation(withBorderImage);
    
    [fileManager createFileAtPath:[Image_filePath stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding] contents:imagedata attributes:nil];
    
    
    //save without border image
    NSString *strWithoutBorderImage= [NSString stringWithFormat:@"%@.png",stickerFileNameWithoutBorder];
    NSString *Image_filePathWithoutBorder = [documentsDirectory stringByAppendingPathComponent:strWithoutBorderImage];
    
    NSDictionary *dictSticker = @{@"stickerImage"  : sticker,
                           @"stickerType"   : @"cropped",
                           @"isDeleted"     : @"No",
                           @"stickerName"   : stickerFileName,
                           @"stickerPath"   : strWithoutBorderImage};
    
    
    
    
    [stickers insertObject:dictSticker atIndex:0];
    
    
    if (stickers.count > 1)
    {
        NSIndexPath *scrollIndex = [NSIndexPath indexPathForItem:0 inSection:0];
        
        [self.collectionView scrollToItemAtIndexPath:scrollIndex atScrollPosition:UICollectionViewScrollPositionLeft animated:YES];
    }

    [self.collectionView insertItemsAtIndexPaths:@[indexPathOfInsertedCell]];
    
    
  //  NSFileManager *fileManager = [NSFileManager defaultManager];
    
    // save without border image
    NSData *imagedataWithoutBorder = UIImagePNGRepresentation(sticker);
    
    [fileManager createFileAtPath:[Image_filePathWithoutBorder stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding] contents:imagedataWithoutBorder attributes:nil];
    
    [self saveStickerPath:stickerFileNameWithoutBorder];
    
//    NSMutableArray *allStickers = [[[NSUserDefaults standardUserDefaults] objectForKey:SKeySticker] mutableCopy];
//    
//    if (allStickers.count == 0)
//    {
//        allStickers = [[NSMutableArray alloc] init];
//    }
//    
//    [allStickers insertObject:stickerFileNameWithoutBorder atIndex:0];
//    
//    [[NSUserDefaults standardUserDefaults] setObject:allStickers forKey:SKeySticker];
//    
//    [[NSUserDefaults standardUserDefaults]synchronize];
}

- (IBAction)sissorsAction:(id)sender
{
    [parentViewController showCropViewController];
}

- (IBAction)closeAction:(id)sender
{
    if (self.isQuivering)
    {
        self.isQuivering = NO;
        [self.collectionView reloadData];
    }
    
    [parentViewController closeStickerList];
}

#pragma mark - delete collectionview cell
- (void)activateDeletionMode:(UILongPressGestureRecognizer *)gr
{
    if (gr.state == UIGestureRecognizerStateBegan)
    {
        ////        if (!isDeleteActive)
        ////        {
        ////
        ////        }
        //
        //        for (int i = 0; i < 10; i++)
        //        {
        //            //NSIndexPath *indexPath = [clvStickers indexPathForItemAtPoint:[gr locationInView:clvStickers]];
        //
        //            NSIndexPath *indexPath = [NSIndexPath indexPathForItem:i inSection:0];
        //
        //            StickerCell *cell = (StickerCell *)[clvStickers cellForItemAtIndexPath:indexPath];
        //
        //            [cell startQuivering];
        //
        //            cell.isQuivering = YES;
        //
        //            NSInteger deletedIndexpath = indexPath.row;
        //
        //            UIButton *deleteButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 5, 5)];
        //
        //            deleteButton.backgroundColor = [UIColor redColor];
        //            [cell addSubview:deleteButton];
        //            
        //            [deleteButton bringSubviewToFront:clvStickers];
        //        }
        
        self.isQuivering = YES;
        [self.collectionView reloadData];

        [parentViewController addDeactiveDeleteMode];
        
    }
}

- (void)deactiveDeleteMode
{
    if (self.isQuivering)
    {
        self.isQuivering = NO;
        [self.collectionView reloadData];
    }
}

@end
