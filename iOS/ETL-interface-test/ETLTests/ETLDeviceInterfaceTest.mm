//
//  ETLDeviceInterfaceTest.m
//  ETL-interface-test
//
//  Created by Carll Hoffman on 7/12/12.
//  Copyright (c) 2012 Microsoft. All rights reserved.
//

#import <GHUnitIOS/GHUnit.h> 
#import <OCMock/OCMock.h>
#import "TestHelper.h"

#import "ETLDeviceInterface.h"
#import "FSKSerialGenerator.h"
#import "AudioSignalAnalyzer.h"
#import <vector>

@interface ETLDeviceInterfaceTest : GHTestCase <CharReceiver>
{
    ETLDeviceInterface * device;
    id generatorMock, analyzerMock, listenerMock;
    
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
    MOCKS_FOR(device)
        WIRE(generatorMock, FSKSerialGenerator, generator)
        WIRE(analyzerMock, AudioSignalAnalyzer, analyzer)
    END
}

- (void)tearDown {
    device = nil;
    VERIFY_MOCK(generatorMock);
    VERIFY_MOCK(analyzerMock);
}  

- (void)receivedChar:(char)input
{
    dataBuffer.push_back(input);
}

- (void)testStartStopGenerator
{ 
    [[generatorMock expect] play];
    [[generatorMock expect] stop];

    [device startPlayer];
    [device stopPlayer];
}

- (void)testStartStopAnalyzer
{
    [[analyzerMock expect] record];
    [[analyzerMock expect] stop];
    
    [device startReader];
    [device stopReader];
}

@end
