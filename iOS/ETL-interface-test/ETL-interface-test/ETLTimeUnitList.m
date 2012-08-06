//
//  ETLTimeUnitList.m
//  ETL-interface-test
//
//  Created by Carll Hoffman on 8/1/12.
//  Copyright (c) 2012 Microsoft. All rights reserved.
//

#import "ETLTimeUnitList.h"

@interface ETLTimeUnitList ()
{
    NSArray *periodUnits, *msTimes;
    NSDictionary * msInUnit;
}
@end

@implementation ETLTimeUnitList
@synthesize delegate;

-(id)init 
{
    self = [super init];
    if(self) {
        periodUnits = Array(@"ms", @"seconds", @"minutes", @"hours"); 
        msTimes = Array(nint(1), nint(1000), nint(1000*60), nint(1000*60*60));        
        msInUnit = [NSDictionary dictionaryWithObjects:msTimes forKeys:periodUnits];
        
        self.listItems = periodUnits;
    }
    
    return self;
}

-(NSString*)getUnitByNumber:(NSUInteger)index 
{    
    return index >= [periodUnits count] ? @"ms" : [periodUnits objectAtIndex:index];
}

-(NSUInteger)getNumberOfUnit:(NSString*)name
{
    NSUInteger value = [periodUnits indexOfObject:name];
    return value == NSNotFound ? 0 : value;
}

-(NSUInteger)msInUnit:(NSString *)name 
{
    NSUInteger value = [[msInUnit objectForKey:name] unsignedIntegerValue];
    return value ? value : 1;
}

-(void)didSelectItem:(id)item 
{
    [delegate didSelectUnit:item ofMs:[self msInUnit:item]];
}
@end
