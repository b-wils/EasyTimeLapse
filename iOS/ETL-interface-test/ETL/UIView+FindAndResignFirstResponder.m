//
//  UIView+FindAndResignFirstResponder.m
//  ETL-interface-test
//
//  Created by Carll Hoffman on 6/19/12.
//  Copyright (c) 2012 Microsoft. All rights reserved.
//

#import "UIView+FindAndResignFirstResponder.h"

@implementation UIView (FindAndResignFirstResponder)
- (BOOL)findAndResignFirstResponder
{
    UIView *result = [self findFirstResponder];
    return result && [result resignFirstResponder];
}

-(UIView *)findFirstResponder
{
    UIView *result = nil;
    if (self.isFirstResponder) return self;
    else for (UIView *subView in self.subviews) {
        if (!result) result = [subView findFirstResponder];
    }
    
    return result;
}
@end
