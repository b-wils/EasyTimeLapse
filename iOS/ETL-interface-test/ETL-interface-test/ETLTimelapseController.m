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
{;
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
        timelapse.exposure = 200;
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
    [self replaceSwitches:Array(@"continuousSwitch")];
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
