//
//  ETLPickerView.h
//  ETL-interface-test
//
//  Created by Carll Hoffman on 8/1/12.
//  Copyright (c) 2012 Microsoft. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ETLFirstResponder.h"

@interface ETLPickerView : UIPickerView <ETLFirstResponder>
- (id)initWithFrame:(CGRect)frame andParent:(UIViewController *)controller;
@end
