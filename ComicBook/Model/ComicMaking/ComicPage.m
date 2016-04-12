//
//  ComicPage.m
//  ComicMakingPage
//
//  Created by ADNAN THATHIYA on 09/01/16.
//  Copyright © 2016 ADNAN THATHIYA. All rights reserved.
//

#import "ComicPage.h"

@implementation ComicPage

//@synthesize containerImage, subviews, subviewData, printScreen,timelineString;
@synthesize containerImagePath, subviews, subviewData,timelineString,printScreenPath;

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super init];
    if (self)
    {
        containerImagePath = [aDecoder decodeObjectForKey:@"containerImagePath"];
        printScreenPath = [aDecoder decodeObjectForKey:@"printScreenImagePath"];
//        containerImage = [aDecoder decodeObjectForKey:@"image"];
        subviews = [aDecoder decodeObjectForKey:@"subviews"];
        subviewData = [aDecoder decodeObjectForKey:@"subviewData"];
//        printScreen = [aDecoder decodeObjectForKey:@"printScreen"];
        timelineString = [aDecoder decodeObjectForKey:@"timelineString"];
    }
    
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeObject:printScreenPath forKey:@"printScreenImagePath"];
    [aCoder encodeObject:containerImagePath forKey:@"containerImagePath"];
//    [aCoder encodeObject:containerImage forKey:@"image"];
    [aCoder encodeObject:subviews forKey:@"subviews"];
    [aCoder encodeObject:subviewData forKey:@"subviewData"];
//    [aCoder encodeObject:printScreen forKey:@"printScreen"];
    [aCoder encodeObject:timelineString forKey:@"timelineString"];
}

@end