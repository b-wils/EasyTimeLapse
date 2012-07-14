//
//  ETLTimelapseControllerTest.m
//  ETL-interface-test
//
//  Created by Carll Hoffman on 7/12/12.
//  Copyright (c) 2012 Microsoft. All rights reserved.
//

#import <GHUnitIOS/GHUnit.h> 
#import <OCMock/OCMock.h>
#import "TestHelper.h"

#import "ETLTimelapseController.h"
#import "ETLTimelapse.h"

@interface ETLTimelapseControllerTest : GHTestCase
{
    ETLTimelapseController *controller;
    id timelapseMock, shotCountMock, switchMock, intervalMock,
       periodUnitMock, controllerMock, pickerMock, panelMock,
       finalLengthMock, totalTimeMock;
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
    MOCKS_FOR(controller)
        WIRE(timelapseMock, ETLTimelapse, timelapse)
        WIRE(shotCountMock, UITextField, shotLimitField)
        WIRE(intervalMock, UITextField, shotPeriodField)
        WIRE(periodUnitMock, UIButton, periodUnitButton)
        WIRE(pickerMock, UIPickerView, periodUnitPicker)
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
}  

//- (IBAction)didSwitchContinuous:(id)sender;
- (void)testDidSwitchContinuous {
    const NSString *shotCountString = @"100";
    const UInt64 shotCount = [shotCountString integerValue];
    BOOL isOn = false;

    [[[shotCountMock stub] andReturn:shotCountString] text];
    
    [[[switchMock expect] andReturnValue:OCMOCK_VALUE(isOn)] isOn];
    [[[timelapseMock expect] andPost:updateNotification] setShotCount:0];
    [[controllerMock expect] updateUICalculations:OCMOCK_ANY];
    [controller didSwitchContinuous:switchMock];
    
    isOn = true;
    [[[switchMock expect] andReturnValue:OCMOCK_VALUE(isOn)] isOn];
    [[[timelapseMock expect] andPost:updateNotification] setShotCount:shotCount];
    [[controllerMock expect] updateUICalculations:updateNotification];
    [controller didSwitchContinuous:switchMock];
}

//    - (IBAction)didUpdatePeriod:(id)sender;
- (void)testDidUpdatePeriod {
    const NSString *intervalString = @"5";
    const UInt64 intervalSecondsInMs = 5000;
    
    [[[intervalMock stub] andReturn:intervalString] text];
    [[[timelapseMock expect] andPost:updateNotification] setShotInterval:intervalSecondsInMs];
    [[controllerMock expect] updateUICalculations:updateNotification];
    [controller didUpdatePeriod:intervalMock];
}

//    - (IBAction)didUpdateShotLimit:(id)sender;
- (void)testDidUpdateShotLimit {
    const NSString *shotCountString = @"100";
    const UInt64 shotCount = [shotCountString integerValue];
    
    [[[shotCountMock stub] andReturn:shotCountString] text];
    [[[timelapseMock expect] andPost:updateNotification] setShotCount:shotCount];
    [[controllerMock expect] updateUICalculations:OCMOCK_ANY];
    [controller didUpdateShotLimit:shotCountMock];
}
//    - (IBAction)didClickPeriodUnit:(id)sender;
- (void)testDidClickPeriodUnit
{
    [[pickerMock expect] setHidden:NO];
    [controller didClickPeriodUnit:periodUnitMock];
}

//    - (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
- (void)testPickerView_didSelectrow_inComponent {
    const NSInteger minutesRow = 2;
    NSString *expectedTitle = @"minutes";
    
    [[periodUnitMock expect] setTitle:expectedTitle forState:UIControlStateNormal];
    [[periodUnitMock expect] setTitle:expectedTitle forState:UIControlStateHighlighted];
    [[pickerMock expect] setHidden:YES];
    [[controllerMock expect] didUpdatePeriod:intervalMock];
    [controller pickerView:pickerMock didSelectRow:minutesRow inComponent:0];
}

//    - (void)updateUICalculations:(NSNotification *)notification
-(void)testUpdateUICalculationsContinuous
{
    bool continuous = true;
    [[[timelapseMock stub] andReturnValue:OCMOCK_VALUE(continuous)] continuousShooting];
    [[panelMock expect] setHidden:YES];
    [controller updateUICalculations:updateNotification];
}

-(void)testUpdateUICalculationsWithLimit
{
    bool continuous = false;
    UInt64 numShots = 100;
    UInt64 interval = 5000;
    double fps = 23.97;
    NSString *expectedLength = @"0:0:4.17";
    NSString *expectedTime = @"0:8:20";
    
    [[[timelapseMock stub] andReturnValue:OCMOCK_VALUE(continuous)] continuousShooting];
    [[panelMock expect] setHidden:NO];
    [[[timelapseMock expect] andReturnValue:OCMOCK_VALUE(numShots)] shotCount];
    [[[timelapseMock expect] andReturnValue:OCMOCK_VALUE(fps)] clipFramesPerSecond];
    [[finalLengthMock expect] setText:expectedLength];
    [[[timelapseMock expect] andReturnValue:OCMOCK_VALUE(numShots)] shotCount];
    [[[timelapseMock expect] andReturnValue:OCMOCK_VALUE(interval)] shotInterval];
    [[totalTimeMock expect] setText:expectedTime];
    
    [controller updateUICalculations:updateNotification];
}
@end