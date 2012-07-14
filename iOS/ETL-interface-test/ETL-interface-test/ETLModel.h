//
//  ETLModel.h
//  ETL-interface-test
//
//  Created by Carll Hoffman on 7/12/12.
//  Copyright (c) 2012 Microsoft. All rights reserved.
//

#import <Foundation/Foundation.h>

#define ModelUpdated @"Updated:"
#define PropertyUpdated(x) ([ModelUpdated stringByAppendingString: @#x ])

#define SimpleModelSetter(name)             \
    [self beginUpdate];                     \
    name = value;                           \
    [self notifyUpdated:@#name];            \
    [self endUpdate];


@interface ETLModel : NSObject
{
    NSMutableSet *pendingUpdates;
    NSInteger updateDepth;
}

- (void)beginUpdate;
- (void)notifyUpdated:(NSString *)propName;
- (void)endUpdate;
@end
