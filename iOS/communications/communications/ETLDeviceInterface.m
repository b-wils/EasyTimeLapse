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
	ETLDeviceInterface *device = (__bridge ETLDeviceInterface *) inUserData;
	
	if (interruptionState == kAudioSessionBeginInterruption) {
		[device pauseProgramming];
	} else if (interruptionState == kAudioSessionEndInterruption) {
		// if the interruption was removed, resume recording
        [device resumeProgramming];
	}
}

void audioRouteChangeListenerCallback (void                   *inUserData,
                                       AudioSessionPropertyID inPropertyID,
                                       UInt32                 inPropertyValueSize,
                                       const void             *inPropertyValue) 
{
    if (inPropertyID != kAudioSessionProperty_AudioRouteChange) return;
    ETLDeviceInterface *device = (__bridge ETLDeviceInterface *)inUserData;

    NSDictionary *routeChangeDictionary = (__bridge NSDictionary *)inPropertyValue;
    SInt32 routeChangeReason = [[routeChangeDictionary objectForKey:
                                    (__bridge NSString *)CFSTR(kAudioSession_AudioRouteChangeKey_Reason)] 
                                integerValue];
    if (routeChangeReason == kAudioSessionRouteChangeReason_OldDeviceUnavailable) {
      
        NSDictionary *oldRouteDesc = [routeChangeDictionary objectForKey:(NSString *)kAudioSession_AudioRouteChangeKey_PreviousRouteDescription];
        NSArray *inputs = [oldRouteDesc objectForKey:(NSString *)kAudioSession_AudioRouteKey_Inputs];
        NSDictionary *inputDesc = inputs.count > 0 ? (__bridge NSDictionary *)[inputs objectAtIndex:0] : nil;
        if (!inputDesc) return;
        
        NSString *type = [inputDesc objectForKey:(NSString *)kAudioSession_AudioRouteKey_Type];
        if ([type isEqualToString:(NSString *)kAudioSessionInputRoute_HeadsetMic]) {
            [device.delegate didAttachHeadphones:false];
        }
    }
    
    if (routeChangeReason == kAudioSessionRouteChangeReason_NewDeviceAvailable) {
//        UInt32 dictRefSize = sizeof(CFDictionaryRef);
//        CFDictionaryRef routeDescriptionRef;
//        AudioSessionGetProperty(kAudioSessionProperty_AudioRouteDescription, &dictRefSize, &routeDescriptionRef);
//        
//        NSDictionary *routeDescription = (__bridge NSDictionary *)routeDescriptionRef;
//        NSArray *inputs = [routeDescription objectForKey:(NSString *)kAudioSession_AudioRouteKey_Inputs];
//        NSDictionary *inputDesc = inputs.count > 0 ? (__bridge NSDictionary *)[inputs objectAtIndex:0] : nil;
//        if (!inputDesc) return;
//        
//        NSString *type = [inputDesc objectForKey:(NSString *)kAudioSession_AudioRouteKey_Type];
//        if ([type isEqualToString:(NSString *)kAudioSessionInputRoute_HeadsetMic]) {
//            [device.delegate didAttachHeadphones:true];
//        }
        [device.delegate didAttachHeadphones:device.isHeadsetAttached];
    }
}

@interface  ETLDeviceInterface ()
{
    UInt64 numBytesWritten;
    UInt64 numTotalBytes;
}

@end

// Location to store the singleton instance of ETLDeviceInterface
@implementation ETLDeviceInterface

static bool audioInitialized = false;

@synthesize analyzer, generator, recognizer, delegate;

- (id)initWithReceiver:(id <CharReceiver>)receiver
{    
    self = [super init];
    
    // initialize the audio session object for this application,
	//  registering the callback that Audio Session Services will invoke 
	//  when there's an interruption
    OSStatus err;
    
    @synchronized([self class]) {
        if(!audioInitialized) {
            err = AudioSessionInitialize (NULL, NULL, interruptionListenerCallback, 
                                    (__bridge_retained void *)self);
            NSAssert1(err == noErr, @"Failed to initialize session", err);
            audioInitialized = true;
        }
    }
    
    // before instantiating the recording audio queue object, 
	//  set the audio session category
	UInt32 sessionCategory = kAudioSessionCategory_PlayAndRecord;
	err = AudioSessionSetProperty (kAudioSessionProperty_AudioCategory,
							 sizeof (sessionCategory),
							 &sessionCategory);
    NSAssert1(err == noErr, @"Failed to set audio category", err);
    
    Float32 preferredBufferSize = .02;
    err = AudioSessionSetProperty(kAudioSessionProperty_PreferredHardwareIOBufferDuration, sizeof(preferredBufferSize), &preferredBufferSize);
    NSAssert1(err == noErr, @"Failed to set buffer duration", err);
    
    err = AudioSessionAddPropertyListener(kAudioSessionProperty_AudioRouteChange, 
                                          audioRouteChangeListenerCallback, 
                                          (__bridge_retained void*)self);
	
	recognizer = [[FSKRecognizer alloc] init];
	analyzer = [[AudioSignalAnalyzer alloc] init];
	[analyzer addRecognizer:recognizer];
	[recognizer addReceiver:receiver];
	generator = [[FSKSerialGenerator alloc] init];
    generator.delegate = self;
	err = AudioSessionSetActive (true);
    NSAssert1(err == noErr, @"Failed to set active session", err);

    return self;
}

- (void)dealloc
{
    OSStatus err = AudioSessionSetActive(false);
    NSAssert1(err == noErr, @"Failed to deactivate audio session", err);
    [super dealloc];
}

- (void)startProgramming
{   
    AudioSessionSetActive(true);
//    NSAssert1(err == noErr, @"Failed to deactivate audio session", err);
    [analyzer record];
    [generator play];
}

- (void)pauseProgramming
{   
    [analyzer stop];
    [generator pause];
}

- (void)resumeProgramming
{   
    [analyzer record];
    [generator resume];
}

- (void)stopProgramming
{   
    OSStatus err = AudioSessionSetActive(false);
//    NSAssert1(err == noErr, @"Failed to deactivate audio session", err);
    [generator stop];
    [analyzer stop];
}

-(void)startPlayer
{
    [generator play];
}

-(void)pausePlayer
{   
    [generator pause];
}

-(void)resumePlayer
{   
    [generator resume];
}

-(void)stopPlayer
{
    [generator stop];
}

-(void)startReader
{
    [analyzer record];
}

-(void)stopReader
{   
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
    numTotalBytes = bufferSize;
    numBytesWritten = 0;
    
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

- (void)didWriteByte
{
    numBytesWritten++;
    if(numBytesWritten == numTotalBytes) 
        [self.delegate didWriteBuffer];
}

-(bool)isHeadsetAttached {
    UInt32 dictRefSize = sizeof(CFDictionaryRef);
    CFDictionaryRef routeDescriptionRef;
    AudioSessionGetProperty(kAudioSessionProperty_AudioRouteDescription, &dictRefSize, &routeDescriptionRef);
    
    NSDictionary *routeDescription = (__bridge NSDictionary *)routeDescriptionRef;
    NSArray *inputs = [routeDescription objectForKey:(NSString *)kAudioSession_AudioRouteKey_Inputs];
    NSDictionary *inputDesc = inputs.count > 0 ? (__bridge NSDictionary *)[inputs objectAtIndex:0] : nil;
    if (!inputDesc) return false; // TODO - is this an error?
    
    NSString *type = [inputDesc objectForKey:(NSString *)kAudioSession_AudioRouteKey_Type];
    if ([type isEqualToString:(NSString *)kAudioSessionInputRoute_HeadsetMic]) {
        return true;
    }
    
    return false;
}

@end
