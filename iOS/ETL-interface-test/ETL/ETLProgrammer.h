//
//  ETLProgrammer.h
//  ETL-interface-test
//
//  Created by Carll Hoffman on 7/16/12.
//  Copyright (c) 2012 Microsoft. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ETLDeviceInterface.h"
#import "Settings.h"

@protocol PacketProvider <NSObject>
-(void)renderPacket:(UInt32)packetNumber to:(VariablePacket *)packet;

@property (nonatomic, readonly) UInt32 packetCount;
@end

#define ByteReceived @"ByteReceived"
#define PacketRequested @"PacketRequested"
#define BadCrc @"BadCrc"
#define ProgrammingComplete @"ProgrammingComplete"
#define GotDeviceInfo @"GotDeviceInfo"
#define HeadsetAttached @"HeadsetAttached"
#define HeadsetDetached @"HeadsetDetached"

#define NOTIFY(msg, info)                   \
    [[NSNotificationCenter defaultCenter]   \
    postNotificationName:msg                \
    object:self userInfo:info]

@interface ETLProgrammer : NSObject <CharReceiver, DeviceStatusDelegate>

-(void)listen;
-(void)pause;
-(void)halt;
-(void)sendPacketNumber:(UInt32)number;

@property (nonatomic, strong) id <PacketProvider> packetProvider;
@property (nonatomic, readonly) UInt32 lastPacketSent;
@property (nonatomic, strong) Settings *settings;
@property (nonatomic, readonly) bool isHeadsetAttached;

@end
