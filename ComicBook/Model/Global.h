//
//  Global.h
//  ComicMakingPage
//
//  Created by ADNAN THATHIYA on 27/12/15.
//  Copyright © 2015 ADNAN THATHIYA. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

#define GlobalObject [Global global]

typedef NS_ENUM(NSInteger, ScreenSizeType)
{
    ScreenSizeTypeUnknown  = 0,
    ScreenSizeTypeIPhone4  = 1,
    ScreenSizeTypeIPhone5  = 2,
    ScreenSizeTypeIPhone6  = 3,
    ScreenSizeTypeIPhone6p = 4
};

@interface Global : NSObject

@property (nonatomic) BOOL isTakePhoto;
@property (nonatomic) BOOL isBlackBoardOpen;

+ (Global *)global;
@property ScreenSizeType deviceType;

@property (strong, nonatomic) NSMutableArray *slides;

@end
