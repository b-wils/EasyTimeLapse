//
//  ETLHdrController.h
//  ETL-interface-test
//
//  Created by Carll Hoffman on 6/18/12.
//  Copyright (c) 2012 Microsoft. All rights reserved.
//

#import "ETLShotViewController.h"
#import "ETLHdrShot.h"

@interface ETLHdrController : ETLShotViewController <UITextFieldDelegate, UIPickerViewDelegate, UIPickerViewDataSource>
{
    ETLHdrShot *hdr;
    
    IBOutlet UITextField *bracketCountField;
    IBOutlet UITextField *initialExposureField;
    IBOutlet UITextField *finalExposureField;
    IBOutlet UIButton *initialExposureButton;
    IBOutlet UIButton *finalExposureButton;
}

- (IBAction)didPressStop:(id)sender;
- (IBAction)didUpdateExposureField:(id)sender;
@end
