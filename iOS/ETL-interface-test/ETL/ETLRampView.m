//
//  ETLRampView.m
//  ETL
//
//  Created by Carll Hoffman on 8/26/12.
//  Copyright (c) 2012 Microsoft. All rights reserved.
//

#import "ETLRampView.h"
#import "ETLUtil.h"

@interface ETLRampView ()
{
    CGPoint p[6];
    UITouch *initialTouch, *finalTouch, *easeInTouch, *easeOutTouch;
    UILabel *initialLabel, *finalLabel;
    
//    ETLThumb *leftThumb, *rightThumb;
}
@end

@implementation ETLRampView

@synthesize easeIn = _easeIn, easeOut = _easeOut, initial, final;

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) { 
        _easeIn = 40;
        _easeOut = 40;
        initial = 40;
        final = self.frame.size.height - 40;
        
        initialLabel = [[UILabel alloc] init];
        finalLabel = [[UILabel alloc] init];
        self.multipleTouchEnabled = YES;
    }
    return self;
}

- (UIBezierPath *)createPath
{
    NSInteger top = self.frame.size.height - final, bot = self.frame.size.height - initial, w = self.frame.size.width;
    NSInteger inSpan = self.easeIn / 4, outSpan = self.easeOut / 4;
    
    float inPct = self.easeIn / 80.0f;
    float outPct = self.easeOut / 80.0f;

    p[0] = (CGPoint) {0, bot};
    p[1] = (CGPoint) {w/4 - inSpan, bot};
    p[2] = (CGPoint) {w/4 + inSpan * 2, bot - (bot - top) * 0.2 * inPct};
    p[3] = (CGPoint) {3*w/4 - outSpan * 2, top + (bot - top) * 0.2 * outPct};
    p[4] = (CGPoint) {3*w/4 + outSpan, top};
    p[5] = (CGPoint) {w, top};
    
//    printf("bot: %d; top: %d\t\t", bot, top);
//    printf("ease in: %.1f%%; out: %.1f%%\n", inPct * 100, 0.0);
//    printf("p[2]: (%.1f, %.1f)\t\tbot - top: %d\n.", p[2].x, p[2].y, bot - top);
    
    CGPoint c1 = {p[1].x + self.easeIn/3, p[1].y}, 
//            c2 = {p[2].x + easeIn/2, p[2].y - easeIn/2},
//            c3 = {p[3].x - easeOut/2, p[3].y + easeOut/2},
            c4 = {p[4].x - self.easeOut/3, p[4].y};
    
    UIBezierPath *path = [UIBezierPath bezierPath];
    [path moveToPoint:p[0]];
    [path addLineToPoint:p[1]];
//    [path addLineToPoint:p[2]];
//    [path addLineToPoint:p[3]];
//    [path addLineToPoint:p[4]];
    [path addQuadCurveToPoint:p[2] controlPoint:c1];
//    [path addCurveToPoint:p[3] controlPoint1:c2 controlPoint2:c3];
    [path addLineToPoint:p[3]];
    [path addQuadCurveToPoint:p[4] controlPoint:c4];
    [path addLineToPoint:p[5]];
    [path moveToPoint:(CGPoint){0,0}];
    [path closePath];

    return path;
}

- (void)setEaseIn:(NSInteger)value
{
    if (value < 10) value = 0;
    _easeIn = value;
    [self setNeedsDisplay];
}

- (NSInteger)easeIn
{
    return (_easeIn < 10) ? 0 : _easeIn;
}

- (void)setEaseOut:(NSInteger)value
{
    if (value < 10) value = 0;
    _easeOut = value;
    [self setNeedsDisplay];
}

- (NSInteger)easeOut
{
    return (_easeOut < 10) ? 0 : _easeOut;
}

- (void)drawRect:(CGRect)rect
{
    UIBezierPath *path = [self createPath];
    
    [[UIColor blackColor] setStroke];
    path.lineWidth = 5;
    [path stroke];
    
    if (self.easeIn > 0) {
        [self drawSpanAt:p[1].x ofWidth:p[2].x - p[1].x];
    }
    else {
        [self drawMarkerAt:p[1].x];
    }

    if (self.easeOut > 0) {    
        [self drawSpanAt:p[3].x ofWidth:p[4].x - p[3].x];
    }
    else {
        [self drawMarkerAt:p[3].x];
    }
    
    if (initialTouch) {
        initialLabel.text = nsprintf(@"%d", initial);
//        initialLabel.frame = CGRectMake(p[2].x, p[1].y, 100, 100);
        initialLabel.bounds = CGRectMake(p[2].x, p[1].y, 50, -8); 
        initialLabel.backgroundColor = [UIColor whiteColor];
       [initialLabel drawRect:initialLabel.bounds]; 
    }
    
    if (finalTouch) {
        finalLabel.text = nsprintf(@"%d", final);
        finalLabel.bounds = CGRectMake(p[3].x - 50, p[4].y, 50, -8); 
        finalLabel.backgroundColor = [UIColor whiteColor];
        finalLabel.textAlignment = UITextAlignmentRight;
        [finalLabel drawRect:finalLabel.bounds];         
    }
    
//    leftThumb.position = p[1];
//    [leftThumb render];
//    rightThumb.position = p[4];
//    [rightThumb render];
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

- (void)tryBindTouch:(UITouch *)touch
{
    CGPoint point = [touch locationInView:self];

    if (point.x <= p[1].x) {
        initialTouch = touch;
    }
    else if (point.x > p[1].x && point.x <= self.frame.size.width/2 - 20) {
        easeInTouch = touch;
    }
    else if (point.x > self.frame.size.width/2 + 20 && point.x < p[4].x) {
        easeOutTouch = touch;
    }
    else if (point.x >= p[4].x) {
        finalTouch = touch;
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
        if (touch.phase == UITouchPhaseBegan) {
            [self tryBindTouch:touch];
        }
        
        if ([touch isEqual:initialTouch]) {
            initial += [touch previousLocationInView:touch.view].y - [touch locationInView:touch.view].y;
        }
        else if ([touch isEqual:finalTouch]) {
            final += [touch previousLocationInView:touch.view].y - [touch locationInView:touch.view].y;
        }
        else if ([touch isEqual:easeInTouch]) {
            _easeIn -= [touch previousLocationInView:touch.view].x - [touch locationInView:touch.view].x;
            _easeIn = MAX(_easeIn, 0);
            _easeIn = MIN(_easeIn, 80);
        }
        else if ([touch isEqual:easeOutTouch]) {
            _easeOut += [touch previousLocationInView:touch.view].x - [touch locationInView:touch.view].x;
            _easeOut = MAX(_easeOut, 0);          
            _easeOut = MIN(_easeOut, 80);
        }
    }
    
    [self setNeedsDisplay];
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    for (UITouch *touch in touches) {
        if ([touch isEqual:initialTouch]) {
            initialTouch = nil;
        }
        else if ([touch isEqual:finalTouch]) {
            finalTouch = nil;
        }
        else if ([touch isEqual:easeInTouch]) {
            easeInTouch = nil;
        }
        else if ([touch isEqual:easeOutTouch]) {
            easeOutTouch = nil;
        }
    }

    [self setNeedsDisplay];
}

@end