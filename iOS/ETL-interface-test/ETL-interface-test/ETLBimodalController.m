//
//  ETLBimodalController.m
//  ETL-interface-test
//
//  Created by Carll Hoffman on 8/1/12.
//  Copyright (c) 2012 Microsoft. All rights reserved.
//

#import "ETLBimodalController.h"
#import "ETLTimelapse.h"

@interface ETLBimodalController ()
{
    ETLTimelapse *modeA, *modeB;
    ETLIntervalSelectionController *intervalA, *intervalB;
}
@end

@implementation ETLBimodalController

- (void)ensureInitialized
{
#define SETUP_MODE(x){ \
    if(!mode##x) { \
        mode##x = [[ETLTimelapse alloc] init];\
        mode##x.exposure = 100;\
        mode##x.shotInterval = 2000;\
    }\
    if (!interval##x) {\
        interval##x = [[ETLIntervalSelectionController alloc] initWithInputField:interval##x##Field \
                                                                    unitButton:interval##x##Button  \
                                                                     andParent:self];               \
        interval##x.unit = @"seconds";\
        interval##x.interval = mode##x.shotInterval;\
    }}
    
    SETUP_MODE(A)
    SETUP_MODE(B)
#undef SETUP_MODE
}

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
    [self ensureInitialized];
    self.packetProvider = self;
}

- (void)updateUICalculations:(NSNotification *)notification
{
    
}

- (void)didUpdateInterval:(NSUInteger)ms forSelection:(id)sender
{
    ETLTimelapse *tl = (sender == intervalA) ? modeA : modeB;
    tl.shotInterval = ms;
}

-(void)renderPacket:(UInt32)packetNumber to:(VariablePacket *)packet
{
    memset(packet, 0, sizeof(VariablePacket));
    switch (packetNumber) {
        case 2:
            [modeA renderPacket:packetNumber to:packet];
            break;
        case 4:
            [modeB renderPacket:packetNumber to:packet];
            break;
        case 3:            
            packet->intervalRamp.numRepeats = INT16_MAX;
        case 1:
            packet->command = ETL_COMMAND_INTERVALRAMP;
            packet->packetId = packetNumber;
            packet->intervalRamp.intervalDelta = 0;
            packet->intervalRamp.changeConfigInfo = 1 << CONFIG_PRESS_TO_ADVANCE;
            break;
        default:
            // TODO - error
            break;
    }
}

-(UInt32)packetCount {
    return 4;
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

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField 
{
    [self hideFirstResponder:nil];
    return TRUE;
}

@end
