//
//  PrivateConversationAPIManager.m
//  CurlDemo
//
//  Created by Vishnu Vardhan PV on 22/02/16.
//  Copyright © 2016 Vishnu Vardhan PV. All rights reserved.
//

#import "PrivateConversationAPIManager.h"
#import "Constants.h"
#import "BaseAPIManager.h"

@implementation PrivateConversationAPIManager

// http://68.169.44.163/api/conversations/userId/2/ownerId/1

+ (void)getPrivateConversationWithFriendId:(NSString *)friendId
                             currentUserId:(NSString *)currentUserId
                              SuccessBlock:(void(^)(id object))successBlock
                                   andFail:(void(^)(NSError *errorMessage))failBlock {
    NSString *urlString = [NSString stringWithFormat:@"%@conversations/userId/%@/ownerId/%@", BASE_URL,currentUserId,friendId];
    [BaseAPIManager getRequestWithURLString:urlString
                              withParameter:nil
                                withSuccess:^(id object) {
                                    successBlock(object);
                                } andFail:^(id errorObj) {
                                    failBlock(errorObj);
                                } showIndicator:YES];
}

@end
