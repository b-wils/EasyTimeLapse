//
//  ETLDeviceInterfaceTest.m
//  ETL-interface-test
//
//  Created by Carll Hoffman on 7/12/12.
//  Copyright (c) 2012 Microsoft. All rights reserved.
//

#import <GHUnitIOS/GHUnit.h> 
#import "ETLDeviceInterface.h"
#import <OCMock.h>
#import <vector>

@interface ETLDeviceInterfaceTest : GHTestCase <CharReceiver>
{
    ETLDeviceInterface * device;
    std::vector<char> dataBuffer;
}
@end

@implementation ETLDeviceInterfaceTest
- (void)setUpClass {
}

- (void)tearDownClass {
}

- (void)setUp {
    device = [[ETLDeviceInterface alloc] initWithReceiver:self];
}

- (void)tearDown {
    device = nil;
}  

- (void)receivedChar:(char)input
{
    dataBuffer.push_back(input);
}

#define bool_to_s(x) (x ? "true" : "false")

- (void)testInit
{
    GHAssertNotNil(device, @"device instance was nil");
    GHAssertTrue(device.generator.stopped, 
                 @"device.generator should be stopped, got: %s", bool_to_s(device.generator.stopped));
//    bool isRunning = device.analyzer.isRunning; 
//    GHAssertFalse(isRunning,
//                  @"device.analyzer should not be running, got: %s", bool_to_s(isRunning));
}

- (void)testStartStopGenerator
{
    GHAssertTrue(device.generator.stopped, 
                 @"device.generator should be stopped, got: %s", bool_to_s(device.generator.stopped));
    [device startPlayer];
    GHAssertFalse(device.generator.stopped, 
                 @"device.generator should not be stopped, got: %s", bool_to_s(device.generator.stopped));
    [device stopPlayer];
    GHAssertTrue(device.generator.stopped, 
                 @"device.generator should be stopped, got: %s", bool_to_s(device.generator.stopped));
    [device startPlayer];
    GHAssertFalse(device.generator.stopped, 
                  @"device.generator should not be stopped, got: %s", bool_to_s(device.generator.stopped));
}

@end
