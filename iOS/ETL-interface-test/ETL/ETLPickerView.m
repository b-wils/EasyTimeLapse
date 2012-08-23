//
//  ETLPickerView.m
//  ETL-interface-test
//
//  Created by Carll Hoffman on 8/1/12.
//  Copyright (c) 2012 Microsoft. All rights reserved.
//

#import "ETLPickerView.h"
#import "ETLViewController.h"

@interface ETLPickerView ()
{
    ETLViewController *parent;
}
@end

@implementation ETLPickerView

- (id)initWithFrame:(CGRect)frame andParent:(ETLViewController *)controller
{
    self = [super initWithFrame:frame];
    if (self) {
        parent = controller;
        [parent.view addSubview:self];
    }
    return self;
}

- (void)show:(bool)show animated:(bool)animated
{
    if (show != self.hidden) return;
    if (show) [parent hideFirstResponder:nil];
    
    self.hidden = NO;
    float duration = animated ? 0.25 : 0.0;
    CGRect targetBounds = show 
        ? CGRectMake(0,
                     parent.view.frame.size.height - self.frame.size.height,
                     self.frame.size.width,
                     self.frame.size.height)
        : CGRectMake(0,
                     parent.view.frame.size.height,
                     parent.view.frame.size.width,
                     self.frame.size.height);
    
    [UIView 
         animateWithDuration:duration 
         animations:^{
             [self setFrame:targetBounds];            
         }
         completion:^(BOOL finished) {
             if (finished) self.hidden = !show;
         }
     ];
}

@end
