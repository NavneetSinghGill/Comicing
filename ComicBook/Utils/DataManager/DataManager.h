//
//  DataManager.h
//  Inbox
//
//  Created by Vishnu Vardhan PV on 19/12/15.
//  Copyright © 2015 Vishnu Vardhan PV. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DataManager : NSObject

@property (nonatomic, strong) NSArray *friendsArray;
@property (nonatomic, strong) NSArray *groupsArray;
@property (nonatomic, strong) NSArray *activeInboxArray;
@end
