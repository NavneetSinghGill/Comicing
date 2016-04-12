//
//  User.h
//  ComicApp
//
//  Created by Ramesh on 26/11/15.
//  Copyright © 2015 Ramesh. All rights reserved.
//

#import "JSONModel.h"

@protocol UserGroup @end

@interface UserGroup : JSONModel

@property (strong, nonatomic) NSString *group_id;
@property (strong, nonatomic) NSString *group_title;
@property (strong, nonatomic) NSString *group_icon;
//@property (strong, nonatomic) NSString *role;
@property (strong, nonatomic) NSMutableArray *members;

@end