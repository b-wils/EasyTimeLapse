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
}
-(IBAction)programButtonPush;
-(IBAction)listenButtonPush;
-(IBAction)stopButtonPush;

@end
