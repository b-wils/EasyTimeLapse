//
//  ETLSettingsViewController.m
//  ETL-interface-test
//
//  Created by Carll Hoffman on 7/30/12.
//  Copyright (c) 2012 Microsoft. All rights reserved.
//

#import "ETLViewControllers.h"
#import "Settings.h"
#import "CameraType.h"
#import "ETLUtil.h"

@interface ETLSettingsViewController ()
{
    Settings *settings;   
}
@end

@implementation ETLSettingsViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self replaceSwitches:Array(@"enableInstructionsSwitch", @"flashFeedbackSwitch")];
    settings = [Settings ensureDefaultForContext:self.objectContext];
    [self updateUICalculations:nil];
}

- (void)updateUICalculations:(NSNotification *)notification
{
    cameraTypeButton.allTitles = ((CameraType *)settings.cameraType).name;
    videoFramerateButton.allTitles = [NSString stringWithFormat:@"%.2f fps", settings.videoFramerate.floatValue];
    flashOffsetField.text = [NSString stringWithFormat:@"%d", settings.flashOffset.unsignedIntValue];
    bufferTimeField.text = [NSString stringWithFormat:@"%d", settings.bufferTime.unsignedIntValue];
    [enableInstructionsSwitch setOn:settings.isHelpEnabled.boolValue animated:NO];
    [flashFeedbackSwitch setOn:settings.useFlashFeedback.boolValue animated:NO];
}

- (IBAction)didUpdateFlashOffset:(id)sender
{
    settings.flashOffset = nint(flashOffsetField.text.integerValue);
    NSError *error = nil;
    if (![self.objectContext save:&error]) {
        // Handle the error.
    }
}

- (IBAction)didUpdateBufferTime:(id)sender
{
    settings.bufferTime = nint(bufferTimeField.text.integerValue);
    NSError *error = nil;
    if (![self.objectContext save:&error]) {
        // Handle the error.
    }
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self hideFirstResponder:nil];
}

@end
