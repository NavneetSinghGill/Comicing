//
//  Global.m
//  ComicMakingPage
//
//  Created by ADNAN THATHIYA on 27/12/15.
//  Copyright © 2015 ADNAN THATHIYA. All rights reserved.
//

#import "Global.h"

@implementation Global

@synthesize isTakePhoto,deviceType,isBlackBoardOpen,placeholder_comic;

+ (Global *)global
{
    static Global *global = nil;
    
    static dispatch_once_t onceToken;
    
    dispatch_once(&onceToken, ^
                  {
                      global = [[self alloc] init];
                  });
    
    return global;
}

- (instancetype)init
{
    if (self = [super init])
    {
        deviceType = [self identifyDeviceType];
        
        placeholder_comic = [UIImage imageNamed:@"placeholder-comic"];
    }
    
    return self;
}

- (ScreenSizeType)identifyDeviceType
{
    CGSize screenSize = [UIScreen mainScreen].bounds.size;
    
    if(screenSize.height == 480)
    {
        return ScreenSizeTypeIPhone4;
    }
    else if(screenSize.height == 568)
    {
        return ScreenSizeTypeIPhone5;
    }
    else if (screenSize.height == 667)
    {
        return ScreenSizeTypeIPhone6;
    }
    else if (screenSize.height == 736)
    {
        return ScreenSizeTypeIPhone6p;
    }
    
    return ScreenSizeTypeUnknown;
}


@end
