//
//  ETLIntervalSelectionControllerTest.m
//  ETL-interface-test
//
//  Created by Carll Hoffman on 8/1/12.
//  Copyright (c) 2012 Microsoft. All rights reserved.
//

#import "TestHelper.h"
#import "ETLIntervalSelectionController.h"
#import "ETLPickerView.h"
#import "ETLTimeUnitList.h"

@interface ETLIntervalSelectionControllerTest : ETLTestCase
{
    ETLIntervalSelectionController *controller;
    id fieldMock, buttonMock, parentMock, parentViewMock, pickerMock,
        controllerMock;
    
    CGRect viewFrame;
}
@end

@implementation ETLIntervalSelectionControllerTest
- (void)setUpClass {
}

- (void)tearDownClass {
}

- (void)setUp {
    controller = [[ETLIntervalSelectionController alloc] init];
    controllerMock = [OCMockObject partialMockForObject:controller];
    
    MOCKS_FOR(controller)
        WIRE(fieldMock, UITextField, textField)
        WIRE(buttonMock, UIButton, unitButton)
        WIRE(parentMock, ETLViewController, parent)
        WIRE(pickerMock, ETLPickerView, picker)
    END
    
    SETUP_MOCK(parentViewMock, UIView)
    [[[parentMock stub] andReturn:parentViewMock] view];
    [[[parentViewMock stub] andReturnStruct:&viewFrame objCType:@encode(CGRect)] frame];
    [[[pickerMock stub] andReturnStruct:&viewFrame objCType:@encode(CGRect)] frame];
}

- (void)tearDown {
    controller = nil;
    VERIFY_MOCK(fieldMock)
    VERIFY_MOCK(buttonMock)
    VERIFY_MOCK(parentMock)
    VERIFY_MOCK(parentViewMock)
    VERIFY_MOCK(pickerMock)
    VERIFY_MOCK(controllerMock)
}  

- (void)testInitWithInputField_unitButton_andParent
{
    [[parentViewMock stub] addSubview:[OCMArg any]]; // ISSUE - expect doesn't work...
    
    // TODO - decouple actual selectors from test?
    [[buttonMock expect] addTarget:controller action:@selector(didClickPeriodUnit:) forControlEvents:UIControlEventTouchUpInside];
    [[fieldMock expect] addTarget:controller action:@selector(didUpdatePeriod:) forControlEvents:UIControlEventEditingDidEnd];
    
    id initResult = [controller initWithInputField:fieldMock unitButton:buttonMock andParent:parentMock];
    assertThat(initResult, is(equalTo(controller)));
}

- (void)testDidClickPeriodUnit
{
    [[pickerMock expect] show:YES animated:YES];
    [[parentMock expect] emulateFirstResponder:pickerMock];
    [controller performSelector:@selector(didClickPeriodUnit:) withObject:buttonMock];
}

- (void)testDidUpdatePeriod
{
    id unitListMock;
    MOCKS_FOR(controller)
        WIRE(unitListMock, ETLTimeUnitList, unitList)
    END
    
    NSString *intervalFieldValue = @"5";
    NSUInteger msInSecond = 1000;
    NSUInteger expectedIntervalValue = 5000;
    [[[fieldMock expect] andReturn:intervalFieldValue] text];
    [[[unitListMock stub] andReturnValue:OCMOCK_VALUE(msInSecond)] msInUnit:OCMOCK_ANY];

    [controller performSelector:@selector(didUpdatePeriod:) withObject:fieldMock];
    
    assertThatUnsignedInteger(controller.interval, is(equalToUnsignedInteger(expectedIntervalValue)));
    VERIFY_MOCK(unitListMock)
}

- (void)testDidSelectUnit
{
    NSString *expectedUnit = @"seconds";

    // Ignore this mock
//    SKIP_MOCK(fieldMock)
    [[[fieldMock stub] andReturnBoolean:FALSE] performSelector:@selector(isNSString__)];
    
    [[controllerMock expect] performSelector:@selector(didUpdatePeriod:) withObject:expectedUnit withObject:nint(1000)];
    [controllerMock didSelectUnit:expectedUnit ofMs:1000];
    assertThat(controller.unit, is(equalTo(expectedUnit)));
}
@end