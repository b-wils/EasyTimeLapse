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

@interface ETLProgramViewController : ETLViewController <CharReceiver>
{
    IBOutlet UIProgressView * programmingProgress;
    IBOutlet UILabel * bytesTransferred;
    IBOutlet UIButton * cancelButton;
    
    ETLProgrammer *programmer;
    NSUInteger totalCommandBits;
    
    NSTimer * progressBarTimer, *startTimer;
}

- (void) didFinishProgramming:(id)sender;

@property (nonatomic, strong) id <PacketProvider> packetProvider;
@end
