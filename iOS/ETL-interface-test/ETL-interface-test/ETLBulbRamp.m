//
//  ETLBlubRamp.m
//  ETL-interface-test
//
//  Created by Carll Hoffman on 7/18/12.
//  Copyright (c) 2012 Microsoft. All rights reserved.
//

#import "ETLBulbRamp.h"

@implementation ETLBulbRamp
@synthesize timelapse;
//@synthesize fStopChangeOnPress;
ModelSynthesize(NSInteger, fStopChangeOnPress, setFStopChangeOnPress)
//@synthesize numStops;
ModelSynthesize(NSInteger, numStops, setNumStops)

-(id)init {
    self =  [super init];
    if (self) {
        timelapse = [[ETLTimelapse alloc] init];
        timelapse.updateIdentity = self;
    }
    return self;
}

-(float)fStopChangePerMinute
{
    return numStops / (timelapse.shootingTime / MINUTES);
}

-(void) renderBulbRamp:(BulbRamp *)ramp {
    ramp->exposureFstopChangePerMin = self.fStopChangePerMinute;
    ramp->fstopChangeOnPress = -fStopChangeOnPress;
//    ramp->fstopSinAmplitude = ...
}

-(void) renderPacket:(UInt32)packetNumber to:(VariablePacket *)packet;
{
    switch (packetNumber) {
        case 1:
            packet->command = ETL_COMMAND_BULBRAMP;
            [self renderBulbRamp:&packet->bulbRamp];
            break;
        case 2:
            [timelapse renderPacket:1 to:packet];
            break;
        default:
            // TODO - error handling
            break;
    }
}

- (UInt32)packetCount {
    return 2;
}

@end
