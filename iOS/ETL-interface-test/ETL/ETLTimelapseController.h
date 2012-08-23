//
//  ETLTimelapseController.h
//  ETL-interface-test
//
//  Created by Carll Hoffman on 6/18/12.
//  Copyright (c) 2012 Microsoft. All rights reserved.
//

#import "ETLShotViewController.h"
#import "ETLTimelapse.h"
#import "ETLTimeUnitList.h"
#import "ETLIntervalSelectionController.h"

@interface ETLTimelapseController : ETLShotViewController <UITextFieldDelegate, ETLIntervalSelectionDelegate>
{    
    IBOutlet UISlider *eventDurationSlider;
    IBOutlet UISlider *clipLengthSlider;
    IBOutlet UISlider *timeScaleSlider;
    
    IBOutlet UIButton * readyButton;
}

//- (IBAction)didSwitchContinuous:(id)sender;

@property (nonatomic, strong) ETLTimelapse *timelapse;
@end
