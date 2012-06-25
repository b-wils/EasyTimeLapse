//
//  ETLDeviceInterface.m
//  ETL-interface-test
//
//  Created by Carll Hoffman on 6/20/12.
//  Copyright (c) 2012 Microsoft. All rights reserved.
//

#import "ETLDeviceInterface.h"
#import <AudioToolbox/AudioServices.h>

void interruptionListenerCallback (void	*inUserData, UInt32	interruptionState) 
{
	// This callback, being outside the implementation block, needs a reference 
	//	to the AudioViewController object
	ETLDeviceInterface *device = (__bridge ETLDeviceInterface *) inUserData;
	
	if (interruptionState == kAudioSessionBeginInterruption) {
		[device pauseProgramming];
	} else if (interruptionState == kAudioSessionEndInterruption) {
		// if the interruption was removed, resume recording
        [device resumeProgramming];
	}
}

// Location to store the singleton instance of ETLDeviceInterface
ETLDeviceInterface * __theDeviceInterface = NULL;

@implementation ETLDeviceInterface

@synthesize analyzer, generator, recognizer;

- (id)initWithReceiver:(id <CharReceiver>)receiver
{
    // TODO - verify that this works for singleton instantiation
    if (__theDeviceInterface) {
        return __theDeviceInterface;
    }
    
    self = [super init];
    
    // initialize the audio session object for this application,
	//  registering the callback that Audio Session Services will invoke 
	//  when there's an interruption
	AudioSessionInitialize (NULL, NULL, interruptionListenerCallback, 
                            (__bridge_retained void *)self);
    
    // before instantiating the recording audio queue object, 
	//  set the audio session category
	UInt32 sessionCategory = kAudioSessionCategory_PlayAndRecord;
	AudioSessionSetProperty (kAudioSessionProperty_AudioCategory,
							 sizeof (sessionCategory),
							 &sessionCategory);
	
	recognizer = [[FSKRecognizer alloc] init];
	analyzer = [[AudioSignalAnalyzer alloc] init];
	[analyzer addRecognizer:recognizer];
	[recognizer addReceiver:receiver];
	generator = [[FSKSerialGenerator alloc] init];
	AudioSessionSetActive (true);
    
    for (int i = 0; i<5;i++) {
        //SectionConfig *myConfig = malloc(sizeof(SectionConfig));
        //initEtlConfig(myConfig);
        //[mySectionConfigs addObject:myConfig];
        
        initEtlConfig(&myConfigs[i]);
    }
    
    configIndex = 0;

    return self;
}

- (void)startProgramming
{
    NSLog (@"Programming started.");    
    
    [analyzer record];
    [generator play];
}

- (void)pauseProgramming
{
    NSLog (@"Interrupted. Pausing programming.");
    
    [analyzer stop];
    [generator pause];
}

- (void)resumeProgramming
{
    NSLog (@"Resuming programming.");
    
    [analyzer record];
    [generator resume];
}

- (void)stopProgramming
{
    NSLog (@"Programming stopped.");    
    
    [generator stop];
    [analyzer stop];
}

- (void)writeBuffer:(unsigned char *)buffer ofSize:(size_t)bufferSize withCrc:(bool)withCrc
{
    if (withCrc) {
        crc_t crc = crc_update(crc_init(), buffer, bufferSize);
        crc = crc_finalize(crc);
        
        [self writeBuffer:(unsigned char *)&crc ofSize:sizeof(crc_t)];
    }
    
    [self writeBuffer:buffer ofSize:bufferSize];
}

- (void)writeBuffer:(unsigned char *)buffer ofSize:(size_t)bufferSize
{
    for (size_t i = 0; i < bufferSize; i++) [generator writeByte:buffer[i]];
}

- (void)sendCommand:(uint8_t)command data:(uint8_t)data
{
    uint8_t buffer[] = {command, data};
    [self writeBuffer:(unsigned char *)buffer ofSize:sizeof(uint8_t)*2 withCrc:YES];
}

- (void)sendSection:(SectionConfig *)section
{
    [self writeBuffer:(unsigned char *)section ofSize:sizeof(SectionConfig) withCrc:YES];
}

- (void)doTestProgram
{    
    SectionConfig section;
    
    initEtlConfig(&section);

    section.shots = 100; //[shots.text intValue];
    section.interval = 8; //[interval.text intValue];
    
    [self sendCommand:10 data:5];
    [self sendSection:&section];
    [self sendSection:&section];
    [self sendSection:&section];
    [self sendSection:&section];
    [self sendSection:&section];
}

@end
