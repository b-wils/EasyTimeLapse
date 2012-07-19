//
//  ETLShot.m
//  ETL-interface-test
//
//  Created by Carll Hoffman on 7/19/12.
//  Copyright (c) 2012 Microsoft. All rights reserved.
//

#import "ETLShot.h"
#import "NSArray+ArrayUtility.h"

@interface ETLShot ()
{
    NSMutableArray * shots;
}
@end

@implementation ETLShot

-(id)init 
{
    self = [super init];
    if (self) {
        shots = [[NSMutableArray alloc] init];
    }
    return self;
}

-(void)add:(id <PacketProvider>)component
{
    [shots addObject:component];
}

-(void)renderPacket:(UInt32)packetNumber to:(VariablePacket *)packet
{
    UInt32 acc = 0;
    id <PacketProvider> p;
    
    for (p in shots) {
        if (acc + p.packetCount >= packetNumber) break;
        acc += p.packetCount;
    }
    
    packetNumber -= acc;
    [p renderPacket:packetNumber to:packet];
}

#define UINT32_V(c) [NSValue valueWithBytes:&c objCType:@encode(UInt32)]

-(UInt32)packetCount {
    UInt32 value = 0;
    NSValue *count;
    count = [shots reduceFrom:UINT32_V(value) with:^id(id acc, id object) {
        UInt32 x;
        [acc getValue:&x];
        
        x += [object packetCount];
        
        return [NSValue valueWithBytes:&x objCType:@encode(UInt32)];
    }];
    
    [count getValue:&value];
    return value;
}

@end
