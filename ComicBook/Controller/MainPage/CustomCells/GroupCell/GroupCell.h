//
//  GroupCell.h
//  CurlDemo
//
//  Created by Vishnu Vardhan PV on 05/02/16.
//  Copyright © 2016 Vishnu Vardhan PV. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface GroupCell : UITableViewCell

@property(nonatomic,weak)IBOutlet NSLayoutConstraint*widthconstraint;
@property (weak, nonatomic) IBOutlet UILabel *lblDate;
@property (weak, nonatomic) IBOutlet UILabel *lblTime;
@property (weak, nonatomic) IBOutlet UIView *viewComicBook;
@property (weak, nonatomic) IBOutlet UIButton *btnUser;
@property (weak, nonatomic) IBOutlet UIImageView *profileImageView;
@property (weak, nonatomic) IBOutlet UILabel *mUserName;
@property (weak, nonatomic) IBOutlet UILabel *lblComicTitle;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *heightConstraintComicTitle;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *heightConstraintCointainerView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *topSpacingComicView;

@end
