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
    assertThat(timelapse, isNot(nil));
    assertThatInt(timelapse.shotInterval, isNot(equalToInt(0)));
    assertThatDouble(timelapse.clipFramesPerSecond, isNot(equalToDouble(0)));
}

- (void)testClipLength
{
    assertThatDouble(timelapse.clipLength, equalToDouble(INFINITY));
    
    timelapse.shotCount = 10;
    assertThatDouble(timelapse.clipLength, isNot(equalToDouble(INFINITY)));
    
    double expectedLength = 10/timelapse.clipFramesPerSecond;
    assertThatDouble(timelapse.clipLength, equalToDouble(expectedLength));
    
    // Changing shotInterval should not affect clipLength
    expectedLength = timelapse.clipLength;
    timelapse.shotInterval = 5000;
    assertThatDouble(timelapse.clipLength, equalToDouble(expectedLength));
    
    expectedLength *= 2;
    timelapse.shotCount *= 2;
    assertThatDouble(timelapse.clipLength, equalToDouble(expectedLength));
    
    UInt64 expectedCount = timelapse.shotCount / 2;
    timelapse.clipLength /= 2;
    assertThatInt(timelapse.shotCount, equalToInt(expectedCount));
}

- (void)testShootingTime
{
    assertThatFloat(timelapse.shootingTime, equalToFloat(INFINITY));
    
    timelapse.shotCount = 10;
    assertThatFloat(timelapse.shootingTime, isNot(equalToFloat(INFINITY)));
    
    double expectedLength = 10 * timelapse.shotInterval;
    assertThatDouble(timelapse.shootingTime, equalToDouble(expectedLength));
    
    // Changing clipFramesPerSecond should not affect shootingTime
    expectedLength = timelapse.shootingTime;
    timelapse.clipFramesPerSecond = 30.0;
    assertThatDouble(timelapse.shootingTime, equalToDouble(expectedLength));
    
    expectedLength *= 2;
    timelapse.shotInterval *= 2;
    assertThatDouble(timelapse.shootingTime, equalToDouble(expectedLength));
    
    UInt64 expectedInterval = timelapse.shotInterval / 2;
    timelapse.shootingTime /= 2;
    assertThatDouble(timelapse.shotInterval, equalToDouble(expectedInterval));
    
    // Setting the shooting time should not change the shotInterval when there is no shot count
    timelapse.shotCount = 0;
    timelapse.shootingTime /= 2;
    assertThatDouble(timelapse.shotInterval, equalToDouble(expectedInterval));
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
    VariablePacket packet;
    uint32_t expectedCount = 100;
    uint32_t expectedInterval = 5000;
    uint8_t packetNumber = 0;
    float expectedPower = 0.0f;
    timelapse.shotCount = expectedCount;
    timelapse.shotInterval = expectedInterval;
    
    [timelapse renderPacket:0 to:&packet];
    assertThatInt(packet.command, equalToInt(ETL_COMMAND_BASICTIMELAPSE));
    assertThatInt(packet.packetId, equalToInt(packetNumber));
    assertThatInt(packet.basicTimelapse.shots, equalToInt(expectedCount));
    assertThatInt(packet.basicTimelapse.interval, equalToInt(expectedInterval));
    assertThatFloat(packet.basicTimelapse.exposureLengthPower, equalToFloat(expectedPower));
}

-(void) testPacketCount 
{
    assertThatInt(timelapse.packetCount, equalToInt(1));
}

-(void) testExposureLengthPower
{
    timelapse.exposure = 1000;
    assertThatFloat(timelapse.exposureLengthPower, is(equalToFloat(0.0)));

    timelapse.exposure = 500;
    assertThatFloat(timelapse.exposureLengthPower, is(equalToFloat(-1.0)));
    
    timelapse.exposure = 4000;
    assertThatFloat(timelapse.exposureLengthPower, is(equalToFloat(2.0)));
}
@end