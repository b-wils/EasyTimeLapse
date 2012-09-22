//
//  ETLProgramControllerViewController.h
//  ETL-interface-test
//
//  Created by Carll Hoffman on 6/20/12.
//  Copyright (c) 2012 Microsoft. All rights reserved.
//

#import "ETLViewController.h"
#import "ETLProgrammer.h"
#import "CharReceiver.h"

@interface ETLProgramViewController : ETLViewController
{
    IBOutlet UIProgressView * programmingProgress;
    IBOutlet UILabel * bytesTransferred;
    IBOutlet UIButton * cancelButton;
    IBOutlet UILabel * batteryLevelLabel;
    IBOutlet UILabel * percentComplete;

    NSUInteger totalCommandBits;
    
    NSTimer * progressBarTimer, *startTimer;
    
    uint16_t batteryLevel;
}

- (void)didFinishProgramming:(id)sender;
- (void)ensureInitialized;

@property (nonatomic, strong) id <PacketProvider> packetProvider;
@property (nonatomic, strong) ETLProgrammer *programmer;
@property (nonatomic, assign) bool firstPacketSuccessful;
@end
