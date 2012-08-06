//
//  ETLTimeUnitListTest.m
//  ETL-interface-test
//
//  Created by Carll Hoffman on 8/1/12.
//  Copyright (c) 2012 Microsoft. All rights reserved.
//

#import "TestHelper.h"
#import "ETLTimeUnitList.h"

@interface ETLTimeUnitListTest : ETLTestCase
{
    ETLTimeUnitList *unitList;
}
@end

@implementation ETLTimeUnitListTest
- (void)setUpClass {
}

- (void)tearDownClass {
}

- (void)setUp {
    unitList = [[ETLTimeUnitList alloc] init];
}

- (void)tearDown {
    unitList = nil;
}  

- (void)testMsInUnit
{
    assertThatUnsignedInteger([unitList msInUnit:@"ms"], is(equalToUnsignedInteger(1)));
    assertThatUnsignedInteger([unitList msInUnit:@"not-a-unit"], is(equalToUnsignedInteger(1)));
    assertThatUnsignedInteger([unitList msInUnit:@"seconds"], is(equalToUnsignedInteger(1000)));
    assertThatUnsignedInteger([unitList msInUnit:@"minutes"], is(equalToUnsignedInteger(1000*60)));
    assertThatUnsignedInteger([unitList msInUnit:@"hours"], is(equalToUnsignedInteger(1000*60*60)));
}

- (void)testGetNumberOfUnit
{
    assertThatUnsignedInteger([unitList getNumberOfUnit:@"ms"], is(equalToUnsignedInteger(0)));
    assertThatUnsignedInteger([unitList getNumberOfUnit:@"not-a-unit"], is(equalToUnsignedInteger(0)));
    assertThatUnsignedInteger([unitList getNumberOfUnit:@"seconds"], is(equalToUnsignedInteger(1)));
    assertThatUnsignedInteger([unitList getNumberOfUnit:@"minutes"], is(equalToUnsignedInteger(2)));
    assertThatUnsignedInteger([unitList getNumberOfUnit:@"hours"], is(equalToUnsignedInteger(3)));
}

- (void)testGetUnitByNumber 
{
    assertThat([unitList getUnitByNumber:0], is(equalTo(@"ms")));
    assertThat([unitList getUnitByNumber:10], is(equalTo(@"ms")));
    assertThat([unitList getUnitByNumber:1], is(equalTo(@"seconds")));
    assertThat([unitList getUnitByNumber:2], is(equalTo(@"minutes")));
    assertThat([unitList getUnitByNumber:3], is(equalTo(@"hours")));
}
@end