//
//  NSArray+ArrayUtility.m
//  ETL-interface-test
//
//  Created by Carll Hoffman on 7/3/12.
//  Copyright (c) 2012 Microsoft. All rights reserved.
//

#import "NSArray+ArrayUtility.h"

@implementation NSArray (ArrayUtility)
- (NSArray *)filterWith:(ETLPredicate)filter
{
    NSMutableArray *results = [[NSMutableArray alloc] init];
    for (id obj in self) {
        if(filter(obj)) { [results addObject:obj]; }
    }
    
    return results;
}

-(NSArray *)mapWith:(ETLMapper)mapper
{
    int count = [self count];
    id results[count];
    int i = 0;
    for (id obj in self) {
        results[i++] = mapper(obj);
    }
    
    return [[NSArray alloc] initWithObjects:results count:count];
}

- (void)eachWith:(ETLAction)block
{
    for (id obj in self) block(obj);
}

- (id) reduceFrom:(id)initial with:(ETLReducer)block
{
    for (id obj in self) {
        initial = block(initial, obj);
    }
    
    return initial;
}
@end
