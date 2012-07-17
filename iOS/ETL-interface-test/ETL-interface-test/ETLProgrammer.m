//
//  ETLProgrammer.m
//  ETL-interface-test
//
//  Created by Carll Hoffman on 7/16/12.
//  Copyright (c) 2012 Microsoft. All rights reserved.
//

#import "ETLProgrammer.h"

@interface ETLProgrammer () 
{
    ETLDeviceInterface *device;
    IPhonePacket inPacket;
    UInt32 readOffset;
    UInt32 currentPacket;
    
    id progressTimer;
    NSUInteger totalCommandBits;
    double programmingProgress;
}
@end

@implementation ETLProgrammer

@synthesize packetProvider;

-(id)init
{
    self = [super init];
    if (self) {
        readOffset = 0;
        memset(&inPacket, 0, sizeof(IPhonePacket));
        device = [[ETLDeviceInterface alloc] initWithReceiver:self];
        device.delegate = self;
        
        [device startReader];
    }
    
    return self;
}

-(void)listen {
    [device stopProgramming];
    [device startReader];
}

-(bool)isCrcValid
{
    crc_t crc = crc_init();
    crc = crc_update(crc, ((byte *) &inPacket) + sizeof(crc_t), sizeof(inPacket) - sizeof(crc_t));
    crc = crc_finalize(crc);
    
    return crc == inPacket.crc;
}

-(void)sendPacketNumber:(UInt32)number 
{
    [device stopReader];
    
    currentPacket = number;
    VariablePacket packet;
    [self.packetProvider renderPacket:currentPacket to:&packet];
    packet.crc = crc_update(crc_init(), ((byte *)&packet) + sizeof(crc_t), sizeof(VariablePacket) - sizeof(crc_t));
    packet.crc = crc_finalize(packet.crc);
    
    [device startPlayer];
    [device writeBuffer:(uint8_t *)&packet ofSize:sizeof(packet)];
    totalCommandBits = sizeof(packet)*14;
}

#define VALUE_WITH_BYTES(data,type) [NSValue valueWithBytes:data objCType:@encode(type)]

-(void)receivedChar:(char)input 
{
    ((byte *)&inPacket)[readOffset++] = input;
    
    if (readOffset >= sizeof(IPhonePacket)) {
        readOffset = 0;
        
        bool isValid = [self isCrcValid];
        UInt32 packetId = isValid ? inPacket.data : currentPacket;
        
        NSDictionary *userInfo = [NSDictionary dictionaryWithObjectsAndKeys:
                      VALUE_WITH_BYTES(&isValid, bool), @"isCrcValid",
                      VALUE_WITH_BYTES(&packetId, UInt32), @"sendingPacketId",
                      nil];
        [[NSNotificationCenter defaultCenter] postNotificationName:PacketRequested object:self userInfo:userInfo];
     
        if (isValid && packetId > packetProvider.packetCount) return; 
        else [self sendPacketNumber:packetId];
    }
}

- (void)finalizeWrite:(NSTimer *)timer
{
    printf("finalizing write... ");
    [timer invalidate];
    device.generator.numRawBitsWritten = 0;
    usleep(500000);
    [device stopProgramming];
    [device startReader];
    printf("done\n");
}

-(void)halt 
{
    [device stopProgramming];
    [progressTimer invalidate];
    progressTimer = 0;
}

-(void)didWriteBuffer
{
    progressTimer = [NSTimer scheduledTimerWithTimeInterval:0.01 
                                     target:self 
                                   selector:@selector(finalizeWrite:) 
                                   userInfo:nil 
                                    repeats:NO];
}
@end
