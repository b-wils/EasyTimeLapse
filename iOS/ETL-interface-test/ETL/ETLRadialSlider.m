//
//  ETLRadialSlider.m
//  ETL
//
//  Created by Carll Hoffman on 9/3/12.
//  Copyright (c) 2012 Microsoft. All rights reserved.
//

#import "ETLRadialSlider.h"
#import "ETLThumb.h"
#define PI 3.14159265358979323846
#define EPSILON 0.000001
#include <math.h>
#import "ETLUtil.h"
#import <QuartzCore/QuartzCore.h>

bool isClockwise(CGPoint a, CGPoint b);
double distance(CGPoint a, CGPoint b);

@interface ETLRadialCurveLayer : CALayer
{
    double start, end;
}
@property (nonatomic, assign) double theta;
@end

@implementation ETLRadialCurveLayer
@synthesize theta;
- (id)initWithStart:(double)st andEnd:(double)ed
{
    self = [super init];
    if (self) {
        self.delegate = self;
        self.contentsScale = [[UIScreen mainScreen] scale];
        start = st;
        end = ed;
    }
    return self;
}

- (void)drawArcFrom:(CGFloat)start to:(CGFloat)end ofWidth:(CGFloat)width andColor:(UIColor *)color inContext:(CGContextRef)ctx 
{
//    CGPoint center = {self.frame.size.width / 2, self.frame.size.height / 2};
    CGFloat radius = self.frame.size.height/2 - 50;
    
    UIBezierPath *path = [UIBezierPath bezierPathWithArcCenter:self.position radius:radius startAngle:start endAngle:end clockwise:YES];
    CGContextBeginPath(ctx);
    CGContextAddPath(ctx, path.CGPath);
    CGContextSetStrokeColorWithColor(ctx, color.CGColor);
    CGContextSetLineWidth(ctx, width);
    CGContextStrokePath(ctx);
}

- (void)drawLayer:(CALayer *)layer inContext:(CGContextRef)ctx
{
//    CGFloat start = 3*PI/4, end = PI/4;
//    CGFloat start = 5*PI/4, end = 3*PI/4;    
    UIColor *color = [UIColor colorWithRed:48.0/255 green:180.0/255 blue:74.0/255 alpha:0.5];
    [self drawArcFrom:start to:-theta ofWidth:12 andColor:color inContext:ctx];
    
    color = [UIColor colorWithRed:48.0/255 green:180.0/255 blue:74.0/255 alpha:1];
    [self drawArcFrom:start to:-theta ofWidth:8 andColor:color inContext:ctx];

    color = [UIColor colorWithRed:204.0/255 green:204.0/255 blue:204.0/255 alpha:0.5];
    [self drawArcFrom:-theta to:end ofWidth:12 andColor:color inContext:ctx];
    
    color = [UIColor colorWithRed:204.0/255 green:204.0/255 blue:204.0/255 alpha:1];
    [self drawArcFrom:-theta to:end ofWidth:6 andColor:color inContext:ctx];
}
@end

@interface ETLRadialSlider ()
{
    ETLThumb *thumb;
    UITouch *thumbTouch;
    UILabel *pctLabel;
    UIButton *unitButton;
    UIView *menuView;
    ETLRadialCurveLayer *curveLayer;
    
    double start, end;
    CGPoint center;
}
@end

@implementation ETLRadialSlider

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:(NSCoder *)aDecoder];
    if (self) {
        const int xOffset = 30;
        thumb = [[ETLThumb alloc] initWithSize:60];
        start = 5*PI/4, end = 3*PI/4;    
        center = (CGPoint){self.frame.size.width / 2 + xOffset, self.frame.size.height / 2};
        CGFloat radius = self.frame.size.height/2 - 50;
        
        unitButton = [[UIButton alloc] init];
        unitButton.center = center;
        unitButton.titleLabel.textAlignment = UITextAlignmentCenter;
        unitButton.titleLabel.font = [UIFont fontWithName:@"Futura-CondensedMedium" size:48];
        unitButton.backgroundColor = nil;
        unitButton.allTitles = @"seconds";
        [unitButton setTitleColor:[UIColor colorWithRed:47.0/255 green:47.0/255 blue:47.0/255 alpha:1] forState:UIControlStateNormal];
        [unitButton setTitleColor:[UIColor whiteColor] forState:UIControlStateHighlighted];
        unitButton.bounds = CGRectMake(0, center.y + radius - 20, radius*2 - 20, 24);
        [unitButton addTarget:self action:@selector(showUnitMenu:) forControlEvents:UIControlEventTouchUpInside];
        
        center.x -= 145;
        pctLabel = [[UILabel alloc] init]; //WithFrame:CGRectMake(0, center.y - 12, self.frame.size.width, 24)];
        pctLabel.center = center;
        pctLabel.textAlignment = UITextAlignmentRight;
        pctLabel.font = [UIFont fontWithName:@"Futura-CondensedMedium" size:124];
        pctLabel.textColor = [UIColor colorWithRed:47.0/255 green:47.0/255 blue:47.0/255 alpha:1];
        pctLabel.backgroundColor = [UIColor colorWithHue:0 saturation:0 brightness:0 alpha:0];
//        pctLabel.backgroundColor = [UIColor blueColor];
        pctLabel.text = nsprintf(@"%1.0f", 33.33333);
        pctLabel.bounds = CGRectMake(0, center.y - 68, 150, 120);
        center.x += 145;
        
        menuView = [[self.subviews filterWith:^bool(id object) {
            return strcmp(object_getClassName(object), "UIView") == 0;
        }] objectAtIndex:(0)];
        [menuView removeFromSuperview];
        menuView.hidden = true;
        menuView.layer.cornerRadius = 10;
        menuView.layer.borderWidth = 3;
        menuView.layer.borderColor = [UIColor grayColor].CGColor;
        
        [[menuView.subviews filterWith:^bool(id object) {
            return [[object class] isSubclassOfClass:NSClassFromString(@"UIButton")];
        }] eachWith:^(id object) {
            [object addTarget:self action:@selector(selectUnit:) forControlEvents:UIControlEventTouchUpInside];
        }];
        
        curveLayer = [[ETLRadialCurveLayer alloc] initWithStart:start andEnd:end];
        curveLayer.frame = (CGRect){{0,0}, self.frame.size};
        curveLayer.backgroundColor = nil;
        curveLayer.position = (CGPoint){center.x - xOffset/2, center.y};
        curveLayer.theta = 0;
        
        [self addSubview:pctLabel];
        [self addSubview:unitButton];
        [self.layer addSublayer:curveLayer];
        [self.layer addSublayer:thumb.layer];
        [self addSubview:menuView];
        
        [self moveThumbToTheta:[self percentToTheta:0.33333]];
        curveLayer.theta = [self percentToTheta:0.33333];
        
        [self setNeedsDisplay];
        
        unitButton.titleLabel.textColor = [UIColor colorWithRed:47.0/255 green:47.0/255 blue:47.0/255 alpha:1];
    }
    return self;
}

- (void)setNeedsDisplay 
{
    [super setNeedsDisplay];
    [curveLayer setNeedsDisplay];
}

- (void)showUnitMenu:(id)sender
{
    menuView.hidden = false;
    menuView.alpha = 0;
    menuView.transform = CGAffineTransformMakeScale(0.1, 0.1);
    [UIView animateWithDuration:0.2 animations:^{
        menuView.alpha = 1.0;
        menuView.transform = CGAffineTransformMakeScale(1, 1);
    }];
}

- (void)selectUnit:(id)sender
{
    [UIView animateWithDuration:0.2 animations:^{
        menuView.alpha = 0;
        menuView.transform = CGAffineTransformMakeScale(0.1, 0.1);
    } completion:^(BOOL finished) {
        menuView.hidden = true;
    }];
    
    UIButton *btn = (UIButton *)sender;
    [unitButton setAllTitles:btn.titleLabel.text.lowercaseString];
}

-(double) thetaToPercent:(double)theta
{
    double pct = 0;
    
    theta += end;
    pct = theta / (3*PI/2);
    pct = (1 - pct);
    
    return pct;
}

-(double) percentToTheta:(double)pct
{
    double theta = 0;
    theta = (1 - pct) * 3*PI/2;
    theta -= end;
    
    if (theta > PI) {
        theta -= 2*PI;
    }
    
    return theta;
}

- (void)tryBindTouch:(UITouch *)touch
{
    CGPoint point = [touch locationInView:self];
    if(!thumbTouch && distance(point, thumb.position) < 30) {
        thumbTouch = touch;
        thumb.highlighted = true;
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

- (void)moveThumbToTheta:(CGFloat)theta
{
    CGFloat radius = self.frame.size.height/2 - 50;
//     center = {self.frame.size.width / 2, self.frame.size.height / 2};
    CGFloat x = radius * cos(theta) + center.x;
    CGFloat y = -radius * sin(theta) + center.y;
    
    thumb.position = CGPointMake(x, y);
    curveLayer.theta = theta;
    [self setNeedsDisplay];
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    if(thumbTouch) {
        UITouch *touch = thumbTouch; //[event touchesForView:self].anyObject;
        CGFloat radius = self.frame.size.height/2 - 50;
//        CGPoint center = {self.frame.size.width / 2, self.frame.size.height / 2};
        CGFloat x = [touch locationInView:self].x - center.x;
        CGFloat y = [touch locationInView:self].y - center.y;
        CGFloat r = sqrt(x*x + y*y);
        CGFloat theta = acos(x/r);
        
        CGFloat oldX = thumb.position.x - center.x;
        CGFloat oldY = thumb.position.y - center.y;
        CGFloat oldTheta = acos(oldX/radius);
        
        if(isClockwise(CGPointMake(1, 0), CGPointMake(x, y))) theta *= -1;
        if(isClockwise(CGPointMake(1, 0), CGPointMake(oldX, oldY))) oldTheta *= -1;
        
        if (theta > -(start - 2*PI) || theta < -end) {
            if (y < 0) theta = -(start - 2*PI) - 0.01;
            if (y > 0) theta = -end;
            if (ABS(y) < 10) { thumbTouch = nil; thumb.highlighted = false; }
        }
        
        double pct = [self thetaToPercent:theta];
        pctLabel.text = nsprintf(@"%1.0f", pct * 100);
        [self moveThumbToTheta:theta];
    }
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    for (UITouch *touch in touches) {
        if ([touch isEqual:thumbTouch]) {
            thumbTouch = nil;
            thumb.highlighted = false;
        }
    }
    
    [self setNeedsDisplay];
}

@end


bool isClockwise(CGPoint a, CGPoint b)
{
    return (a.x*b.y - a.y*b.x) > 0;
}

double distance(CGPoint a, CGPoint b) 
{
    double dx = a.x - b.x;
    double dy = a.y - b.y;
    return sqrt(dx*dx + dy*dy);
}