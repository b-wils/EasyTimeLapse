//
//  ETLHdrShot.m
//  ETL-interface-test
//
//  Created by Carll Hoffman on 7/18/12.
//  Copyright (c) 2012 Microsoft. All rights reserved.
//

#import "ETLHdrShot.h"
#import "ETLTimelapse.h"

@implementation ETLHdrShot

@synthesize timelapse;

ModelSynthesize(UInt32, bracketCount, setBracketCount);
ModelSynthesize(UInt32, initialExposure, setInitialExposure);
ModelSynthesize(UInt32, finalExposure, setFinalExposure);

- (id)init {
    self = [super init];
    if(self) {
        timelapse = [[ETLTimelapse alloc] init];
        timelapse.shotCount = 1;
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(synchronizeTimelapse) name:ModelUpdated object:self];
    }
    return self;
}

- (void)synchronizeTimelapse
{
    timelapse.shotInterval = finalExposure * 2;
}

- (void)renderPacket:(UInt32)packetNumber to:(VariablePacket *)packet;
{
    switch (packetNumber) {
        case 1:
            packet->command = ETL_COMMAND_HDRSHOT;
            packet->packetId = packetNumber;
            
            HDRShot * hdr = &packet->hdrShot;
            hdr->numHDRShots = bracketCount - 1;
            hdr->fstopIncreasePerHDRShot = log2f((float)finalExposure / (float)initialExposure) / bracketCount;
            break;
        case 2:
            [timelapse renderPacket:2 to:packet];
            packet->basicTimelapse.exposureLengthPower = log2f(initialExposure/1000.0);
            break;
        default:
            // TODO - error
            break;
    }
}

- (UInt32)packetCount {
    return 2;
}

@end
