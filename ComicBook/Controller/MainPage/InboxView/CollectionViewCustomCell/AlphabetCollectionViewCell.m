//
//  AlphabetCollectionViewCell.m
//  CurlDemo
//
//  Created by ADNAN THATHIYA on 19/02/16.
//  Copyright © 2016 Vishnu Vardhan PV. All rights reserved.
//

#import "AlphabetCollectionViewCell.h"
#import "AppConstants.h"
@implementation AlphabetCollectionViewCell
-(void)awakeFromNib
{
    [super awakeFromNib];
    CGFloat fontSize = 8;
    if (IS_IPHONE_5)
    {
        fontSize = 7;
        
    }
    else if (IS_IPHONE_6)
    {
        fontSize = 8;
        
    }
    else if (IS_IPHONE_6P)
    {
        fontSize = 9;
    }
   
    self.lblAlphabet.font = [self.lblAlphabet.font fontWithSize:fontSize];

}
@end
