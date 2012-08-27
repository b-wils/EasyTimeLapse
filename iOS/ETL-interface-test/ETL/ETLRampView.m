//
//  ETLRampView.m
//  ETL
//
//  Created by Carll Hoffman on 8/26/12.
//  Copyright (c) 2012 Microsoft. All rights reserved.
//

#import "ETLRampView.h"

@interface ETLRampView ()
{
    CGPoint p[6];
    //bool draggingLeft, draggingRight;
    UITouch *leftTouch, *rightTouch;
}
@end

@implementation ETLRampView

@synthesize easeIn, easeOut, initial, final;

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) { 
        easeIn = 40;
        easeOut = 40;
        initial = 40;
        final = self.frame.size.height - 40;
        
//        draggingLeft = false;
//        draggingRight = false;
        leftTouch = nil;
        rightTouch = nil;
        
        self.multipleTouchEnabled = YES;
    }
    return self;
}

- (UIBezierPath *)createPath
{
    NSUInteger top = self.frame.size.height - final, bot = self.frame.size.height - initial, w = self.frame.size.width;
    NSUInteger inSpan = easeIn / 4, outSpan = easeOut / 4;

    p[0] = (CGPoint) {0, bot};
    p[1] = (CGPoint) {w/3 - inSpan, bot};
    p[2] = (CGPoint) {w/3 + inSpan * 2, bot - inSpan};
    p[3] = (CGPoint) {2*w/3 - outSpan * 2, top + outSpan};
    p[4] = (CGPoint) {2*w/3 + outSpan, top};
    p[5] = (CGPoint) {w, top};
    
    CGPoint c1 = {p[1].x + easeIn/2, p[1].y}, 
            c2 = {p[2].x + easeIn/2, p[2].y - easeIn/2},
            c3 = {p[3].x - easeOut/2, p[3].y + easeOut/2},
            c4 = {p[4].x - easeOut/2, p[4].y};
    
    UIBezierPath *path = [UIBezierPath bezierPath];
    [path moveToPoint:p[0]];
    [path addLineToPoint:p[1]];
    [path addQuadCurveToPoint:p[2] controlPoint:c1];
    [path addCurveToPoint:p[3] controlPoint1:c2 controlPoint2:c3];
    [path addQuadCurveToPoint:p[4] controlPoint:c4];
    [path addLineToPoint:p[5]];
    [path moveToPoint:(CGPoint){0,0}];
    [path closePath];

    return path;
}

- (void)setEaseIn:(NSUInteger)value
{
    if (value < 10) value = 0;
    easeIn = value;
    [self setNeedsDisplay];
}

- (void)setEaseOut:(NSUInteger)value
{
    if (value < 10) value = 0;
    easeOut = value;
    [self setNeedsDisplay];
}

- (void)drawRect:(CGRect)rect
{
    UIBezierPath *path = [self createPath];
    
    [[UIColor blackColor] setStroke];
    path.lineWidth = 5;
    [path stroke];
    
    if (easeIn > 0) {
        [self drawSpanAt:p[1].x ofWidth:p[2].x - p[1].x];
    }
    else {
        [self drawMarkerAt:p[1].x];
    }

    if (easeOut > 0) {    
        [self drawSpanAt:p[3].x ofWidth:p[4].x - p[3].x];
    }
    else {
        [self drawMarkerAt:p[3].x];
    }
    
    [self drawNubAt:p[1]];
    [self drawNubAt:p[4]];
}

- (void)drawSpanAt:(NSInteger)position ofWidth:(NSUInteger)width
{
    [self doInContext:^(CGContextRef context) {
        CGContextSetLineWidth(context, 0);
        CGColorSpaceRef colorspace = CGColorSpaceCreateDeviceRGB();
        CGFloat components[] = {1.0, 1.0, 1.0, 0.5};
        CGColorRef color = CGColorCreate(colorspace, components);

        CGContextSetFillColorWithColor(context, color);
        CGRect rect = {{position, 0}, {width, self.frame.size.height}};
        CGContextFillRect(context, rect);
        CGColorSpaceRelease(colorspace);
        CGColorRelease(color);
    }];
}

- (void)drawMarkerAt:(NSInteger)position
{
    [self doInContext:^(CGContextRef context) {
        CGContextSetLineWidth(context, 0);
        CGColorSpaceRef colorspace = CGColorSpaceCreateDeviceRGB();
        CGFloat components[] = {1.0, 1.0, 1.0, 0.5};
        CGColorRef color = CGColorCreate(colorspace, components);
        
        CGContextSetStrokeColorWithColor(context, color);
        
        CGFloat dashes[] = {10,10};
        
        CGContextSetLineDash(context, 0.0, dashes, 2);
        CGContextSetLineWidth(context, 5);
        
        CGContextMoveToPoint(context, position, 0);
        CGContextAddLineToPoint(context, position, self.frame.size.height);
        
        CGContextStrokePath(context);
        
        CGColorSpaceRelease(colorspace);
        CGColorRelease(color);
    }];
}

- (void)drawNubAt:(CGPoint)point
{
    [self doInContext:^(CGContextRef context) {
        CGContextSetLineWidth(context, 5);
        CGContextSetRGBFillColor(context, 255, 255, 255, 1);
        CGContextSetRGBStrokeColor(context, 0, 0, 0, 1);

        CGContextFillEllipseInRect(context, CGRectMake(point.x - 5, point.y - 5, 10, 10));
        CGContextStrokeEllipseInRect(context, CGRectMake(point.x - 5, point.y - 5, 10, 10));
    }];
}

- (void)tryBindTouch:(UITouch *)touch
{
    CGPoint point = [touch locationInView:self];
    point.x -= p[1].x;
    point.y -= (self.frame.size.height - initial);
    
    float dist = sqrtf(point.x*point.x + point.y*point.y);
    if (dist < 15) {
        leftTouch = touch;
        return;
    }
    point = [touch locationInView:self];
    point.x -= p[4].x;
    point.y -= (self.frame.size.height - final);
    
    dist = sqrtf(point.x*point.x + point.y*point.y);
    if (dist < 15) {
        rightTouch = touch;
    }

}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    for (UITouch *touch in touches) {
        if (touch.phase == UITouchPhaseBegan) {
            [self tryBindTouch:touch];
        }
    }
    
    [self setNeedsDisplay];
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    for (UITouch *touch in touches) {
        CGPoint point = [touch locationInView:self];
        
        if (touch.phase == UITouchPhaseBegan) {
            [self tryBindTouch:touch];
        }
        
        if ([touch isEqual:leftTouch]) {
            initial = self.frame.size.height - point.y;
        }
        else if ([touch isEqual:rightTouch]) {
            final = self.frame.size.height - point.y; 
        }
    }
    
    [self setNeedsDisplay];
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    for (UITouch *touch in touches) {
        if ([touch isEqual:leftTouch]) {
            leftTouch = nil;
        }
        else if ([touch isEqual:rightTouch]) {
            rightTouch = nil;
        }
    }
}

- (void)doInContext:(void(^)(CGContextRef context))block
{
    CGContextRef context =  UIGraphicsGetCurrentContext();
    CGContextSaveGState(context);
    
    block(context);
    
    CGContextRestoreGState(context);
}

@end