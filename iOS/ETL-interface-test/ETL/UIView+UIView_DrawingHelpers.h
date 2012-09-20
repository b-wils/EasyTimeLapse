//
//  UIView+UIView_DrawingHelpers.h
//  ETL
//
//  Created by Carll Hoffman on 8/28/12.
//  Copyright (c) 2012 Microsoft. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIView (UIView_DrawingHelpers)
- (void)doInContext:(void(^)(CGContextRef context))block;
@end
