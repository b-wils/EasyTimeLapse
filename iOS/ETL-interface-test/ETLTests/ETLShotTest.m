//
//  ETLShotTest.m
//  ETL-interface-test
//
//  Created by Carll Hoffman on 7/19/12.
//  Copyright (c) 2012 Microsoft. All rights reserved.
//

#import "TestHelper.h"
#import "ETLShot.h"

@interface ETLShotTest : ETLTestCase
{
    ETLShot *shot;
    id shotMock, componentMock, component2Mock, arrayMock;
}
@end

@implementation ETLShotTest
- (void)setUpClass {
}

- (void)tearDownClass {
}

- (void)setUp {
    shot = [[ETLShot alloc] init];
    shotMock = [OCMockObject partialMockForObject:shot];
    
    SETUP_PROTOCOL_MOCK(componentMock, PacketProvider)
    SETUP_PROTOCOL_MOCK(component2Mock, PacketProvider)
}

- (void)tearDown {
    VERIFY_MOCK(shotMock)
    VERIFY_MOCK(arrayMock)
    VERIFY_MOCK(componentMock)
    VERIFY_MOCK(component2Mock)
    shot = nil;
}  

- (void)testAdd {
    MOCKS_FOR(shot)
        WIRE(arrayMock, NSMutableArray, shots)
    END
    
    [[arrayMock expect] addObject:componentMock];
    [shot add:componentMock];
}

- (void)testPacketCount {
    UInt32 componentSize = 1;
    [[[componentMock stub] andReturnValue:OCMOCK_VALUE(componentSize)] packetCount];
    
    assertThatInt(shot.packetCount, is(equalToInt(0)));
    [shot add:componentMock];
    assertThatInt(shot.packetCount, is(equalToInt(componentSize)));
}

- (void)testRenderPacket 
{    
    VariablePacket packet;
    UInt32 componentSize = 1;
    [[[componentMock stub] andReturnValue:OCMOCK_VALUE(componentSize)] packetCount];
    UInt32 component2Size = 2;
    [[[component2Mock stub] andReturnValue:OCMOCK_VALUE(component2Size)] packetCount];
    [shot add:componentMock];

    [[componentMock expect] renderPacket:1 to:&packet];
    [shot renderPacket:1 to:&packet];
    
    [shot add:component2Mock];
    [[component2Mock expect] renderPacket:1 to:&packet];
    [[component2Mock expect] renderPacket:2 to:&packet];
    [shot renderPacket:2 to:&packet];
    [shot renderPacket:3 to:&packet];
}
@end