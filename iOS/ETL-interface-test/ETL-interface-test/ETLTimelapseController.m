//
//  ETLTimelapseController.m
//  ETL-interface-test
//
//  Created by Carll Hoffman on 6/18/12.
//  Copyright (c) 2012 Microsoft. All rights reserved.
//

#import "ETLViewControllers.h"
#import "RCSwitchOnOff.h"
#import "ETLTimeUnitList.h"
#import "ETLPickerView.h"

@interface ETLTimelapseController ()
{
//    ETLTimeUnitList *unitList;
//    ETLPickerView *periodUnitPicker;
    ETLIntervalSelectionController *intervalSelection;
}
@end

@implementation ETLTimelapseController

@synthesize timelapse;//, periodUnit;

- (void)setTimelapse:(ETLTimelapse *)value {
    if (timelapse) [[NSNotificationCenter defaultCenter] removeObserver:self name:ModelUpdated object:timelapse];

    timelapse = value;
    [self observe:timelapse forEvent:ModelUpdated andRun:@selector(updateUICalculations:)];   
}

- (void)ensureInitialized {
    if(!timelapse) {
        self.timelapse = [[ETLTimelapse alloc] init];
        timelapse.shotInterval = 5000;
        timelapse.shotCount = 0;
        timelapse.clipFramesPerSecond = 23.97f;
    }
    
    if (!intervalSelection) {
        intervalSelection = [[ETLIntervalSelectionController alloc] initWithInputField:shotPeriodField 
                                                                             unitButton:periodUnitButton
                                                                             andParent:self];
        intervalSelection.parent = self;
        intervalSelection.unit = @"seconds";
        intervalSelection.interval = timelapse.shotInterval;
    }
    
    if (!self.packetProvider) {
        self.packetProvider = timelapse;
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
    
//    periodUnitPicker = [[ETLPickerView alloc] initWithFrame:CGRectMake(0,
//                                                               self.view.frame.size.height,
//                                                               self.view.frame.size.width,
//                                                               periodUnitPicker.frame.size.height)
//                                                  andParent:self];
//    periodUnitPicker.delegate = unitList;
//    periodUnitPicker.dataSource = unitList;
//    [periodUnitPicker selectRow:[unitList getNumberOfUnit:periodUnit] inComponent:0 animated:NO];
//    periodUnitPicker.hidden = YES;
    
//    shotPeriodField.inputAccessoryView = numpadToolbar;
//    shotLimitField.inputAccessoryView = numpadToolbar;
    
    [self updateUICalculations:nil];
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
    
//    UInt64 period = timelapse.shotInterval;
//    period /= [intervalSelection interval]; //[unitList msInUnit:periodUnit];
//    shotPeriodField.text = [NSString stringWithFormat:@"%d", period];
//    periodUnitButton.allTitles = periodUnit;
    
    if (!timelapse.continuousShooting)
    {
        shotLimitField.text = [NSString stringWithFormat:@"%d", timelapse.shotCount];
        
        float_t totalSeconds = timelapse.shotCount / timelapse.clipFramesPerSecond;
        finalShotLengthLabel.text = [self formatSeconds:totalSeconds with:@"%u:%u:%2.2f"];
        
        totalSeconds = (float_t)timelapse.shotCount * ((float_t)timelapse.shotInterval / 1000.0);
        totalShootingTimeLabel.text = [self formatSeconds:totalSeconds with:@"%u:%u:%2.0f"];
        
        if (continuousSwitch.on) {
            [continuousSwitch setOn:NO animated:YES];
        }
    }
    else {
        if (!continuousSwitch.on) {
            [continuousSwitch setOn:YES animated:YES];
        }
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

- (void)didUpdateInterval:(NSUInteger)ms forSelection:(id)sender
{
    timelapse.shotInterval = ms;
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

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField 
{
    [self hideFirstResponder:nil];
    return TRUE;
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
    [self hideFirstResponder:nil];
}

@end
