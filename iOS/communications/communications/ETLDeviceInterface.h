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
#import "etl_typedefs.h"

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

@end
