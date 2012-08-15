//
//  ETLHdrController.m
//  ETL-interface-test
//
//  Created by Carll Hoffman on 6/18/12.
//  Copyright (c) 2012 Microsoft. All rights reserved.
//

#import "ETLViewControllers.h"
#import "ETLStopSelectionController.h"

@interface ETLHdrController ()
{    
    ETLHdrShot *hdr;
    ETLStopSelectionController *initialExposure, *finalExposure;
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

    if (!initialExposure)
    {
        initialExposure = [[ETLStopSelectionController alloc] initWithInputField:initialExposureField stopButton:initialExposureButton andParent:self];
        initialExposure.duration = hdr.initialExposure;
    }
    
    if (!finalExposure)
    {
        finalExposure = [[ETLStopSelectionController alloc] initWithInputField:finalExposureField stopButton:finalExposureButton andParent:self];
        finalExposure.duration = hdr.finalExposure;
    }
    
    if (!self.packetProvider) {
        self.packetProvider = hdr;
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self ensureInitialized];
    
    [self updateUICalculations:nil];
}

- (void)updateUICalculations:(id)sender 
{
    bracketCountField.text = [NSString stringWithFormat:@"%u", hdr.bracketCount];
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

- (void)didUpdateStop:(NSUInteger)ms forSelection:(id)sender
{
    if (sender == initialExposure) {
        hdr.initialExposure = initialExposure.duration;
    }
    else {
        hdr.finalExposure = finalExposure.duration;
    }
}

- (void)viewDidUnload
{
    [super viewDidUnload];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    changingStopButton = nil;
    [self hideFirstResponder:nil];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"Timelapse"]) {
        [hdr synchronizeTimelapse];
        
        ETLTimelapseController *controller = [segue destinationViewController];
        controller.timelapse = hdr.timelapse;
        controller.packetProvider = hdr;
        [self hideFirstResponder:nil];
    }
    else {
        [super prepareForSegue:segue sender:sender];
    }
}

@end