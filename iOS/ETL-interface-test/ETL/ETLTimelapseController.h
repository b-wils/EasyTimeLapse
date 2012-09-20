//
//  ETLTimelapseController.h
//  ETL-interface-test
//
//  Created by Carll Hoffman on 6/18/12.
//  Copyright (c) 2012 Microsoft. All rights reserved.
//

#import "ETLShotViewController.h"
#import "ETLTimelapse.h"
#import "ETLSliderStepController.h"
#import "ETLValueListView.h"

@interface ETLTimelapseController : ETLShotViewController <UITextFieldDelegate, ETLIntervalSelectionDelegate, ETLValueListDelegate>
{           
    IBOutlet UIButton *readyButton;
//    IBOutlet UILabel *eventLabel, *clipLabel, *intervalLabel, *shotsLabel;
//    IBOutlet UIImageView *selectorImage;
    IBOutlet ETLValueListView *valueList;
    IBOutlet UIView *editorPane;
    IBOutlet UIView *menuView;
    IBOutlet UIButton *editorToggleButton;
}

- (IBAction)toggleEditorType:(id)sender;

@property (nonatomic, strong) ETLTimelapse *timelapse;
@end
