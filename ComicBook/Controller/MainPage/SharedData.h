//
//  SharedData.h
//  CurlDemo
//
//  Created by Subin Kurian on 10/19/15.
//  Copyright © 2015 Subin Kurian. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SharedData : NSObject
@property(nonatomic,assign)int selectedPageNumber;
@property(nonatomic,assign)int startedPage;
@property(nonatomic,assign)bool indexSlected;

+ (id)sharedManager;
@end
