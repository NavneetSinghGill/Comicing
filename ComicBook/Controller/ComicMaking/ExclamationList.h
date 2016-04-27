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

@interface ExclamationList : UICollectionViewController

//@property(nonatomic,strong) NSMutableArray *exclamationListArray;
@property(nonatomic,strong) NSMutableArray *exclamationLargeListArray;
@property (nonatomic, strong) ComicMakingViewController *parentViewController;
@property (nonatomic, strong) NSMutableArray *exclamationSmallListArray;

@end
