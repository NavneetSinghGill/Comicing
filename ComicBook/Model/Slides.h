//
//  Slides.h
//  CurlDemo
//
//  Created by Vishnu Vardhan PV on 06/01/16.
//  Copyright © 2016 Subin Kurian. All rights reserved.
//

#import "MTLModel.h"
#import "MTLJSONAdapter.h"

@interface Slides : MTLModel <MTLJSONSerializing>

@property (nonatomic, strong) NSString *comicSlideId;
@property (nonatomic, strong) NSString *slideImage;
@property (nonatomic, strong) NSString *slideStatus;
@property (nonatomic, strong) NSArray *enhancements;

@end
