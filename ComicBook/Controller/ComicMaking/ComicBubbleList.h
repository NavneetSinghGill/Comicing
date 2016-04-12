//
//  ComicBubbleList.h
//  ComicMakingPage
//
//  Created by Ramesh on 31/12/15.
//  Copyright © 2015 ADNAN THATHIYA. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ComicMakingViewController.h"
#import "AppConstants.h"

@interface ComicBubbleList : UICollectionViewController

@property(nonatomic,strong) NSMutableArray *bubbleListArray;
@property(nonatomic,strong) NSMutableArray *bubbleLargeListArray;
@property(nonatomic,strong) NSMutableArray *bubbleLargeListTextFieldArray;
@property (nonatomic, strong) ComicMakingViewController *parentViewController;

@end
