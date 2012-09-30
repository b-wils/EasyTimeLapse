//
//  ETLValueListView.m
//  ETL
//
//  Created by Carll Hoffman on 9/17/12.
//  Copyright (c) 2012 Microsoft. All rights reserved.
//

#import "ETLValueListView.h"
#import <QuartzCore/QuartzCore.h>

@interface ETLValueListView ()
{
    NSMutableArray *list;
//    UIImageView *nubView;
    UIView *nubView;
    CAShapeLayer *nubLayer;
}
@end

@implementation ETLValueListView

@synthesize  delegate;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setupView];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self setupView];
    }
    return self;
}

- (void)setupView 
{
    list = [NSMutableArray array];
    nubView = [[UIView alloc] initWithFrame:CGRectMake(115, 0, 20, 55)];
    nubView.backgroundColor = [UIColor clearColor];
    nubView.clipsToBounds = true;
    
    double d = nubView.frame.size.width;
    double h = nubView.frame.size.height / 2;
    
    double m = -h/d;
    double x = (-4*m*h - 2*m*d)/(-4*m) - 3; 
    double s = ABS(4*(-x + d));
    
    UIBezierPath *path = [UIBezierPath bezierPathWithOvalInRect:CGRectMake(-s + d, -(s - 2*h)/2, s, s)];
    nubLayer = [CAShapeLayer layer];
    nubLayer.path = path.CGPath;
    nubLayer.lineWidth = 0;
    nubLayer.strokeColor = [UIColor clearColor].CGColor;

    [nubView.layer addSublayer:nubLayer];
    [self addSubview:nubView];
}

- (ETLValueSelector *)addItemNamed:(NSString *)name withValue:(ETLUnitScaleValue *)value 
{
    CGRect rect = CGRectMake(0, 0, self.frame.size.width, 55);
    CGPoint center = CGPointMake(CGRectGetMidX(rect), CGRectGetMidY(rect) + [list count] * 55);
    ETLValueSelector *sel = [[ETLValueSelector alloc] initWithFrame:rect];
    sel.center = center;
    
    sel.title = name;
    sel.value = value;
    sel.delegate = self;
    
    CALayer *bottomBorder = [CALayer layer];
    bottomBorder.frame = CGRectMake(0, 54, self.frame.size.width, 1);
    bottomBorder.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.2].CGColor;
    [sel.layer addSublayer:bottomBorder];
    
    [self addSubview:sel];
    [list addObject:sel];
    
    [nubView removeFromSuperview];
    [self addSubview:nubView];
    
    return sel;
}

- (void)didSelectValue:(ETLValueSelector *)target
{
    CGPoint center = nubView.center;
    center.y = target.center.y;
    [UIView animateWithDuration:0.2 animations:^{
        nubLayer.fillColor = target.color.CGColor;
        nubView.center = center;
    }];
    
    [delegate didSelectValue:target];
}

@end
