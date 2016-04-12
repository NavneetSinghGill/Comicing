//
//  ComicsAPIManager.m
//  CurlDemo
//
//  Created by Vishnu Vardhan PV on 06/01/16.
//  Copyright © 2016 Subin Kurian. All rights reserved.
//

#import "ComicsAPIManager.h"
#import "Constants.h"
#import "BaseAPIManager.h"

@implementation ComicsAPIManager

+ (void)getTheComicsWithSuccessBlock:(void(^)(id object))successBlock
                               andFail:(void(^)(NSError *errorMessage))failBlock {
    NSString *urlString = [NSString stringWithFormat:@"%@comics/page/3/itemCount/8", BASE_URL];
    [BaseAPIManager getRequestWithURLString:urlString
                              withParameter:nil
                                withSuccess:^(id object) {
                                    successBlock(object);
                                } andFail:^(id errorObj) {
                                    failBlock(errorObj);
                                } showIndicator:YES];
}

@end
