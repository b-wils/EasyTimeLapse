//
//  ETLStopList.m
//  ETL-interface-test
//
//  Created by Carll Hoffman on 8/1/12.
//  Copyright (c) 2012 Microsoft. All rights reserved.
//

#import "ETLStopList.h"

@interface ETLStopList () 
{
    NSArray *fStops, *msTimes;
    NSDictionary *msForStop, *stopForMs;
}
@end

@implementation ETLStopList
@synthesize delegate;

-(id)init 
{
    self = [super init];
    if (self) {
        fStops = Array(@"ms", @"1/15", @"1/13", @"1/10", @"1/8", @"1/6", @"1/5", @"1/4", 
                       @"0\"3", @"0\"4", @"0\"5", @"0\"6", @"0\"8", @"1\"", @"1\"3", @"1\"6",
                       @"2\"", @"2\"5", @"3\"2", @"4\"", @"5\"", @"6\"", @"8\"", 
                       @"10\"", @"13\"", @"15\"", @"20\"", @"25\"", @"30\"");
        msTimes = Array(nint(0), thOfSec(15), thOfSec(13), thOfSec(10), thOfSec(8), thOfSec(6),
                          thOfSec(5), thOfSec(4), nint(300), nint(400), nint(500), nint(600),
                          nint(800), nint(1000), nint(1300), nint(1600), nint(2000), nint(2500),
                          nint(3200), nint(4000), nint(5000), nint(6000), nint(8000), nint(10000),
                          nint(13000), nint(15000), nint(20000), nint(25000), nint(30000));
        
        msForStop = [NSDictionary dictionaryWithObjects:msTimes forKeys:fStops];
        stopForMs = [NSDictionary dictionaryWithObjects:fStops forKeys:msTimes];
        
        self.listItems = fStops;
    }
    
    return self;
}

-(NSString *)getStopForMs:(NSUInteger)ms 
{
    NSString *val = [stopForMs objectForKey:nint(ms)];
    return val ? val : [fStops objectAtIndex:0];
}

-(NSUInteger)getStopNumberFor:(NSString *)name 
{
    NSUInteger val = [fStops indexOfObject:name];
    return val == NSNotFound ? 0 : val;
}

-(NSUInteger)count
{
    return [fStops count];
}

-(NSString *)getStopNumber:(NSUInteger)index
{
    return (index >= [self count]) ? @"ms" : [fStops objectAtIndex:index];
}

-(NSUInteger)getMsForStop:(NSString *)name
{
    return [(NSNumber *)[msForStop objectForKey:name] unsignedIntValue];
}

-(NSString *)getClosestStopToMs:(NSUInteger)ms 
{
    int idx = 0, last = 0, value;
    for (id x in msTimes) {
        value = [x intValue];
        if (value >= ms)
            break;
        
        last = value;
        idx++;
    }
    
    return (abs(ms - last) < abs(ms - value)) 
            ? [self getStopForMs:last]
            : [self getStopForMs:value]; 
}

- (void)didSelectItem:(id)item
{
    [delegate didSelectStop:item ofMs:[self getMsForStop:item]];
}

@end
