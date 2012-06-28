//
//  ETLBulbController.h
//  ETL-interface-test
//
//  Created by Carll Hoffman on 6/18/12.
//  Copyright (c) 2012 Microsoft. All rights reserved.
//

#import "ETLShotViewController.h"

@interface ETLBulbController : ETLShotViewController

@property (weak, nonatomic) IBOutlet UITextField *intervalField;
@property (weak, nonatomic) IBOutlet UIButton *intervalUnitButton;
@property (weak, nonatomic) IBOutlet UITextField *initialExposureField;
@property (weak, nonatomic) IBOutlet UITextField *initialDurationField;
@property (weak, nonatomic) IBOutlet UIButton *initialDurationUnitsButton;
@property (weak, nonatomic) IBOutlet UITextField *numStopsField;
@property (weak, nonatomic) IBOutlet UITextField *rampDurationField;
@property (weak, nonatomic) IBOutlet UIButton *rampDurationUnitsButton;
@property (weak, nonatomic) IBOutlet UITextField *endingExposureField;
@property (weak, nonatomic) IBOutlet UITextField *endingDurationField;
@property (weak, nonatomic) IBOutlet UIButton *endingDurationUnitsButton;
@end
