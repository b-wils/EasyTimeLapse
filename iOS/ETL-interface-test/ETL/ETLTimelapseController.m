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
    ETLIntervalSelectionController *intervalSelection;   
}
@end

@implementation ETLTimelapseController

@synthesize timelapse;

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
    [[UIApplication sharedApplication] setStatusBarHidden:YES];
    [UIViewController attemptRotationToDeviceOrientation];
    
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
    if (!timelapse.continuousShooting) {
    }
    else {
    }
}

//- (IBAction)didSwitchContinuous:(id)sender
//{
//}

- (void)didUpdateInterval:(NSUInteger)ms forSelection:(id)sender
{
    timelapse.shotInterval = ms;
}
//
//- (BOOL)textFieldShouldReturn:(UITextField *)textField
//{
//    [textField resignFirstResponder];
//    return YES;
//}
//
//- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField 
//{
//    [self hideFirstResponder:nil];
//    return TRUE;
//}

- (BOOL)canBecomeFirstResponder
{
    return YES;
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self becomeFirstResponder];
}

//- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
//{
//    [self hideFirstResponder:nil];
//}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
{
    return (toInterfaceOrientation == UIInterfaceOrientationLandscapeLeft) || (toInterfaceOrientation == UIInterfaceOrientationLandscapeRight);
    return YES;
}

@end
