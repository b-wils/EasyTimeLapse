//
//  CameraModel.h
//  ETL-interface-test
//
//  Created by Carll Hoffman on 8/8/12.
//  Copyright (c) 2012 Microsoft. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface CameraType : NSManagedObject

@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSNumber * flashOffset;

+ (CameraType *)ensureDefaultForContext:(NSManagedObjectContext *)context;

@end
