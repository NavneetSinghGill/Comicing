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
    IBOutlet UIButton *btn_Recycle;
}
@end

@implementation AnimationCollectionVC

- (void)viewDidLoad {
    [super viewDidLoad];
    btn_Recycle.hidden = YES;
    // Do any additional setup after loading the view.
}
-(void)viewDidAppear:(BOOL)animated
{
}
-(CGFloat)spacingInAnimations
{
    if (IS_IPHONE_6)
    {
        return 19.5;
    }
    else if (IS_IPHONE_6P)
    {
        return 23.8;
    }
    else
    {
        return 4.25;
    }
}
-(void)adjustLayoutForAllThings
{
    if (IS_IPHONE_5)
    {
        //btn_Exclaimation.frame = CGRectMake(10, 63, 18, 42);
        btn_Cross.frame = CGRectMake(20, 106, 20, 17.2);
        clc_Category.frame = CGRectMake(85, 102, 235, 35);
        clc_Animations.frame = CGRectMake(69, 23, 251, 78);
        btn_Recycle.frame = CGRectMake(20, 70, 25, 25);
        
    }
    else if (IS_IPHONE_6)
    {
        //btn_Exclaimation.frame = CGRectMake(11.5, 75.5, 23.5, 56);
        btn_Cross.frame = CGRectMake(20, 116, 25, 21.42);
        clc_Category.frame = CGRectMake(88, 110, 290, 40);
        clc_Animations.frame = CGRectMake(72, 25, 302, 80);
        btn_Recycle.frame = CGRectMake(20, 73, 28, 28);
        
    }
    else if (IS_IPHONE_6P)
    {
        //btn_Exclaimation.frame = CGRectMake(11.5, 78.5, 23.5, 56);
        btn_Cross.frame = CGRectMake(23, 129, 27, 23.13);
        clc_Category.frame = CGRectMake(98, 123, 316, 40);
        clc_Animations.frame = CGRectMake(83, 30, 331, 79);
        btn_Recycle.frame = CGRectMake(23, 78, 29, 29);
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
    return [self bindJson:@"latestAnimationList"];
}

-(NSMutableArray*)getCategoryList{
    NSMutableDictionary* dicObj = [self bindJson];
    return [dicObj objectForKey:@"animationcategories"];
}

-(NSMutableArray*)getAllStickeyList:(NSString *)strCategoryId{
    NSMutableDictionary* dicObj = [self bindJson];
    NSMutableArray* arrayValue = [dicObj objectForKey:@"animationList"];
    
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
        cell.img_Animation.image = [UIImage imageNamed:[NSString stringWithFormat:@"%@",[[arrOfAnimationTemp objectAtIndex:indexPath.row] valueForKey:@"thumImage"]]];
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
        [self.parentViewController addAnimationWithInstructionForObj:[arrOfAnimationTemp objectAtIndex:indexPath.row]];
        
        /*[self.parentViewController addAnimatedSticker:[NSString stringWithFormat:@"%@",[[arrOfAnimationTemp objectAtIndex:indexPath.row] valueForKey:@"image_gif"]]];*/
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
    [self stopBeingExcutedAfterSomeMoment];
}
- (IBAction)garbageAction:(id)sender {
    [self.parentViewController removeExstingAnimatedStickerFromComicPage];
}
-(void)showGarbageBinForSomeMoment
{
    btn_Recycle.hidden = NO;
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(hideGarbageBin) object:nil];
    [self performSelector:@selector(hideGarbageBin) withObject:nil afterDelay:8];
}
-(void)hideGarbageBin
{
    btn_Recycle.hidden = YES;
}
-(void)stopBeingExcutedAfterSomeMoment
{
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(hideGarbageBinAndNotify) object:nil];
    [self hideGarbageBin];
}
-(void)showInstructionAndGarbageBinForSomeMoment
{
    btn_Recycle.hidden = NO;
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(hideGarbageBin) object:nil];
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(hideGarbageBinAndNotify) object:nil];
    [self performSelector:@selector(hideGarbageBinAndNotify) withObject:nil afterDelay:8];
}
-(void)hideGarbageBinAndNotify
{
    [self.parentViewController notifyParentForCompletionOfInterval];
    [self hideGarbageBin];
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
