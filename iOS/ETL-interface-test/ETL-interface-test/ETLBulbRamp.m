//
//  ETLBlubRamp.m
//  ETL-interface-test
//
//  Created by Carll Hoffman on 7/18/12.
//  Copyright (c) 2012 Microsoft. All rights reserved.
//

#import "ETLBulbRamp.h"

@implementation ETLBulbRamp

-(id)init {
    self =  [super init];
    if (self) {
        timelapse = [[ETLTimelapse alloc] init];
        timelapse.updateIdentity = self;
    }
    return self;
}

-(void) renderBulbRamp:(BulbRamp *)ramp {
    //    ramp->exposureFstopChangePerMin = ...
    //    ramp->fstopChangeOnPress = ...
    //    ramp->fstopSinAmplitude = ...
}

-(void) renderPacket:(UInt32)packetNumber to:(VariablePacket *)packet;
{
    switch (packetNumber) {
        case 1:
            packet->command = ETL_COMMAND_HDRSHOT;
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
