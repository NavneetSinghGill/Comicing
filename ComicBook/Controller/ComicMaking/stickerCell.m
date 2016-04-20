//
//  stickerCell.m
//  ComicMakingPage
//
//  Created by ADNAN THATHIYA on 04/03/16.
//  Copyright © 2016 ADNAN THATHIYA. All rights reserved.
//

#import "stickerCell.h"

@implementation stickerCell

- (void)startQuivering
{
    CABasicAnimation *quiverAnim = [CABasicAnimation animationWithKeyPath:@"transform.rotation"];
    float startAngle = (-1) * M_PI/180.0;
    float stopAngle = -startAngle;
    quiverAnim.fromValue = [NSNumber numberWithFloat:startAngle];
    quiverAnim.toValue   = [NSNumber numberWithFloat:3 * stopAngle];
    quiverAnim.autoreverses = YES;
    quiverAnim.duration = 0.13;
    quiverAnim.repeatCount = HUGE_VALF;
    quiverAnim.timeOffset = (float)(arc4random() % 100)/100 - 0.50;
    
    [self.layer addAnimation:quiverAnim forKey:@"quivering"];
}

- (void)stopQuivering
{
    [self.layer removeAnimationForKey:@"quivering"];
}

@end
