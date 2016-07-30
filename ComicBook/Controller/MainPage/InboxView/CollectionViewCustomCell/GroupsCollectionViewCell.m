//
//  GroupsCollectionViewCell.m
//  Inbox
//
//  Created by Vishnu Vardhan PV on 20/12/15.
//  Copyright © 2015 Vishnu Vardhan PV. All rights reserved.
//

#import "GroupsCollectionViewCell.h"
#import "UIImageView+WebCache.h"
#import "AppConstants.h"
#import "AppHelper.h"

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
    self.groupImageView.layer.masksToBounds = YES;
    CGFloat fontSize = 7;
    CGFloat borderWidthon;
    if (IS_IPHONE_5)
    {
        borderWidthon = 2;
        fontSize = 6;

    }
    else if (IS_IPHONE_6)
    {
        borderWidthon = 3;
        fontSize = 7;

    }
    else if (IS_IPHONE_6P)
    {
        borderWidthon = 3;
        fontSize = 7;

    }
    else
    {
        borderWidthon = 2;
        fontSize = 6;
    }
    self.groupNameLabel.font = [self.groupNameLabel.font fontWithSize:fontSize];
    if (grp.isSelected && ![self isComicRead:grp.groupId shareType:@"G"])
    {
        self.groupImageView.layer.borderWidth = borderWidthon;
        self.groupImageView.layer.borderColor = [UIColor yellowColor].CGColor;
    }
    else
    {
        self.groupImageView.layer.borderWidth = borderWidthon;
        self.groupImageView.layer.borderColor = [UIColor clearColor].CGColor;
    }


}

- (IBAction)tappedGroupPic:(id)sender {
    if([self.delegate respondsToSelector:@selector(didTapImageOfGroup:)]) {
        [self.delegate didTapImageOfGroup:self.groupObject];
    }
}

#pragma mark DataBase

-(BOOL)isComicRead:(NSString*)user_id shareType:(NSString*)share_type{
    NSError *error = nil;
    // Fetch the devices from persistent data store
    NSManagedObjectContext *context = [[AppHelper initAppHelper] managedObjectContext];
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] initWithEntityName:@"ActiveInbox"];
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"user_id == %@ AND isRead == %@ AND share_type == %@", user_id,@"YES",share_type];
    [fetchRequest setPredicate:predicate];
    NSArray *results = [context executeFetchRequest:fetchRequest error:&error];
    if (results == nil || [results count] ==0) {
        return NO;
    }else{
        return YES;
    }
}
@end
