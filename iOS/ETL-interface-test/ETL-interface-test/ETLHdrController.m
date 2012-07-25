//
//  ETLHdrController.m
//  ETL-interface-test
//
//  Created by Carll Hoffman on 6/18/12.
//  Copyright (c) 2012 Microsoft. All rights reserved.
//

#import "ETLHdrController.h"
#import "UIButton+setAllTitles.h"
#import "ETLProgramViewController.h"

@interface ETLHdrController ()
{
    NSArray *fStops;
    NSDictionary *msForStop, *stopForMs;
    UIPickerView *picker;
    UIButton *changingStopButton;
    bool initialMsMode, finalMsMode;
}
@end

@implementation ETLHdrController

#define nint(x) [NSNumber numberWithInt:x]
#define thOfSec(x) nint(ceil(1000.0/x))
#define Array(...) [NSArray arrayWithObjects: __VA_ARGS__ , nil]

- (void)ensureInitialized
{
    if(!hdr) {
        fStops = Array(@"ms", @"1/15", @"1/13", @"1/10", @"1/8", @"1/6", @"1/5", @"1/4", 
                       @"0\"3", @"0\"4", @"0\"5", @"0\"6", @"0\"8", @"1\"", @"1\"3", @"1\"6",
                       @"2\"", @"2\"5", @"3\"2", @"4\"", @"5\"", @"6\"", @"8\"", 
                       @"10\"", @"13\"", @"15\"", @"20\"", @"25\"", @"30\"");
        NSArray * msTimes = Array(nint(0), thOfSec(15), thOfSec(13), thOfSec(10), thOfSec(8), thOfSec(6),
                                  thOfSec(5), thOfSec(4), nint(300), nint(400), nint(500), nint(600),
                                  nint(800), nint(1000), nint(1300), nint(1600), nint(2000), nint(2500),
                                  nint(3200), nint(4000), nint(5000), nint(6000), nint(8000), nint(10000),
                                  nint(13000), nint(15000), nint(20000), nint(25000), nint(30000));
        
        msForStop = [NSDictionary dictionaryWithObjects:msTimes forKeys:fStops];
        stopForMs = [NSDictionary dictionaryWithObjects:fStops forKeys:msTimes];
        
        hdr = [[ETLHdrShot alloc] init];
        hdr.bracketCount = 2;
        hdr.initialExposure = 100;
        hdr.finalExposure = 1000;
        
        [self observe:hdr forEvent:ModelUpdated andRun:@selector(updateUICalculations:)];   
        
//        periodUnit = [periodUnits objectAtIndex:1]; // "seconds"
        initialMsMode = finalMsMode = false;
    }
}

#undef thOfSec
#undef Array

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self ensureInitialized];
    
    picker = [[UIPickerView alloc] init];
    picker.delegate = self;
    picker.dataSource = self;
    [picker selectRow:1 inComponent:0 animated:NO];
    picker.hidden = YES;
    picker.frame = CGRectMake(0,
                            self.view.frame.size.height,
                            self.view.frame.size.width,
                            picker.frame.size.height);
    [self.view addSubview:picker];
    
    [self updateUICalculations:nil];

//    bracketCountField.inputAccessoryView = numpadToolbar;
}

#define UpdateExposureUI(kind, yOffset){            \
    CGRect frame = {{143,yOffset}, {80,35}};        \
    if (kind##MsMode) {                             \
        kind##ExposureButton.allTitles = @"ms";     \
        kind##ExposureField.hidden = NO;            \
        frame.origin.x = 215;                       \
        kind##ExposureField.text = [NSString stringWithFormat:@"%d", hdr.kind##Exposure];\
    }                                               \
    else {                                          \
        kind##ExposureButton.allTitles = [stopForMs objectForKey:nint(hdr.kind##Exposure)];\
        kind##ExposureField.hidden = YES;           \
    }                                               \
    kind##ExposureButton.frame = frame;             \
}

- (void)updateUICalculations:(id)sender 
{
    UpdateExposureUI(initial, 105)
    UpdateExposureUI(final, 144)
}

#undef UpdateExposureUI

- (void)displayPicker:(bool)show animated:(bool)animated
{
    if (show != picker.hidden) return;
    if (show) [self hideFirstResponder:nil];
    
    picker.hidden = NO;
    float duration = animated ? 0.25 : 0.0;
    CGRect targetBounds = show 
    ? CGRectMake(0,
                 self.view.frame.size.height - picker.frame.size.height,
                 picker.frame.size.width,
                 picker.frame.size.height)
    : CGRectMake(0,
                 self.view.frame.size.height,
                 self.view.frame.size.width,
                 picker.frame.size.height);
    
    [UIView 
     animateWithDuration:duration 
     animations:^{
         [picker setFrame:targetBounds];            
     }
     completion:^(BOOL finished) {
         if (finished) picker.hidden = !show;
     }
     ];
}

- (IBAction)didPressStop:(id)sender
{
    changingStopButton = (UIButton *)sender;
    [picker selectRow:[fStops indexOfObject:changingStopButton.titleLabel.text] 
          inComponent:0 
             animated:YES];
    [self displayPicker:YES animated:YES];
}

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return 1;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    return [fStops count];
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    NSString *stopName = [fStops objectAtIndex:row];
    
    if ([stopName isEqualToString:@"ms"]) {
        if (changingStopButton == initialExposureButton) {
            initialMsMode = true;
        }
        else if (changingStopButton == finalExposureButton) {
            finalMsMode = true;
        }
        [self updateUICalculations:nil];
    }
    else if (changingStopButton == initialExposureButton) {
        initialMsMode = false;
        hdr.initialExposure = [(NSNumber *)[msForStop objectForKey:stopName] integerValue];
    }
    else if (changingStopButton == finalExposureButton) {
        finalMsMode = false;
        hdr.finalExposure = [(NSNumber *)[msForStop objectForKey:stopName] integerValue];
    }
}

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    return [fStops objectAtIndex:row];
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
    [self displayPicker:NO animated:YES];
    [self hideFirstResponder:nil];
}

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    [self displayPicker:NO animated:YES];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"Program"]) {
        ETLProgramViewController *controller = [segue destinationViewController];
        controller.packetProvider = hdr;
    }
    if ([segue.identifier isEqualToString:@"Timelapse"]) {
        // TODO - support composition with timelapse
    }
    
    //    [super prepareForSegue:segue sender:sender];
}

@end
#undef nint