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
#import "ETLRadialSlider.h"
#import "ETLUnitKeypad.h"
#import <QuartzCore/QuartzCore.h>

#define UIColorBurntOrange [UIColor colorWithRed:224/255.0 green:132/255.0 blue:59/255.0 alpha:1]
#define UIColorForestGreen [UIColor colorWithRed:121/255.0 green:137/255.0 blue:109/255.0 alpha:1]

@interface ETLTimelapseController ()
{
    ETLSliderStepController *eventDurationController, *clipLengthController, *timeScaleController;
    ETLRangeMapper *eventDurationMapper, *clipLengthMapper, *timeScaleMapper;
    ETLShortTimeValue *shotLength, *clipLength, *intervalValue;
    ETLSimpleValue *numShots;
    ETLRadialSlider *slider;
    ETLUnitKeypad *keypad;
    UIButton *cancelUnitMenu;
    
    bool editorMode;
    bool ignoreUpdates;
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
    if (!timelapse) {
        self.timelapse = [[ETLTimelapse alloc] init];
        timelapse.shotInterval = 5000;
        timelapse.shotCount = 0;
        timelapse.clipFramesPerSecond = 23.97f;
        timelapse.exposure = 200;
    }
    
    if (!slider) {
        CGRect frame = editorPane.bounds;
        slider = [[ETLRadialSlider alloc] initWithFrame:frame];
        frame = (CGRect){{frame.origin.x + frame.size.width, frame.origin.y}, frame.size};
        keypad = [[ETLUnitKeypad alloc] initWithFrame:frame];         
        [editorPane addSubview:slider];
        [editorPane addSubview:keypad];
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
    
    valueList.delegate = self;
    
    shotLength = [[ETLShortTimeValue alloc] init];
    shotLength.unit = @"hours";
    
    clipLength = [[ETLShortTimeValue alloc] init];
    clipLength.unit = @"seconds";
    
    intervalValue = [[ETLShortTimeValue alloc] init];
    
    numShots = [[ETLSimpleValue alloc] init];
    numShots.unit = @"shots";
    
    [shotLength addObserver:self forKeyPath:@"rawValue" options:NSKeyValueObservingOptionNew context:nil];
    [shotLength addObserver:self forKeyPath:@"scaledValue" options:NSKeyValueObservingOptionNew context:nil];
    [clipLength addObserver:self forKeyPath:@"rawValue" options:NSKeyValueObservingOptionNew context:nil];
    [clipLength addObserver:self forKeyPath:@"scaledValue" options:NSKeyValueObservingOptionNew context:nil];
    [numShots addObserver:self forKeyPath:@"rawValue" options:NSKeyValueObservingOptionNew context:nil];
    [numShots addObserver:self forKeyPath:@"scaledValue" options:NSKeyValueObservingOptionNew context:nil];
    [intervalValue addObserver:self forKeyPath:@"rawValue" options:NSKeyValueObservingOptionNew context:nil];
    [intervalValue addObserver:self forKeyPath:@"scaledValue" options:NSKeyValueObservingOptionNew context:nil];
    
    shotLength.scaledValue = nint(4);
    shotLength.bounds = [[ETLBounds alloc] init];
    shotLength.bounds.lower = nint(1);
    shotLength.bounds.upper = nint(90);
    ETLValueSelector *picker = [valueList addItemNamed:@"Record" withValue:shotLength];
    picker.color = UIColorForestGreen;
    [valueList didSelectValue:picker];
    
    clipLength.scaledValue = nint(40);
    clipLength.bounds = [[ETLBounds alloc] init];
    clipLength.bounds.lower = nint(1);
    clipLength.bounds.upper = nint(90);
    picker = [valueList addItemNamed:@"Play" withValue:clipLength];
    picker.color = UIColorForestGreen;
    
//    intervalValue.scaledValue = nint(4);
//    intervalValue.unit = @"seconds";
    intervalValue.bounds = [[ETLBounds alloc] init];
    intervalValue.bounds.lower = nint(1);
    intervalValue.bounds.upper = nint(90);

    //    tv = [[ETLShortTimeValue alloc] init];
//    tv.millis = 4 * HOURS;
    picker = [valueList addItemNamed:@"Interval" withValue:intervalValue];
    picker.color = UIColorBurntOrange;

//    numShots.scaledValue = nint(400);
    numShots.bounds = [[ETLBounds alloc] init];
    numShots.bounds.lower = nint(1);
    numShots.bounds.upper = nint(1000);
    
    picker = [valueList addItemNamed:@"Shots" withValue:numShots];
    picker.color = UIColorBurntOrange;
    
    menuView.hidden = true;
    menuView.layer.cornerRadius = 10;
    menuView.layer.borderWidth = 0;
//    menuView.layer.borderColor = [UIColor grayColor].CGColor;
    menuView.backgroundColor = [UIColor colorWithRed:47.0/255 green:47.0/255 blue:47.0/255 alpha:0.8];
    
    [[menuView.subviews filterWith:^bool(id object) {
        return [[object class] isSubclassOfClass:NSClassFromString(@"UIButton")];
    }] eachWith:^(id object) {
        [object addTarget:self action:@selector(didSelectUnit:) forControlEvents:UIControlEventTouchUpInside];
    }];
    
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
    
    [keypad setHidden:YES];
    
    cancelUnitMenu = [UIButton buttonWithType:UIButtonTypeCustom];
    cancelUnitMenu.frame = (CGRect){self.view.frame.origin, {self.view.frame.size.height, self.view.frame.size.width}};
    cancelUnitMenu.backgroundColor = UIColor.clearColor;
    cancelUnitMenu.hidden = true;
    [cancelUnitMenu addTarget:self action:@selector(hideUnitMenu:) forControlEvents:UIControlEventTouchUpInside];
    
    
    [menuView removeFromSuperview];
    [self.view addSubview:cancelUnitMenu];
    [self.view addSubview:menuView];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if (ignoreUpdates) return;
    
    ignoreUpdates = YES;
    UInt64 shotCount = numShots.rawValue.unsignedLongValue;
    UInt64 shotInterval = intervalValue.rawValue.unsignedLongValue;
    NSTimeInterval shootingTime = shotLength.rawValue.doubleValue;
    NSTimeInterval clipLen = clipLength.rawValue.doubleValue;
    
    if (object == numShots) {
        shotLength.millis = shotCount * shotInterval;
        [shotLength consolidateValue];
        
        clipLength.millis = shotCount / timelapse.clipFramesPerSecond * SECONDS;
        [clipLength consolidateValue];
    }
    else if (object == intervalValue) {
        shotLength.millis = shotCount * shotInterval;
        [shotLength consolidateValue];
    }
    else if (object == shotLength)
    {
        intervalValue.millis = shootingTime / shotCount;
        [intervalValue consolidateValue];
    }
    else if (object == clipLength)
    {
        numShots.rawValue = ubig(clipLength.millis / SECONDS * timelapse.clipFramesPerSecond);
        intervalValue.millis = shootingTime / numShots.rawValue.unsignedLongValue;
        [intervalValue consolidateValue];
    }
    
    timelapse.shotCount = numShots.rawValue.unsignedLongValue;
    timelapse.shotInterval = intervalValue.millis;
    
    ignoreUpdates = NO;
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

- (void)didSelectValue:(ETLValueSelector *)sel
{
    slider.color = sel.color;
    slider.value = sel.value;
    
//    keypad.colo
    keypad.value = sel.value;
}
     
- (void)didUpdateDuration:(NSNotification *)notification {
    int value = [[notification.userInfo objectForKey:@"value"] intValue];
    
    if (value == FOREVER || value < 0) {
//        clipLengthSlider.enabled = false;
//        clipLengthLabel.text = msToEnglish(FOREVER);
        
        timelapse.shotCount = 0;
    }
    else {
//        clipLengthSlider.enabled = true;
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

- (void)showUnitMenu:(id)sender
{
    if(slider.value != numShots) {
        cancelUnitMenu.hidden = false;
        menuView.hidden = false;
        menuView.alpha = 0;
        menuView.transform = CGAffineTransformMakeScale(0.1, 0.1);
        [UIView animateWithDuration:0.2 animations:^{
            menuView.alpha = 1.0;
            menuView.transform = CGAffineTransformMakeScale(1, 1);
        }];
    }
}

- (void)hideUnitMenu:(id)sender
{
    cancelUnitMenu.hidden = true;
    [UIView animateWithDuration:0.2 animations:^{
        menuView.alpha = 0;
        menuView.transform = CGAffineTransformMakeScale(0.1, 0.1);
    } completion:^(BOOL finished) {
        menuView.hidden = true;
    }];
}

- (void)didSelectUnit:(id)sender
{
    [self hideUnitMenu:sender];
    
    UIButton *btn = (UIButton *)sender;
    NSString *unit = btn.titleLabel.text.lowercaseString;
    slider.value.unit = unit;
}

- (void)toggleEditorType:(id)sender
{
    if (editorMode) {
        [UIView animateWithDuration:0.4 animations:^{
            slider.center = (CGPoint){slider.center.x + editorPane.frame.size.width, slider.center.y};
            keypad.center = (CGPoint){keypad.center.x + editorPane.frame.size.width, keypad.center.y};
            editorToggleButton.alpha = 0;
        } completion:^(BOOL finished) {
            [UIView animateWithDuration:0.4 animations:^{
                editorToggleButton.imageView.image = [UIImage imageNamed:@"keypadicon_u.png"];
                editorToggleButton.alpha = 1;
            }];
            keypad.hidden = true;
        }];
    }
    else {
        keypad.hidden = false;
        [UIView animateWithDuration:0.4 animations:^{
            slider.center = (CGPoint){slider.center.x - editorPane.frame.size.width, slider.center.y};
            keypad.center = (CGPoint){keypad.center.x - editorPane.frame.size.width, keypad.center.y};
            editorToggleButton.alpha = 0;
        } completion:^(BOOL finished) {
            [UIView animateWithDuration:0.4 animations:^{
                editorToggleButton.imageView.image = [UIImage imageNamed:@"radialicon_u.png"];
                editorToggleButton.alpha = 1;
            }];
        }];
    }
    
    editorMode = !editorMode;
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    if(!menuView.hidden) {
        for (UITouch *t in touches) {
            [self hideUnitMenu:self.view];
        }
    }
    else {
        [super touchesBegan:touches withEvent:event];
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

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
{
    return NO;
}

@end
