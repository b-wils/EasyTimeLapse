//
//  ETLTimelapseControllerTest.m
//  ETL-interface-test
//
//  Created by Carll Hoffman on 7/12/12.
//  Copyright (c) 2012 Microsoft. All rights reserved.
//

#import "TestHelper.h"

#import "ETLTimelapseController.h"
#import "ETLProgramViewController.h"
#import "ETLTimelapse.h"
#import "UIButton+setAllTitles.h"
#import "ETLPickerView.h"

@interface ETLTimelapseController ()
- (void)displayPicker:(bool)show animated:(bool)animated;
@end

@interface ETLTimelapseControllerTest : ETLTestCase
{
    ETLTimelapseController *controller;
    id timelapseMock, shotCountMock, switchMock, intervalMock,
       periodUnitMock, controllerMock, panelMock,
       finalLengthMock, totalTimeMock, segueMock;
    NSNotification * updateNotification;
}
@end

@implementation ETLTimelapseControllerTest
- (void)setUpClass {
}

- (void)tearDownClass {
}

- (void)setUp {
    controller = [[ETLTimelapseController alloc] init];
    SETUP_MOCK(switchMock, UISwitch)
    SETUP_MOCK(segueMock, UIStoryboardSegue)
    MOCKS_FOR(controller)
        WIRE(timelapseMock, ETLTimelapse, timelapse)
        WIRE(shotCountMock, UITextField, shotLimitField)
        WIRE(intervalMock, UITextField, shotPeriodField)
        WIRE(periodUnitMock, UIButton, periodUnitButton)
        WIRE(panelMock, UIView, shotLimitPanel)
        WIRE(finalLengthMock, UILabel, finalShotLengthLabel)
        WIRE(totalTimeMock, UILabel, totalShootingTimeLabel)
    END
    controllerMock = [OCMockObject partialMockForObject:controller];
    updateNotification = [NSNotification notificationWithName:ModelUpdated object:timelapseMock];
    [controller observe:timelapseMock forEvent:ModelUpdated andRun:@selector(updateUICalculations:)];   
}

- (void)tearDown {
    [[NSNotificationCenter defaultCenter] removeObserver:controller];
    controller = nil;
    updateNotification = nil;
    
    VERIFY_MOCK(controllerMock)
    VERIFY_MOCK(switchMock)
    VERIFY_MOCK(timelapseMock)
    VERIFY_MOCK(shotCountMock)
    VERIFY_MOCK(intervalMock)
    VERIFY_MOCK(periodUnitMock)
    VERIFY_MOCK(segueMock)
}  

//- (IBAction)didSwitchContinuous:(id)sender;
- (void)testDidSwitchContinuous {
    const NSString *shotCountString = @"100";
    const UInt64 shotCount = [shotCountString integerValue];
    BOOL isOn = true;

    [[[shotCountMock stub] andReturn:shotCountString] text];
    
    [[[switchMock expect] andReturnValue:OCMOCK_VALUE(isOn)] isOn];
    [[timelapseMock expect] setShotCount:0];
    [controller didSwitchContinuous:switchMock];
    
    isOn = false;
    [[[switchMock expect] andReturnValue:OCMOCK_VALUE(isOn)] isOn];
    [[timelapseMock expect] setShotCount:shotCount];
    [controller didSwitchContinuous:switchMock];
}

//    - (IBAction)didUpdatePeriod:(id)sender;
//- (void)testDidUpdatePeriod {
//    const NSString *intervalString = @"5";
//    const UInt64 intervalSecondsInMs = 5000;
//    
//    [[[intervalMock stub] andReturn:intervalString] text];
//    [[timelapseMock expect] setShotInterval:intervalSecondsInMs];
//    [controller didUpdatePeriod:intervalMock];
//}

//    - (IBAction)didUpdateShotLimit:(id)sender;
- (void)testDidUpdateShotLimit {
    const NSString *shotCountString = @"100";
    const UInt64 shotCount = [shotCountString integerValue];
    
    [[[shotCountMock stub] andReturn:shotCountString] text];
    [[timelapseMock expect] setShotCount:shotCount];
    [controller didUpdateShotLimit:shotCountMock];
}

//    - (void)updateUICalculations:(NSNotification *)notification
-(void)testUpdateUICalculationsContinuous
{
    bool continuous = true;
    UInt64 interval = 5000;
    NSString *intervalText = [NSString stringWithFormat:@"%u", interval / 1000];
    
    [[[timelapseMock stub] andReturnValue:OCMOCK_VALUE(continuous)] continuousShooting];
    [[[timelapseMock stub] andReturnValue:OCMOCK_VALUE(interval)] shotInterval];
    [[panelMock expect] setHidden:YES];
    [[intervalMock expect] setText:intervalText];
    [[periodUnitMock expect] setAllTitles:@"seconds"];
    [controller updateUICalculations:updateNotification];
}

-(void)testUpdateUICalculationsWithLimit
{
    bool continuous = false;
    UInt64 numShots = 100;
    NSString *numShotsText = [NSString stringWithFormat:@"%u", numShots];
    UInt64 interval = 5000;
    NSString *intervalText = [NSString stringWithFormat:@"%u", interval / 1000];
    double fps = 23.97;
    NSString *expectedLength = @"0:0:4.17";
    NSString *expectedTime = @"0:8:20";
    
    [[[timelapseMock stub] andReturnValue:OCMOCK_VALUE(continuous)] continuousShooting];
    [[[timelapseMock stub] andReturnValue:OCMOCK_VALUE(numShots)] shotCount];
    [[[timelapseMock stub] andReturnValue:OCMOCK_VALUE(fps)] clipFramesPerSecond];
    [[[timelapseMock stub] andReturnValue:OCMOCK_VALUE(interval)] shotInterval];
    
    [[panelMock expect] setHidden:NO];
    [[intervalMock expect] setText:intervalText];
    [[periodUnitMock expect] setAllTitles:@"seconds"];
    [[shotCountMock expect] setText:numShotsText];
    [[finalLengthMock expect] setText:expectedLength];
    [[totalTimeMock expect] setText:expectedTime];
    
    [controller updateUICalculations:updateNotification];
}

//     - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
-(void)testPrepareForSegue
{
    id nextControllerMock = [OCMockObject mockForClass:[ETLProgramViewController class]];
    
    [[[segueMock expect] andReturn:@"Program"] identifier];
    [[[segueMock expect] andReturn:nextControllerMock] destinationViewController];
    [[nextControllerMock expect] setPacketProvider:timelapseMock];
    [[[controllerMock stub] andReturn:timelapseMock] packetProvider];
    [controller prepareForSegue:segueMock sender:OCMOCK_ANY];
}

@end