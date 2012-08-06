//
//  ETLBimodalControllerTest.m
//  ETL-interface-test
//
//  Created by Carll Hoffman on 8/1/12.
//  Copyright (c) 2012 Microsoft. All rights reserved.
//

#import "TestHelper.h"
#import "ETLBimodalController.h"

@interface ETLBimodalControllerTest : ETLTestCase
{
    ETLBimodalController *controller;
}
@end

@implementation ETLBimodalControllerTest
- (void)setUpClass {
}

- (void)tearDownClass {
}

- (void)setUp {
    controller = [[ETLBimodalController alloc] init];
}

- (void)tearDown {
    controller = nil;
}  
@end