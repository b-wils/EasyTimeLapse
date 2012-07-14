//
//  ETLModelTest.m
//  ETL-interface-test
//
//  Created by Carll Hoffman on 7/13/12.
//  Copyright (c) 2012 Microsoft. All rights reserved.
//

#import "TestHelper.h"
#import "ETLModel.h"

@interface ETLModelTest : ETLTestCase
{
    ETLModel *model;
    id updateSetMock;
}
@end

@implementation ETLModelTest

MOCK_HANDLER(propertyUpdated:)
MOCK_HANDLER(modelUpdated:)

- (void)setUpClass {
}

- (void)tearDownClass {
}

- (void)setUp {
    model = [[ETLModel alloc] init];
}

- (void)tearDown {
    model = nil;
    VERIFY_MOCK(updateSetMock);
    
    [super tearDown];
}  

- (void)testCollectNotifications {
    MOCKS_FOR(model)
        WIRE(updateSetMock, NSMutableSet, pendingUpdates)
    END
    
    [[updateSetMock expect] addObject:PropertyUpdated(foo)];
    [[updateSetMock expect] addObject:PropertyUpdated(bar)];
    
    [model notifyUpdated:@"foo"];
    [model notifyUpdated:@"bar"];
}

- (void)testReceiveNotifications {
    [self expectCall:@selector(modelUpdated:) from:model on:ModelUpdated];
    [self expectCall:@selector(propertyUpdated:) from:model on:PropertyUpdated(foo)];
    [self expectCall:@selector(propertyUpdated:) from:model on:PropertyUpdated(bar)];
    
    [model beginUpdate];
    [model notifyUpdated:@"foo"];
    [model notifyUpdated:@"bar"];
    [model endUpdate];
    
    // Verify that foo and bar won't get updated next time
    [self expectCall:@selector(modelUpdated:) from:model on:ModelUpdated];
    [self expectCall:@selector(propertyUpdated:) from:model on:PropertyUpdated(baz)];
    
    [model beginUpdate];
    [model notifyUpdated:@"baz"];
    [model endUpdate];
}

- (void)testNestedNotifications {
    [self expectCall:@selector(modelUpdated:) from:model on:ModelUpdated];
    [self expectCall:@selector(propertyUpdated:) from:model on:PropertyUpdated(foo)];
    [self expectCall:@selector(propertyUpdated:) from:model on:PropertyUpdated(bar)];
    [self expectCall:@selector(propertyUpdated:) from:model on:PropertyUpdated(baz)];
    
    [model beginUpdate];
    [model notifyUpdated:@"foo"];
        [model beginUpdate];
        [model notifyUpdated:@"bar"];
        [model endUpdate];
    [model notifyUpdated:@"baz"];
    [model endUpdate];
}

@end
