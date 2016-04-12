//
//  BaseAPIManager.m
//  Inbox
//
//  Created by Vishnu Vardhan PV on 19/12/15.
//  Copyright © 2015 Vishnu Vardhan PV. All rights reserved.
//

#import "BaseAPIManager.h"
#import "AppDelegate.h"
#import "AppHelper.h"

NSString * const CONTENT_TYPE_JSON = @"text/html";

@implementation BaseAPIManager

#pragma mark Request with mutliple parame callback 

+ (void)getRequestWithURL:(NSString *)urlString
            withParameter:(id)parameters
              withSuccess:(void(^)(id object,AFHTTPRequestOperation* operationObjet))successBlock
                  andFail:(void(^)(id errorObj))failBlock
            showIndicator:(BOOL)shouldShowIndicator{
    
    [AppHelper showHUDLoader:shouldShowIndicator];
    
    AFHTTPRequestOperationManager *manager = [[AFHTTPRequestOperationManager alloc]
                                              initWithBaseURL:[NSURL URLWithString:BASE_URL]];
    manager.requestSerializer = [AFJSONRequestSerializer serializer];
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObject:CONTENT_TYPE_JSON];
    //Adding Authorization
    if ([AppHelper getAuthId] && ![[AppHelper getAuthId] isEqualToString:@""]) {
        [manager.requestSerializer setValue:[AppHelper getAuthId] forHTTPHeaderField:@"Authorization"];
    }
    //Adding Nonce
    if ([AppHelper getNonceId] && ![[AppHelper getNonceId] isEqualToString:@""]) {
        [manager.requestSerializer setValue:[AppHelper getNonceId] forHTTPHeaderField:@"Nonce"];
    }
    manager.operationQueue.maxConcurrentOperationCount = 1;
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    [manager GET:urlString
      parameters:parameters
         success:^(AFHTTPRequestOperation *operation,id responseObject) {
             [AppHelper showHUDLoader:NO];
             [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
             successBlock(responseObject,operation);
         } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
             [AppHelper showHUDLoader:NO];
             [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
             failBlock(error);
         }];
    
}
+ (void) postPublicRequestWith:(NSString *)urlString
                          withParameter:(id)parameters
                            withSuccess:(void(^)(id object,AFHTTPRequestOperation* operationObjet))successBlock
                                andFail:(void(^)(id errorObj))failBlock
                          showIndicator:(BOOL)shouldShowIndicator {
    [AppHelper showHUDLoader:shouldShowIndicator];
    
    AFHTTPRequestOperationManager *manager = [[AFHTTPRequestOperationManager alloc]
                                              initWithBaseURL:[NSURL URLWithString:BASE_URL]];
    manager.requestSerializer = [AFJSONRequestSerializer serializer];
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObject:CONTENT_TYPE_JSON];
    //Adding Authorization
    if ([AppHelper getAuthId] && ![[AppHelper getAuthId] isEqualToString:@""]) {
        [manager.requestSerializer setValue:[AppHelper getAuthId] forHTTPHeaderField:@"Authorization"];
    }
    //Adding Nonce
    if ([AppHelper getNonceId] && ![[AppHelper getNonceId] isEqualToString:@""]) {
        [manager.requestSerializer setValue:[AppHelper getNonceId] forHTTPHeaderField:@"Nonce"];
    }
    manager.operationQueue.maxConcurrentOperationCount = 1;
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    [manager POST:urlString
       parameters:parameters
          success:^(AFHTTPRequestOperation *operation,id responseObject)
     {
         [AppHelper showHUDLoader:NO];
         successBlock(responseObject,operation);
         [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
     }
          failure:^(AFHTTPRequestOperation *operation, NSError *error)
     {
         [AppHelper showHUDLoader:NO];
         [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
         failBlock(error);
     }];
}

+ (void) putRequestWithURL:(NSString *)urlString
                   withParameter:(id)parameters
                     withSuccess:(void(^)(id object,AFHTTPRequestOperation* operationObjet))successBlock
                         andFail:(void(^)(id errorObj))failBlock
                   showIndicator:(BOOL)shouldShowIndicator {
    [AppHelper showHUDLoader:shouldShowIndicator];
    AFHTTPRequestOperationManager *manager = [[AFHTTPRequestOperationManager alloc]
                                              initWithBaseURL:[NSURL URLWithString:BASE_URL]];
    manager.requestSerializer = [AFJSONRequestSerializer serializer];
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObject:CONTENT_TYPE_JSON];
    //Adding Authorization
    if ([AppHelper getAuthId] && ![[AppHelper getAuthId] isEqualToString:@""]) {
        [manager.requestSerializer setValue:[AppHelper getAuthId] forHTTPHeaderField:@"Authorization"];
    }
    //Adding Nonce
    if ([AppHelper getNonceId] && ![[AppHelper getNonceId] isEqualToString:@""]) {
        [manager.requestSerializer setValue:[AppHelper getNonceId] forHTTPHeaderField:@"Nonce"];
    }
    manager.operationQueue.maxConcurrentOperationCount = 1;
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    [manager PUT:urlString
      parameters:parameters
         success:^(AFHTTPRequestOperation *operation,id responseObject)
     {
         [AppHelper showHUDLoader:NO];
         [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
         successBlock(responseObject,responseObject);
     }
         failure:^(AFHTTPRequestOperation *operation, NSError *error)
     {
         [AppHelper showHUDLoader:NO];
         [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
         failBlock(error);
     }];
}

+ (void) getRequestWithURLString:(NSString *)urlString
                   withParameter:(id)parameters
                     withSuccess:(void(^)(id object))successBlock
                         andFail:(void(^)(id errorObj))failBlock
                   showIndicator:(BOOL)shouldShowIndicator {
//    MBProgressHUD *HUD = [[MBProgressHUD alloc]initWithWindow:[[[UIApplication sharedApplication] delegate] window]];
//    if (shouldShowIndicator == true) {
//        [BaseAPIManager showHUD:HUD overTheView:YES];
//    }
    AFHTTPRequestOperationManager *manager = [[AFHTTPRequestOperationManager alloc]
                                              initWithBaseURL:[NSURL URLWithString:BASE_URL]];
    manager.requestSerializer = [AFJSONRequestSerializer serializer];
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObject:CONTENT_TYPE_JSON];
    //Adding Authorization
    if ([AppHelper getAuthId] && ![[AppHelper getAuthId] isEqualToString:@""]) {
        [manager.requestSerializer setValue:[AppHelper getAuthId] forHTTPHeaderField:@"Authorization"];
    }
    //Adding Nonce
    if ([AppHelper getNonceId] && ![[AppHelper getNonceId] isEqualToString:@""]) {
        [manager.requestSerializer setValue:[AppHelper getNonceId] forHTTPHeaderField:@"Nonce"];
    }
    manager.operationQueue.maxConcurrentOperationCount = 1;
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    [manager GET:urlString
      parameters:parameters
         success:^(AFHTTPRequestOperation *operation,id responseObject) {
             [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
             if ([[responseObject valueForKey:@"result"] isEqualToString:@"failed"]) {
                 failBlock(@"");
             }else{
                 successBlock(responseObject);
             }
         } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
//             [AppHelper showHUDLoader:NO];
             [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
             failBlock(error);
         }];
}

+ (void) postPublicRequestWithURLString:(NSString *)urlString
                          withParameter:(id)parameters
                            withSuccess:(void(^)(id object))successBlock
                                andFail:(void(^)(id errorObj))failBlock
                          showIndicator:(BOOL)shouldShowIndicator {
    [AppHelper showHUDLoader:shouldShowIndicator];
    
    AFHTTPRequestOperationManager *manager = [[AFHTTPRequestOperationManager alloc]
                                              initWithBaseURL:[NSURL URLWithString:BASE_URL]];
    manager.requestSerializer = [AFJSONRequestSerializer serializer];
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObject:CONTENT_TYPE_JSON];
    //Adding Authorization
    if ([AppHelper getAuthId] && ![[AppHelper getAuthId] isEqualToString:@""]) {
        [manager.requestSerializer setValue:[AppHelper getAuthId] forHTTPHeaderField:@"Authorization"];
    }
    //Adding Nonce
    if ([AppHelper getNonceId] && ![[AppHelper getNonceId] isEqualToString:@""]) {
        [manager.requestSerializer setValue:[AppHelper getNonceId] forHTTPHeaderField:@"Nonce"];
    }
    manager.operationQueue.maxConcurrentOperationCount = 1;
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    [manager POST:urlString
       parameters:parameters
          success:^(AFHTTPRequestOperation *operation,id responseObject)
     {
         [AppHelper showHUDLoader:NO];
         successBlock(responseObject);
         [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
     }
          failure:^(AFHTTPRequestOperation *operation, NSError *error)
     {
         [AppHelper showHUDLoader:NO];
         [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
         failBlock(error);
     }];
}

+ (void) putRequestWithURLString:(NSString *)urlString
                   withParameter:(id)parameters
                     withSuccess:(void(^)(id object))successBlock
                         andFail:(void(^)(id errorObj))failBlock
                   showIndicator:(BOOL)shouldShowIndicator {
    [AppHelper showHUDLoader:shouldShowIndicator];
    AFHTTPRequestOperationManager *manager = [[AFHTTPRequestOperationManager alloc]
                                              initWithBaseURL:[NSURL URLWithString:BASE_URL]];
    manager.requestSerializer = [AFJSONRequestSerializer serializer];
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObject:CONTENT_TYPE_JSON];
    manager.operationQueue.maxConcurrentOperationCount = 1;
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    [manager PUT:urlString
      parameters:parameters
         success:^(AFHTTPRequestOperation *operation,id responseObject)
    {
         [AppHelper showHUDLoader:NO];
         [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
        successBlock(responseObject);
     }
         failure:^(AFHTTPRequestOperation *operation, NSError *error)
     {
         [AppHelper showHUDLoader:NO];
         [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
         failBlock(error);
     }];
}



@end
