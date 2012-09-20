//
//  ETLTimelapseController.m
//  ETL-interface-test
//
//  Created by Carll Hoffman on 6/18/12.
//  Copyright (c) 2012 Microsoft. All rights reserved.
//

#import "ETLViewControllers.h"
//#import "RCSwitchOnOff.h"
//#import "ETLTimeUnitList.h"
//#import "ETLPickerView.h"
#import "ETLSliderStepController.h"

@interface ETLTimelapseController ()
{
    ETLSliderStepController *eventDurationController, *clipLengthController, *timeScaleController;
    ETLRangeMapper *eventDurationMapper, *clipLengthMapper, *timeScaleMapper;
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
  
    if(!eventDurationMapper) {
        eventDurationMapper = [[ETLRangeMapper alloc] initWithStops:[NSDictionary dictionaryWithObjectsAndKeys:
                                                                     nfloat(0.0), nint(1*MINUTES),
                                                                     nfloat(0.025), nint(5*MINUTES),
                                                                     nfloat(0.05), nint(10*MINUTES),
                                                                     nfloat(0.075), nint(20*MINUTES),
                                                                     nfloat(0.1), nint(30*MINUTES),
                                                                     nfloat(0.15), nint(1*HOURS),
                                                                     nfloat(0.2), nint(2*HOURS),
                                                                     nfloat(0.35), nint(3*HOURS),
                                                                     nfloat(0.5), nint(4*HOURS),
                                                                     nfloat(0.65), nint(6*HOURS + 30*MINUTES),
                                                                     nfloat(0.8), nint(12*HOURS),
                                                                     nfloat(0.9), nint(24*HOURS),
                                                                     nfloat(1.0), nint(FOREVER),
                                                                     nil]];
    }
    
    if(!clipLengthMapper) {
        clipLengthMapper = [[ETLRangeMapper alloc] initWithStops:[NSDictionary dictionaryWithObjectsAndKeys:
                                                                  nfloat(0.0),      nint(1*SECONDS),
                                                                  nfloat(0.025),    nint(2*SECONDS),
                                                                  nfloat(0.05),     nint(3*SECONDS),
                                                                  nfloat(0.075),    nint(4*SECONDS),
                                                                  nfloat(0.1),      nint(5*SECONDS),
                                                                  nfloat(0.125),    nint(6*SECONDS),
                                                                  nfloat(0.15),     nint(7*SECONDS),
                                                                  nfloat(0.2),      nint(8*SECONDS),
                                                                  nfloat(0.225),    nint(9*SECONDS),
                                                                  nfloat(0.25),     nint(10*SECONDS),
                                                                  nfloat(0.3),      nint(12*SECONDS),
                                                                  nfloat(0.4),      nint(15*SECONDS),
                                                                  nfloat(0.5),      nint(20*SECONDS),
                                                                  nfloat(0.6),      nint(30*SECONDS),
                                                                  nfloat(0.7),      nint(45*SECONDS),
                                                                  nfloat(0.8),      nint(1*MINUTES),
//                                                                  nfloat(1.0),      nint(FOREVER), 
                                                                  nil]];
    }
    
    if(!timeScaleMapper) {
        timeScaleMapper = [[ETLRangeMapper alloc] initWithStops:[NSDictionary dictionaryWithObjectsAndKeys:
                                                                 nfloat(0.0),      nint(250*MS),
                                                                 nfloat(0.025),    nint(500*MS),
                                                                 nfloat(0.05),     nint(750*MS),
                                                                 nfloat(0.075),    nint(1*SECONDS),
                                                                 nfloat(0.1),      nint(1*SECONDS + 500*MS),
                                                                 nfloat(0.125),    nint(2*SECONDS),
                                                                 nfloat(0.15),     nint(3*SECONDS),
                                                                 nfloat(0.2),      nint(4*SECONDS),
                                                                 nfloat(0.225),    nint(5*SECONDS),
                                                                 nfloat(0.25),     nint(6*SECONDS),
                                                                 nfloat(0.275),    nint(7*SECONDS),
                                                                 nfloat(0.3),      nint(8*SECONDS),
                                                                 nfloat(0.325),    nint(9*SECONDS),
                                                                 nfloat(0.35),     nint(10*SECONDS),
                                                                 nfloat(0.375),    nint(12*SECONDS),
                                                                 nfloat(0.4),      nint(15*SECONDS),
                                                                 nfloat(0.425),    nint(20*SECONDS),
                                                                 nfloat(0.45),     nint(25*SECONDS),
                                                                 nfloat(0.475),    nint(30*SECONDS),
                                                                 nfloat(0.5),      nint(35*SECONDS),
                                                                 nfloat(0.525),    nint(45*SECONDS),
                                                                 nfloat(0.55),     nint(1*MINUTES),
                                                                 nfloat(0.575),    nint(1*MINUTES + 30*SECONDS),
                                                                 nfloat(0.6),      nint(2*MINUTES),
                                                                 nfloat(0.625),    nint(3*MINUTES),
                                                                 nfloat(0.65),     nint(5*MINUTES),
                                                                 nfloat(0.675),    nint(8*MINUTES),
                                                                 nfloat(0.7),      nint(12*MINUTES),
                                                                 nfloat(0.75),     nint(15*MINUTES),
                                                                 nfloat(0.8),      nint(20*MINUTES),
                                                                 nfloat(0.85),     nint(30*MINUTES),
                                                                 nfloat(0.9),      nint(45*MINUTES),
                                                                 nfloat(0.95),     nint(1*HOURS),
                                                                 nil]];

    }
    
    EnsureSliderStepController(eventDuration)
    EnsureSliderStepController(clipLength)
    EnsureSliderStepController(timeScale)
    
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
    
    [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationFade];
    self.navigationController.navigationBarHidden = YES;
    
    if (UIInterfaceOrientationIsPortrait(UIApplication.sharedApplication.statusBarOrientation)) {
        // Rotate the view if we're in portrait.
        CGAffineTransform transform = CGAffineTransformMakeRotation(3.14159/2);
        self.view.transform = transform;
    }

    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didUpdateDuration:) name:SliderMoved object:eventDurationController];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didUpdateClipLength:) name:SliderMoved object:clipLengthController];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didUpdateTimeScale:) name:SliderMoved object:timeScaleController];
    
    [self updateUICalculations:nil];
}

- (void)updateUICalculations:(NSNotification *)notification
{
    
//    if (!timelapse.continuousShooting) {
//    }
//    else {
//    }
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
     
- (void)didUpdateDuration:(NSNotification *)notification {
    int value = [[notification.userInfo objectForKey:@"value"] intValue];
    
    if (value == FOREVER || value < 0) {
        clipLengthSlider.enabled = false;
        clipLengthLabel.text = msToEnglish(FOREVER);
        
        timelapse.shotCount = 0;
    }
    else {
        clipLengthSlider.enabled = true;
        [clipLengthController updateUI];
        
        int length = [clipLengthController.value intValue];
        float fps = 24;
        int frames = length * (fps / SECONDS);
        float interval = value * 1.0 / frames;
        [timeScaleController setValue:nfloat(interval) animated:YES];
        timelapse.shotInterval = interval;
        timelapse.shotCount = frames;
    }
}

- (void)didUpdateClipLength:(NSNotification *)notification 
{
    int value = [[notification.userInfo objectForKey:@"value"] intValue];
    float fps = 24;
    int frames = value * (fps / SECONDS);
    float interval = [eventDurationController.value intValue] * 1.0 / frames;
    
    [timeScaleController setValue:nfloat(interval) animated:YES];
    
    timelapse.shotInterval = interval;
    timelapse.shotCount = frames;
}

- (void)didUpdateTimeScale:(NSNotification *)notification 
{
    int interval = [[notification.userInfo objectForKey:@"value"] intValue];

    timelapse.shotInterval = interval;
    
    if (!timelapse.continuousShooting) {
        timelapse.shotCount = [eventDurationController.value intValue] * 1.0 / interval;
        [clipLengthController setValue:nint((int)timelapse.clipLength * 1000) animated:YES];
    }
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

//- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
//{
//    [self hideFirstResponder:nil];
//}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
{
//    return (toInterfaceOrientation == UIInterfaceOrientationLandscapeLeft) || (toInterfaceOrientation == UIInterfaceOrientationLandscapeRight);
    return NO;
}

@end
