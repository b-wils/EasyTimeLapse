//
//  AudioQueueObject.h
//  iNfrared
//
//  Created by George Dean on 11/28/08.
//  Culled from SpeakHere sample code.
//  Copyright 2008 Perceptive Development. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AudioUnit/AudioUnit.h>
#import <AudioToolbox/AudioToolbox.h>

#define kNumberAudioDataBuffers	3

@interface AudioUnitObject : NSObject 
{
    bool audioUnitInitialized;
    
    @public 
    AudioUnit audioUnit;
    AudioStreamBasicDescription audioFormat;
}

@property (readwrite) AudioUnit audioUnit;
@property (readwrite) AudioStreamBasicDescription audioFormat;

- (BOOL) isRunning;

@end
