//
//  UIView+LayerOperation.h
//  ComicBook
//
//  Created by Amit on 17/01/17.
//

#import <UIKit/UIKit.h>

@interface UIView (LayerOperation)

@property (nonatomic) IBInspectable UIColor *borderColor;
@property (nonatomic) IBInspectable CGFloat borderWidth;
@property (nonatomic) IBInspectable CGFloat cornerRadius;
@property (nonatomic) IBInspectable BOOL circularView;

@end
