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

#define ModelSynthesize(type,name,setter)   \
@synthesize name;                           \
-(void)setter:(type)value {                 \
    [self beginUpdate];                     \
    name = value;                           \
    [self notifyUpdated:@#name];            \
    [self endUpdate]; }

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

@property (nonatomic, strong) id updateIdentity;
@end
