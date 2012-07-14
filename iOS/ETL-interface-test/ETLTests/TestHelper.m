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
    
- (void)expectCall:(SEL)selector from:(id)sender on:name
{
    if (!listenerMock) SETUP_MOCK(listenerMock, [self class]);

    [[NSNotificationCenter defaultCenter] addObserver:listenerMock selector:selector name:name object:sender];
    [[[listenerMock expect] andCall:@selector(unregisterNotification:) onObject:self]performSelector:selector withObject:OCMOCK_ANY];
}

- (void)unregisterNotification:(NSNotification *)notification
{
    [[NSNotificationCenter defaultCenter] removeObserver:listenerMock name:notification.name object:notification.object];
}

- (void)tearDown
{
    if(listenerMock) {
        [[NSNotificationCenter defaultCenter] removeObserver:listenerMock];
        VERIFY_MOCK(listenerMock);
    }
}

@end