//
//  FirstViewController.h
//  ETL-comm-test
//
//  Created by Inspired Eye on 6/28/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AudioToolbox/AudioToolbox.h>
#import "FSKSerialGenerator.h"
#import "MultiDelegate.h"
#import "FSKRecognizer.h"
#import "AudioSignalAnalyzer.h"
#import "CharReceiver.h"
#import "Common.h"
#import "ETLDeviceInterface.h"
#import "crc.h"
#import "common.h"

#define MAX_PACKETS 16

@interface FirstViewController : UIViewController <CharReceiver> {
    
    IBOutlet UIProgressView * programmingProgress;
    
    ETLDeviceInterface * deviceInterface;
    
    NSUInteger totalCommandBits;
    
    NSTimer * progressBarTimer;
    
    NSUInteger receivedBits;
    NSUInteger packetIndex;
    
    IPhonePacket receivePacket;
    
    VariablePacket sentPackets[MAX_PACKETS];
    
    int sendExtraByte;
}
-(IBAction)programButtonPush;
-(IBAction)listenButtonPush;
-(IBAction)stopButtonPush;
- (void) populatePackets;
-(void) initBulbRampPacket: (VariablePacket *)packet packetId:(uint8_t)packetId fstopChange:(float)fstopChange fstopSinAmp:(float)fstopSinAmp fstopChangePress:(int8_t)fstopChangePress;

-(void) initTimelapsePacket: (VariablePacket *)packet packetId:(uint8_t)packetId shots:(uint32_t)shots interval:(uint32_t)interval expLength:(float)expLength;
-(void) initSignoffPacket: (VariablePacket *)packet packetId:(uint8_t)packetId;

@end
