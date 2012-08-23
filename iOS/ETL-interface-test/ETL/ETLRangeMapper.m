//
//  ETLRangeMapper.m
//  ETL
//
//  Created by Carll Hoffman on 8/22/12.
//  Copyright (c) 2012 Microsoft. All rights reserved.
//

#import "ETLRangeMapper.h"
#import "ETLUtil.h"

@interface ETLRangeMapper ()
{
    NSDictionary *stopsToPositions, *positionsToStops;
    NSArray *sortedPositions, *sortedStops;
}
@end

@implementation ETLRangeMapper

- (id)initWithStops:(NSDictionary *)stops
{
    self = [super init];
    if (self) {
        stopsToPositions = stops;
        sortedPositions = [[stopsToPositions allValues] sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
            if ([obj1 floatValue] > [obj2 floatValue]) {
                return (NSComparisonResult)NSOrderedDescending;
            }
            
            if ([obj1 floatValue] < [obj2 floatValue]) {
                return (NSComparisonResult)NSOrderedAscending;
            }
            return (NSComparisonResult)NSOrderedSame;
        }];
        
        sortedStops = [[stopsToPositions allKeys] sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
            if ([obj1 intValue] > [obj2 intValue]) {
                return (NSComparisonResult)NSOrderedDescending;
            }
            
            if ([obj1 intValue] < [obj2 intValue]) {
                return (NSComparisonResult)NSOrderedAscending;
            }
            return (NSComparisonResult)NSOrderedSame;
        }];

        
        positionsToStops = [NSDictionary dictionaryWithObjects:stopsToPositions.allKeys 
                                                       forKeys:stopsToPositions.allValues];
    }
    return self;
}

- (id)stopClosestToPoint:(float)value 
{
    value = [self snapLocationForPoint:value];
    return [positionsToStops objectForKey:nfloat(value)];
}

- (float)snapLocationForPoint:(float)value
{
    int idx = 0;
    float last = 0, v;
    for (id x in sortedPositions) {
        v = [x floatValue];
        if (v >= value)
            break;
        
        last = v;
        idx++;
    }
    return (ABS(value - last) < ABS(value - v)) ? last : v;
}

- (float)rawPointForValue:(id)value 
{
    int val = [value intValue];
    int idx = 0;
    int last = 0, v;
    for (id x in sortedStops) {
        v = [x intValue];
        if (v >= val)
            break;
        
        last = v;
        idx++;
    }
    
    float low = [[stopsToPositions objectForKey:nint(last)] floatValue];
    float high = [[stopsToPositions objectForKey:nint(v)] floatValue];
    
    if (v < val) return 1.0;
    if (v == val) return high;
    
    float progress = (val - last) * 1.0 / (v - last);
    return (high * progress) + (low * (1 - progress));
}

- (id)valueForRawPoint:(float)point
{
    int idx = 0;
    float last = 0, v;
    for (id x in sortedPositions) {
        v = [x floatValue];
        if (v >= point)
            break;
        
        last = v;
        idx++;
    }
    
    int low = [[positionsToStops objectForKey:nfloat(last)] intValue];
    int high = [[positionsToStops objectForKey:nfloat(v)] intValue];
    
    if (v == point) return nint(high);
    
    float progress = (point - last) / (v - last);
    return nint((int)((low * progress) + (high * (1 - progress))));
}

@end
