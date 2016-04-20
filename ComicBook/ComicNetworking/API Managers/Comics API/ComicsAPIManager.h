//
//  ComicsAPIManager.h
//  CurlDemo
//
//  Created by Vishnu Vardhan PV on 06/01/16.
//  Copyright © 2016 Subin Kurian. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ComicsAPIManager : NSObject

+ (void)getTheComicsWithSuccessBlock:(void(^)(id object))successBlock
                             andFail:(void(^)(NSError *errorMessage))failBlock;

@end
