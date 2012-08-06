//
//  TestHelper.h
//  ETL-interface-test
//
//  Created by Carll Hoffman on 7/12/12.
//  Copyright (c) 2012 Microsoft. All rights reserved.
//

#ifndef ETL_interface_test_TestHelper_h
#define ETL_interface_test_TestHelper_h

#import <OCMock/OCMock.h>
#import <GHUnitIOS/GHUnit.h>
#define HC_SHORTHAND
#import <OCHamcrestIOS/OCHamcrestIOS.h>
#import "TestArcHelper.h"

#define VERIFY_MOCK(x) {    \
    id __mock_tmp__ = x;    \
    x = nil;                \
    [__mock_tmp__ verify];  \
}

//#define VERIFY_MOCKS(__

#define DISABLE_MOCK(x) VERIFY_MOCK(x)

#define MOCKS_FOR(x) {\
    __mockRoot = x;\
    id __mock_target__ = x;
#define END }

#define SETUP_MOCK(mock,klass) { mock = [OCMockObject mockForClass:[klass class]]; }
#define SETUP_PROTOCOL_MOCK(mock,proto) { mock = [OCMockObject mockForProtocol:@protocol(proto)]; }

#define WIRE_MOCK(mock,name,meth,arg) {                   \
    mock = [OCMockObject meth:arg];   \
    [__mock_target__ setValue:mock forKey:@#name]; \
    [mockLookup setObject:mock forKey:@#name]; }

#define WIRE_CLASS(mock,klass,name) WIRE_MOCK(mock, name, mockForClass, [klass class])
#define WIRE_PROTOCOL(mock,proto,name) WIRE_MOCK(mock, name, mockForProtocol, @protocol(proto))
#define WIRE(mock,type,name) WIRE_CLASS(mock,type,name)

#define SKIP_MOCK(mock) {\
    NSString* __name = [mockLookup objectForKey:mock]; \
    mock = nil; \
    if (__name) [__mockRoot setValue:nil forKey:__name];}

#define BOOL_STR(x) (x ? "true" : "false")
#define MOCK_HANDLER(name) -(void) name (NSNotification *)notification {}

@interface ETLTestCase : GHTestCase {
    id listenerMock, __selfMock, __mockRoot;
    NSMutableDictionary *mockLookup;
}

- (void)expectCall:(SEL)selector from:(id)sender on:name;
- (void)unregisterNotification:(NSNotification *)notification;
@end

@interface OCMockRecorder (ExtraMethods)
- (id) andReturnBoolean:(BOOL)aValue;
- (id) andReturnStruct:(void*)aValue objCType:(const char *)type;
@end

#endif
