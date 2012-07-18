//
//  ETLTimelapse.m
//  ETL-interface-test
//
//  Created by Carll Hoffman on 7/12/12.
//  Copyright (c) 2012 Microsoft. All rights reserved.
//

#import "ETLTimelapse.h"

@implementation ETLTimelapse

@synthesize shotInterval, clipFramesPerSecond, shotCount, shootingTime;

-(id) init
{
    self = [super init];
    if (self) {
        shotInterval = 5000;
        clipFramesPerSecond = 23.97;
    }
    
    return self;
}

-(void)setShotInterval:(UInt64)value {
    SimpleModelSetter(shotInterval)
}

-(void)setShotCount:(UInt64)value{
    SimpleModelSetter(shotCount)
}

-(NSTimeInterval)clipLength
{
    if(!self.continuousShooting) return shotCount / clipFramesPerSecond;
    return INFINITY;
}

-(void) setClipLength:(NSTimeInterval)value
{
    self.shotCount = value * clipFramesPerSecond;
}

-(NSTimeInterval)shootingTime
{
    if(!self.continuousShooting) return shotCount * shotInterval;
    return INFINITY;
}

-(void)setShootingTime:(NSTimeInterval)value
{
    if(!self.continuousShooting) self.shotInterval = value / shotCount;
}

-(bool)continuousShooting
{
    return shotCount == 0;
}

-(void) renderPacket:(UInt32)packetNumber to:(VariablePacket *)packet;
{
    packet->command = ETL_COMMAND_BASICTIMELAPSE;
    packet->packetId = packetNumber;
    
    BasicTimelapse * timelapse = &packet->basicTimelapse;
    timelapse->interval = shotInterval;
    timelapse->shots = shotCount;
    timelapse->exposureLengthPower = 0.0f;
}

- (UInt32)packetCount {
    return 1;
}

@end
