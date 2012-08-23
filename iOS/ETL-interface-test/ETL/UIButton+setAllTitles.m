//
//  UIButton+setAllTitles.m
//  ETL-interface-test
//
//  Created by Carll Hoffman on 7/24/12.
//  Copyright (c) 2012 Microsoft. All rights reserved.
//

#import "UIButton+setAllTitles.h"

@implementation UIButton (setAllTitles)
- (void)setAllTitles:(NSString *)title
{
    [self setTitle:title forState:UIControlStateNormal];
    [self setTitle:title forState:UIControlStateHighlighted];
}
@end
