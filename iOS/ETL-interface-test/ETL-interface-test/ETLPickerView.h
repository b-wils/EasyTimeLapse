//
//  ETLPickerView.h
//  ETL-interface-test
//
//  Created by Carll Hoffman on 8/1/12.
//  Copyright (c) 2012 Microsoft. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ETLPickerView : UIPickerView
- (id)initWithFrame:(CGRect)frame andParent:(UIViewController *)controller;
- (void)show:(bool)show animated:(bool)animated;
@end
