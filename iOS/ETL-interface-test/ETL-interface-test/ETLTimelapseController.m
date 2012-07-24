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
    
- (void)ensureInitialized {
    if(!timelapse) {
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
        
        timelapse = [[ETLTimelapse alloc] init];
        timelapse.shotInterval = 5000;
        timelapse.shotCount = 0;
        timelapse.clipFramesPerSecond = 23.97f;
        [self observe:timelapse forEvent:ModelUpdated andRun:@selector(updateUICalculations:)];   
        
        periodUnit = [periodUnits objectAtIndex:1]; // "seconds"
    }
}

- (id)init {
    self = [super init];
    if (self) {
        [self ensureInitialized];
    }
    
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self ensureInitialized];

    NSArray *switchNames = [NSArray arrayWithObjects:@"continuousSwitch", nil];    
    [switchNames eachWith:^void (id obj) {
        UISwitch *s = (UISwitch *)[self valueForKey:obj];
        RCSwitchOnOff *res = [[RCSwitchOnOff alloc] initWithFrame:s.frame];
        [res setOn:[s isOn]];
        
        NSArray* actions = [s actionsForTarget:self forControlEvent:UIControlEventValueChanged];
        for (NSString *a in actions) {
            [res addTarget:self action:NSSelectorFromString(a) forControlEvents:UIControlEventValueChanged];
        }
        
        [[self view] addSubview:res];
        [s removeFromSuperview];
        [self setValue:res forKey:obj];
    }];
    
    periodUnitPicker = [[UIPickerView alloc] init];
    periodUnitPicker.delegate = self;
    periodUnitPicker.dataSource = self;
    [periodUnitPicker selectRow:1 inComponent:0 animated:NO];
    periodUnitPicker.hidden = YES;
    periodUnitPicker.frame = CGRectMake(0,
                                      self.view.frame.size.height,
                                      self.view.frame.size.width,
                                      periodUnitPicker.frame.size.height);
    [self.view addSubview:periodUnitPicker];
    
    shotPeriodField.inputAccessoryView = numpadToolbar;
    shotLimitField.inputAccessoryView = numpadToolbar;
    
    [self updateUICalculations:nil];
}

- (void)displayPicker:(bool)show animated:(bool)animated
{
    if (show != periodUnitPicker.hidden) return;
    
    periodUnitPicker.hidden = NO;
    float duration = animated ? 0.25 : 0.0;
    CGRect targetBounds = show 
    ? CGRectMake(0,
                 self.view.frame.size.height - periodUnitPicker.frame.size.height,
                 periodUnitPicker.frame.size.width,
                 periodUnitPicker.frame.size.height)
    : CGRectMake(0,
                 self.view.frame.size.height,
                 self.view.frame.size.width,
                 periodUnitPicker.frame.size.height);
    
    [UIView 
        animateWithDuration:duration 
        animations:^{
            [periodUnitPicker setFrame:targetBounds];            
        }
        completion:^(BOOL finished) {
            if (finished) periodUnitPicker.hidden = !show;
        }
    ];
}

- (NSString *)formatSeconds:(float_t)totalSeconds with:(NSString *)formatString
{
    NSUInteger hours = floor(totalSeconds / 3600);
    NSUInteger minutes = floor((totalSeconds - hours * 3600) / 60);
    float_t seconds = totalSeconds - (hours * 3600.0) - (minutes * 60.0);
    
    return [NSString stringWithFormat:formatString, hours, minutes, seconds];
}

- (void)updateUICalculations:(NSNotification *)notification
{
    shotLimitPanel.hidden = timelapse.continuousShooting;
    if (!timelapse.continuousShooting)
    {
        float_t totalSeconds = timelapse.shotCount / timelapse.clipFramesPerSecond;
        finalShotLengthLabel.text = [self formatSeconds:totalSeconds with:@"%u:%u:%2.2f"];
        
        totalSeconds = (float_t)timelapse.shotCount * ((float_t)timelapse.shotInterval / 1000.0);
        totalShootingTimeLabel.text = [self formatSeconds:totalSeconds with:@"%u:%u:%2.0f"];
    }
}

- (IBAction)didSwitchContinuous:(id)sender
{
    UISwitch * s = (UISwitch *)sender;
    if (!s.on) {
        timelapse.shotCount = [shotLimitField.text integerValue];
    }
    else {
        [timelapse setShotCount:0];
    }
}

- (IBAction)didUpdatePeriod:(id)sender
{
    float_t value = [(UITextField *)sender text].floatValue;
    NSUInteger multiple = [(NSNumber *)[msInUnit objectForKey:periodUnit] unsignedIntegerValue];
    
    timelapse.shotInterval = floor(value * multiple); 
}

- (IBAction)didUpdateShotLimit:(id)sender
{
    NSInteger newValue = [(UITextField *)sender text].intValue;
    if (newValue < 1) {
        newValue = 0;
        ((UITextField *)sender).text = [NSString stringWithFormat:@"%i", timelapse.shotCount];
        [continuousSwitch setOn:!continuousSwitch.on animated:YES];
    }
    
    timelapse.shotCount = newValue;
}

- (IBAction)didClickPeriodUnit:(id)sender {
//    [periodUnitPicker setHidden:NO];
    [self displayPicker:YES animated:YES];
    [self hideFirstResponder:sender];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    printf("'%s' didBeginEditing", [textField.text cStringUsingEncoding:NSUTF8StringEncoding]);
    [self displayPicker:NO animated:YES];
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
    [self displayPicker:NO animated:YES];
    
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
    [self displayPicker:NO animated:YES];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"Program"]) {
        ETLProgramViewController *controller = [segue destinationViewController];
        controller.packetProvider = timelapse;
    }
    
//    [super prepareForSegue:segue sender:sender];
}

@end
