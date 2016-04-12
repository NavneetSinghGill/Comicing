//
//  MZCroppableView.m
//  MZCroppableView
//
//  Created by macbook on 30/10/2013.
//  Copyright (c) 2013 macbook. All rights reserved.
//

#import "MZCroppableView.h"
#import "UIBezierPath-Points.h"
#import "AppConstants.h"

#define VALUE(_INDEX_) [NSValue valueWithCGPoint:points[_INDEX_]]
#define POINT(_INDEX_) [(NSValue *)[points objectAtIndex:_INDEX_] CGPointValue]

@implementation MZCroppableView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}
- (id)initWithImageView:(UIImageView *)imageView
{
    self = [super initWithFrame:imageView.frame];
    
    if (self)
    {
        NSArray *animationArray=[NSArray arrayWithObjects:
                                 [UIImage imageNamed:@"scissor1.png"],
                                 [UIImage imageNamed:@"scissor2.png"],
                                 [UIImage imageNamed:@"scissor3.png"],
                                 [UIImage imageNamed:@"scissor4.png"],
                                 [UIImage imageNamed:@"scissor5.png"],
                                 [UIImage imageNamed:@"scissor6.png"],
                                 nil];
        animationView=[[UIImageView alloc]initWithFrame:CGRectMake(0, 0,33, 30)];
        animationView.backgroundColor = [UIColor clearColor];
        animationView.animationImages = animationArray;
        animationView.animationDuration = .5;
        animationView.animationRepeatCount = 0;
        [animationView startAnimating];
        [self addSubview:animationView];
        animationView.hidden = true;
        
        self.lineWidth = 5.0f;
        [self setBackgroundColor:[UIColor clearColor]];
        [self setClipsToBounds:YES];
        [self setUserInteractionEnabled:YES];
        self.croppingPath = [[UIBezierPath alloc] init];
        [self.croppingPath setLineWidth:self.lineWidth];
        

        //        [self.layer setBorderColor:[[UIColor colorWithPatternImage:[UIImage imageNamed:@"boy.png"]] CGColor]];///just add image name and create image with dashed or doted drawing and add here
        
        const CGFloat dashPattern[] = {10,10,10,10}; //make your pattern here
        [self.croppingPath setLineDash:dashPattern count:4 phase:3];
        [self.croppingPath setLineCapStyle:kCGLineCapRound];
//
        //        [self.layer setBorderColor:[[UIColor colorWithPatternImage:[UIImage imageNamed:@"point.png"]] CGColor]];///just add image name and create image with dashed or doted drawing and add here
        
        //        self.lineColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"point.png"]];
        //        self.lineColor = [UIColor greenColor];
    }
    return self;
}

- (void)drawRect:(CGRect)rect
{
    //    CGContextRef context = UIGraphicsGetCurrentContext();
    //    CGContextSetLineWidth(context, 100);
    //    CGFloat dashes[] = {1,1};
    //    CGContextSetLineDash(context, 2.0, dashes, 2);
    //    CGContextMoveToPoint(context, 0, self.bounds.size.height * 0.5);
    //    CGContextAddLineToPoint(context, self.bounds.size.width, self.bounds.size.height * 0.5);
    //    CGContextSetRGBStrokeColor(context, 0.5, 0.5, 0.5, 1.0);
    //
    //    CGContextStrokePath(context);
    
    
    // Drawing code
    [self.lineColor setStroke];
    [self.croppingPath stroke];
}


#pragma mark - My Methods -
+ (CGRect)scaleRespectAspectFromRect1:(CGRect)rect1 toRect2:(CGRect)rect2
{
    CGSize scaledSize = rect2.size;
    
    float scaleFactor = 1.0;
    
    CGFloat widthFactor  = rect2.size.width / rect1.size.width;
    CGFloat heightFactor = rect2.size.height / rect1.size.width;
    
    if (widthFactor < heightFactor)
        scaleFactor = widthFactor;
    else
        scaleFactor = heightFactor;
    
    scaledSize.height = rect1.size.height *scaleFactor;
    scaledSize.width  = rect1.size.width  *scaleFactor;
    
    return CGRectMake(rect2.origin.x, rect2.origin.y,rect2.size.width, rect2.size.height);
}


+ (CGPoint)convertCGPoint:(CGPoint)point1 fromRect1:(CGSize)rect1 toRect2:(CGSize)rect2
{
    point1.y = rect1.height - point1.y;
    CGPoint result = CGPointMake((point1.x*rect2.width)/rect1.width, (point1.y*rect2.height)/rect1.height);
    return result;
}
+ (CGPoint)convertPoint:(CGPoint)point1 fromRect1:(CGSize)rect1 toRect2:(CGSize)rect2
{
    CGPoint result = CGPointMake((point1.x*rect2.width)/rect1.width, (point1.y*rect2.height)/rect1.height);
    return result;
}


//- (UIImage *)deleteBackgroundOfImage:(UIImageView *)image
//{
//    NSArray *points = [self.croppingPath points];
//    
//    if (points.count > 0 ) {
//        
//        CGRect rect = CGRectZero;
//        rect.size = image.image.size;
//        
//        UIBezierPath *aPath;
//        UIGraphicsBeginImageContextWithOptions(rect.size, YES, 0.0);
//        {
//            [[UIColor blackColor] setFill];
//            UIRectFill(rect);
//            [[UIColor whiteColor] setFill];
//            
//            aPath = [UIBezierPath bezierPath];
//            
//            // Set the starting point of the shape.
//            CGPoint p1 = [MZCroppableView convertCGPoint:[[points objectAtIndex:0] CGPointValue] fromRect1:image.frame.size toRect2:image.image.size];
//            [aPath moveToPoint:CGPointMake(p1.x, p1.y)];
//            
//            for (uint i=1; i<points.count; i++)
//            {
//                CGPoint p = [MZCroppableView convertCGPoint:[[points objectAtIndex:i] CGPointValue] fromRect1:image.frame.size toRect2:image.image.size];
//                [aPath addLineToPoint:CGPointMake(p.x, p.y)];
//            }
//            [aPath closePath];
//            [aPath fill];
//        }
//        
//        UIImage *mask = UIGraphicsGetImageFromCurrentImageContext();
//        UIGraphicsEndImageContext();
//        
//        UIGraphicsBeginImageContextWithOptions(rect.size, NO, 0.0);
//        
//        {
//            CGContextClipToMask(UIGraphicsGetCurrentContext(), rect, mask.CGImage);
//            [image.image drawAtPoint:CGPointZero];
//        }
//        
//        UIImage *maskedImage = UIGraphicsGetImageFromCurrentImageContext();
//        UIGraphicsEndImageContext();
//        
//        CGRect croppedRect = aPath.bounds;
//        
//        croppedRect.origin.y = rect.size.height - CGRectGetMaxY(aPath.bounds);//This because mask become inverse of the actual image;
//        
//        croppedRect.origin.x = croppedRect.origin.x*2;
//        croppedRect.origin.y = croppedRect.origin.y*2;
//        croppedRect.size.width = croppedRect.size.width*2;
//        croppedRect.size.height = croppedRect.size.height*2;
//        if ( UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone )
//        {
//            
//            if ([[UIScreen mainScreen] bounds].size.height >= 669)
//            {
//                croppedRect.size.width = croppedRect.size.width*4;
//                croppedRect.size.height = croppedRect.size.height*4;
//            }
//        }
//        
//        
//        CGImageRef imageRef = CGImageCreateWithImageInRect(maskedImage.CGImage, croppedRect);
//        
//        maskedImage = [UIImage imageWithCGImage:imageRef];
//        
//        return maskedImage;
//    }
//    return nil;
//}

- (UIImage *)deleteBackgroundOfImageWithoutBorder:(UIImageView* )image
{

    NSArray *temppoints = [self.croppingPath points];
//    NSArray *points = [self catmullRomSplineAlgorithmOnPoints:temppoints segments:40];
    UIBezierPath *aPath = [self catmullRomSplineAlgorithmOnPoints_ramesh:temppoints segments:40 fromRect1:image.frame.size toRect2:image.image.size];
    if ([temppoints count] == 0) {
        return image.image;
    }
    
    CGRect rect = CGRectZero;
    rect.size = image.image.size;
    
    aPath = [UIBezierPath bezierPath];
    aPath.miterLimit = -10;
    aPath.flatness = 0;
    
//    float loopCount=1;
//    float loopAdded=1;
//    // Set the starting point of the shape.
//    CGPoint p1 = [MZCroppableView convertCGPoint:[[points objectAtIndex:0] CGPointValue] fromRect1:image.frame.size toRect2:image.image.size];
//    [aPath moveToPoint:CGPointMake(p1.x, p1.y)];
//    
//    for (uint i=1; i<points.count; i++)
//    {
//        CGPoint p = [MZCroppableView convertCGPoint:[[points objectAtIndex:i] CGPointValue] fromRect1:image.frame.size toRect2:image.image.size];
//        
//        if ([aPath containsPoint:p])
//        {
//            break;
//        }
//        
//        [aPath addLineToPoint:CGPointMake(p.x, p.y)];
//        NSLog(@"In the loopAdded %f : %f",p.x,p.y);
//    }
    
    aPath = [self smoothedPathWithGranularity:70 withPath:aPath];
    UIGraphicsBeginImageContextWithOptions(rect.size, YES, 0.0);
    {
        [[UIColor blackColor] setFill];
        UIRectFill(rect);
        [[UIColor whiteColor] setFill];
        
        [aPath closePath];
        [aPath fill];
    }
    
    UIImage *mask = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    NSLog(@"==5");
    UIGraphicsBeginImageContextWithOptions(rect.size, NO, 0.0);
    
    {
        CGContextClipToMask(UIGraphicsGetCurrentContext(), rect, mask.CGImage);
        [image.image drawAtPoint:CGPointZero];
    }
    
    UIImage *maskedImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    NSLog(@"==6");
    // self.imgCropedSection = maskedImage;
    
    CGRect croppedRect = aPath.bounds;
    
    croppedRect.origin.y = rect.size.height - CGRectGetMaxY(aPath.bounds);//This because mask become inverse of the actual image;
    
    croppedRect = CGRectMake(CGRectGetMinX(croppedRect) - 30,
                             CGRectGetMinY(croppedRect) - 30,
                             CGRectGetWidth(croppedRect) + 60,
                             CGRectGetHeight(croppedRect) + 60);
    
    if (IS_IPHONE_5)
    {
        croppedRect.origin.x = croppedRect.origin.x*2;
        croppedRect.origin.y = croppedRect.origin.y*2;
        croppedRect.size.width = croppedRect.size.width*2;
        croppedRect.size.height = croppedRect.size.height*2;
    }
    else if (IS_IPHONE_6)
    {
        croppedRect.origin.x = croppedRect.origin.x*2;
        croppedRect.origin.y = croppedRect.origin.y*2;
        croppedRect.size.width = croppedRect.size.width*4;
        croppedRect.size.height = croppedRect.size.height*4;
    }
    else if (IS_IPHONE_6P)
    {
        croppedRect.origin.x = croppedRect.origin.x*2;
        croppedRect.origin.y = croppedRect.origin.y*2;
        croppedRect.size.width = croppedRect.size.width*6;
        croppedRect.size.height = croppedRect.size.height*6;
    }
    
    CGImageRef imageRef = CGImageCreateWithImageInRect(maskedImage.CGImage, croppedRect);
    
    maskedImage = [UIImage imageWithCGImage:imageRef];
    NSLog(@"==7");
    return maskedImage;
}

//- (UIImage *)deleteBackgroundOfImageWithoutBorder:(UIImageView* )image
//{
//    
//    NSArray *temppoints = [self.croppingPath points];
//    //    NSArray *points = [self catmullRomSplineAlgorithmOnPoints:temppoints segments:40];
//    UIBezierPath *aPath = [self catmullRomSplineAlgorithmOnPoints_ramesh:temppoints segments:40 fromRect1:image.frame.size toRect2:image.image.size];
//    if ([temppoints count] == 0 &&
//        [points count] == 0) {
//        return image.image;
//    }
//    CGRect rect = CGRectZero;
//    rect.size = image.image.size;
//    
//    UIBezierPath *aPath;
//    
//    aPath = [UIBezierPath bezierPath];
//    aPath.miterLimit = -10;
//    aPath.flatness = 0;
//    
//    float loopCount=1;
//    float loopAdded=1;
//    // Set the starting point of the shape.
//    CGPoint p1 = [MZCroppableView convertCGPoint:[[points objectAtIndex:0] CGPointValue] fromRect1:image.frame.size toRect2:image.image.size];
//    [aPath moveToPoint:CGPointMake(p1.x, p1.y)];
//    
//    for (uint i=1; i<points.count; i++)
//    {
//        //        NSLog(@"In the loop %f",loopCount);
//        //        loopCount++;
//        
//        CGPoint p = [MZCroppableView convertCGPoint:[[points objectAtIndex:i] CGPointValue] fromRect1:image.frame.size toRect2:image.image.size];
//        
//        if ([aPath containsPoint:p])
//        {
//            break;
//        }
//        
//        [aPath addLineToPoint:CGPointMake(p.x, p.y)];
//        NSLog(@"In the loopAdded %f : %f",p.x,p.y);
//        //        loopAdded++;
//    }
//    NSLog(@"Pounts Array %@",points);
//    aPath = [self smoothedPathWithGranularity:70 withPath:aPath];
//    UIGraphicsBeginImageContextWithOptions(rect.size, YES, 0.0);
//    {
//        [[UIColor blackColor] setFill];
//        UIRectFill(rect);
//        [[UIColor whiteColor] setFill];
//        
//        [aPath closePath];
//        [aPath fill];
//    }
//    
//    UIImage *mask = UIGraphicsGetImageFromCurrentImageContext();
//    UIGraphicsEndImageContext();
//    NSLog(@"==5");
//    UIGraphicsBeginImageContextWithOptions(rect.size, NO, 0.0);
//    
//    {
//        CGContextClipToMask(UIGraphicsGetCurrentContext(), rect, mask.CGImage);
//        [image.image drawAtPoint:CGPointZero];
//    }
//    
//    UIImage *maskedImage = UIGraphicsGetImageFromCurrentImageContext();
//    UIGraphicsEndImageContext();
//    NSLog(@"==6");
//    // self.imgCropedSection = maskedImage;
//    
//    CGRect croppedRect = aPath.bounds;
//    
//    croppedRect.origin.y = rect.size.height - CGRectGetMaxY(aPath.bounds);//This because mask become inverse of the actual image;
//    
//    croppedRect = CGRectMake(CGRectGetMinX(croppedRect) - 30,
//                             CGRectGetMinY(croppedRect) - 30,
//                             CGRectGetWidth(croppedRect) + 60,
//                             CGRectGetHeight(croppedRect) + 60);
//    
//    if (IS_IPHONE_5)
//    {
//        croppedRect.origin.x = croppedRect.origin.x*2;
//        croppedRect.origin.y = croppedRect.origin.y*2;
//        croppedRect.size.width = croppedRect.size.width*2;
//        croppedRect.size.height = croppedRect.size.height*2;
//    }
//    else if (IS_IPHONE_6)
//    {
//        croppedRect.origin.x = croppedRect.origin.x*2;
//        croppedRect.origin.y = croppedRect.origin.y*2;
//        croppedRect.size.width = croppedRect.size.width*4;
//        croppedRect.size.height = croppedRect.size.height*4;
//    }
//    else if (IS_IPHONE_6P)
//    {
//        croppedRect.origin.x = croppedRect.origin.x*2;
//        croppedRect.origin.y = croppedRect.origin.y*2;
//        croppedRect.size.width = croppedRect.size.width*6;
//        croppedRect.size.height = croppedRect.size.height*6;
//    }
//    
//    CGImageRef imageRef = CGImageCreateWithImageInRect(maskedImage.CGImage, croppedRect);
//    
//    maskedImage = [UIImage imageWithCGImage:imageRef];
//    NSLog(@"==7");
//    return maskedImage;
//}

void getPointsFromBezier1(void *info, const CGPathElement *element)
{
    NSMutableArray *bezierPoints = (__bridge NSMutableArray *)info;
    
    // Retrieve the path element type and its points
    CGPathElementType type = element->type;
    CGPoint *points = element->points;
    
    // Add the points if they're available (per type)
    if (type != kCGPathElementCloseSubpath)
    {
        [bezierPoints addObject:VALUE(0)];
        if ((type != kCGPathElementAddLineToPoint) &&
            (type != kCGPathElementMoveToPoint))
            [bezierPoints addObject:VALUE(1)];
    }
    if (type == kCGPathElementAddCurveToPoint)
        [bezierPoints addObject:VALUE(2)];
}

NSArray *pointsFromBezierPath(UIBezierPath *bpath)
{
    NSMutableArray *points = [NSMutableArray array];
    CGPathApply(bpath.CGPath, (__bridge void *)points, getPointsFromBezier1);
    return points;
}

- (UIBezierPath*)smoothedPathWithGranularity:(NSInteger)granularity withPath:(UIBezierPath *)path;
{
    NSMutableArray *points = [pointsFromBezierPath(path) mutableCopy];
    
    if (points.count < 4) return [path copy];
    
    // Add control points to make the math make sense
    [points insertObject:[points objectAtIndex:0] atIndex:0];
    [points addObject:[points lastObject]];
    
    UIBezierPath *smoothedPath = [path copy];
    [smoothedPath removeAllPoints];
    
    [smoothedPath moveToPoint:POINT(0)];
    
    for (NSUInteger index = 1; index < points.count - 2; index++)
    {
        CGPoint p0 = POINT(index - 1);
        CGPoint p1 = POINT(index);
        CGPoint p2 = POINT(index + 1);
        CGPoint p3 = POINT(index + 2);
        
        // now add n points starting at p1 + dx/dy up until p2 using Catmull-Rom splines
        for (int i = 1; i < granularity; i++)
        {
            float t = (float) i * (1.0f / (float) granularity);
            float tt = t * t;
            float ttt = tt * t;
            
            CGPoint pi; // intermediate point
            pi.x = 0.5 * (2*p1.x+(p2.x-p0.x)*t + (2*p0.x-5*p1.x+4*p2.x-p3.x)*tt + (3*p1.x-p0.x-3*p2.x+p3.x)*ttt);
            pi.y = 0.5 * (2*p1.y+(p2.y-p0.y)*t + (2*p0.y-5*p1.y+4*p2.y-p3.y)*tt + (3*p1.y-p0.y-3*p2.y+p3.y)*ttt);
            
            [smoothedPath addLineToPoint:pi];
        }
        
        // Now add p2
        [smoothedPath addLineToPoint:p2];
    }
    
    // finish by adding the last point
    [smoothedPath addLineToPoint:POINT(points.count - 1)];
    
    return smoothedPath;
}

- (float)findDistance:(CGPoint)point lineA:(CGPoint)lineA lineB:(CGPoint)lineB
{
    CGPoint v1 = CGPointMake(lineB.x - lineA.x, lineB.y - lineA.y);
    CGPoint v2 = CGPointMake(point.x - lineA.x, point.y - lineA.y);
    float lenV1 = sqrt(v1.x * v1.x + v1.y * v1.y);
    float lenV2 = sqrt(v2.x * v2.x + v2.y * v2.y);
    float angle = acos((v1.x * v2.x + v1.y * v2.y) / (lenV1 * lenV2));
    return sin(angle) * lenV2;
}


- (NSArray *)catmullRomSplineAlgorithmOnPoints:(NSArray *)points segments:(int)segments
{
    long count = [points count];
    if(count < 4) {
        return points;
    }
    
    float b[segments][4];
    {
        // precompute interpolation parameters
        float t = 0.0f;
        float dt = 1.0f/(float)segments;
        for (int i = 0; i < segments; i++, t+=dt) {
            float tt = t*t;
            float ttt = tt * t;
            b[i][0] = 0.5f * (-ttt + 2.0f*tt - t);
            b[i][1] = 0.5f * (3.0f*ttt -5.0f*tt +2.0f);
            b[i][2] = 0.5f * (-3.0f*ttt + 4.0f*tt + t);
            b[i][3] = 0.5f * (ttt - tt);
        }
    }
    
    NSMutableArray *resultArray = [NSMutableArray array];
    {
        int i = 0; // first control point
        [resultArray addObject:[points objectAtIndex:0]];
        for (int j = 1; j < segments; j++) {
            CGPoint pointI = [[points objectAtIndex:i] CGPointValue];
            CGPoint pointIp1 = [[points objectAtIndex:(i + 1)] CGPointValue];
            CGPoint pointIp2 = [[points objectAtIndex:(i + 2)] CGPointValue];
            float px = (b[j][0]+b[j][1])*pointI.x + b[j][2]*pointIp1.x + b[j][3]*pointIp2.x;
            float py = (b[j][0]+b[j][1])*pointI.y + b[j][2]*pointIp1.y + b[j][3]*pointIp2.y;
            [resultArray addObject:[NSValue valueWithCGPoint:CGPointMake(px, py)]];
        }
    }
    
    for (int i = 1; i < count-2; i++) {
        // the first interpolated point is always the original control point
        [resultArray addObject:[points objectAtIndex:i]];
        for (int j = 1; j < segments; j++) {
            CGPoint pointIm1 = [[points objectAtIndex:(i - 1)] CGPointValue];
            CGPoint pointI = [[points objectAtIndex:i] CGPointValue];
            CGPoint pointIp1 = [[points objectAtIndex:(i + 1)] CGPointValue];
            CGPoint pointIp2 = [[points objectAtIndex:(i + 2)] CGPointValue];
            float px = b[j][0]*pointIm1.x + b[j][1]*pointI.x + b[j][2]*pointIp1.x + b[j][3]*pointIp2.x;
            float py = b[j][0]*pointIm1.y + b[j][1]*pointI.y + b[j][2]*pointIp1.y + b[j][3]*pointIp2.y;
            [resultArray addObject:[NSValue valueWithCGPoint:CGPointMake(px, py)]];
        }
    }
    
    {
        long i = count-2; // second to last control point
        [resultArray addObject:[points objectAtIndex:i]];
        for (int j = 1; j < segments; j++) {
            CGPoint pointIm1 = [[points objectAtIndex:(i - 1)] CGPointValue];
            CGPoint pointI = [[points objectAtIndex:i] CGPointValue];
            CGPoint pointIp1 = [[points objectAtIndex:(i + 1)] CGPointValue];
            float px = b[j][0]*pointIm1.x + b[j][1]*pointI.x + (b[j][2]+b[j][3])*pointIp1.x;
            float py = b[j][0]*pointIm1.y + b[j][1]*pointI.y + (b[j][2]+b[j][3])*pointIp1.y;
            [resultArray addObject:[NSValue valueWithCGPoint:CGPointMake(px, py)]];
        }
    }
    // the very last interpolated point is the last control point
    [resultArray addObject:[points objectAtIndex:(count - 1)]];
    
    return resultArray;
}

- (UIBezierPath*)catmullRomSplineAlgorithmOnPoints_ramesh:(NSArray *)points segments:(int)segments fromRect1:(CGSize)rect1 toRect2:(CGSize)rect2
{
    UIBezierPath *aPath;
    long count = [points count];
    if(count < 4) {
        return aPath;
    }
//    UIBezierPath *aPath;
    float b[segments][4];
    {
        // precompute interpolation parameters
        float t = 0.0f;
        float dt = 1.0f/(float)segments;
        for (int i = 0; i < segments; i++, t+=dt) {
            float tt = t*t;
            float ttt = tt * t;
            b[i][0] = 0.5f * (-ttt + 2.0f*tt - t);
            b[i][1] = 0.5f * (3.0f*ttt -5.0f*tt +2.0f);
            b[i][2] = 0.5f * (-3.0f*ttt + 4.0f*tt + t);
            b[i][3] = 0.5f * (ttt - tt);
        }
    }
    
    NSMutableArray *resultArray = [NSMutableArray array];
    
    {
        int i = 0; // first control point
        [resultArray addObject:[points objectAtIndex:0]];
        
        //Getting First Point
        
        CGPoint pointI_1 = [[points objectAtIndex:0] CGPointValue];
        CGPoint pointIp1_1 = [[points objectAtIndex:(0 + 1)] CGPointValue];
        CGPoint pointIp2_1 = [[points objectAtIndex:(0 + 2)] CGPointValue];
        float px = (b[0][0]+b[0][1])*pointI_1.x + b[0][2]*pointIp1_1.x + b[0][3]*pointIp2_1.x;
        float py = (b[0][0]+b[0][1])*pointI_1.y + b[0][2]*pointIp1_1.y + b[0][3]*pointIp2_1.y;
        
        [aPath moveToPoint:CGPointMake(px, py)];
        for (int j = 1; j < segments; j++) {
            CGPoint pointI = [[points objectAtIndex:i] CGPointValue];
            CGPoint pointIp1 = [[points objectAtIndex:(i + 1)] CGPointValue];
            CGPoint pointIp2 = [[points objectAtIndex:(i + 2)] CGPointValue];
            float px = (b[j][0]+b[j][1])*pointI.x + b[j][2]*pointIp1.x + b[j][3]*pointIp2.x;
            float py = (b[j][0]+b[j][1])*pointI.y + b[j][2]*pointIp1.y + b[j][3]*pointIp2.y;

            py = rect1.height - py;
            CGPoint result = CGPointMake((px*rect2.width)/rect1.width, (py*rect2.height)/rect1.height);
            
//            [resultArray addObject:[NSValue valueWithCGPoint:CGPointMake(px, py)]];
            [aPath addLineToPoint:result];
        }
    }
    
    for (int i = 1; i < count-2; i++) {
        // the first interpolated point is always the original control point
        [resultArray addObject:[points objectAtIndex:i]];
        for (int j = 1; j < segments; j++) {
            CGPoint pointIm1 = [[points objectAtIndex:(i - 1)] CGPointValue];
            CGPoint pointI = [[points objectAtIndex:i] CGPointValue];
            CGPoint pointIp1 = [[points objectAtIndex:(i + 1)] CGPointValue];
            CGPoint pointIp2 = [[points objectAtIndex:(i + 2)] CGPointValue];
            float px = b[j][0]*pointIm1.x + b[j][1]*pointI.x + b[j][2]*pointIp1.x + b[j][3]*pointIp2.x;
            float py = b[j][0]*pointIm1.y + b[j][1]*pointI.y + b[j][2]*pointIp1.y + b[j][3]*pointIp2.y;
//            [resultArray addObject:[NSValue valueWithCGPoint:CGPointMake(px, py)]];
            
            py = rect1.height - py;
            CGPoint result = CGPointMake((px*rect2.width)/rect1.width, (py*rect2.height)/rect1.height);
            [aPath addLineToPoint:result];
        }
    }
    
    {
        long i = count-2; // second to last control point
        [resultArray addObject:[points objectAtIndex:i]];
        for (int j = 1; j < segments; j++) {
            CGPoint pointIm1 = [[points objectAtIndex:(i - 1)] CGPointValue];
            CGPoint pointI = [[points objectAtIndex:i] CGPointValue];
            CGPoint pointIp1 = [[points objectAtIndex:(i + 1)] CGPointValue];
            float px = b[j][0]*pointIm1.x + b[j][1]*pointI.x + (b[j][2]+b[j][3])*pointIp1.x;
            float py = b[j][0]*pointIm1.y + b[j][1]*pointI.y + (b[j][2]+b[j][3])*pointIp1.y;
//            [resultArray addObject:[NSValue valueWithCGPoint:CGPointMake(px, py)]];
            py = rect1.height - py;
            CGPoint result = CGPointMake((px*rect2.width)/rect1.width, (py*rect2.height)/rect1.height);
            [aPath addLineToPoint:result];
        }
    }
    // the very last interpolated point is the last control point
    [resultArray addObject:[points objectAtIndex:(count - 1)]];
    
    return aPath;
}

//- (UIImage *)deleteBackgroundOfImage:(UIImageView *)image
//{
//    NSArray *temppoints = [self.croppingPath points];
//    
//    NSArray *points = [self catmullRomSplineAlgorithmOnPoints:temppoints segments:30];
//    
//    CGRect rect = CGRectZero;
//    rect.size = image.image.size;
//    
//    UIBezierPath *aPath;
//    UIGraphicsBeginImageContextWithOptions(rect.size, YES, 0.0);
//    {
//        [[UIColor blackColor] setFill];
//        UIRectFill(rect);
//        [[UIColor whiteColor] setFill];
//        
//        aPath = [UIBezierPath bezierPath];
//        aPath.miterLimit = -10;
//        aPath.flatness = 0;
//        
//        // Set the starting point of the shape.
//        CGPoint p1 = [MZCroppableView convertCGPoint:[[points objectAtIndex:0] CGPointValue] fromRect1:image.frame.size toRect2:image.image.size];
//        [aPath moveToPoint:CGPointMake(p1.x, p1.y)];
//        
//        for (uint i=1; i<points.count; i++)
//        {
//            CGPoint p = [MZCroppableView convertCGPoint:[[points objectAtIndex:i] CGPointValue] fromRect1:image.frame.size toRect2:image.image.size];
//            
//            if ([aPath containsPoint:p])
//            {
//                break;
//            }
//            
//            [aPath addLineToPoint:CGPointMake(p.x, p.y)];
//        }
//        [aPath closePath];
//        [aPath fill];
//    }
//    
//    UIImage *mask = UIGraphicsGetImageFromCurrentImageContext();
//    UIGraphicsEndImageContext();
//    
//    UIGraphicsBeginImageContextWithOptions(rect.size, NO, 0.0);
//    
//    {
//        CGContextClipToMask(UIGraphicsGetCurrentContext(), rect, mask.CGImage);
//        [image.image drawAtPoint:CGPointZero];
//    }
//    
//    UIImage *maskedImage = UIGraphicsGetImageFromCurrentImageContext();
//    UIGraphicsEndImageContext();
//
//    
////    NSArray *temppoints = [self.croppingPath points];
////    
////    NSArray *points = [self catmullRomSplineAlgorithmOnPoints:temppoints segments:60];
////    
////    CGRect rect = CGRectZero;
////    rect.size = image.image.size;
////    
////    UIBezierPath *aPath;
////    aPath = [UIBezierPath bezierPath];
////    aPath.flatness = 0;
////    aPath.miterLimit = -100;
////    
////  //  rect = CGRectMake(0, 0, CGRectGetWidth(rect) + 50, CGRectGetHeight(rect) + 50);
////    
////    CGPoint p1 = [MZCroppableView convertCGPoint:[[points objectAtIndex:0] CGPointValue] fromRect1:image.frame.size toRect2:image.image.size];
////    [aPath moveToPoint:CGPointMake(p1.x, p1.y)];
////    
////    for (uint i=1; i<points.count; i++)
////    {
////        CGPoint p = [MZCroppableView convertCGPoint:[[points objectAtIndex:i] CGPointValue] fromRect1:image.frame.size toRect2:image.image.size];
////        
////        if ([aPath containsPoint:p])
////        {
////            break;
////        }
////        
////        [aPath addLineToPoint:CGPointMake(p.x, p.y)];
////    }
////    
////    aPath = [self smoothedPathWithGranularity:60 withPath:aPath];
////    
////    UIGraphicsBeginImageContextWithOptions(rect.size, YES, 0.0);
////    {
////        [[UIColor blackColor] setFill];
////        UIRectFill(rect);
////        [[UIColor whiteColor] setFill];
////        
////        [aPath closePath];
////        [aPath fill];
////    }
////    
////    UIImage *mask = UIGraphicsGetImageFromCurrentImageContext();
////    UIGraphicsEndImageContext();
////    
////    UIGraphicsBeginImageContextWithOptions(rect.size, NO, 0.0);
////    {
////        CGContextClipToMask(UIGraphicsGetCurrentContext(), rect, mask.CGImage);
////        [image.image drawAtPoint:CGPointZero];
////    }
////    
////    UIImage *maskedImage = UIGraphicsGetImageFromCurrentImageContext();
////    UIGraphicsEndImageContext();
//    
//    //--------- white color border
//    
////    UIGraphicsBeginImageContextWithOptions(rect.size, NO, 0.0);
////    {
////        [[UIColor whiteColor] setStroke];
////        
////        [aPath setLineWidth:4];
////        
////        [aPath closePath];
////        [aPath stroke];
////    }
////    
////    UIImage *borderImage = UIGraphicsGetImageFromCurrentImageContext();
////    UIGraphicsEndImageContext();
////    
////    
////    UIGraphicsBeginImageContextWithOptions(rect.size, NO, 0.0);
////    {
////         [[UIColor whiteColor] setFill];
////         UIRectFill(rect);
////    }
////    
////    UIImage *whiteImage = UIGraphicsGetImageFromCurrentImageContext();
////    UIGraphicsEndImageContext();
////    
////    UIGraphicsBeginImageContextWithOptions(rect.size, NO, 0.0);
////    {
////        CGContextClipToMask(UIGraphicsGetCurrentContext(), rect, borderImage.CGImage);
////        [whiteImage drawAtPoint:CGPointZero];
////    }
////    
////    UIImage *whiteflippedImage = UIGraphicsGetImageFromCurrentImageContext();
////    UIGraphicsEndImageContext();
//    
//    //---------------
//    
//    
//    // ------ grey color
//    
////    UIGraphicsBeginImageContextWithOptions(rect.size, NO, 0.0);
////    {
////        [[UIColor colorWithRed:209/255.0f green:211/255.0f blue:212/255.0f alpha:1] setStroke];
////        
////        [aPath setLineWidth:15];
////        
////        [aPath closePath];
////        [aPath stroke];
////    }
////    
////    UIImage *greyborderImage = UIGraphicsGetImageFromCurrentImageContext();
////    UIGraphicsEndImageContext();
////    
////    UIGraphicsBeginImageContextWithOptions(rect.size, NO, 0.0);
////    {
////        [[UIColor colorWithRed:209/255.0f green:211/255.0f blue:212/255.0f alpha:1] setFill];
////        UIRectFill(rect);
////    }
////    
////    UIImage *greyImage = UIGraphicsGetImageFromCurrentImageContext();
////    UIGraphicsEndImageContext();
////    
////    UIGraphicsBeginImageContextWithOptions(rect.size, NO, 0.0);
////    {
////        CGContextClipToMask(UIGraphicsGetCurrentContext(), rect, greyborderImage.CGImage);
////        [greyImage drawAtPoint:CGPointZero];
////    }
////    
////    UIImage *greyflippedImage = UIGraphicsGetImageFromCurrentImageContext();
////    UIGraphicsEndImageContext();
//  
//    // ----------------
//    
//   // UIImage *imageWithGrey = [self drawImage:greyflippedImage inImage:maskedImage atPoint:CGPointMake(0, 0)];
//    
//    
//  //
//  //  maskedImage = [self drawImage:whiteflippedImage inImage:maskedImage atPoint:CGPointMake(0, 0)];
//    
// //   maskedImage = [self drawImage:imageWithWhite inImage:imageWithGrey atPoint:CGPointMake(0, 0)];
//    
//    CGRect croppedRect = aPath.bounds;
//    
//    croppedRect.origin.y = rect.size.height - CGRectGetMaxY(aPath.bounds);//This because mask become inverse of the actual image;
//    
//    croppedRect = CGRectMake(CGRectGetMinX(croppedRect) - 30,
//                             CGRectGetMinY(croppedRect) - 30,
//                             CGRectGetWidth(croppedRect) + 60,
//                             CGRectGetHeight(croppedRect) + 60);
//    if (IS_IPHONE_5)
//    {
//        croppedRect.origin.x = croppedRect.origin.x*2;
//        croppedRect.origin.y = croppedRect.origin.y*2;
//        croppedRect.size.width = croppedRect.size.width*2;
//        croppedRect.size.height = croppedRect.size.height*2;
//    }
//    else if (IS_IPHONE_6)
//    {
//        croppedRect.origin.x = croppedRect.origin.x*2;
//        croppedRect.origin.y = croppedRect.origin.y*2;
//        croppedRect.size.width = croppedRect.size.width*4;
//        croppedRect.size.height = croppedRect.size.height*4;
//    }
//    else if (IS_IPHONE_6P)
//    {
//        croppedRect.origin.x = croppedRect.origin.x*2;
//        croppedRect.origin.y = croppedRect.origin.y*2;
//        croppedRect.size.width = croppedRect.size.width*6;
//        croppedRect.size.height = croppedRect.size.height*6;
//    }
//
//    CGImageRef imageRef = CGImageCreateWithImageInRect(maskedImage.CGImage, croppedRect);
//    
//    maskedImage = [UIImage imageWithCGImage:imageRef];
//    
//    UIImage *shadowImage = [self imageWithShadowForImage:maskedImage];
//    
//    return shadowImage;
//}




#pragma mark - Touch Methods -
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    if ([[NSUserDefaults standardUserDefaults]objectForKey:@"tappEnder"] != nil)
    {
        if (![[[NSUserDefaults standardUserDefaults]objectForKey:@"tappEnder"] isEqualToString:@"not"])
        {
            
            animationView.hidden = false;
            
            UITouch *mytouch=[[touches allObjects] objectAtIndex:0];
            [self.croppingPath moveToPoint:CGPointMake(roundf([mytouch locationInView:self].x), roundf([mytouch locationInView:self].y))];
        }
    }
    else
    {
        animationView.hidden = false;
        
        UITouch *mytouch=[[touches allObjects] objectAtIndex:0];
        [self.croppingPath moveToPoint:CGPointMake(roundf([mytouch locationInView:self].x), roundf([mytouch locationInView:self].y))];
    }
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    CGPoint nowPoint = [[touches anyObject] locationInView:self];
    CGPoint prevPoint = [[touches anyObject] previousLocationInView:self];
    
    if( nowPoint.x <= prevPoint.x && nowPoint.y <= prevPoint.y)
    {
        animationView.transform = CGAffineTransformMakeRotation(.5); //rotation in radians
        
        //        NSLog(@"1");
    }
    else if( nowPoint.x >= prevPoint.x && nowPoint.y >= prevPoint.y)
    {
        animationView.transform = CGAffineTransformMakeRotation(-.5); //rotation in radians
        
        //        NSLog(@"2");
        
    }
    
    
    if ([[NSUserDefaults standardUserDefaults]objectForKey:@"tappEnder"] != nil)
    {
        if (![[[NSUserDefaults standardUserDefaults]objectForKey:@"tappEnder"] isEqualToString:@"not"])
        {
            UITouch *mytouch=[[touches allObjects] objectAtIndex:0];
            
            CGPoint touchLocation = CGPointMake(roundf([mytouch locationInView:self].x), roundf([mytouch locationInView:self].y));
            
            // move the image view
            animationView.center = touchLocation;
            [self.croppingPath addLineToPoint:CGPointMake(roundf([mytouch locationInView:self].x), roundf([mytouch locationInView:self].y))];
            
            [self setNeedsDisplay];
        }
    }
    else
    {
        UITouch *mytouch=[[touches allObjects] objectAtIndex:0];
        
        CGPoint touchLocation = CGPointMake(roundf([mytouch locationInView:self].x), roundf([mytouch locationInView:self].y));
        
        // move the image view
        animationView.center = touchLocation;
        [self.croppingPath addLineToPoint:CGPointMake(roundf([mytouch locationInView:self].x), roundf([mytouch locationInView:self].y))];
        
        [self setNeedsDisplay];
    }
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    
    animationView.hidden = true;
    [[NSUserDefaults standardUserDefaults]setObject:@"not" forKey:@"tappEnder"];
    [[NSUserDefaults standardUserDefaults]synchronize];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"cropFinished"
     object:self];
}

@end
