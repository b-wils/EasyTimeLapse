//
//  ETLThumb.m
//  ETL
//
//  Created by Carll Hoffman on 8/28/12.
//  Copyright (c) 2012 Microsoft. All rights reserved.
//

#import "ETLThumb.h"
#import "ETLUtil.h"
#import <QuartzCore/QuartzCore.h>

@interface ETLThumb ()
{
    CAShapeLayer *nubLayer, *nubFade;
    CAShapeLayer *ringLayer;
}
@end

@implementation ETLThumb

@synthesize highlighted, layer, enabled;

- (id)initWithSize:(CGFloat)size
{
    self = [super init];
    if (self) {
        layer = [CALayer layer];
        layer.frame = (CGRect){{0,0}, size, size};
        NSDictionary *newActions = [[NSDictionary alloc] initWithObjectsAndKeys:[NSNull null], @"onOrderIn",
                                                                                [NSNull null], @"onOrderOut",
                                                                                [NSNull null], @"sublayers",
                                                                                [NSNull null], @"contents",
                                                                                [NSNull null], @"bounds",
                                                                                [NSNull null], @"position",
                                                                                nil];
        layer.actions = newActions;
        self.enabled = true;
        
        [self setupView];
    }
    
    return self;
}

- (void)setupView
{
    CGFloat height = layer.frame.size.height;
    CGFloat width = layer.frame.size.width;
    CGFloat size = MIN(height, width);
    
    nubLayer = [CAShapeLayer layer];
    nubLayer.frame = CGRectInset(layer.bounds, width/4, height/4);
    CGRect rect = (CGRect){{0,0}, size/2, size/2};
    UIBezierPath *path = [UIBezierPath bezierPathWithOvalInRect:rect];
    nubLayer.path = path.CGPath;
    nubLayer.fillColor = [UIColor colorWithRed:47.0/255 green:47.0/255 blue:47.0/255 alpha:1].CGColor;
    
    nubFade = [CAShapeLayer layer];
    nubFade.frame = nubLayer.frame;
    nubFade.path = [UIBezierPath bezierPathWithOvalInRect:rect].CGPath;
    nubFade.fillColor = [UIColor whiteColor].CGColor;
    nubFade.opacity = 0;
    
    ringLayer = [CAShapeLayer layer];
    ringLayer.frame = CGRectInset(layer.bounds, size/16, size/16);
    ringLayer.opacity = 0.0;
    ringLayer.path = [UIBezierPath bezierPathWithOvalInRect:(CGRect){{0,0}, ringLayer.frame.size}].CGPath;
    ringLayer.fillColor = nil;
    ringLayer.strokeColor = [UIColor colorWithRed:47.0/255 green:47.0/255 blue:47.0/255 alpha:1].CGColor;
    ringLayer.lineWidth = size/8;
    ringLayer.transform = CATransform3DMakeScale(0.5, 0.5, 1);
    
    [layer addSublayer:nubLayer];
    [layer addSublayer:nubFade];
    [layer addSublayer:ringLayer];
}

- (void)setPosition:(CGPoint)value
{
    layer.position = value;
}

- (CGPoint)position
{
    return layer.position;
}

- (void)setHighlighted:(bool)value
{
    highlighted = value;
    if(value) {
        ringLayer.opacity = 0.8;
        ringLayer.transform = CATransform3DMakeScale(1, 1, 1);
    }
    else {
        ringLayer.opacity = 0.0;
        ringLayer.transform = CATransform3DMakeScale(0.5, 0.5, 1);
    }
}

- (void)setEnabled:(bool)value
{
    enabled = value;
    if (value) {
        nubFade.opacity = 0;
    }
    else {
        self.highlighted = false;
        nubFade.opacity = 0.5;
    }
}
@end
