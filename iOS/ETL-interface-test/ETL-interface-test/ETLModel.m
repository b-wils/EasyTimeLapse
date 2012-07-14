//
//  ETLModel.m
//  ETL-interface-test
//
//  Created by Carll Hoffman on 7/12/12.
//  Copyright (c) 2012 Microsoft. All rights reserved.
//

#import "ETLModel.h"

@implementation ETLModel

- (void)beginUpdate {
    if(!pendingUpdates) { 
        updateDepth = 0;
        pendingUpdates = [[NSMutableSet alloc] init];
    }
    updateDepth++;
}

- (void)endUpdate {
    if (updateDepth == 1 && pendingUpdates && [pendingUpdates count] > 0) {
        [pendingUpdates addObject:ModelUpdated];
        
        for (id msg in pendingUpdates) {
            [[NSNotificationCenter defaultCenter]
                postNotificationName:msg object:self];
        }
        pendingUpdates = nil;
    }
    
    updateDepth--;
    NSAssert1(updateDepth >= 0, @"Invalid update nesting, depth: %d", updateDepth);
}

- (void)notifyUpdated:(NSString *)propName {
    [pendingUpdates addObject:[ModelUpdated stringByAppendingString: propName]];
}

@end
