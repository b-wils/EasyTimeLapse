//
//  ETLDeviceInterface.h
//  ETL-interface-test
//
//  Created by Carll Hoffman on 6/20/12.
//  Copyright (c) 2012 Microsoft. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FSKRecognizer.h"
#import "FSKSerialGenerator.h"
#import "AudioSignalAnalyzer.h"
#import "CharReceiver.h"
#import "Common.h"

@interface ETLDeviceInterface : NSObject
{
    SectionConfig myConfigs[5];
    NSUInteger configIndex;
}

@property (nonatomic, readonly) FSKRecognizer * recognizer;
@property (nonatomic, readonly) AudioSignalAnalyzer * analyzer;
@property (nonatomic, readonly) FSKSerialGenerator * generator;

- (id)initWithReceiver:(id <CharReceiver>)receiver;

- (void)sendCommand:(uint8_t)command data:(uint8_t)data;
- (void)sendSection:(SectionConfig *)section;

- (void)startProgramming;
- (void)pauseProgramming;
- (void)resumeProgramming;
- (void)stopProgramming;

- (void) startReader;
- (void) stopReader;
- (void) startPlayer;
- (void) stopPlayer;
- (void) pausePlayer;
- (void) resumePlayer;

- (void)writeBuffer:(unsigned char *)buffer ofSize:(size_t)bufferSize;

@end
