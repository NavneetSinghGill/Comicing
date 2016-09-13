//
//  AnimationCollectionVC.m
//  ComicBook
//
//  Created by Sanjay Thakkar on 06/09/16.
//  Copyright © 2016 ADNAN THATHIYA. All rights reserved.
//

#import "AnimationCollectionVC.h"
#import "AnimationCategoryCollectionViewCell.h"
#import "AnimationsCollectionViewCell.h"
@interface AnimationCollectionVC ()<UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout>
{
    IBOutlet UICollectionView *clc_Animations;
    IBOutlet UICollectionView *clc_Category;
    NSMutableArray *arrOfAnimationTemp;
    NSMutableArray *arrOfCategoryList;
    NSInteger previousSelected;
    IBOutlet UIButton *btn_Exclaimation;
    IBOutlet UIButton *btn_Cross;
    NSMutableArray *arrOfContentOffset;
    BOOL doneFrameChanges;
}
@end

@implementation AnimationCollectionVC

- (void)viewDidLoad {
    [super viewDidLoad];
        // Do any additional setup after loading the view.
}
-(void)viewDidAppear:(BOOL)animated
{
}
-(CGFloat)spacingInAnimations
{
    if (IS_IPHONE_6)
    {
        return 20;
    }
    else if (IS_IPHONE_6P)
    {
        return 25;
    }
    else
    {
        return 17;
    }
}
-(void)adjustLayoutForAllThings
{
    NSLog(@"btn_Cross %@",NSStringFromCGRect(btn_Cross.frame));
    NSLog(@"btn_Exclaimation %@",NSStringFromCGRect(btn_Exclaimation.frame));
    NSLog(@"clc_Category %@",NSStringFromCGRect(clc_Category.frame));
    NSLog(@"clc_Animations %@",NSStringFromCGRect(clc_Animations.frame));
    if (IS_IPHONE_5)
    {
        btn_Exclaimation.frame = CGRectMake(10, 63, 18, 42);
        btn_Cross.frame = CGRectMake(10, 42, 18, 27);
        clc_Category.frame = CGRectMake(43, 85, 277, 30);
        clc_Animations.frame = CGRectMake(43, 20, 277, 60);
    }
    else if (IS_IPHONE_6)
    {
        btn_Exclaimation.frame = CGRectMake(11.5, 75.5, 23.5, 56);
        btn_Cross.frame = CGRectMake(10, 54.5, 23.5, 37.5);
        clc_Category.frame = CGRectMake(43, 100, 332, 30);
        clc_Animations.frame = CGRectMake(43, 35, 332, 66);
    }
    else if (IS_IPHONE_6P)
    {
        btn_Exclaimation.frame = CGRectMake(11.5, 78.5, 23.5, 56);
        btn_Cross.frame = CGRectMake(10, 57.5, 23.5, 37.5);
        clc_Category.frame = CGRectMake(43, 105, 371, 38);
        clc_Animations.frame = CGRectMake(43, 40, 371, 77);
    }
}
-(void)viewDidLayoutSubviews
{
    
    [self adjustLayoutForAllThings];
    if (!doneFrameChanges)
    {
        doneFrameChanges = YES;
        arrOfCategoryList = [self getCategoryList];
        [clc_Category reloadData];
        arrOfAnimationTemp = [[NSMutableArray alloc]init];
        arrOfContentOffset = [[NSMutableArray alloc]init];
        CGFloat lastFloat = 0;
        for (int i=0; i<arrOfCategoryList.count; i++)
        {
            NSMutableArray *arrIgot = [self getAllStickeyList:[[arrOfCategoryList objectAtIndex:i] valueForKey:@"categoryid"]];
            [arrOfContentOffset addObject:@{
                                            @"from":[NSString stringWithFormat:@"%f",lastFloat],
                                            @"to":[NSString stringWithFormat:@"%f",lastFloat+(arrIgot.count*(clc_Animations.frame.size.height+[self spacingInAnimations]))]
                                            }];
            lastFloat += (arrIgot.count*(clc_Animations.frame.size.height+[self spacingInAnimations])) +1;
            [arrOfAnimationTemp addObjectsFromArray:arrIgot];
        }
        [clc_Animations performBatchUpdates:^{
            [clc_Animations reloadData];
        } completion:^(BOOL finished) {
            previousSelected = 0;
            [self makeFirstRowSelectedAtStart];
        }];
        
    }

}
-(id)bindJson:(NSString*)fileName{
    
    NSString *jsonFilePath = [[NSBundle mainBundle] pathForResource:fileName ofType:@"json"];
    if (!jsonFilePath) {
    }
    
    NSError *error = nil;
    NSInputStream *inputStream = [[NSInputStream alloc] initWithFileAtPath:jsonFilePath];
    [inputStream open];
    id jsonObject = [NSJSONSerialization JSONObjectWithStream: inputStream
                                                      options:kNilOptions
                                                        error:&error];
    [inputStream close];
    if (error) {
        return nil;
    }
    return jsonObject;
    
}
-(id)bindJson{
    return [self bindJson:@"AnimationList"];
}

-(NSMutableArray*)getCategoryList{
    NSMutableDictionary* dicObj = [self bindJson];
    return [dicObj objectForKey:@"stickercategories"];
}

-(NSMutableArray*)getAllStickeyList:(NSString *)strCategoryId{
    NSMutableDictionary* dicObj = [self bindJson];
    NSMutableArray* arrayValue = [dicObj objectForKey:@"stickeyimages"];
    
    //    NSMutableArray* stickeyArray = [[self getAllStickeyList:@"0" ArrayObje:arrayValue] mutableCopy];
    
   // float scoreValue = [AppHelper getCurrentScoreFromDB];
   // NSMutableArray* stickeyArray = [[self getAllStickeyList:[NSString stringWithFormat:@"%.f", scoreValue]
   //                                               ArrayObje:arrayValue] mutableCopy];
   // NSMutableArray *arrBefore = [self addOtherStickersByConditions];
   // [arrBefore addObjectsFromArray:stickeyArray];
    
    
    
    
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:
                              @"categoryid CONTAINS[cd] %@", strCategoryId];
    NSArray *matchingDicts = [arrayValue filteredArrayUsingPredicate:predicate];
   NSMutableArray* stickeyArray = [matchingDicts mutableCopy];
    
    
    
   
    
    return stickeyArray;
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    if (collectionView == clc_Category)
    {
        return arrOfCategoryList.count;
    }
    else
    {
        return arrOfAnimationTemp.count;
    }
    
}
-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    if (clc_Category == collectionView)
    {
        NSLog(@"%ld",(long)indexPath.row);
    static NSString *identifier = @"AnimationCategoryCollectionViewCell";
        AnimationCategoryCollectionViewCell *cell =  [collectionView dequeueReusableCellWithReuseIdentifier:identifier forIndexPath:indexPath];
        cell.img_Category.image = [UIImage imageNamed:[[arrOfCategoryList objectAtIndex:indexPath.row] valueForKey:@"imagename"]];
        return cell;
    }
    else
    {
        
        static NSString *identifier = @"AnimationsCollectionViewCell";
        AnimationsCollectionViewCell *cell =  [collectionView dequeueReusableCellWithReuseIdentifier:identifier forIndexPath:indexPath];
        cell.img_Animation.image = [UIImage imageNamed:[NSString stringWithFormat:@"%@.gif",[[arrOfAnimationTemp objectAtIndex:indexPath.row] valueForKey:@"image_gif"]]];
        return cell;
    }
}
- (CGFloat)collectionView:(UICollectionView *)collectionView
                   layout:(UICollectionViewLayout*)collectionViewLayout
minimumLineSpacingForSectionAtIndex:(NSInteger)section
{
    if (clc_Category==collectionView)
    {
        if (IS_IPHONE_6)
        {
            return 27;
        }
        else if (IS_IPHONE_6P)
        {
            return 27;
        }
        else
        {
            return 17;
        }
    }
    else
    {
        return [self spacingInAnimations];
    }
}
-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    if (clc_Animations == collectionView)
    {
        [self.parentViewController addExclamationListImage:[NSString stringWithFormat:@"%@.gif",[[arrOfAnimationTemp objectAtIndex:indexPath.row] valueForKey:@"image_gif"]]];
    }
    else
    {
        
        [clc_Animations setContentOffset:CGPointMake([[[arrOfContentOffset objectAtIndex:indexPath.row] valueForKey:@"from"] floatValue], 0) animated:YES];
    }
}
-(CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    return CGSizeMake(collectionView.frame.size.height, collectionView.frame.size.height);
}
-(void)makeCategorySelected:(NSInteger)row ForBool:(BOOL)arg
{
    if (arg)
    {
        AnimationCategoryCollectionViewCell *cell = (AnimationCategoryCollectionViewCell *)[clc_Category cellForItemAtIndexPath:[NSIndexPath indexPathForRow:row inSection:0]];
        cell.img_Category.image = [UIImage imageNamed:[[arrOfCategoryList objectAtIndex:row] valueForKey:@"imagename_selected"]];
        [self makeCategorySelected:previousSelected ForBool:NO];
        previousSelected = row;

    }
    else
    {
        AnimationCategoryCollectionViewCell *cell = (AnimationCategoryCollectionViewCell *)[clc_Category cellForItemAtIndexPath:[NSIndexPath indexPathForRow:row inSection:0]];
        cell.img_Category.image = [UIImage imageNamed:[[arrOfCategoryList objectAtIndex:row] valueForKey:@"imagename"]];
    }
}

-(void)makeFirstRowSelectedAtStart
{
    AnimationCategoryCollectionViewCell *cell = (AnimationCategoryCollectionViewCell *)[clc_Category cellForItemAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
    cell.img_Category.image = [UIImage imageNamed:[[arrOfCategoryList objectAtIndex:0] valueForKey:@"imagename_selected"]];
}
-(UIImage *)getTintedImage:(UIImage *)img
{
    UIImage *newImage = [img imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    UIGraphicsBeginImageContextWithOptions(img.size, NO, newImage.scale);
    [[UIColor redColor] set];
    [newImage drawInRect:CGRectMake(0, 0, img.size.width, newImage.size.height)];
    newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return  newImage;
}
-(void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    /*CGFloat pageWidth = scrollView.frame.size.width; // you need to have a **iVar** with getter for scrollView
    float fractionalPage = scrollView.contentOffset.x / ((clc_Animations.frame.size.height+[self spacingInAnimations])*6);
    NSInteger page = lround(fractionalPage);
    //self.pageController.currentPage = page;*/
    NSInteger page = [self indexFromOffset:scrollView.contentOffset.x];
    if (previousSelected == page || page <0 || page>5)
    {
        return;
    }
    [self makeCategorySelected:page ForBool:YES];
}
-(NSInteger)indexFromOffset:(CGFloat)offset
{
    NSInteger index;
    for (int i=0; i<arrOfContentOffset.count; i++)
    {
        NSDictionary *range = [arrOfContentOffset objectAtIndex:i];
        if (offset>=[[range valueForKey:@"from"] floatValue]&& offset <= [[range valueForKey:@"to"] floatValue])
        {
            index = i;
            break;
        }
    }
    return index;
}
- (IBAction)closeAction:(id)sender {
    [self.parentViewController closeExclamationList];
}
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
