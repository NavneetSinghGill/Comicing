//
//  ComicPage.h
//  ComicMakingPage
//
//  Created by ADNAN THATHIYA on 09/01/16.
//  Copyright © 2016 ADNAN THATHIYA. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface ComicPage : NSObject <NSCoding>


@property (strong, nonatomic) NSString *printScreenPath;
@property (strong, nonatomic) NSString *containerImagePath;
//@property (strong, nonatomic) NSData *printScreen;
//@property (strong, nonatomic) NSData *containerImage;
@property (strong, nonatomic) NSMutableArray *subviews;
@property (strong, nonatomic) NSMutableArray *subviewData;
@property (strong, nonatomic) NSMutableArray *subviewTranformData;
@property (strong, nonatomic) NSString *timelineString;

- (id)initWithCoder:(NSCoder *)decoder;
- (void)encodeWithCoder:(NSCoder *)encoder;

@end