//
//  ComicBubbleList.m
//  ComicMakingPage
//
//  Created by Ramesh on 31/12/15.
//  Copyright © 2015 ADNAN THATHIYA. All rights reserved.
//

#import "ExclamationList.h"

@interface ExclamationList ()

@end

@implementation ExclamationList
@synthesize parentViewController,animationListArray;

static NSString * const reuseIdentifier = @"Cell";
static NSString * const reuseIdentifier1 = @"Cell1";

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations
    self.clearsSelectionOnViewWillAppear = NO;
    
    // Register cell classes
    // [self.collectionView registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:reuseIdentifier];
    
    // Do any additional setup after loading the view.
    
//    if (exclamationListArray) {
//        [exclamationListArray removeAllObjects];
//        exclamationListArray = nil;
//    }
//    if (exclamationLargeListArray) {
//        [exclamationLargeListArray removeAllObjects];
//        exclamationLargeListArray = nil;
//    }
    
    
//    exclamationListArray = [[NSMutableArray alloc] initWithObjects:[UIImage imageNamed:@"01 Regular"],[UIImage imageNamed:@"02 Eh"],[UIImage imageNamed:@"03 Thinking"],[UIImage imageNamed:@"04 Love"],[UIImage imageNamed:@"05 Scared"],[UIImage imageNamed:@"06 Angry_yelling"],[UIImage imageNamed:@"07 Great_Awesome"],[UIImage imageNamed:@"08 Strong_Powerful"],[UIImage imageNamed:@"09 Angry"],[UIImage imageNamed:@"10 Ohno"], nil];

    
    animationListArray = [[NSMutableArray alloc] initWithObjects:
                                 @"WTF",
                                 @"WOW",
                                 @"OOPPS",
                                 @"OMG",
                                 @"ARGH",nil];
    
    
    
    
    
    [self.collectionView reloadData];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

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

    if (IS_IPHONE_5)
    {
        return CGSizeMake(72, 72);
    }
    else if (IS_IPHONE_6)
    {
        return CGSizeMake(80, 80);
    }
    else if (IS_IPHONE_6P)
    {
        return CGSizeMake(88, 88);
    }
    else
    {
        return CGSizeMake(72, 72);
    }
    
}
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
//    return animationListArray.count + 1;
    return animationListArray.count;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return 1;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
//    if(indexPath.item == 0 && indexPath.section == 0)
//    {
//        UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:reuseIdentifier1 forIndexPath:indexPath];
//        return cell;
//    }
//    else
//    {
        UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:reuseIdentifier forIndexPath:indexPath];
        
        // Configure the cell
        UIImageView *img = (UIImageView*)[cell viewWithTag:1];
        img.image = [UIImage imageNamed:animationListArray[indexPath.section]];
        
        return cell;
//    }
}

#pragma mark <UICollectionViewDelegate>

-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    if(indexPath.item == 0 && indexPath.section == 0)
    {
        
    }
    else
    {
//        [parentViewController addExclamationListImage:exclamationLargeListArray[indexPath.row - 1]];
        [parentViewController addAnimation:animationListArray[indexPath.section]];
        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 1.5 * NSEC_PER_SEC),
                       dispatch_get_main_queue(), ^{
            [self closeAction:nil];
        });
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
- (IBAction)closeAction:(id)sender {
    [parentViewController closeExclamationList];
}

@end
