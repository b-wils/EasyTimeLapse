//
//  ETLThumb.m
//  ETL
//
//  Created by Carll Hoffman on 8/28/12.
//  Copyright (c) 2012 Microsoft. All rights reserved.
//

#import "ETLThumb.h"
#import "ETLUtil.h"

@implementation ETLThumb

@synthesize position;

- (id)initWithSize:(CGFloat)size
{
    return [self initWithFrame:CGRectMake(0, 0, size, size)];
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)drawRect:(CGRect)rect
{    
    [self doInContext:^(CGContextRef context) {
        CGContextSetLineWidth(context, 5);
        CGContextSetRGBFillColor(context, 255, 255, 255, 1);
        CGContextSetRGBStrokeColor(context, 0, 0, 0, 1);
        
        CGContextFillEllipseInRect(context, rect);
        CGContextStrokeEllipseInRect(context, rect);
    }];
}

- (void)render
{
    float height = self.frame.size.height;
    float width = self.frame.size.width;  
    [self drawRect:CGRectMake(position.x - width/2, position.y - height/2, width, height)];
}

@end
