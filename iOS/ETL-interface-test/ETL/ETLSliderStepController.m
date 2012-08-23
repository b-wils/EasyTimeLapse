//
//  ETLSliderStepController.m
//  ETL
//
//  Created by Carll Hoffman on 8/22/12.
//  Copyright (c) 2012 Microsoft. All rights reserved.
//

#import "ETLSliderStepController.h"
#import "ETLUtil.h"

@interface ETLSliderStepController ()
{
    ETLRangeMapper *mapper;
    UISlider *slider;
    UILabel *label;
}
@end

@implementation ETLSliderStepController
- (id)init:(UISlider *)control withMapper:(ETLRangeMapper *)range andLabel:(UILabel *)valueLabel
{
    self = [super init];
    if (self) {
        slider = control;
        [slider addTarget:self action:@selector(sliderMoved:) forControlEvents:UIControlEventValueChanged];
        [slider addTarget:self action:@selector(sliderReleased:) forControlEvents:UIControlEventTouchUpInside];
        
        mapper = range;
        label = valueLabel;
    }
    
    return self;
}

- (void)updateUI
{
    int value = [[mapper stopClosestToPoint:slider.value] intValue];
    label.text = msToEnglish(value);
}

- (void)sliderMoved:(id)sender
{
    [self updateUI];
    
    int value = [[mapper stopClosestToPoint:slider.value] intValue];
    NSDictionary *userInfo = [NSDictionary dictionaryWithObjectsAndKeys:
                              nfloat(value),@"value", 
                              nfloat(slider.value),@"rawValue",
                              nil];
    [[NSNotificationCenter defaultCenter] postNotificationName:SliderMoved object:self userInfo:userInfo];
}

- (void)sliderReleased:(id)sender
{
    float value = [mapper snapLocationForPoint:slider.value];
    [slider setValue:value animated:YES];
    NSDictionary *userInfo = [NSDictionary dictionaryWithObjectsAndKeys:
                              nfloat([[mapper stopClosestToPoint:slider.value] intValue]),@"value", 
                              nfloat(slider.value),@"rawValue",
                              nil];
    [[NSNotificationCenter defaultCenter] postNotificationName:SliderMoved object:self userInfo:userInfo];
    [[NSNotificationCenter defaultCenter] postNotificationName:SliderReleased object:self userInfo:userInfo];
}

- (void)setValue:(id)value animated:(BOOL)animated
{
    float v = [value floatValue];
    label.text = msToEnglish(v);
    [slider setValue:MIN(1.0, [mapper rawPointForValue:nint((int)v)]) animated:YES];
}

- (id)value
{
    return [mapper valueForRawPoint:slider.value];
}
@end
