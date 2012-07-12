//
//  AudioSignalAnalyzer.m
//  iNfrared
//
//  Created by George Dean on 11/28/08.
//  Copyright 2008 Perceptive Development. All rights reserved.
//

#import "AudioSignalAnalyzer.h"

#define SAMPLE_RATE  44100
#define NUM_CHANNELS  1
#define BYTES_PER_FRAME  (NUM_CHANNELS * sizeof(SAMPLE))

#define SAMPLES_TO_NS(__samples__) (((UInt64)(__samples__) * 1000000000) / SAMPLE_RATE)
#define NS_TO_SAMPLES(__nanosec__)  (unsigned)(((UInt64)(__nanosec__)  * SAMPLE_RATE) / 1000000000)
#define US_TO_SAMPLES(__microsec__) (unsigned)(((UInt64)(__microsec__) * SAMPLE_RATE) / 1000000)
#define MS_TO_SAMPLES(__millisec__) (unsigned)(((UInt64)(__millisec__) * SAMPLE_RATE) / 1000)

#define EDGE_DIFF_THRESHOLD		8192
#define EDGE_SLOPE_THRESHOLD	256
#define EDGE_MAX_WIDTH			8
#define IDLE_CHECK_PERIOD		MS_TO_SAMPLES(10)


#define kOutputBus 0
#define kInputBus 1

static int analyze(SAMPLE *inputBuffer,
                   unsigned long framesPerBuffer,
                   AudioSignalAnalyzer* analyzer)
{
	analyzerData *data = analyzer.pulseData;
	SAMPLE *pSample = inputBuffer;
	int lastFrame = data->lastFrame;
	
	unsigned idleInterval = data->plateauWidth + data->lastEdgeWidth + data->edgeWidth;
	
	for (long i=0; i < framesPerBuffer; i++, pSample++)
	{
		int thisFrame = *pSample;
		int diff = thisFrame - lastFrame;
		
		int sign = 0;
		if (diff > EDGE_SLOPE_THRESHOLD)
		{
			// Signal is rising
			sign = 1;
		}
		else if(-diff > EDGE_SLOPE_THRESHOLD)
		{
			// Signal is falling
			sign = -1;
		}
		
		// If the signal has changed direction or the edge detector has gone on for too long,
		//  then close out the current edge detection phase
		if(data->edgeSign != sign || (data->edgeSign && data->edgeWidth + 1 > EDGE_MAX_WIDTH))
		{
			if(abs(data->edgeDiff) > EDGE_DIFF_THRESHOLD && data->lastEdgeSign != data->edgeSign)
			{
				// The edge is significant
				[analyzer edge:data->edgeDiff
						 width:data->edgeWidth
					  interval:(data->lastEdgeWidth + data->plateauWidth + data->plateauWidth + data->edgeWidth) >> 1];
				
				// Save the edge
				data->lastEdgeSign = data->edgeSign;
				data->lastEdgeWidth = data->edgeWidth;
				
				// Reset the plateau
				data->plateauWidth = 0;
				idleInterval = data->edgeWidth;
#ifdef DETAILED_ANALYSIS
				data->plateauSum = 0;
				data->plateauMin = data->plateauMax = thisFrame;
#endif
			}
			else
			{
				// The edge is rejected; add the edge data to the plateau
				data->plateauWidth += data->edgeWidth;
#ifdef DETAILED_ANALYSIS
				data->plateauSum += data->edgeSum;
				if(data->plateauMax < data->edgeMax)
					data->plateauMax = data->edgeMax;
				if(data->plateauMin > data->edgeMin)
					data->plateauMin = data->edgeMin;
#endif
			}
			
			data->edgeSign = sign;
			data->edgeWidth = 0;
			data->edgeDiff = 0;
#ifdef DETAILED_ANALYSIS
			data->edgeSum = 0;
			data->edgeMin = data->edgeMax = lastFrame;
#endif
		}
		
		if(data->edgeSign)
		{
			// Sample may be part of an edge
			data->edgeWidth++;
			data->edgeDiff += diff;
#ifdef DETAILED_ANALYSIS
			data->edgeSum += thisFrame;
			if(data->edgeMax < thisFrame)
				data->edgeMax = thisFrame;
			if(data->edgeMin > thisFrame)
				data->edgeMin = thisFrame;
#endif
		}
		else
		{
			// Sample is part of a plateau
			data->plateauWidth++;
#ifdef DETAILED_ANALYSIS
			data->plateauSum += thisFrame;
			if(data->plateauMax < thisFrame)
				data->plateauMax = thisFrame;
			if(data->plateauMin > thisFrame)
				data->plateauMin = thisFrame;
#endif
		}
		idleInterval++;
		
		data->lastFrame = lastFrame = thisFrame;
		
		if ( (idleInterval % IDLE_CHECK_PERIOD) == 0 )
			[analyzer idle:idleInterval];
		
	}
	
	return 0;
}


static OSStatus	recordingCallback(
							void						*inUserData, 
							AudioUnitRenderActionFlags 	*ioActionFlags, 
							const AudioTimeStamp 		*inTimeStamp, 
							UInt32 						inBusNumber, 
							UInt32 						inNumFrames, 
							AudioBufferList 			*ioData)
{	
 	// This callback, being outside the implementation block, needs a reference to the AudioRecorder object
    AudioSignalAnalyzer *analyzer = (AudioSignalAnalyzer *) inUserData;
    AudioBuffer buffer;
    
    // TODO - figure out why buffer needs sizeof(SAMPLE)*2 bytes per sample
    buffer.mNumberChannels = 1;
    buffer.mDataByteSize = inNumFrames * sizeof(SAMPLE) * 2;
    buffer.mData = malloc(buffer.mDataByteSize);
    
    AudioBufferList bufferList;
    bufferList.mNumberBuffers = 1;
    bufferList.mBuffers[0] = buffer;
    
    OSStatus err = AudioUnitRender([analyzer audioUnit],
                                   ioActionFlags,
                                   inTimeStamp,
                                   kInputBus,
                                   inNumFrames,
                                   &bufferList);
	if (err) { printf("renderingCallback: error %d\n", (int)err); return err; }

	
	// if there is audio data, analyze it
	if (inNumFrames > 0) {
		analyze((SAMPLE*)bufferList.mBuffers[0].mData, bufferList.mBuffers[0].mDataByteSize / BYTES_PER_FRAME, analyzer);		
	}
    
    free(buffer.mData);
    
    return noErr;
}

@interface AudioSignalAnalyzer ()
- (OSStatus) createAudioUnit;
@end

@implementation AudioSignalAnalyzer

@synthesize stopping;

- (analyzerData*) pulseData
{
	return &pulseData;
}

- (void) setupAudioFormat
{
    // these statements define the audio stream basic description
    // for the file to record into.
    audioFormat.mSampleRate			= 44100; //SAMPLE_RATE;
    audioFormat.mFormatID			= kAudioFormatLinearPCM;
    audioFormat.mFormatFlags		= kAudioFormatFlagIsSignedInteger | kAudioFormatFlagIsPacked;
    audioFormat.mFramesPerPacket	= 1;
    audioFormat.mChannelsPerFrame	= 1;
    audioFormat.mBitsPerChannel		= 16;
    audioFormat.mBytesPerPacket		= 2;
    audioFormat.mBytesPerFrame		= 2;
}

- (void) createBuffers
{
    UInt32 maxFPS;
    UInt32 size = sizeof(UInt32);
    OSStatus err = AudioUnitGetProperty(audioUnit, kAudioUnitProperty_MaximumFramesPerSlice, kAudioUnitScope_Global, 0, &maxFPS, &size);
    NSAssert1(err == noErr, @"Failed to get the remote I/O unit's max frames per slice: %ld", err);
    if(sampleBuffer) {
        free(sampleBuffer);
        sampleBuffer = nil;
    }
    
    sampleBuffer = malloc(sizeof(SAMPLE)*maxFPS);
}

- (id) init
{
	self = [super init];

	if (self != nil) 
	{
		recognizers = [[NSMutableArray alloc] init];
		[self setupAudioFormat];
		[self createAudioUnit];
		[self createBuffers];
	}
	return self;
}

- (void) diagnoseAudioUnit
{
    AudioStreamBasicDescription format;
    UInt32 size = sizeof(AudioStreamBasicDescription);
    OSStatus err;
    
    err = AudioUnitGetProperty(audioUnit, kAudioUnitProperty_StreamFormat, kAudioUnitScope_Input, 0, &format, &size);
    if (err) {
        printf("Error getting stream format: %ld\n", err);
    }
    else {
        printf("Format\n\tsample rate: %f\n", format.mSampleRate);
        printf("\tchannels: %ld\n", format.mChannelsPerFrame);
        printf("\tbytes per frame: %ld\n", format.mBytesPerFrame);
        printf("\tbytes per packet: %ld\n", format.mBytesPerPacket);        
    }
}

- (OSStatus) createAudioUnit
{
    if (audioUnitInitialized) return noErr;
    
	AudioComponentDescription defaultOutputDescription;
	defaultOutputDescription.componentType = kAudioUnitType_Output;
	defaultOutputDescription.componentSubType = kAudioUnitSubType_RemoteIO;
	defaultOutputDescription.componentManufacturer = kAudioUnitManufacturer_Apple;
	defaultOutputDescription.componentFlags = 0;
	defaultOutputDescription.componentFlagsMask = 0;
	
	// Get the default playback output unit
	AudioComponent defaultOutput = AudioComponentFindNext(NULL, &defaultOutputDescription);
	NSAssert(defaultOutput, @"Can't find default output");
	
	// Create a new unit based on this that we'll use for output
	OSErr err = AudioComponentInstanceNew(defaultOutput, &audioUnit);
	NSAssert1(audioUnit, @"Error creating unit: %ld", err);
    
    // Disable output
    UInt32 enableOutput = NO;
    err = AudioUnitSetProperty(audioUnit, 
                               kAudioOutputUnitProperty_EnableIO, 
                               kAudioUnitScope_Output, 
                               kOutputBus, 
                               &enableOutput, sizeof(UInt32));
    NSAssert1(err == noErr, @"Error disabling output: %ld", err);
    
    // Enable input
    UInt32 enableInput = YES;
    err = AudioUnitSetProperty(audioUnit, 
                               kAudioOutputUnitProperty_EnableIO, 
                               kAudioUnitScope_Input, 
                               kInputBus, 
                               &enableInput, sizeof(UInt32));
    NSAssert1(err == noErr, @"Error enabling input: %ld", err);
    
    // Disable voice noise reduction
//    UInt32 shouldBypass = YES;
//    err = AudioUnitSetProperty(audioUnit, 
//                               kAUVoiceIOProperty_BypassVoiceProcessing, 
//                               kAudioUnitScope_Input, 
//                               0, 
//                               &shouldBypass, sizeof(UInt32));
//    NSAssert1(err == noErr, @"Error disabling noice reduction: %ld", err);
	
	// Set our tone rendering function on the unit
	AURenderCallbackStruct input;
	input.inputProc = recordingCallback;
	input.inputProcRefCon = (__bridge void*)self;
	err = AudioUnitSetProperty(audioUnit, 
                               kAudioOutputUnitProperty_SetInputCallback, 
                               kAudioUnitScope_Global,
                               kInputBus, 
                               &input, sizeof(AURenderCallbackStruct));
	NSAssert1(err == noErr, @"Error setting callback: %ld", err);
	
	// Set the format to 32 bit, single channel, floating point, linear PCM
	err = AudioUnitSetProperty (audioUnit,
                                kAudioUnitProperty_StreamFormat,
                                kAudioUnitScope_Input,
                                kOutputBus,
                                &audioFormat,
                                sizeof(AudioStreamBasicDescription));
    NSAssert1(err == noErr, @"Error setting stream format: %ld", err);
    
    [self diagnoseAudioUnit];
    
    err = AudioUnitInitialize(audioUnit);
    NSAssert1(err == noErr, @"Error initializing audio unit", err);
    
    audioUnitInitialized = true;
    
    return noErr;
}

- (void) addRecognizer: (id<PatternRecognizer>)recognizer
{
	[recognizers addObject:recognizer];
}

- (void) record
{
	[self setupRecording];	
	[self reset];
	
    AudioOutputUnitStart(audioUnit);
}


- (void) stop
{
    AudioOutputUnitStop(audioUnit);
	
	[self reset];
}


- (void) setupRecording
{
	// allocate and enqueue buffers
//	int bufferByteSize = 4096;		// this is the maximum buffer size used by the player class
//	int bufferIndex;
//	
//	for (bufferIndex = 0; bufferIndex < 20; ++bufferIndex) {
//		
//		AudioQueueBufferRef bufferRef;
//		
//		AudioQueueAllocateBuffer (
//								  queueObject,
//								  bufferByteSize, &bufferRef
//								  );
//		
//		AudioQueueEnqueueBuffer (
//								 queueObject,
//								 bufferRef,
//								 0,
//								 NULL
//								 );
//	}
}

- (void) idle: (unsigned)samples
{
	// Convert to microseconds
	UInt64 nsInterval = SAMPLES_TO_NS(samples);
	for (id<PatternRecognizer> rec in recognizers)
		[rec idle:nsInterval];
}

- (void) edge: (int)height width:(unsigned)width interval:(unsigned)interval
{
	// Convert to microseconds
	UInt64 nsInterval = SAMPLES_TO_NS(interval);
	UInt64 nsWidth = SAMPLES_TO_NS(width);
	for (id<PatternRecognizer> rec in recognizers)
		[rec edge:height width:nsWidth interval:nsInterval];
}

- (void) reset
{
	[recognizers makeObjectsPerformSelector:@selector(reset)];
	
	memset(&pulseData, 0, sizeof(pulseData));
}

- (void) dealloc
{
//	AudioQueueDispose (queueObject,
//					   TRUE);
	[recognizers release];
	
	[super dealloc];
}

@end
