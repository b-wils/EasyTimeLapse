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
#import "UIView+UIView_DrawingHelpers.h"
#import "NSArray+ArrayUtility.h"

#define nint(x) [NSNumber numberWithInt:x]
#define nbig(x) [NSNumber numberWithLong:x];
#define ubig(x) [NSNumber numberWithUnsignedLong:x];
#define nfloat(x) [NSNumber numberWithFloat:x]
#define ndouble(x) [NSNumber numberWithDouble:x]
#define nbool(x) [NSNumber numberWithBool:x]
#define thOfSec(x) nint(ceil(1000.0/x))
#define Array(...) [NSArray arrayWithObjects: __VA_ARGS__ , nil]

#define MS 1.0
#define SECONDS (1000 * MS)
#define MINUTES (SECONDS * 60)
#define HOURS (MINUTES * 60)
#define FOREVER INT_MAX

#define PI 3.14159265358979323846
#define EPSILON 0.000001

#define nsprintf(str, ...) ([NSString stringWithFormat:str, __VA_ARGS__])
#define coalesce(a, b) (a == nil ? b : a)

NSString *msToEnglish(NSUInteger ms);

#endif
