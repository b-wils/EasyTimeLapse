//
//  ETLIntervalSelectionController.m
//  ETL-interface-test
//
//  Created by Carll Hoffman on 8/1/12.
//  Copyright (c) 2012 Microsoft. All rights reserved.
//

#import "ETLIntervalSelectionController.h"
#import "ETLTimeUnitList.h"
#import "ETLPickerView.h"

@interface ETLIntervalSelectionController ()
{
    ETLPickerView *picker;
    ETLTimeUnitList *unitList;
    UITextField *textField;
    UIButton *unitButton;
}
@end

@implementation ETLIntervalSelectionController
@synthesize parent, unit, interval;
//ModelSynthesize(UInt64, interval, setShotInterval)
- (void)setInterval:(NSUInteger)value
{
    [self beginUpdate];
    interval = value;
    value /= [unitList msInUnit:unit];
    textField.text = [NSString stringWithFormat:@"%d", value];
    [self notifyUpdated:@"interval"];
    [self endUpdate];
}

- (id)initWithInputField:(UITextField *)field unitButton:(UIButton *)units andParent:(ETLViewController <ETLIntervalSelectionDelegate> *)controller
{
    self = [super init];
    
    if (self) {
        textField = field;
        unitButton = units;
        parent = controller;
        unitList = [[ETLTimeUnitList alloc] init];
        unitList.delegate = self;
        
        picker = [[ETLPickerView alloc] initWithFrame:CGRectMake(0,
                                                         parent.view.frame.size.height,
                                                         parent.view.frame.size.width,
                                                         picker.frame.size.height) //???
                                            andParent:controller];
        picker.delegate = unitList;
        picker.dataSource = unitList;
        picker.hidden = YES;
        picker.showsSelectionIndicator = true;
        
        [parent.view addSubview:picker];
        
        [units addTarget:self action:@selector(didClickPeriodUnit:) forControlEvents:UIControlEventTouchUpInside];
        [textField addTarget:self action:@selector(didUpdatePeriod:) forControlEvents:UIControlEventEditingDidEnd];
    }
    
    return self;
}

- (void)setUnit:(NSString *)value
{
    unit = value;
    unitButton.allTitles = unit;    
    [picker selectRow:[unitList getNumberOfUnit:unit] inComponent:0 animated:NO];
}

- (void)didClickPeriodUnit:(id)sender 
{
    [picker show:YES animated:YES];
    [parent emulateFirstResponder:picker];
}

- (void)didUpdatePeriod:(id)sender
{
    float_t value = [sender text].floatValue;
    NSUInteger multiple = [unitList msInUnit:unit];
    self.interval = floor(value * multiple); 
    [parent didUpdateInterval:self.interval forSelection:self];
}

- (void)didSelectUnit:(NSString *)name ofMs:(NSUInteger)millis 
{
    self.unit = name;
    [self didUpdatePeriod:textField];
//    [picker show:NO animated:YES];
}

@end
