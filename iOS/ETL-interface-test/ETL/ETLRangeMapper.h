//
//  ETLRangeMapper.h
//  ETL
//
//  Created by Carll Hoffman on 8/22/12.
//  Copyright (c) 2012 Microsoft. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ETLRangeMapper : NSObject
- (id)initWithStops:(NSDictionary *)stops;
- (id)stopClosestToPoint:(float)value;
- (float)snapLocationForPoint:(float)value;
- (float)rawPointForValue:(id)value;
- (id)valueForRawPoint:(float)point;
@end
