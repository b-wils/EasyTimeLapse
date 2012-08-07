//
//  ETLBulbController.m
//  ETL-interface-test
//
//  Created by Carll Hoffman on 6/18/12.
//  Copyright (c) 2012 Microsoft. All rights reserved.
//

#import "ETLBulbController.h"
#import "ETLTimelapse.h"
#import "ETLBulbRamp.h"

@interface ETLBulbController ()
{
    ETLStopSelectionController *initialExposure;
    ETLIntervalSelectionController *interval, *initialDuration, *rampDuration, *endingDuration;
    ETLTimelapse *initial, *final;
    ETLBulbRamp *ramp;
}
@end

@implementation ETLBulbController
@synthesize intervalField, intervalButton;
@synthesize initialExposureField, initialExposureButton;
@synthesize initialDurationField, initialDurationButton;
@synthesize rampDurationField, rampDurationButton;
@synthesize endingDurationField, endingDurationButton;
@synthesize numStopsField, stopChangeField;

- (void)ensureInitialized 
{
    if (!initial) {
        initial = [[ETLTimelapse alloc] init];
        initial.shotInterval = 5*SECONDS;
        initial.shotCount = 10*MINUTES / initial.shotInterval;
        initial.exposure = 200*MS;
    }
    
    if (!ramp) {
        ramp = [[ETLBulbRamp alloc] init];
        ramp.timelapse.shotInterval = 5*SECONDS;
        ramp.timelapse.shotCount = 20*MINUTES / ramp.timelapse.shotInterval;
        ramp.timelapse.exposure = initial.exposure;
        ramp.numStops = 10;
        ramp.fStopChangeOnPress = 3;
    }
    
    if (!final) {
        final = [[ETLTimelapse alloc] init];
        final.shotInterval = 5*SECONDS;
        final.shotCount = 10*MINUTES / final.shotInterval;
        final.exposureLengthPower = initial.exposureLengthPower + ramp.numStops;
    }
    
    if (!interval) InitIntervalSelection(interval) WITH 
        interval.interval = initial.shotInterval / SECONDS; 
        interval.unit = @"seconds";
    END
    
    if (!initialExposure) InitStopSelection(initialExposure) WITH
        initialExposure.duration = initial.exposure;
    END
    
    if (!initialDuration) InitIntervalSelection(initialDuration) WITH
        initialDuration.interval = initial.shootingTime / MINUTES;
        initialDuration.unit = @"minutes";
    END
    
    if (!rampDuration) InitIntervalSelection(rampDuration) WITH
        rampDuration.interval = ramp.timelapse.shootingTime / MINUTES;
        rampDuration.unit = @"minutes";
    END
    
    if (!endingDuration) InitIntervalSelection(endingDuration) WITH
        endingDuration.interval = final.shootingTime / MINUTES;
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
    
    self.packetProvider = self;
}

- (void)didUpdateStop:(NSUInteger)ms forSelection:(id)sender 
{
    initial.exposure = ((ETLStopSelectionController *)sender).duration;
    ramp.timelapse.exposure = initial.exposure;
    final.exposureLengthPower = initial.exposureLengthPower + ramp.numStops;
}

- (void)didUpdateInterval:(NSUInteger)ms forSelection:(id)sender 
{
    if (sender == interval) {
        initial.shotInterval = interval.interval;
        final.shotInterval = interval.interval;
        ramp.timelapse.shotInterval = interval.interval;
    }
    
    if (sender == initialDuration) {
//        initial.shootingTime = initialDuration.interval;
        initial.shotCount = initialDuration.interval / initial.shotInterval;
    }
    
    if (sender == rampDuration) {
//        ramp.timelapse.shootingTime = rampDuration.interval;
        ramp.timelapse.shotCount = rampDuration.interval / ramp.timelapse.shotInterval;
    }
    
    if (sender == endingDuration) {
//        final.shootingTime = endingDuration.interval;
        final.shotCount = endingDuration.interval / final.shotInterval;
    }
}

- (IBAction)didUpdateNumStops:(id)sender 
{
    ramp.numStops = [[sender text] integerValue];
    final.exposureLengthPower = initial.exposureLengthPower + ramp.numStops;
}

- (IBAction)didUpdateStopChange:(id)sender
{
    ramp.fStopChangeOnPress = [[sender text] integerValue];
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

- (void)renderPacket:(UInt32)packetNumber to:(VariablePacket *)packet 
{
    switch (packetNumber) {
        case 1:
            [initial renderPacket:packetNumber to:packet];
            break;
        case 2:
        case 3:
            [ramp renderPacket:packetNumber - 1 to:packet];
            packet->packetId = packetNumber;
            break;
        case 4:
            [final renderPacket:packetNumber to:packet];
            break;
        default:
            // TODO - error
            break;
    }
}
 
- (UInt32)packetCount {
    return 4;
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
    [self setEndingDurationField:nil];
    [self setEndingDurationButton:nil];
    [super viewDidUnload];
}
@end
