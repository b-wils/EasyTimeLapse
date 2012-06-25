//
//  ETLProgramControllerViewController.h
//  ETL-interface-test
//
//  Created by Carll Hoffman on 6/20/12.
//  Copyright (c) 2012 Microsoft. All rights reserved.
//

#import "ETLViewController.h"
#import "ETLDeviceInterface.h"
#import "CharReceiver.h"

@interface ETLProgramViewController : ETLViewController <CharReceiver>
{
    IBOutlet UIProgressView * programmingProgress;
    IBOutlet UILabel * bytesTransferred;
    IBOutlet UIButton * cancelButton;
    
    ETLDeviceInterface * deviceInterface;
    CommandPacket command;
    SectionConfig *sections;
    NSUInteger totalCommandBits;
    
    NSTimer * progressBarTimer;
}

- (void) setDeviceCommand:(CommandPacket)deviceCommand withSections:(SectionConfig *)commandSections;

@end
