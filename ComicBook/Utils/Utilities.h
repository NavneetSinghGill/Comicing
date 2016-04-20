//
//  Utilities.h
//  CurlDemo
//
//  Created by Vishnu Vardhan PV on 24/12/15.
//  Copyright © 2015 Subin Kurian. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Friend.h"

@interface Utilities : NSObject

+ (NSDictionary *) dictionaryWithPropertiesOfObject:(id)obj;
+ (NSString *)getDateStringForParam:(NSString *)param;
+ (BOOL)isReachable;
+ (Friend *)getTheFriendObjForUserID:(NSString *)userId;

@end
