//
//  AnimationCollectionVC.h
//  ComicBook
//
//  Created by Sanjay Thakkar on 06/09/16.
//  Copyright © 2016 ADNAN THATHIYA. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AnimationCategoryCollectionViewCell.h"
#import "ComicMakingViewController.h"
#import "AppConstants.h"
@interface AnimationCollectionVC : UIViewController
@property (weak, nonatomic) UIPageControl *pageController;
@property (nonatomic, strong) ComicMakingViewController *parentViewController;
-(void)showGarbageBinForSomeMoment;
-(void)hideGarbageBin;
-(void)stopBeingExcutedAfterSomeMoment;
-(void)showInstructionAndGarbageBinForSomeMoment;
@end
