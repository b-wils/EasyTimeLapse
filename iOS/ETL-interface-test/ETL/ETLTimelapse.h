//
//  ETLTimelapse.h
//  ETL-interface-test
//
//  Created by Carll Hoffman on 7/12/12.
//  Copyright (c) 2012 Microsoft. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ETLModel.h"
#import "Common.h"
#import "ETLProgrammer.h"

#define MS 1.0
#define SECONDS (1000 * MS)
#define MINUTES (SECONDS * 60)
#define HOURS (MINUTES * 60)

@interface ETLTimelapse : ETLModel <PacketProvider>

-(bool) continuousShooting;

@property (nonatomic) UInt64 shotInterval;
@property (nonatomic) UInt64 shotCount;
@property (nonatomic) NSTimeInterval clipLength;
@property (nonatomic) NSTimeInterval shootingTime;
@property (nonatomic) double clipFramesPerSecond;
@property (nonatomic) NSUInteger exposure;
@property (nonatomic) float exposureLengthPower;

@end
