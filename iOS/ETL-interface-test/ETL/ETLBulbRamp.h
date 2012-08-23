//
//  ETLBlubRamp.h
//  ETL-interface-test
//
//  Created by Carll Hoffman on 7/18/12.
//  Copyright (c) 2012 Microsoft. All rights reserved.
//

#import "ETLModel.h"
#import "ETLTimelapse.h"
#import "ETLProgrammer.h"

@interface ETLBulbRamp : ETLModel <PacketProvider>
@property (nonatomic, strong) ETLTimelapse *timelapse;
@property (nonatomic, assign) NSInteger fStopChangeOnPress;
@property (nonatomic, assign) NSInteger numStops;
@property (nonatomic, assign, readonly) float fStopChangePerMinute;
@end
