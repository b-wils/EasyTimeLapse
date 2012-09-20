//
//  ETLFlickPicker.m
//  ETL
//
//  Created by Carll Hoffman on 9/7/12.
//  Copyright (c) 2012 Microsoft. All rights reserved.
//

#import "ETLFlickPicker.h"
#import <QuartzCore/QuartzCore.h>

@interface ETLFlickPicker ()
{
    CATextLayer *textLayer;
    CALayer *maskLayer;
    CALayer *blueLayer;
    UITouch *activeTouch;
    
    CGRect smallMaskFrame;
}
@end

@implementation ETLFlickPicker

- (void)setupView
{
    CGFloat height = self.bounds.size.height;
    CGRect frame = self.bounds;
    frame.size.height = height / 4;
    frame.origin.y = 3 * height / 4;
    smallMaskFrame = frame;
    
    maskLayer = [CALayer layer];
    maskLayer.frame = smallMaskFrame;
    maskLayer.cornerRadius = 10;
    maskLayer.backgroundColor = [UIColor redColor].CGColor;

//    blueLayer = [CALayer layer];
//    blueLayer.frame = CGRectInset(self.bounds, 20, 20);
//    blueLayer.backgroundColor = [UIColor blueColor].CGColor;
//    blueLayer.mask = maskLayer;
    
    frame.size.height -= 10;
    frame.origin.y += 10;
    textLayer = [CATextLayer layer];
    textLayer.frame = frame;
    textLayer.string = @"Foo";
    textLayer.foregroundColor = [UIColor whiteColor].CGColor;
    textLayer.alignmentMode = @"center";
    [self.layer addSublayer:textLayer];
    
    frame.origin.y -= height / 4;
    textLayer = [CATextLayer layer];
    textLayer.frame = frame;
    textLayer.string = @"Bar";
    textLayer.alignmentMode = @"center";
    textLayer.foregroundColor = [UIColor whiteColor].CGColor;
    textLayer.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.3].CGColor;
    [self.layer addSublayer:textLayer];
    
    frame.origin.y -= height / 4;
    textLayer = [CATextLayer layer];
    textLayer.frame = frame;
    textLayer.string = @"Baz";
    textLayer.alignmentMode = @"center";
    textLayer.foregroundColor = [UIColor whiteColor].CGColor;
    [self.layer addSublayer:textLayer];
    
    frame.origin.y -= height / 4;
    textLayer = [CATextLayer layer];
    textLayer.frame = frame;
    textLayer.string = @"Bot";
    textLayer.alignmentMode = @"center";
    textLayer.foregroundColor = [UIColor whiteColor].CGColor;
    textLayer.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.3].CGColor;
    [self.layer addSublayer:textLayer];
    
    self.layer.mask = maskLayer;
}

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

- (void)tryBindTouch:(UITouch *)touch
{
    CGPoint point = [touch locationInView:self];
    CGRect rect = maskLayer.frame;
    if(CGRectContainsPoint(rect, point) && !activeTouch) {
        maskLayer.frame = self.bounds;
        activeTouch = touch;
    }
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    for (UITouch *touch in touches) {
        if (touch.phase == UITouchPhaseBegan) {
            [self tryBindTouch:touch];
        }
    }
//    [self setNeedsDisplay];
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    for (UITouch *touch in touches) {
        if (touch == activeTouch) {
            CGRect bounds = self.bounds;
            CGRect frame = self.frame;
            CGPoint loc = [touch locationInView:self.superview];
            CGPoint oldLoc = [touch previousLocationInView:self.superview];
            bounds.origin.y -= loc.y - oldLoc.y;
//            frame.origin.y -= loc.y - oldLoc.y;
            self.bounds = bounds;
            self.frame = frame;
            maskLayer.frame = self.bounds;
        }
    }
    [self setNeedsDisplay];
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    maskLayer.frame = smallMaskFrame;
    activeTouch = nil;
}

@end
