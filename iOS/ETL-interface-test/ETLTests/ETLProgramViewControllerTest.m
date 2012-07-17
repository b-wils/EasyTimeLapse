//
//  ETLProgramViewControllerTest.m
//  ETL-interface-test
//
//  Created by Carll Hoffman on 7/16/12.
//  Copyright (c) 2012 Microsoft. All rights reserved.
//

#import "TestHelper.h"
#import "ETLProgramViewController.h"

@interface ETLProgramViewControllerTest : ETLTestCase
{
    ETLProgramViewController *controller;
    id programmerMock;
}
@end

@implementation ETLProgramViewControllerTest
- (void)setUpClass {
}

- (void)tearDownClass {
}

- (void)setUp {
    controller = [[ETLProgramViewController alloc] init];
    MOCKS_FOR(controller)
        WIRE(programmerMock, ETLProgrammer, programmer)
    END
}

- (void)tearDown {
    VERIFY_MOCK(programmerMock)
}  

- (void)testStartProgramming
{
    [controller performSelector:@selector(startProgramming)];
}
@end
