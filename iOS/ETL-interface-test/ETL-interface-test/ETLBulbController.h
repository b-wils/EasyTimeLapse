//
//  ETLBulbController.h
//  ETL-interface-test
//
//  Created by Carll Hoffman on 6/18/12.
//  Copyright (c) 2012 Microsoft. All rights reserved.
//

#import "ETLShotViewController.h"
#import "ETLStopSelectionController.h"
#import "ETLIntervalSelectionController.h"

@interface ETLBulbController : ETLShotViewController <ETLStopSelectionDelegate, ETLIntervalSelectionDelegate, UITextFieldDelegate, PacketProvider>

@property (weak, nonatomic) IBOutlet UITextField *intervalField;
@property (weak, nonatomic) IBOutlet UIButton *intervalButton;

@property (weak, nonatomic) IBOutlet UITextField *initialExposureField;
@property (weak, nonatomic) IBOutlet UIButton *initialExposureButton;

@property (weak, nonatomic) IBOutlet UITextField *initialDurationField;
@property (weak, nonatomic) IBOutlet UIButton *initialDurationButton;

@property (weak, nonatomic) IBOutlet UITextField *rampDurationField;
@property (weak, nonatomic) IBOutlet UIButton *rampDurationButton;

@property (weak, nonatomic) IBOutlet UITextField *endingDurationField;
@property (weak, nonatomic) IBOutlet UIButton *endingDurationButton;

@property (weak, nonatomic) IBOutlet UITextField *numStopsField;
@property (weak, nonatomic) IBOutlet UITextField *stopChangeField;

@property (nonatomic, assign) bool sunsetMode;

- (IBAction)didUpdateNumStops:(id)sender;
- (IBAction)didUpdateStopChange:(id)sender;
@end
