//
//  UIView+UIView_DrawingHelpers.m
//  ETL
//
//  Created by Carll Hoffman on 8/28/12.
//  Copyright (c) 2012 Microsoft. All rights reserved.
//

#import "UIView+UIView_DrawingHelpers.h"

@implementation UIView (UIView_DrawingHelpers)
- (void)doInContext:(void(^)(CGContextRef context))block
{
    CGContextRef context =  UIGraphicsGetCurrentContext();
    CGContextSaveGState(context);
    
    block(context);
    
    CGContextRestoreGState(context);
}
@end
