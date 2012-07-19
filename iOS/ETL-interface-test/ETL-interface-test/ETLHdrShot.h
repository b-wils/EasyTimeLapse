//
//  ETLHdrShot.h
//  ETL-interface-test
//
//  Created by Carll Hoffman on 7/18/12.
//  Copyright (c) 2012 Microsoft. All rights reserved.
//

#import "ETLModel.h"
#import "ETLProgrammer.h"

@interface ETLHdrShot : ETLModel <PacketProvider>

@property (nonatomic) UInt32 bracketCount;
@property (nonatomic) UInt32 initialExposure;
@property (nonatomic) UInt32 finalExposure;

@end
