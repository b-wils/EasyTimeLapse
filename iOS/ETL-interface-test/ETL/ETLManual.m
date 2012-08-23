//
//  ETLManual.m
//  ETL-interface-test
//
//  Created by Carll Hoffman on 7/24/12.
//  Copyright (c) 2012 Microsoft. All rights reserved.
//

#import "ETLManual.h"

@implementation ETLManual

-(void) renderPacket:(UInt32)packetNumber to:(VariablePacket *)packet;
{
    packet->command = ETL_COMMAND_MANUALMODE;
    packet->packetId = packetNumber;
}

- (UInt32)packetCount {
    return 1;
}

@end
