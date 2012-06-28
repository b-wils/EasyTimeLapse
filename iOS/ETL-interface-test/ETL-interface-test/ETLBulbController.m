//
//  ETLBulbController.m
//  ETL-interface-test
//
//  Created by Carll Hoffman on 6/18/12.
//  Copyright (c) 2012 Microsoft. All rights reserved.
//

#import "ETLBulbController.h"

@interface ETLBulbController ()

@end

@implementation ETLBulbController
@synthesize intervalField;
@synthesize intervalUnitButton;
@synthesize initialExposureField;
@synthesize initialDurationField;
@synthesize initialDurationUnitsButton;
@synthesize numStopsField;
@synthesize rampDurationField;
@synthesize rampDurationUnitsButton;
@synthesize endingExposureField;
@synthesize endingDurationField;
@synthesize endingDurationUnitsButton;

- (void)viewDidLoad
{
    NSArray * numFields = [NSArray arrayWithObjects:intervalField,
                           initialExposureField, initialDurationField,
                           numStopsField, rampDurationField,
                           endingExposureField, endingDurationField,
                           nil];
    for (UITextField *f in numFields) {
        f.inputAccessoryView = numpadToolbar;
    }
}

- (void)viewDidUnload {
    [self setIntervalField:nil];
    [self setIntervalUnitButton:nil];
    [self setInitialExposureField:nil];
    [self setInitialDurationField:nil];
    [self setInitialDurationUnitsButton:nil];
    [self setNumStopsField:nil];
    [self setRampDurationField:nil];
    [self setRampDurationUnitsButton:nil];
    [self setEndingExposureField:nil];
    [self setEndingDurationField:nil];
    [self setEndingDurationUnitsButton:nil];
    [super viewDidUnload];
}
@end
