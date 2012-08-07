//
//  ETLStopSelectionController.m
//  ETL-interface-test
//
//  Created by Carll Hoffman on 8/6/12.
//  Copyright (c) 2012 Microsoft. All rights reserved.
//

#import "ETLStopSelectionController.h"
#import "ETLPickerView.h"

@interface ETLStopSelectionController ()
{
    ETLPickerView *picker;
    ETLStopList *stopList;
    UITextField *textField;
    UIButton *stopButton;
    
    CGRect buttonFrame, fieldFrame;
}
@end

@implementation ETLStopSelectionController

@synthesize parent;
@synthesize msMode;
@synthesize duration;

- (id)initWithInputField:(UITextField *)field stopButton:(UIButton *)stops andParent:(ETLViewController <ETLStopSelectionDelegate> *)controller
{
    self = [super init];
    
    if (self) {
        textField = field;
        stopButton = stops;
        parent = controller;
        stopList = [[ETLStopList alloc] init];
        stopList.delegate = self;
        msMode = false;
        
        buttonFrame = stopButton.frame;
        fieldFrame = textField.frame;
        
        picker = [[ETLPickerView alloc] initWithFrame:CGRectMake(0,
                                                                 parent.view.frame.size.height,
                                                                 parent.view.frame.size.width,
                                                                 picker.frame.size.height) //???
                                            andParent:controller];
        picker.delegate = stopList;
        picker.dataSource = stopList;
        picker.hidden = YES;
        picker.showsSelectionIndicator = true;
        
        [parent.view addSubview:picker];
        
        [stops addTarget:self action:@selector(didClickStops:) forControlEvents:UIControlEventTouchUpInside];
        [textField addTarget:self action:@selector(didUpdateMsDuration:) forControlEvents:UIControlEventEditingDidEnd];
    }
    
    return self;
}

- (void)setDuration:(NSUInteger)value
{
    if(value > 0) duration = value;
    NSString * stop = [stopList getStopForMs:value];
    stopButton.allTitles = stop;
    [picker selectRow:[stopList getStopNumberFor:stop] inComponent:0 animated:NO];
    textField.text = [NSString stringWithFormat:@"%d", duration];
    
    if ([stop isEqualToString:@"ms"]) {
        msMode = true;
    }
    
    if (msMode) {
        stopButton.frame = buttonFrame;
        stopButton.allTitles = @"ms";
        textField.hidden = NO;
    }
    else {
        // TODO - figure out how to calculate origin.x, fieldFrame.origin.x is 0
        stopButton.frame = (CGRect){{fieldFrame.origin.x, buttonFrame.origin.y}, buttonFrame.size};
        stopButton.allTitles = [stopList getStopForMs:value];
        textField.hidden = YES;
    }
    
    [parent didUpdateStop:duration forSelection:self];
}

- (void)didUpdateMsDuration:(id)sender
{
    NSUInteger d = [textField.text intValue];
    [self setDuration:d];
}

- (void)didClickStops:(id)sender
{
    [picker selectRow:[stopList getStopNumberFor:[stopList getClosestStopToMs:duration]] inComponent:0 animated:NO];
    [picker show:YES animated:YES];
    [parent emulateFirstResponder:picker];
}

-(void)didSelectStop:(NSString *)name ofMs:(NSUInteger)millis
{
    msMode = [name isEqualToString:@"ms"];
    [self setDuration:millis];
}
@end
