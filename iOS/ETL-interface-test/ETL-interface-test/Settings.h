//
//  Settings.h
//  ETL-interface-test
//
//  Created by Carll Hoffman on 8/8/12.
//  Copyright (c) 2012 Microsoft. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface Settings : NSManagedObject

@property (nonatomic, retain) NSNumber * useFlashFeedback;
@property (nonatomic, retain) NSNumber * isHelpEnabled;
@property (nonatomic, retain) NSNumber * videoFramerate;
@property (nonatomic, retain) NSNumber * flashOffset;
@property (nonatomic, retain) NSManagedObject *cameraType;

+ (Settings *)ensureDefaultForContext:(NSManagedObjectContext *)context;

@end
