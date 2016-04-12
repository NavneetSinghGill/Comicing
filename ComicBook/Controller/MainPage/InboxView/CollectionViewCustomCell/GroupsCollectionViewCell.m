//
//  GroupsCollectionViewCell.m
//  Inbox
//
//  Created by Vishnu Vardhan PV on 20/12/15.
//  Copyright © 2015 Vishnu Vardhan PV. All rights reserved.
//

#import "GroupsCollectionViewCell.h"
#import "UIImageView+WebCache.h"

@implementation GroupsCollectionViewCell
@synthesize groupImageView;

- (void)populateCell:(Group *)groupModel
{
    [self makeCircularImageView:groupModel];
    
    self.groupObject = groupModel;
    
    [self.groupImageView sd_setImageWithURL:[NSURL URLWithString:groupModel.groupIcon]];
    
    self.groupNameLabel.text = groupModel.groupTitle;
}

- (void)makeCircularImageView:(Group *)grp
{
    self.groupImageView.layer.cornerRadius = 4.0;
    self.groupImageView.clipsToBounds = YES;

    if (grp.isSelected)
    {
        self.groupImageView.layer.borderWidth = 4.0f;
        self.groupImageView.layer.borderColor = [UIColor yellowColor].CGColor;
    }
    else
    {
        self.groupImageView.layer.borderWidth = 4.0f;
        self.groupImageView.layer.borderColor = [UIColor clearColor].CGColor;
    }


}

- (IBAction)tappedGroupPic:(id)sender {
    if([self.delegate respondsToSelector:@selector(didTapImageOfGroup:)]) {
        [self.delegate didTapImageOfGroup:self.groupObject];
    }
}

@end
