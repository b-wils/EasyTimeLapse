//
//  ETLHdrController.m
//  ETL-interface-test
//
//  Created by Carll Hoffman on 6/18/12.
//  Copyright (c) 2012 Microsoft. All rights reserved.
//

#import "ETLViewControllers.h"
#import "ETLStopList.h"
#import "ETLPickerView.h"

@interface ETLHdrController ()
{    
    ETLHdrShot *hdr;
    ETLStopList *stopList;
    ETLPickerView *picker;
    UIButton *changingStopButton;
    bool initialMsMode, finalMsMode;
}
@end

@implementation ETLHdrController

- (void)ensureInitialized
{
    if(!hdr) {
        hdr = [[ETLHdrShot alloc] init];
        hdr.bracketCount = 3;
        hdr.initialExposure = 500;
        hdr.finalExposure = 1500;
        
        [self observe:hdr forEvent:ModelUpdated andRun:@selector(updateUICalculations:)];   
    }

    if (!stopList) {
        stopList = [[ETLStopList alloc] init];
        stopList.delegate = self;
//        periodUnit = [periodUnits objectAtIndex:1]; // "seconds"
        initialMsMode = finalMsMode = false;
    }
    
    if (!self.packetProvider) {
        self.packetProvider = hdr;
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self ensureInitialized];
    
    picker = [[ETLPickerView alloc] initWithFrame:CGRectMake(0,
                                                      self.view.frame.size.height,
                                                      self.view.frame.size.width,
                                                      picker.frame.size.height)
                                        andParent:self];
    picker.delegate = stopList;
    picker.dataSource = stopList;
    
    [picker selectRow:1 inComponent:0 animated:NO];
    picker.hidden = YES;
    
    [self.view addSubview:picker];
    [self updateUICalculations:nil];

//    bracketCountField.inputAccessoryView = numpadToolbar;
}

- (void)updateUICalculations:(id)sender 
{
    bracketCountField.text = [NSString stringWithFormat:@"%u", hdr.bracketCount];
    
#define UpdateExposureUI(kind, yOffset){                                                    \
    CGRect frame = {{143,yOffset}, {80,35}};                                                \
    NSString *stopName = [stopList getStopForMs:hdr.kind##Exposure];                        \
    if ([stopName isEqualToString:@"ms"]) kind##MsMode = true;                              \
    if (kind##MsMode) {                                                                     \
        kind##ExposureButton.allTitles = @"ms";                                             \
        kind##ExposureField.hidden = NO;                                                    \
        frame.origin.x = 215;                                                               \
        kind##ExposureField.text = [NSString stringWithFormat:@"%d", hdr.kind##Exposure];   \
    }                                                                                       \
    else {                                                                                  \
        kind##ExposureButton.allTitles = stopName;                                          \
        kind##ExposureField.hidden = YES;                                                   \
    }                                                                                       \
    kind##ExposureButton.frame = frame; }
    
    UpdateExposureUI(initial, 105)
    UpdateExposureUI(final, 144)
#undef UpdateExposureUI
}

- (IBAction)didPressStop:(id)sender
{
    changingStopButton = (UIButton *)sender;
    NSString *stopName = (changingStopButton == initialExposureButton) 
                            ? [stopList getClosestStopToMs:hdr.initialExposure]
                            : [stopList getClosestStopToMs:hdr.finalExposure];
    [picker selectRow:[stopList getStopNumberFor:stopName] 
          inComponent:0 
             animated:YES];
    [picker show:YES animated:YES];
}

-(void)didSelectStop:(NSString *)name ofMs:(NSUInteger)millis
{
#define SetStopValues(kind)                                 \
    if (changingStopButton == kind##ExposureButton) {       \
        kind##MsMode = [name isEqualToString:@"ms"];        \
        if (! kind##MsMode) { hdr.kind##Exposure = millis; }\
        else [self updateUICalculations:nil]; }
    
    SetStopValues(initial)
    SetStopValues(final)
#undef SetStopValues
}

- (IBAction)didUpdateExposureField:(id)sender
{
    if (sender == initialExposureField) {
        hdr.initialExposure = [[sender text] intValue];
    }
    else if (sender == finalExposureField)
    {
        hdr.finalExposure = [[sender text] intValue];
    }
}

- (IBAction)didUpdateBracketCount:(id)sender 
{
    hdr.bracketCount = [[sender text] intValue];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    picker = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    changingStopButton = nil;
    [picker show:NO animated:YES];
    [self hideFirstResponder:nil];
}

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    [picker show:NO animated:YES];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"Timelapse"]) {
        ETLTimelapseController *controller = [segue destinationViewController];
        controller.timelapse = hdr.timelapse;
        controller.packetProvider = hdr;
        controller.periodUnit = @"ms";
    }
    else {
        [super prepareForSegue:segue sender:sender];
    }
}

@end