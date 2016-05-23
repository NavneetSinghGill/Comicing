//
//  ComicBubbleList.m
//  ComicMakingPage
//
//  Created by Ramesh on 31/12/15.
//  Copyright © 2015 ADNAN THATHIYA. All rights reserved.
//

#import "ComicBubbleList.h"

@interface ComicBubbleList ()

@end

@implementation ComicBubbleList
@synthesize bubbleListArray,parentViewController,bubbleLargeListArray;

static NSString * const reuseIdentifier = @"Cell";
static NSString * const reuseIdentifier1 = @"Cell1";

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations
    self.clearsSelectionOnViewWillAppear = NO;
    
    // Register cell classes
    // [self.collectionView registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:reuseIdentifier];
    
    // Do any additional setup after loading the view.
    
    if (bubbleListArray) {
        [bubbleListArray removeAllObjects];
        bubbleListArray = nil;
    }
    if (bubbleLargeListArray) {
        [bubbleLargeListArray removeAllObjects];
        bubbleLargeListArray = nil;
    }
    if (self.bubbleLargeListTextFieldArray) {
        [self.bubbleLargeListTextFieldArray removeAllObjects];
        self.bubbleLargeListTextFieldArray = nil;
    }
    
//    bubbleListArray = [[NSMutableArray alloc] initWithObjects:[UIImage imageNamed:@"Regular_Large_01"],[UIImage imageNamed:@"02 Eh"],[UIImage imageNamed:@"03 Thinking"],[UIImage imageNamed:@"04 Love"],[UIImage imageNamed:@"05 Scared"],[UIImage imageNamed:@"06 Angry_yelling"],[UIImage imageNamed:@"07 Great_Awesome"],[UIImage imageNamed:@"08 Strong_Powerful"],[UIImage imageNamed:@"09 Angry"],[UIImage imageNamed:@"10 Ohno"], nil];

    
    bubbleListArray = [[NSMutableArray alloc] initWithObjects:@"firstBubble",@"Regular_Large_01",@"Eh_Large_1",@"Thinking_Large_01",@"Love_Large_01",@"Scared_Large_01",@"Angry_yelling_Large_01",@"Great_Awesome_Large_01",@"Strong_Powerful_Large_01",@"Angry_Large_01",@"Oh no_Large_01", nil];
    
    bubbleLargeListArray = [[NSMutableArray alloc] initWithObjects:@"firstBubble",@"Regular_Large_01",@"Eh_Large_1",@"Thinking_Large_01",@"Love_Large_01",@"Scared_Large_01",@"Angry_yelling_Large_01",@"Great_Awesome_Large_01",@"Strong_Powerful_Large_01",@"Angry_Large_01",@"Oh no_Large_01", nil];
    
    //May be this is bad idea, but i d't have any option right now sorry.
    self.bubbleLargeListTextFieldArray = [[NSMutableArray alloc] initWithObjects:
                                          [NSValue valueWithCGRect:CGRectMake(40,30,70,70)],
                                          [NSValue valueWithCGRect:CGRectMake(10,40,135,65)],
                                          [NSValue valueWithCGRect:CGRectMake(30,45,90,65)],[NSValue valueWithCGRect:CGRectMake(30,40,100,75)],[NSValue valueWithCGRect:CGRectMake(10,50,120,65)],[NSValue valueWithCGRect:CGRectMake(10,30,120,65)],[NSValue valueWithCGRect:CGRectMake(10,50,130,65)],[NSValue valueWithCGRect:CGRectMake(10,30,130,75)],[NSValue valueWithCGRect:CGRectMake(10,40,130,75)],[NSValue valueWithCGRect:CGRectMake(10,40,130,75)],[NSValue valueWithCGRect:CGRectMake(30,40,110,85)], nil];
    
    
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
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return bubbleListArray.count + 1;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    if(indexPath.item == 0)
    {
        UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:reuseIdentifier1 forIndexPath:indexPath];
        return cell;
    }
    else
    {
        UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:reuseIdentifier forIndexPath:indexPath];
        
        // Configure the cell
        UIImageView *img = (UIImageView*)[cell viewWithTag:1];
        img.image = [UIImage imageNamed:bubbleListArray[indexPath.row  -1]];
        
        return cell;
    }
}

#pragma mark <UICollectionViewDelegate>

-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    if(indexPath.item == 0)
    {
        
    }
    else
    {
        [parentViewController addBubbleWithImage:bubbleLargeListArray[indexPath.row - 1]
                                   TextFiledRect:[self.bubbleLargeListTextFieldArray[indexPath.row - 1] CGRectValue]];
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
    [parentViewController closeBubbleList];
}

@end
