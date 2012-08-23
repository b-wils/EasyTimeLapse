//
//  NSArray+ArrayUtility.h
//  ETL-interface-test
//
//  Created by Carll Hoffman on 7/3/12.
//  Copyright (c) 2012 Microsoft. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef bool (^ETLPredicate)(id object);
typedef id (^ETLMapper)(id object);
typedef id (^ETLReducer)(id acc, id object);
typedef void (^ETLAction)(id object);

@interface NSArray (ArrayUtility)
- (NSArray *)filterWith:(ETLPredicate)filter;
- (NSArray *)mapWith:(ETLMapper)mapper;
- (void)eachWith:(ETLAction)block;
- (id) reduceFrom:(id)initial with:(ETLReducer)block;
@end
