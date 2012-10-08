//
//  ETLTimelapseController.m
//  ETL-interface-test
//
//  Created by Carll Hoffman on 6/18/12.
//  Copyright (c) 2012 Microsoft. All rights reserved.
//

#import "ETLViewControllers.h"
#import "ETLSliderStepController.h"
#import "ETLRadialSlider.h"
#import "ETLUnitKeypad.h"
#import <QuartzCore/QuartzCore.h>

#define UIColorBurntOrange [UIColor colorWithRed:224/255.0 green:132/255.0 blue:59/255.0 alpha:1]
#define UIColorForestGreen [UIColor colorWithRed:121/255.0 green:137/255.0 blue:109/255.0 alpha:1]

@interface ETLTimelapseController ()
{
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
    
    [shotLength addObserver:self];
    [clipLength addObserver:self];
    [numShots addObserver:self];
    [intervalValue addObserver:self];
    
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
    
    intervalValue.bounds = [[ETLBounds alloc] init];
    intervalValue.bounds.lower = nint(1);
    intervalValue.bounds.upper = nint(90);

    picker = [valueList addItemNamed:@"Interval" withValue:intervalValue];
    picker.color = UIColorBurntOrange;

    numShots.bounds = [[ETLBounds alloc] init];
    numShots.bounds.lower = nint(1);
    numShots.bounds.upper = nint(1000);
    
    picker = [valueList addItemNamed:@"Shots" withValue:numShots];
    picker.color = UIColorBurntOrange;
    
    menuView.hidden = true;
    menuView.layer.cornerRadius = 10;
    menuView.layer.borderWidth = 0;
    menuView.backgroundColor = [UIColor colorWithRed:47.0/255 green:47.0/255 blue:47.0/255 alpha:0.8];
    
    [[menuView.subviews filterWith:^bool(id object) {
        return [[object class] isSubclassOfClass:NSClassFromString(@"UIButton")];
    }] eachWith:^(id object) {
        [object addTarget:self action:@selector(didSelectUnit:) forControlEvents:UIControlEventTouchUpInside];
    }];
        
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
}

- (void)didSelectValue:(ETLValueSelector *)sel
{
    slider.color = sel.color;
    slider.value = sel.value;
    
    keypad.value = sel.value;
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
        CGPoint c = menuView.center;
        c.x += 32; menuView.center = c;
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
        CGPoint c = menuView.center;
        c.x -= 32; menuView.center = c;
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
