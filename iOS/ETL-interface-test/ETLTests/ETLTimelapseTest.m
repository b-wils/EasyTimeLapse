#import <GHUnitIOS/GHUnit.h> 
#import "ETLTimelapse.h"

@interface ETLTimelapseTest : GHTestCase 
{
    ETLTimelapse *timelapse;
}
@end

@implementation ETLTimelapseTest

- (void)setUpClass {
    // Run at start of all tests in the class
}

- (void)tearDownClass {
    // Run at end of all tests in the class
}

- (void)setUp {
    timelapse = [[ETLTimelapse alloc] init];
}

- (void)tearDown {
    // Run after each test method
}  

- (void)testInit
{
    GHAssertNotNil(timelapse, @"timelapse instance was nil");
    GHTestLog(@"timelapse.interval: %d", timelapse.interval);
    GHAssertNotEquals(timelapse.interval, (UInt64)0, 
                      @"interval must be non-zero");
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
    timelapse.interval = 5000;
    GHAssertEquals(timelapse.clipLength, expectedLength, 
                   @"Changing interval should not affect clipLength");
    
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
    
    double expectedLength = 10 * timelapse.interval;
    GHAssertEquals(timelapse.shootingTime, expectedLength, 
                   @"Expected shootingTime of: %f, got: $f",expectedLength, timelapse.shootingTime);
    
    expectedLength = timelapse.shootingTime;
    timelapse.clipFramesPerSecond = 30.0;
    GHAssertEquals(timelapse.shootingTime, expectedLength, 
                   @"Changing clipFramesPerSecond should not affect shootingTime");
    
    expectedLength *= 2;
    timelapse.interval *= 2;
    GHAssertEquals(timelapse.shootingTime, expectedLength,
                   @"Doubling the interval should double the shootingTime");
    
    UInt64 expectedInterval = timelapse.interval / 2;
    timelapse.shootingTime /= 2;
    GHAssertEquals(timelapse.interval, expectedInterval,
                   @"Halving the shootingTime should halve the interval");
    
    timelapse.shotCount = 0;
    timelapse.shootingTime /= 2;
    GHAssertEquals(timelapse.interval, expectedInterval, 
                   @"Setting the shooting time should not change the interval when there is no shot count");
}
@end