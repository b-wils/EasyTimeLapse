//
//  ETLBulbController.m
//  ETL-interface-test
//
//  Created by Carll Hoffman on 6/18/12.
//  Copyright (c) 2012 Microsoft. All rights reserved.
//

#import "ETLBulbController.h"

@interface ETLBulbController ()
{
    ETLStopSelectionController *initialExposure;
    ETLIntervalSelectionController *interval, *initialDuration, *rampDuration, *endingDuration;
}
@end

@implementation ETLBulbController
@synthesize intervalField, intervalButton;
@synthesize initialExposureField, initialExposureButton;
@synthesize initialDurationField, initialDurationButton;
@synthesize rampDurationField, rampDurationButton;
@synthesize endingDurationField, endingDurationButton;
@synthesize numStopsField;
@synthesize endingExposureField;

- (void)ensureInitialized 
{
    if (!interval) InitIntervalSelection(interval) WITH 
        interval.interval = 5; 
        interval.unit = @"seconds";
    END
    
    if (!initialExposure) InitStopSelection(initialExposure) WITH
        initialExposure.duration = 200;
    END
    
    if (!initialDuration) InitIntervalSelection(initialDuration) WITH
        initialDuration.interval = 10;
        initialDuration.unit = @"minutes";
    END
    
    if (!rampDuration) InitIntervalSelection(rampDuration) WITH
        rampDuration.interval = 20;
        rampDuration.unit = @"minutes";
    END
    
    if (!endingDuration) InitIntervalSelection(endingDuration) WITH
        endingDuration.interval = 10;
        endingDuration.unit = @"minutes";
    END
}

- (void)viewDidLoad
{
    
    [super viewDidLoad];
    [self ensureInitialized];
    [Array(endingDurationButton, initialDurationButton, initialExposureButton, rampDurationButton) 
     eachWith:^(id object) {
        [object addTarget:self action:@selector(scrollToControl:) forControlEvents:UIControlEventTouchUpInside];
    }];

}

- (void)didUpdateStop:(NSUInteger)ms forSelection:(id)sender {
    
}

- (void)didUpdateInterval:(NSUInteger)ms forSelection:(id)sender {
    
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self hideFirstResponder:nil];
    [UIView animateWithDuration:0.2 animations:^{
        [self.view viewWithTag:1].transform = CGAffineTransformMakeTranslation(0, 0);
    }];
}

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    [self hideFakeFirstResponder];
    [self scrollToControl:textField];
    
    return TRUE;
}

- (void) scrollToControl:(UIView *)control
{
    [UIView animateWithDuration:0.2 animations:^{
        [self.view viewWithTag:1].transform = CGAffineTransformMakeTranslation(0, -(MAX(100, control.frame.origin.y) - 100));
    }];
}

- (void)viewDidUnload {
    [self setIntervalField:nil];
    [self setIntervalButton:nil];
    [self setInitialExposureField:nil];
    [self setInitialDurationField:nil];
    [self setInitialDurationButton:nil];
    [self setNumStopsField:nil];
    [self setRampDurationField:nil];
    [self setRampDurationButton:nil];
    [self setEndingExposureField:nil];
    [self setEndingDurationField:nil];
    [self setEndingDurationButton:nil];
    [super viewDidUnload];
}
@end
