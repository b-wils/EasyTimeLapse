//
//  ETLHdrShot.m
//  ETL-interface-test
//
//  Created by Carll Hoffman on 7/18/12.
//  Copyright (c) 2012 Microsoft. All rights reserved.
//

#import "ETLHdrShot.h"

@implementation ETLHdrShot

ModelSynthesize(UInt32, bracketCount, setBracketCount)
ModelSynthesize(UInt32, initialExposure, setInitialExposure)
ModelSynthesize(UInt32, finalExposure, setFinalExposure)

-(void) renderPacket:(UInt32)packetNumber to:(VariablePacket *)packet;
{
    packet->command = ETL_COMMAND_HDRSHOT;
    packet->packetId = packetNumber;
    
    HDRShot * hdr = &packet->hdrShot;
    hdr->numHDRShots = bracketCount;
    hdr->fstopIncreasePerHDRShot = (finalExposure - initialExposure) / ((float)bracketCount);
}

- (UInt32)packetCount {
    return 1;
}

@end
