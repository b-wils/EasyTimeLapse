#import <GHUnitIOS/GHUnit.h> 
#import <OCMock/OCMock.h>
#import "TestHelper.h"

#import "ETLTimelapse.h"
#import <Foundation/Foundation.h>
#import "Common.h"

@interface ETLTimelapseTest : ETLTestCase
{
    ETLTimelapse *timelapse;
}
@end

@implementation ETLTimelapseTest

- (void)setUpClass {
    // Run at start of all tests in the class
}

MOCK_HANDLER(propertyUpdated:)
MOCK_HANDLER(modelUpdated:)

- (void)tearDownClass {
    // Run at end of all tests in the class
}

- (void)setUp {
    timelapse = [[ETLTimelapse alloc] init];
}

- (void)tearDown {
    timelapse = nil;
    
    [super tearDown];
}  

- (void)testInit
{
    GHAssertNotNil(timelapse, @"timelapse instance was nil");
    GHTestLog(@"timelapse.shotInterval: %d", timelapse.shotInterval);
    GHAssertNotEquals(timelapse.shotInterval, (UInt64)0, 
                      @"shotInterval must be non-zero");
    GHAssertNotEquals(timelapse.clipFramesPerSecond, (double)0, 
                      @"clipFramesPerSecond must be non-zero");
}

- (void)testClipLength
{
    GHAssertEquals(timelapse.clipLength, __builtin_inf(), 
                   @"clipLength should have been INFINITY, got %f", timelapse.clipLength);
    timelapse.shotCount = 10;
    GHAssertNotEquals(timelapse.clipLength, __builtin_inf(), 
                      @"clipLength should not have been INFINITY, got %f", timelapse.clipLength);
    
    double expectedLength = 10/timelapse.clipFramesPerSecond;
    GHAssertEquals(timelapse.clipLength, expectedLength, 
                   @"Expected clipLength of: %f, got: $f",expectedLength, timelapse.clipLength);
    
    expectedLength = timelapse.clipLength;
    timelapse.shotInterval = 5000;
    GHAssertEquals(timelapse.clipLength, expectedLength, 
                   @"Changing shotInterval should not affect clipLength");
    
    expectedLength *= 2;
    timelapse.shotCount *= 2;
    GHAssertEquals(timelapse.clipLength, expectedLength,
                   @"Doubling the shotCount should double the clipLength");
    
    UInt64 expectedCount = timelapse.shotCount / 2;
    timelapse.clipLength /= 2;
    GHAssertEquals(timelapse.shotCount, expectedCount,
                   @"Halving the clipLength should halve the shotCount");
}

- (void)testShootingTime
{
    GHAssertEquals(timelapse.shootingTime, __builtin_inf(), 
                   @"shootingTime should have been INFINITY, got %f", timelapse.shootingTime);
    
    timelapse.shotCount = 10;
    GHAssertNotEquals(timelapse.shootingTime, __builtin_inf(), 
                      @"shootingTime should not have been INFINITY, got %f", timelapse.shootingTime);
    
    double expectedLength = 10 * timelapse.shotInterval;
    GHAssertEquals(timelapse.shootingTime, expectedLength, 
                   @"Expected shootingTime of: %f, got: $f",expectedLength, timelapse.shootingTime);
    
    expectedLength = timelapse.shootingTime;
    timelapse.clipFramesPerSecond = 30.0;
    GHAssertEquals(timelapse.shootingTime, expectedLength, 
                   @"Changing clipFramesPerSecond should not affect shootingTime");
    
    expectedLength *= 2;
    timelapse.shotInterval *= 2;
    GHAssertEquals(timelapse.shootingTime, expectedLength,
                   @"Doubling the shotInterval should double the shootingTime");
    
    UInt64 expectedInterval = timelapse.shotInterval / 2;
    timelapse.shootingTime /= 2;
    GHAssertEquals(timelapse.shotInterval, expectedInterval,
                   @"Halving the shootingTime should halve the shotInterval");
    
    timelapse.shotCount = 0;
    timelapse.shootingTime /= 2;
    GHAssertEquals(timelapse.shotInterval, expectedInterval, 
                   @"Setting the shooting time should not change the shotInterval when there is no shot count");
}

-(void) testNotifications
{
    [self expectCall:@selector(propertyUpdated:) from:timelapse on:PropertyUpdated(shotCount)];
    [self expectCall:@selector(modelUpdated:) from:timelapse on:ModelUpdated];
    timelapse.shotCount = 10;
    
    [self expectCall:@selector(propertyUpdated:) from:timelapse on:PropertyUpdated(shotInterval)];
    [self expectCall:@selector(modelUpdated:) from:timelapse on:ModelUpdated];
    timelapse.shotInterval = 10;
    
    [self expectCall:@selector(propertyUpdated:) from:timelapse on:PropertyUpdated(shotCount)];
    [self expectCall:@selector(modelUpdated:) from:timelapse on:ModelUpdated];
    timelapse.clipLength = 10.0;
    
    [self expectCall:@selector(propertyUpdated:) from:timelapse on:PropertyUpdated(shotInterval)];
    [self expectCall:@selector(modelUpdated:) from:timelapse on:ModelUpdated];
    timelapse.shootingTime = 10;
}

-(void) testRenderPacket
{
    BasicTimelapse packet;
//    [[timelapse expect] renderPacket:&packet];
}
@end