//
//  ETLTimelapseController.m
//  ETL-interface-test
//
//  Created by Carll Hoffman on 6/18/12.
//  Copyright (c) 2012 Microsoft. All rights reserved.
//

#import "ETLTimelapseController.h"
#import "ETLProgramViewController.h"
#import "RCSwitchOnOff.h"

@interface ETLTimelapseController ()

@end

@implementation ETLTimelapseController

@synthesize continuousShooting = _continuousShooting;
@synthesize shotPeriodInMs = _shotPeriodInMs;
@synthesize shotLimit = _shotLimit;
@synthesize shotFramesPerSecond = _shotFramesPerSecond;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        periodUnits = [NSArray arrayWithObjects:
                       @"ms",
                       @"seconds",
                       @"minutes",
                       @"hours", nil]; 
        NSArray * msTimes = [NSArray arrayWithObjects:
                             [NSNumber numberWithInt:1], 
                             [NSNumber numberWithInt:1000], 
                             [NSNumber numberWithInt:1000*60], 
                             [NSNumber numberWithInt:1000*3600], nil];
        
        msInUnit = [NSDictionary dictionaryWithObjects:msTimes forKeys:periodUnits];
        
        _shotFramesPerSecond = 24.0f;
        
        // TODO better automatic update for these data
        _shotPeriodInMs = 5000; // 5 sec default
        _shotLimit = 100; // 100 shot default
        periodUnit = [periodUnits objectAtIndex:1]; // "seconds"
    }
    
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    ETLPredicate pSwitch = ^bool (id obj) {return [obj class] == CLASS(UISwitch);};
    NSArray *switches = [[self view].subviews filterWith:pSwitch];
    
    [switches eachWith:^void (id obj) {
        UISwitch *s = (UISwitch *)obj;
        RCSwitchOnOff *res = [[RCSwitchOnOff alloc] initWithFrame:s.frame];
        [res setOn:[s isOn]];
        
        NSArray* actions = [s actionsForTarget:self forControlEvent:UIControlEventValueChanged];
        for (NSString *a in actions) {
            [res addTarget:self action:NSSelectorFromString(a) forControlEvents:UIControlEventValueChanged];
        }
        
        [[self view] addSubview:res];
        [s removeFromSuperview];
    }];
    
    
    [periodUnitPicker selectRow:1 inComponent:0 animated:NO];
    shotPeriodField.inputAccessoryView = numpadToolbar;
    shotLimitField.inputAccessoryView = numpadToolbar;
}

- (void)setContinuousShooting:(bool)value
{
    NSLog(@"Continuous shooting mode: %@", value ? @"true" : @"false");
    _continuousShooting = value;
    [self updateUICalculations];
    shotLimitPanel.hidden = value;
}

- (NSString *)formatSeconds:(float_t)totalSeconds with:(NSString *)formatString
{
    NSUInteger hours = floor(totalSeconds / 3600);
    NSUInteger minutes = floor((totalSeconds - hours * 3600) / 60);
    float_t seconds = totalSeconds - (hours * 3600.0) - (minutes * 60.0);
    
    return [NSString stringWithFormat:formatString, hours, minutes, seconds];
}

- (void)updateUICalculations
{
    if (!self.continuousShooting)
    {
        float_t totalSeconds = _shotLimit / (float_t)_shotFramesPerSecond;
        finalShotLengthLabel.text = [self formatSeconds:totalSeconds with:@"%u:%u:%2.2f"];
        
        totalSeconds = (float_t)_shotLimit * ((float_t)_shotPeriodInMs / 1000.0);
        totalShootingTimeLabel.text = [self formatSeconds:totalSeconds with:@"%u:%u:%2.0f"];
    }
}

- (void)setShotPeriodInMs:(NSUInteger)value
{
    _shotPeriodInMs = value;
    [self updateUICalculations];
}

- (void)setShotLimit:(NSUInteger)value
{
    _shotLimit = value;
    [self updateUICalculations];
}

- (IBAction)didSwitchContinuous:(id)sender
{
    UISwitch * s = (UISwitch *)sender;
    self.continuousShooting = s.on;
}

- (IBAction)didUpdatePeriod:(id)sender
{
    float_t value = [(UITextField *)sender text].floatValue;
    NSUInteger multiple = [(NSNumber *)[msInUnit objectForKey:periodUnit] unsignedIntegerValue];
    
    self.shotPeriodInMs = floor(value * multiple);
}

- (IBAction)didUpdateShotLimit:(id)sender
{
    self.shotLimit = [(UITextField *)sender text].intValue;
}

- (IBAction)didClickPeriodUnit:(id)sender {
    [periodUnitPicker setHidden:NO];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return 1;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    return [periodUnits count];
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    periodUnit = [periodUnits objectAtIndex:row];
    [periodUnitButton setTitle:periodUnit forState:UIControlStateNormal];
    [periodUnitButton setTitle:periodUnit forState:UIControlStateHighlighted];
    [periodUnitButton setTitle:periodUnit forState:UIControlStateSelected];
    periodUnitPicker.hidden = YES;
    
    [self didUpdatePeriod:shotPeriodField];
}

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    return [periodUnits objectAtIndex:row];
}

- (BOOL)canBecomeFirstResponder
{
    return YES;
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self becomeFirstResponder];
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    NSLog(@"Detected touches...");
    periodUnitPicker.hidden = YES;
}

- (IBAction)goProgramDevice:(id)sender 
{
/*  TODO - do something else for continuousShooting mode
    if (self.continuousShooting) {
        
    }
    else {*/
        command.command = 10; // TODO - this is just grabbed from the sample, verify correct command
        command.data = 1; // TODO - verify this is appropriate for the correct command
        
        sections[0].shots = _shotLimit;
        sections[0].interval = _shotPeriodInMs;
//    }
    
    [super goProgramDevice:sender];
}

@end
