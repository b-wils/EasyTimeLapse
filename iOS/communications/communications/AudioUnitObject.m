//
//  AudioQueueObject.m
//  iNfrared
//
//  Created by George Dean on 11/28/08.
//  Culled from SpeakHere sample code.
//  Copyright 2008 Perceptive Development. All rights reserved.
//

#import "AudioUnitObject.h"
#import <AudioUnit/AudioUnit.h>
#import <AudioToolbox/AudioToolbox.h>


@implementation AudioUnitObject

@synthesize audioUnit;
@synthesize audioFormat;

- (BOOL) isRunning {
    UInt32 result;
    UInt32 dataSize;
    AudioUnitGetProperty(audioUnit, kAudioOutputUnitProperty_IsRunning, kAudioUnitScope_Global, 0, &result, &dataSize);    
    //return audioUnit != nil;
    return result;
}


@end
