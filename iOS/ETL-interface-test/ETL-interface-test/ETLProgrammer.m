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
    crc = crc_update(crc, ((byte *) &inPacket) + sizeof(crc_t), sizeof(IPhonePacket) - sizeof(crc_t));
    crc = crc_finalize(crc);
    
    return crc == inPacket.crc;
}

-(void)sendPacket:(VariablePacket *)packet
{
    printf("\nwriting: ");
    packet->crc = crc_update(crc_init(), ((byte *)packet) + sizeof(crc_t), sizeof(VariablePacket) - sizeof(crc_t));
    packet->crc = crc_finalize(packet->crc);

    totalCommandBits = sizeof(VariablePacket)*14;
    [device stopReader];
    [device startPlayer];
    [device writeBuffer:(uint8_t *)packet ofSize:sizeof(VariablePacket)];
}

-(void)sendPacketNumber:(UInt32)number 
{
    currentPacket = number;
    VariablePacket packet;
    memset(&packet, 0, sizeof(VariablePacket));
    [self.packetProvider renderPacket:currentPacket to:&packet];
    [self sendPacket:&packet];
}

-(void)sendSignoffPacket
{   
    VariablePacket packet;
    memset(&packet, 0, sizeof(VariablePacket));
    packet.command = ETL_COMMAND_SIGNOFF;
    packet.packetId = currentPacket + 1;
    [self sendPacket:&packet];
}

-(UInt32)lastPacketSent
{
    return currentPacket;
}

/* tryFixupPacket will take a packet that fails a crc check and iterate over all
 * non-crc bytes. If a given byte has the most significant bit set, it will unset the
 * bit and check the crc again. If the crc passes, we report true and modify the data.
 *
 * This bit of unintuitive code comes from the casual observation that crc errors tend
 * to arise on the mic channel into the iPhone as a high MSB. No idea why, but it this
 * makes transfers on certain iOS devices much faster.
 */
-(bool)tryFixupPacket {
    for (NSUInteger offset = 2; offset < sizeof(IPhonePacket); offset++) {
        byte *b = ((byte *)&inPacket) + offset;
        if (*b & 0x80) {
            byte originalByte = *b;
            *b = *b & 0x7F;
            if ([self isCrcValid]) {
                printf("\n(Packet fixed @byte #%d)", offset); 
                return true;
            }
            *b = originalByte;
        }
    }
    return false;
}

#define VALUE_WITH_BYTES(data,type) [NSValue valueWithBytes:data objCType:@encode(type)]

-(void)receivedChar:(char)input 
{
    ((byte *)&inPacket)[readOffset++] = input;
    
    if (readOffset >= sizeof(IPhonePacket)) {
        readOffset = 0;
        
        bool isValid = [self isCrcValid];
        if (!isValid) {
            isValid = [self tryFixupPacket];
        }
        
        UInt32 packetId = isValid ? inPacket.packetId : currentPacket;
        
        NSDictionary *userInfo = [NSDictionary dictionaryWithObjectsAndKeys:
                      VALUE_WITH_BYTES(&isValid, bool), @"isCrcValid",
                      VALUE_WITH_BYTES(&packetId, UInt32), @"sendingPacketId",
                      nil];
     
        if (isValid) {
            switch (inPacket.command) {
                case IOS_COMMAND_REQUESTPACKETID:
                    printf("\npacket #%lu requested.", packetId);
                    if (packetId <= packetProvider.packetCount) {
                        NOTIFY(PacketRequested, userInfo);
                        [self sendPacketNumber:packetId];
                    }
                    else {
                        NOTIFY(PacketRequested, userInfo);
                        [self sendSignoffPacket];
                        NOTIFY(ProgrammingComplete, userInfo);
                    }
                    break;
                case IOS_COMMAND_DEVICEINFO: {
                    printf("\nDevice info:\n");
                    printf("  Major Version: %d\n", inPacket.deviceInfo.majorVersion);
                    printf("  Minor Version: %d\n", inPacket.deviceInfo.minorVersion);
                    printf("  BatteryLevel: %d\n", inPacket.deviceInfo.batteryLevel);
                    NSDictionary *deviceInfo = [NSDictionary dictionaryWithObjectsAndKeys:
                        VALUE_WITH_BYTES(&inPacket.deviceInfo.majorVersion, uint8_t), @"majorVersion",
                        VALUE_WITH_BYTES(&inPacket.deviceInfo.minorVersion, uint8_t), @"minorVersion",
                        VALUE_WITH_BYTES(&inPacket.deviceInfo.batteryLevel, uint8_t), @"batteryLevel",
                        nil];
                    NOTIFY(GotDeviceInfo, deviceInfo);
                    NOTIFY(PacketRequested, userInfo);
                    [self sendPacketNumber:packetId];
                    break; 
                }
                case IOS_COMMAND_INVALID:
                default:
                    printf("unrecognized command %x\n", inPacket.command);
                    [self sendPacketNumber:0];
                    break;
            }
        }
        else {
            printf("bad crc\n");
            [self sendPacketNumber:packetId];
        }
    }
}

- (void)finalizeWrite:(NSTimer *)timer
{
    printf("-> finalizing... ");
    [timer invalidate];
    device.generator.numRawBitsWritten = 0;
    usleep(500000);
    [device stopProgramming];
    [device startReader];
    printf("done\nreading: ");
}

-(void)halt 
{
    [device stopProgramming];
    device = nil;
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
