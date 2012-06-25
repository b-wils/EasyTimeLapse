//
//  ETLTimelapseController.h
//  ETL-interface-test
//
//  Created by Carll Hoffman on 6/18/12.
//  Copyright (c) 2012 Microsoft. All rights reserved.
//

#import "ETLShotViewController.h"

@interface ETLTimelapseController : ETLShotViewController <UITextFieldDelegate, UIPickerViewDelegate, UIPickerViewDataSource>
{
    NSArray * periodUnits;
    NSDictionary * msInUnit;
    NSString * periodUnit;
    
    IBOutlet UITextField * shotPeriodField;
    IBOutlet UIButton * periodUnitButton;
    IBOutlet UIPickerView * periodUnitPicker;
    
    IBOutlet UIView * shotLimitPanel;
    IBOutlet UITextField * shotLimitField;
    
    IBOutlet UILabel * finalShotLengthLabel;
    IBOutlet UILabel * totalShootingTimeLabel;
    
    IBOutlet UIButton * readyButton;
}

@property(nonatomic, assign) bool continuousShooting;
@property(nonatomic, assign) NSUInteger shotPeriodInMs;
@property(nonatomic, assign) NSUInteger shotLimit;
@property(nonatomic, assign) float_t shotFramesPerSecond;

- (IBAction)didSwitchContinuous:(id)sender;
- (IBAction)didUpdatePeriod:(id)sender;
- (IBAction)didUpdateShotLimit:(id)sender;
- (IBAction)didClickPeriodUnit:(id)sender;

@end
