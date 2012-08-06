//
//  TestHelper.m
//  ETL-interface-test
//
//  Created by Carll Hoffman on 7/12/12.
//  Copyright (c) 2012 Microsoft. All rights reserved.
//

#include "TestHelper.h"
#include <Foundation/Foundation.h>

@implementation ETLTestCase

- (void)unregisterNotification:(NSNotification *)notification
{
    [[NSNotificationCenter defaultCenter] removeObserver:listenerMock name:notification.name object:notification.object];
}

- (void)expectCall:(SEL)selector from:(id)sender on:name
{
    if (!listenerMock) SETUP_MOCK(listenerMock, [self class]);

    [[NSNotificationCenter defaultCenter] addObserver:listenerMock selector:selector name:name object:sender];

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
    // Ignoring this warning since we're only calling the selector on a mock object, which won't leak.
    [[[listenerMock expect] andCall:@selector(unregisterNotification:) onObject:self] 
                            performSelector:selector withObject:OCMOCK_ANY];
#pragma clang pop
}

- (void)tearDown
{
    if(listenerMock) {
        [[NSNotificationCenter defaultCenter] removeObserver:listenerMock];
        VERIFY_MOCK(listenerMock);
    }
}

@end

@implementation OCMockRecorder (ExtraMethods)
- (id) andReturnBoolean:(BOOL)aValue {
    NSValue *wrappedValue = nil;
    wrappedValue = [NSValue valueWithBytes:&aValue
                                  objCType:@encode(BOOL)];
	
    return [self andReturnValue:wrappedValue];
}

- (id) andReturnStruct:(void*)aValue objCType:(const char *)type{
    NSValue *wrappedValue = nil;
    wrappedValue = [NSValue valueWithBytes:aValue
                                  objCType:type];
	
    return [self andReturnValue:wrappedValue];
}
@end