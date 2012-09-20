//
//  ETLTimelapseController.h
//  ETL-interface-test
//
//  Created by Carll Hoffman on 6/18/12.
//  Copyright (c) 2012 Microsoft. All rights reserved.
//

#import "ETLShotViewController.h"
#import "ETLTimelapse.h"
//#import "ETLTimeUnitList.h"
//#import "ETLIntervalSelectionController.h"
#import "ETLSliderStepController.h"

#import "ETLThumb.h"

@interface ETLTimelapseController : ETLShotViewController <UITextFieldDelegate, ETLIntervalSelectionDelegate>
{           
    IBOutlet UIButton *readyButton;
    IBOutlet UILabel *eventLabel, *clipLabel, *intervalLabel, *shotsLabel;
    IBOutlet UIImageView *selectorImage;
}

- (IBAction)didTapEvent:(id)sender;
- (IBAction)didTapClip:(id)sender;
- (IBAction)didTapInterval:(id)sender;
- (IBAction)didTapShots:(id)sender;

@property (nonatomic, strong) ETLTimelapse *timelapse;
@end
