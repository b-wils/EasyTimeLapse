//
//  ETLRadialSlider.h
//  ETL
//
//  Created by Carll Hoffman on 9/3/12.
//  Copyright (c) 2012 Microsoft. All rights reserved.
//

#import <UIKit/UIKit.h>

// TODO - remove when ETLUnitScaleValue moves to other files
#import "ETLValueSelector.h"

@interface ETLRadialSlider : UIView

@property (nonatomic, strong) ETLUnitScaleValue *value;
@property (nonatomic, assign) bool slideEnabled;

- (void)setColor:(UIColor *)value;

//HACK animation hack
- (void)animateTheta:(NSTimer *)timer;

@end
