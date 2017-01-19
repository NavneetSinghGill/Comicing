//
//  UIView+LayerOperation.m
//  ComicBook
//
//  Created by Amit on 17/01/17
//

#import "UIView+LayerOperation.h"

@implementation UIView (LayerOperation)

@dynamic borderColor,borderWidth,cornerRadius,circularView;

-(void)setBorderColor:(UIColor *)borderColor{
    [self.layer setBorderColor:borderColor.CGColor];
}

-(void)setBorderWidth:(CGFloat)borderWidth{
    [self.layer setBorderWidth:borderWidth];
}

-(void)setCornerRadius:(CGFloat)cornerRadius{
    [self.layer setCornerRadius:cornerRadius];
}

- (void)setCircularView:(BOOL)circularView {
    if (circularView) {
        [self.layer setCornerRadius:self.frame.size.width/2];
        [self.layer setMasksToBounds:YES];
    }
};

@end
