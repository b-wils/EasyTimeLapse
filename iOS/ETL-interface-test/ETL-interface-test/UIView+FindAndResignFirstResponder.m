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
    if (self.isFirstResponder) {
        [self resignFirstResponder];
        return YES;     
    }
    for (UIView *subView in self.subviews) {
        if ([subView findAndResignFirstResponder])
            return YES;
    }
    return NO;
}
@end
