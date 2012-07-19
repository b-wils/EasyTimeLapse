//
//  ETLHdrControllerTest.m
//  ETL-interface-test
//
//  Created by Carll Hoffman on 7/18/12.
//  Copyright (c) 2012 Microsoft. All rights reserved.
//

#import "TestHelper.h"
#import "ETLHdrController.h"

@interface ETLHdrControllerTest : ETLTestCase
{
    ETLHdrController *controller;
    id controllerMock, hdrMock;
}
@end

@implementation ETLHdrControllerTest
- (void)setUpClass {
}

- (void)tearDownClass {
}

- (void)setUp {
    controller = [[ETLHdrController alloc] init];
    controllerMock = [OCMockObject partialMockForObject:controller];
    
    MOCKS_FOR(controller)
        WIRE(hdrMock, ETLHdrShot, hdr)
    END
}

- (void)tearDown {
    VERIFY_MOCK(controllerMock)
    VERIFY_MOCK(hdrMock)
}  
@end
