//
//  TestArcHelper.h
//  ETL-interface-test
//
//  Created by Carll Hoffman on 7/16/12.
//  Copyright (c) 2012 Microsoft. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Reflection : NSObject
+ (void)getInstanceVariableFrom:(id)object named:(const char *)name as:(void **)pValue;
@end
