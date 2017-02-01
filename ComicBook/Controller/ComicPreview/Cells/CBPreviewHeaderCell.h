//
//  CBPreviewHeaderCell.h
//  ComicBook
//
//  Created by Atul Khatri on 07/12/16.
//  Copyright © 2016 Providence. All rights reserved.
//

#import "CBBaseTableViewCell.h"

@interface CBPreviewHeaderCell : CBBaseTableViewCell
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UIButton *horizontalAddButton;
@property (weak, nonatomic) IBOutlet UIButton *verticalAddButton;
@property (weak, nonatomic) IBOutlet UIButton *rainbowColorCircleButton;

@property (strong, nonatomic) NSString *fontName;

@property (strong, nonatomic) NSString *fontName;

@end
