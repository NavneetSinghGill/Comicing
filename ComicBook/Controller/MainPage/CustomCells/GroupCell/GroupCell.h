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

@end
