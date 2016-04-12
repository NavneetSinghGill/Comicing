//
//  GroupsAPIManager.m
//  Inbox
//
//  Created by Vishnu Vardhan PV on 20/12/15.
//  Copyright © 2015 Vishnu Vardhan PV. All rights reserved.
//

#import "GroupsAPIManager.h"
#import "Constants.h"
#import "BaseAPIManager.h"


@implementation GroupsAPIManager

+ (void)getTheListOfGroupsForTheUserID:(NSString *)userID
                      withSuccessBlock:(void(^)(id object))successBlock
                               andFail:(void(^)(NSError *errorMessage))failBlock {
    
    NSString *urlString = [NSString stringWithFormat:@"%@%@%@", BASE_URL, GET_GROUPS_URL, userID];
    [BaseAPIManager getRequestWithURLString:urlString
                              withParameter:nil
                                withSuccess:^(id object) {
                                    successBlock(object);
                                } andFail:^(id errorObj) {
                                    failBlock(errorObj);
                                } showIndicator:YES];
}

+ (void)getListOfGroupMemberForGroupID:(NSString *)groupID
                      withSuccessBlock:(void(^)(id object))successBlock
                               andFail:(void(^)(NSError *errorMessage))failBlock
{
    NSString *urlString = [NSString stringWithFormat:@"%@%@%@", BASE_URL,GET_GROUPS_MEMBER , groupID];
    
    [BaseAPIManager getRequestWithURLString:urlString
                              withParameter:nil
                                withSuccess:^(id object)
     {
         successBlock(object);
         
     } andFail:^(id errorObj) {
         failBlock(errorObj);
     } showIndicator:YES];
}

+ (void)getListComicsOfGroupForGroupID:(NSString *)groupID
                      withSuccessBlock:(void(^)(id object))successBlock
                               andFail:(void(^)(NSError *errorMessage))failBlock
{
    NSString *urlString = [NSString stringWithFormat:@"%@%@%@", BASE_URL,GET_GROUPS_COMICS , groupID];
    
    [BaseAPIManager getRequestWithURLString:urlString
                              withParameter:nil
                                withSuccess:^(id object)
     {
         successBlock(object);
         
     } andFail:^(id errorObj) {
         failBlock(errorObj);
     } showIndicator:YES];
}

@end
