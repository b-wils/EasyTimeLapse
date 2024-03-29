//
//  ETLSettingsViewController.h
//  ETL-interface-test
//
//  Created by Carll Hoffman on 7/30/12.
//  Copyright (c) 2012 Microsoft. All rights reserved.
//

#import "ETLViewController.h"

@interface ETLSettingsViewController : ETLViewController
{
    IBOutlet UISwitch *flashFeedbackSwitch;
    IBOutlet UISwitch *enableInstructionsSwitch;
    IBOutlet UIButton *cameraTypeButton;
    IBOutlet UIButton *videoFramerateButton;
    IBOutlet UITextField *flashOffsetField;
    IBOutlet UITextField *bufferTimeField;
}

- (IBAction)didUpdateFlashOffset:(id)sender;
- (IBAction)didUpdateBufferTime:(id)sender;
@end
