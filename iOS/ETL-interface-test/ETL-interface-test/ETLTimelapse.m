//
//  ETLTimelapse.m
//  ETL-interface-test
//
//  Created by Carll Hoffman on 7/12/12.
//  Copyright (c) 2012 Microsoft. All rights reserved.
//

#import "ETLTimelapse.h"

@implementation ETLTimelapse

@synthesize interval, shotCount, clipFramesPerSecond;

-(id) init
{
    self = [super init];
    if (self) {
        interval = 5000;
        clipFramesPerSecond = 23.97;
    }
    
    return self;
}

-(void) setInterval:(UInt64)value
{
    interval = value;
}

-(void) setShotCount:(UInt64)value
{
    shotCount = value;
}

-(NSTimeInterval)clipLength
{
    if(shotCount > 0) return shotCount / clipFramesPerSecond;
    return INFINITY;
}

-(void) setClipLength:(NSTimeInterval)value
{
    shotCount = value * clipFramesPerSecond;
}

-(NSTimeInterval)shootingTime
{
    if(shotCount > 0) return shotCount * interval;
    return INFINITY;
}

-(void)setShootingTime:(NSTimeInterval)value
{
    if(shotCount > 0) interval = value / shotCount;
}

@end
