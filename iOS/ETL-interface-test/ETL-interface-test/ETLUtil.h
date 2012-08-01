//
//  ETLUtil.h
//  ETL-interface-test
//
//  Created by Carll Hoffman on 8/1/12.
//  Copyright (c) 2012 Microsoft. All rights reserved.
//

#ifndef ETL_interface_test_ETLUtil_h
#define ETL_interface_test_ETLUtil_h

#import "UIView+FindAndResignFirstResponder.h"
#import "UIButton+setAllTitles.h"
#import "NSArray+ArrayUtility.h"

#define nint(x) [NSNumber numberWithInt:x]
#define thOfSec(x) nint(ceil(1000.0/x))
#define Array(...) [NSArray arrayWithObjects: __VA_ARGS__ , nil]

#endif
