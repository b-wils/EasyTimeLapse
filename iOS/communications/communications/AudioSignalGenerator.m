//
//  AudioSignalGenerator.m
//  FSK Terminal
//
//  Created by George Dean on 1/6/09.
//  Copyright 2009 Perceptive Development. All rights reserved.
//

#include <AudioToolbox/AudioToolbox.h>
#import "AudioQueueObject.h"
#import "AudioSignalGenerator.h"


static void playbackCallback (
							  void					*inUserData,
							  AudioQueueRef			inAudioQueue,
							  AudioQueueBufferRef		bufferReference
) {
	// This is not a Cocoa thread, it needs a manually allocated pool
//    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	
	// This callback, being outside the implementation block, needs a reference to the AudioSignalGenerator object
	AudioSignalGenerator *player = (AudioSignalGenerator *) inUserData;
	if ([player stopped]) return;
	
	[player fillBuffer:bufferReference->mAudioData];
	
	bufferReference->mAudioDataByteSize = player.bufferByteSize;		

	AudioQueueEnqueueBuffer (
								 inAudioQueue,
								 bufferReference,
								 player.bufferPacketCount,
								 player.packetDescriptions
								 );		
	
//	[pool release];
}

@implementation AudioSignalGenerator

@synthesize packetDescriptions;
@synthesize bufferByteSize;
@synthesize bufferPacketCount;
@synthesize stopped;
@synthesize audioPlayerShouldStopImmediately;


- (id) init {
	
	self = [super init];
	
	if (self != nil) {
		[self setupAudioFormat];
		[self setupPlaybackAudioQueueObject];
		self.stopped = YES;
		self.audioPlayerShouldStopImmediately = NO;
	}
	
	return self;
}

- (void) setupAudioFormat {
}

- (void) fillBuffer: (void*) buffer
{
}

- (void) setupPlaybackAudioQueueObject {
	
	// create the playback audio queue object
	OSStatus myStatus = AudioQueueNewOutput (
						 &audioFormat,
						 playbackCallback,
						 self, 
						 CFRunLoopGetCurrent (),
						 kCFRunLoopCommonModes,
						 0,								// run loop flags
						 &queueObject
						 );
	
    NSLog(@"AudioQueueNewOutput retval: %ld", myStatus);
    
	AudioQueueSetParameter (
							queueObject,
							kAudioQueueParam_Volume,
							1.0f
							);
	
}

- (void) setupAudioQueueBuffers {
	
	// prime the queue with some data before starting
	// allocate and enqueue buffers				
	int bufferIndex;
	
	for (bufferIndex = 0; bufferIndex < 3; ++bufferIndex) {
		
		AudioQueueAllocateBuffer (
								  [self queueObject],
								  [self bufferByteSize],
								  &buffers[bufferIndex]
								  );
		
		playbackCallback ( 
						  self,
						  [self queueObject],
						  buffers[bufferIndex]
						  );
		
		if ([self stopped]) break;
	}
}


- (void) play {
    if (stopped) {
        stopped = NO;
        [self setupAudioQueueBuffers];
        
        AudioQueueStart (
                         self.queueObject,
                         NULL			// start time. NULL means ASAP.
                         );
    }
}

- (void) stop {
	if (!stopped) {	
        AudioQueueStop (
                        self.queueObject,
                        self.audioPlayerShouldStopImmediately
                        );
        AudioQueueReset(self.queueObject);
        stopped = YES;
    }
}


- (void) pause {
	
	AudioQueuePause (
					 self.queueObject
					 );
}


- (void) resume {
	
	AudioQueueStart (
					 self.queueObject,
					 NULL			// start time. NULL means ASAP
					 );
}


- (void) dealloc {
	
	AudioQueueDispose (
					   queueObject, 
					   YES
					   );
    stopped = YES;
	[super dealloc];
}

@end
