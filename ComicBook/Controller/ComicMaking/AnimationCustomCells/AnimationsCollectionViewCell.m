//
//  AnimationsCollectionViewCell.m
//  ComicBook
//
//  Created by Sanjay Thakkar on 06/09/16.
//  Copyright © 2016 ADNAN THATHIYA. All rights reserved.
//

#import "AnimationsCollectionViewCell.h"

@implementation AnimationsCollectionViewCell
-(void)awakeFromNib
{
    [super awakeFromNib];
    _img_Animation.contentMode = UIViewContentModeScaleAspectFit;
}
@end
