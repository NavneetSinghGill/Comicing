//
//  ComicPage.m
//  ComicMakingPage
//
//  Created by ADNAN THATHIYA on 09/01/16.
//  Copyright © 2016 ADNAN THATHIYA. All rights reserved.
//

#import "ComicPage.h"

NSString* const slideTypeWide = @"wide";
NSString* const slideTypeTall = @"tall";

@implementation ComicPage

//@synthesize containerImage, subviews, subviewData, printScreen,timelineString;
@synthesize containerImagePath, subviews, subviewData,timelineString,printScreenPath,subviewTranformData,titleString, slideType;

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super init];
    if (self)
    {
        containerImagePath = [aDecoder decodeObjectForKey:@"containerImagePath"];
        printScreenPath = [aDecoder decodeObjectForKey:@"printScreenImagePath"];
        subviews = [aDecoder decodeObjectForKey:@"subviews"];
        subviewData = [aDecoder decodeObjectForKey:@"subviewData"];
        subviewTranformData = [aDecoder decodeObjectForKey:@"subviewTranformData"];
        timelineString = [aDecoder decodeObjectForKey:@"timelineString"];
        titleString = [aDecoder decodeObjectForKey:@"titleString"];
        slideType = [aDecoder decodeObjectForKey:@"iswideslide"];
    }
    
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeObject:printScreenPath forKey:@"printScreenImagePath"];
    [aCoder encodeObject:containerImagePath forKey:@"containerImagePath"];
    [aCoder encodeObject:subviews forKey:@"subviews"];
    [aCoder encodeObject:subviewData forKey:@"subviewData"];
    [aCoder encodeObject:subviewTranformData forKey:@"subviewTranformData"];
    [aCoder encodeObject:timelineString forKey:@"timelineString"];
    [aCoder encodeObject:titleString forKey:@"titleString"];
    [aCoder encodeObject:slideType forKey:@"iswideslide"];

}

@end