//
//  TestArcHelper.m
//  ETL-interface-test
//
//  Created by Carll Hoffman on 7/16/12.
//  Copyright (c) 2012 Microsoft. All rights reserved.
//

#import "TestArcHelper.h"
#import <objc/runtime.h>

@implementation Reflection
+ (void)getInstanceVariableFrom:(id)object named:(const char *)name as:(void **)pValue {
    object_getInstanceVariable(object, name, pValue);
}
@end
