//
//  ETLSliderStepController.h
//  ETL
//
//  Created by Carll Hoffman on 8/22/12.
//  Copyright (c) 2012 Microsoft. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ETLRangeMapper.h"

#define InitSliderStepController(name) {\
    name##Controller = [[ETLSliderStepController alloc] init:name##Slider withMapper:name##Mapper andLabel:name##Label]; }
#define EnsureSliderStepController(name) { if (!name##Controller) InitSliderStepController(name) }

#define SliderMoved @"SliderMoved"
#define SliderReleased @"SliderReleased"

@interface ETLSliderStepController : NSObject
- (id)init:(UISlider *)control withMapper:(ETLRangeMapper *)range andLabel:(UILabel *)valueLabel;
- (void)setValue:(id)value animated:(BOOL)animated;
- (void)updateUI;
- (id)value;
@end
