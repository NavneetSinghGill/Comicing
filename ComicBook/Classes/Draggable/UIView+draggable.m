//
//  UIView+draggable.m
//  UIView+draggable
//
//  Created by Andrea on 13/03/14.
//  Copyright (c) 2014 Fancy Pixel. All rights reserved.
//

#import "UIView+draggable.h"
#import <objc/runtime.h>

@implementation UIView (draggable)

float edgePadding;
#pragma mark - Associated properties

- (void)setPanGesture:(UIPanGestureRecognizer*)panGesture {
    objc_setAssociatedObject(self, @selector(panGesture), panGesture, OBJC_ASSOCIATION_RETAIN);
}

- (UIPanGestureRecognizer*)panGesture {
    return objc_getAssociatedObject(self, @selector(panGesture));
}

- (void)setCagingArea:(CGRect)cagingArea {
    if (CGRectEqualToRect(cagingArea, CGRectZero) ||
        CGRectContainsRect(cagingArea, self.frame)) {
        NSValue *cagingAreaValue = [NSValue valueWithCGRect:cagingArea];
        objc_setAssociatedObject(self, @selector(cagingArea), cagingAreaValue, OBJC_ASSOCIATION_RETAIN);
    }
}

- (CGRect)cagingArea {
    NSValue *cagingAreaValue = objc_getAssociatedObject(self, @selector(cagingArea));
    return [cagingAreaValue CGRectValue];
}

- (void)setHandle:(CGRect)handle {
    CGRect relativeFrame = CGRectMake(0, 0, self.frame.size.width, self.frame.size.height);
    if (CGRectContainsRect(relativeFrame, handle)) {
        NSValue *handleValue = [NSValue valueWithCGRect:handle];
        objc_setAssociatedObject(self, @selector(handle), handleValue, OBJC_ASSOCIATION_RETAIN);
    }
}

- (CGRect)handle {
    NSValue *handleValue = objc_getAssociatedObject(self, @selector(handle));
    return [handleValue CGRectValue];
}

- (void)setShouldMoveAlongY:(BOOL)newShould {
    NSNumber *shouldMoveAlongYBool = [NSNumber numberWithBool:newShould];
    objc_setAssociatedObject(self, @selector(shouldMoveAlongY), shouldMoveAlongYBool, OBJC_ASSOCIATION_RETAIN );
}

- (BOOL)shouldMoveAlongY {
    NSNumber *moveAlongY = objc_getAssociatedObject(self, @selector(shouldMoveAlongY));
    return (moveAlongY) ? [moveAlongY boolValue] : YES;
}

- (void)setShouldMoveAlongX:(BOOL)newShould {
    NSNumber *shouldMoveAlongXBool = [NSNumber numberWithBool:newShould];
    objc_setAssociatedObject(self, @selector(shouldMoveAlongX), shouldMoveAlongXBool, OBJC_ASSOCIATION_RETAIN );
}

- (BOOL)shouldMoveAlongX {
    NSNumber *moveAlongX = objc_getAssociatedObject(self, @selector(shouldMoveAlongX));
    return (moveAlongX) ? [moveAlongX boolValue] : YES;
}

- (void)setDraggingStartedBlock:(void (^)())draggingStartedBlock {
    objc_setAssociatedObject(self, @selector(draggingStartedBlock), draggingStartedBlock, OBJC_ASSOCIATION_RETAIN);
}

- (void (^)())draggingStartedBlock {
    return objc_getAssociatedObject(self, @selector(draggingStartedBlock));
}

- (void)setDraggingEndedBlock:(void (^)())draggingEndedBlock {
    objc_setAssociatedObject(self, @selector(draggingEndedBlock), draggingEndedBlock, OBJC_ASSOCIATION_RETAIN);
}

- (void)setdraggingClosedBlock:(void (^)())draggingClosedBlock {
    objc_setAssociatedObject(self, @selector(draggingClosedBlock), draggingClosedBlock, OBJC_ASSOCIATION_RETAIN);
}

- (void (^)())draggingEndedBlock {
    return objc_getAssociatedObject(self, @selector(draggingEndedBlock));
}
- (void (^)())draggingClosedBlock {
    return objc_getAssociatedObject(self, @selector(draggingClosedBlock));
}
#pragma mark - Gesture recognizer

- (void)handlePan:(UIPanGestureRecognizer*)sender {
    // Check to make you drag from dragging area
    CGPoint locationInView = [sender locationInView:self];
    if (!CGRectContainsPoint(self.handle, locationInView)
        && sender.state == UIGestureRecognizerStateBegan) {
        return;
    }
    
    [self adjustAnchorPointForGestureRecognizer:sender];
    
    if (sender.state == UIGestureRecognizerStateBegan && self.draggingStartedBlock) {
        self.draggingStartedBlock();
    }
    
    if (sender.state == UIGestureRecognizerStateEnded && self.draggingEndedBlock) {
        self.layer.anchorPoint = CGPointMake(0.5, 0.5);
        self.draggingEndedBlock();
    }
    
    CGPoint translation = [sender translationInView:[self superview]];
    
    CGPoint currentlocation = [sender locationInView:[self superview]];
    
//    NSLog(@"handlePan : %@", NSStringFromCGPoint(currentlocation));
//    NSLog(@"translation : %@", NSStringFromCGPoint(translation));
    //    NSLog(@"cagingArea: %@", NSStringFromCGRect(self.cagingArea));
    
    CGFloat newXOrigin = CGRectGetMinX(self.frame) + (([self shouldMoveAlongX]) ? translation.x : 0);
    CGFloat newYOrigin = CGRectGetMinY(self.frame) + (([self shouldMoveAlongY]) ? translation.y : 0);
    
    CGRect cagingArea = self.cagingArea;
    
    CGFloat cagingAreaOriginX = CGRectGetMinX(cagingArea);
    CGFloat cagingAreaOriginY = CGRectGetMinY(cagingArea);
    
    CGFloat cagingAreaRightSide = cagingAreaOriginX + CGRectGetWidth(cagingArea);
    CGFloat cagingAreaBottomSide = cagingAreaOriginY + CGRectGetHeight(cagingArea);

    
    //Letf close
    if (currentlocation.x <= edgePadding) {
        self.draggingClosedBlock();
        return;
    }
    //right close
    else if(currentlocation.x >= (cagingArea.size.width - edgePadding)){
        self.draggingClosedBlock();
        return;
    }
    //Top close
    else if(currentlocation.y <= edgePadding){
        self.draggingClosedBlock();
        return;
    }
    //bottom close
    else if(currentlocation.y >= (cagingArea.size.height - edgePadding)){
        self.draggingClosedBlock();
        return;
    }
    if (!CGRectEqualToRect(cagingArea, CGRectZero)) {
        
        // Check to make sure the view is still within the caging area
        if (newXOrigin <= cagingAreaOriginX ||
            newYOrigin <= cagingAreaOriginY ||
            newXOrigin + CGRectGetWidth(self.frame) >= cagingAreaRightSide ||
            newYOrigin + CGRectGetHeight(self.frame) >= cagingAreaBottomSide) {
            
            // Don't move
            //            newXOrigin = CGRectGetMinX(self.frame);
            //            newYOrigin = CGRectGetMinY(self.frame);
        }
    }
    
    self.frame = CGRectMake(newXOrigin,
                            newYOrigin,
                            CGRectGetWidth(self.frame),
                            CGRectGetHeight(self.frame));
    
    [sender setTranslation:(CGPoint){0, 0} inView:[self superview]];
}

- (void)adjustAnchorPointForGestureRecognizer:(UIGestureRecognizer *)gestureRecognizer {
    if (gestureRecognizer.state == UIGestureRecognizerStateBegan) {
        CGPoint locationInView = [gestureRecognizer locationInView:self];
        CGPoint locationInSuperview = [gestureRecognizer locationInView:self.superview];
        
        self.layer.anchorPoint = CGPointMake(locationInView.x / self.bounds.size.width, locationInView.y / self.bounds.size.height);
        self.center = locationInSuperview;
    }
}

- (void)handleLeftEdgeGesture:(UIScreenEdgePanGestureRecognizer *)gesture {
    self.draggingClosedBlock();
}

- (void)handleRightEdgeGesture:(UIScreenEdgePanGestureRecognizer *)gesture {
    self.draggingClosedBlock();
}

#pragma mark - Drag state handling

- (void)setDraggable:(BOOL)draggable {
    self.panGesture.enabled = draggable;
}

- (void)enableDragging:(float)edgeValue {
    edgePadding = edgeValue;
    self.panGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePan:)];
    self.panGesture.maximumNumberOfTouches = 1;
    self.panGesture.minimumNumberOfTouches = 1;
    self.panGesture.cancelsTouchesInView = NO;
    self.handle = CGRectMake(0, 0, self.frame.size.width, self.frame.size.height);
    //    if (self.edgePadding == 0) {
    //        self.edgePadding = 10;
    //    }
    [self addGestureRecognizer:self.panGesture];
    
    //    [self handleLeftSwipe];
    //    [self handleRightSwipe];
}

- (void)enableDragging {
    edgePadding = 0;
    self.panGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePan:)];
    self.panGesture.maximumNumberOfTouches = 1;
    self.panGesture.minimumNumberOfTouches = 1;
    self.panGesture.cancelsTouchesInView = NO;
    self.handle = CGRectMake(0, 0, self.frame.size.width, self.frame.size.height);
//    if (self.edgePadding == 0) {
//        self.edgePadding = 10;
//    }
    [self addGestureRecognizer:self.panGesture];
    
//    [self handleLeftSwipe];
//    [self handleRightSwipe];
}
-(void)handleLeftSwipe{
    UIScreenEdgePanGestureRecognizer *leftEdgeGesture = [[UIScreenEdgePanGestureRecognizer alloc] initWithTarget:self action:@selector(handleLeftEdgeGesture:)];
    leftEdgeGesture.edges = UIRectEdgeLeft;
    leftEdgeGesture.delegate = self;
    [[self superview] addGestureRecognizer:leftEdgeGesture];
}
-(void)handleRightSwipe{
    UIScreenEdgePanGestureRecognizer *rightEdgeGesture = [[UIScreenEdgePanGestureRecognizer alloc] initWithTarget:self action:@selector(handleRightEdgeGesture:)];
    rightEdgeGesture.edges = UIRectEdgeRight;
    rightEdgeGesture.delegate = self;
    [[self superview] addGestureRecognizer:rightEdgeGesture];
}
@end
