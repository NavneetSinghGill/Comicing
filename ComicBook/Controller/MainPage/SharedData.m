//
//  SharedData.m
//  CurlDemo
//
//  Created by Subin Kurian on 10/19/15.
//  Copyright © 2015 Subin Kurian. All rights reserved.
//

#import "SharedData.h"

@implementation SharedData
@synthesize selectedPageNumber,startedPage,indexSlected;
+ (id)sharedManager {
    static SharedData *sharedMyManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedMyManager = [[self alloc] init];
    });
    return sharedMyManager;
}

- (id)init {
    if (self = [super init]) {
        self.selectedPageNumber=-1;
        self.indexSlected=false;
        self.startedPage=-1;
    }
    return self;
}

@end
