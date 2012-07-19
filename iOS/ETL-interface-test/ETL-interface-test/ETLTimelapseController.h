//
//  ETLTimelapseController.h
//  ETL-interface-test
//
//  Created by Carll Hoffman on 6/18/12.
//  Copyright (c) 2012 Microsoft. All rights reserved.
//

#import "ETLShotViewController.h"
#import "ETLTimelapse.h"

@interface ETLTimelapseController : ETLShotViewController <UITextFieldDelegate, UIPickerViewDelegate, UIPickerViewDataSource>
{
    NSArray * periodUnits;
    NSDictionary * msInUnit;
    NSString * periodUnit;
    
    ETLTimelapse *timelapse;
    
    IBOutlet UITextField * shotPeriodField;
    IBOutlet UIButton * periodUnitButton;
    IBOutlet UIPickerView * periodUnitPicker;
    
    IBOutlet UISwitch * continuousSwitch;
    IBOutlet UIView * shotLimitPanel;
    IBOutlet UITextField * shotLimitField;
    
    IBOutlet UILabel * finalShotLengthLabel;
    IBOutlet UILabel * totalShootingTimeLabel;
    
    IBOutlet UIButton * readyButton;
}

- (IBAction)didSwitchContinuous:(id)sender;
- (IBAction)didUpdatePeriod:(id)sender;
- (IBAction)didUpdateShotLimit:(id)sender;
- (IBAction)didClickPeriodUnit:(id)sender;

- (void)updateUICalculations:(NSNotification *)notification;

@end
