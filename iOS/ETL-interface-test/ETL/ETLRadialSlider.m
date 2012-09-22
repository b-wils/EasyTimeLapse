//
//  ETLRadialSlider.m
//  ETL
//
//  Created by Carll Hoffman on 9/3/12.
//  Copyright (c) 2012 Carll Hoffman. All rights reserved.
//

#import "ETLRadialSlider.h"
#import "ETLThumb.h"
#include <math.h>
#import "ETLUtil.h"
#import <QuartzCore/QuartzCore.h>

bool isClockwise(CGPoint a, CGPoint b);
double distance(CGPoint a, CGPoint b);

@interface ETLRadialCurveLayer : CALayer
{
    double start, end;
    CAShapeLayer *fill, *track, *fillFade, *disableFade;
}
@property (nonatomic, assign) double theta;

- (void)setEnabled:(bool)value;
- (void)setColor:(UIColor *)value;
@end

@implementation ETLRadialCurveLayer
@synthesize theta;
- (id)initWithStart:(double)st andEnd:(double)ed
{
    self = [super init];
    if (self) {
        self.contentsScale = [[UIScreen mainScreen] scale];
        start = st;
        end = ed;
        
        track = [CAShapeLayer layer];
        track.fillColor = [UIColor clearColor].CGColor;
        track.strokeColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.4].CGColor;
        track.lineWidth = 8;
        
        fill = [CAShapeLayer layer];
        fill.fillColor = [UIColor clearColor].CGColor;
        fill.strokeColor = [UIColor blackColor].CGColor;
        fill.lineWidth = 8;
        
        fillFade = [CAShapeLayer layer];
        fillFade.fillColor = [UIColor clearColor].CGColor;
        fillFade.strokeColor = [UIColor blackColor].CGColor;
        fillFade.lineWidth = 12;
        fillFade.opacity = 0.5;
        
        disableFade = [CAShapeLayer layer];
        disableFade.fillColor = [UIColor clearColor].CGColor;
        disableFade.strokeColor = [UIColor colorWithRed:1 green:1 blue:1 alpha:1].CGColor;
        disableFade.lineWidth = 12;
        disableFade.opacity = 0;
        
        [self addSublayer:track];
        [self addSublayer:fillFade];
        [self addSublayer:fill];
        [self addSublayer:disableFade];
    }
    return self;
}

- (CGPathRef) arcFrom:(CGFloat)st to:(CGFloat)ed
{
    CGFloat radius = self.frame.size.height/2 - 50;
    
    UIBezierPath *path = [UIBezierPath bezierPathWithArcCenter:self.position radius:radius startAngle:st endAngle:ed clockwise:YES];
    CGPathRef pathRef = path.CGPath;
    
    CGPathRetain(pathRef);
    return path.CGPath;
}

- (void)setTheta:(double)value
{
    theta = value;
    
    track.path = [self arcFrom:-theta to:end];
    fill.path = [self arcFrom:start to:-theta];
    fillFade.path = [self arcFrom:start to:-theta];
    disableFade.path = [self arcFrom:start to:end];
}

- (void)setColor:(UIColor *)value
{
    fill.strokeColor = value.CGColor;
    fillFade.strokeColor = value.CGColor;
}

- (void)setEnabled:(bool)value
{
    disableFade.opacity = value ? 0 : 0.5;
}

//- (void)dealloc
//{
//    track.path = nil;
//    fill.path = nil;
//    fillFade.path = nil;
//    disableFade.path = nil;
//}
@end

@interface ETLRadialSlider ()
{
    ETLThumb *thumb;
    UITouch *thumbTouch;
    UILabel *pctLabel;
    UIButton *unitButton;
    ETLRadialCurveLayer *curveLayer;
    
    double start, end, min, max;
    CGPoint center;
    
    // HACK animation hack
    CGFloat targetTheta;
    NSTimer *animationTimer;
}
@end

@implementation ETLRadialSlider

@synthesize slideEnabled, value;

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:(NSCoder *)aDecoder];
    if (self) {
        [self setupView];
    }
    
    return self;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setupView];
    }
    
    return self;
}

- (void)setupView
{
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
    [unitButton setTitleColor:[UIColor colorWithRed:47.0/255 green:47.0/255 blue:47.0/255 alpha:1] forState:UIControlStateNormal];
    [unitButton setTitleColor:[UIColor whiteColor] forState:UIControlStateHighlighted];
    unitButton.bounds = CGRectMake(0, center.y + radius - 20, radius*2 - 20, 24);
    [unitButton addTarget:self.superview action:@selector(showUnitMenu:) forControlEvents:UIControlEventTouchUpInside];
    
    center.x -= 145;
    pctLabel = [[UILabel alloc] init];
    pctLabel.center = center;
    pctLabel.textAlignment = UITextAlignmentRight;
    pctLabel.font = [UIFont fontWithName:@"Futura-CondensedMedium" size:124];
    pctLabel.textColor = [UIColor colorWithRed:47.0/255 green:47.0/255 blue:47.0/255 alpha:1];
    pctLabel.backgroundColor = [UIColor colorWithHue:0 saturation:0 brightness:0 alpha:0];
    pctLabel.text = nsprintf(@"%1.0f", 33.33333);
    pctLabel.bounds = CGRectMake(0, center.y - 68, 150, 120);
    center.x += 145;
        
    curveLayer = [[ETLRadialCurveLayer alloc] initWithStart:start andEnd:end];
    curveLayer.frame = (CGRect){{0,0}, self.frame.size};
    curveLayer.backgroundColor = nil;
    curveLayer.position = (CGPoint){center.x - xOffset/2, center.y};
    curveLayer.theta = 0;
    
    [self addSubview:pctLabel];
    [self addSubview:unitButton];
    [self.layer addSublayer:curveLayer];
    [self.layer addSublayer:thumb.layer];
    
    [self moveThumbToTheta:[self percentToTheta:0.33333]];
    curveLayer.theta = [self percentToTheta:0.33333];
    
    [self setNeedsDisplay];
    
    unitButton.titleLabel.textColor = [UIColor colorWithRed:47.0/255 green:47.0/255 blue:47.0/255 alpha:1];
    slideEnabled = true;
}

- (void)setNeedsDisplay 
{
    [super setNeedsDisplay];
    [curveLayer setNeedsDisplay];
}

- (void)setColor:(UIColor *)color 
{
    [curveLayer setColor:color];
}

- (void)updateUI
{
    min = value.bounds.lower.doubleValue;
    max = value.bounds.upper.doubleValue;
    unitButton.allTitles = value.unit;
    self.slideEnabled = ![value.unit isEqualToString:@"forever"];
    pctLabel.text = nsprintf(@"%1.0f", value.scaledValue.floatValue);
    
    double pct = (value.scaledValue.doubleValue - min) / (max - min);
    [self moveThumbToTheta:[self percentToTheta:pct]];
}

- (void)setValue:(ETLUnitScaleValue *)val
{
    [value removeObserver:self forKeyPath:@"scaledValue"];
    [value removeObserver:self forKeyPath:@"unit"];
    value = val;
    [value addObserver:self forKeyPath:@"scaledValue" options:NSKeyValueObservingOptionNew context:nil];
    [value addObserver:self forKeyPath:@"unit" options:NSKeyValueObservingOptionNew context:nil];
    
//    [self updateUI];
    //HACK animation hack
    CGFloat oldTheta = [self calculateTheta];
    [self updateUI];
    targetTheta = [self calculateTheta];
    [self moveThumbToTheta:oldTheta];
    
    if (animationTimer) {
        [animationTimer invalidate];
        animationTimer = nil;
    }
    animationTimer = [NSTimer scheduledTimerWithTimeInterval:0.02 target:self selector:@selector(animateTheta:) userInfo:nil repeats:YES];
}

//HACK animation hack
- (void)animateTheta:(NSTimer *)timer
{
    CGFloat curTheta = [self calculateTheta];
    CGFloat dTheta = targetTheta < curTheta ? -0.18 : 0.18;
    CGFloat newTheta = ABS(dTheta) >= ABS(targetTheta - curTheta) ? targetTheta : curTheta + dTheta;
    
    [self moveThumbToTheta:newTheta];
    
    if(ABS(targetTheta - newTheta) <= EPSILON) {
        [animationTimer invalidate];
        animationTimer = nil;
    }
}

- (void)setSlideEnabled:(bool)val
{
    slideEnabled = val;
    curveLayer.enabled = val;
    thumb.enabled = val;
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if (object == value) {
        [self updateUI];
    }
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

- (double)radius
{
    return self.frame.size.height/2 - 50;   
}

- (double)calculateTheta 
{
    CGFloat x = thumb.position.x - center.x;
    CGFloat y = thumb.position.y - center.y;
    CGFloat ret = acos(x/self.radius);
    if(isClockwise(CGPointMake(1, 0), CGPointMake(x, y))) ret *= -1;
    return ret;
}

- (void)tryBindTouch:(UITouch *)touch
{
    CGPoint point = [touch locationInView:self];
    if(!thumbTouch && thumb.enabled && distance(point, thumb.position) < 30) {
        thumbTouch = touch;
        thumb.highlighted = true;
        
        //HACK animation hack
        if (animationTimer) {
            [animationTimer invalidate];
            animationTimer = nil;
        }
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
    CGFloat radius = self.radius;
    CGFloat x = radius * cos(theta) + center.x;
    CGFloat y = -radius * sin(theta) + center.y;
    
    thumb.position = CGPointMake(x, y);
    curveLayer.theta = theta;
    [self setNeedsDisplay];
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    if(thumbTouch) {
        UITouch *touch = thumbTouch;
        CGFloat x = [touch locationInView:self].x - center.x;
        CGFloat y = [touch locationInView:self].y - center.y;
        CGFloat r = sqrt(x*x + y*y);
        CGFloat theta = acos(x/r);
        
        if(isClockwise(CGPointMake(1, 0), CGPointMake(x, y))) theta *= -1;
        
        if (theta > -(start - 2*PI) || theta < -end) {
            if (y < 0) theta = -(start - 2*PI) - 0.01;
            if (y > 0) theta = -end;
            if (ABS(y) < 10) { thumbTouch = nil; thumb.highlighted = false; }
        }
    
        [self moveThumbToTheta:theta];
        double v =  floor(min + (max - min) * [self thetaToPercent:theta]);
        self.value.scaledValue = nint(v);
        pctLabel.text = nsprintf(@"%1.0f", v);
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

@interface ETLRadialSlider (AnimationHack)

@end

@implementation ETLRadialSlider (AnimationHack)

@end