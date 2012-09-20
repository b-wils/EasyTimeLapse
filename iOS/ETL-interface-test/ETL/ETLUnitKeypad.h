//
//  ETLUnitKeypad.h
//  ETL
//
//  Created by Carll Hoffman on 9/17/12.
//  Copyright (c) 2012 Microsoft. All rights reserved.
//

#import <UIKit/UIKit.h>

// TODO - remove when ETLUnitScaleValue moves to other files
#import "ETLValueSelector.h"

@interface ETLUnitKeypad : UIView

@property (nonatomic, strong) ETLUnitScaleValue *value;

@end
