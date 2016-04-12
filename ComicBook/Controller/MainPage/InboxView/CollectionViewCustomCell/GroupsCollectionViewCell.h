//
//  GroupsCollectionViewCell.h
//  Inbox
//
//  Created by Vishnu Vardhan PV on 20/12/15.
//  Copyright © 2015 Vishnu Vardhan PV. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Group.h"

@protocol GroupsCellProtocol;

@interface GroupsCollectionViewCell : UICollectionViewCell

@property (nonatomic, weak) IBOutlet UIImageView *groupImageView;
@property (nonatomic, weak) IBOutlet UILabel *groupNameLabel;
@property (nonatomic, strong) Group *groupObject;
@property (nonatomic, strong) id <GroupsCellProtocol> delegate;

- (void)populateCell:(Group *)groupModel;

@end

@protocol GroupsCellProtocol <NSObject>

- (void)didTapImageOfGroup:(Group *)groupObj;

@end
