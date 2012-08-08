//
//  CameraModel.m
//  ETL-interface-test
//
//  Created by Carll Hoffman on 8/8/12.
//  Copyright (c) 2012 Microsoft. All rights reserved.
//

#import "CameraType.h"
#import "ETLUtil.h"

#define DEFAULT_CAMERA_NAME @"Canon 7D"

@implementation CameraType

@dynamic name;
@dynamic flashOffset;

+ (CameraType *)ensureDefaultForContext:(NSManagedObjectContext *)context
{
    CameraType *camera;
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    request.entity = [NSEntityDescription entityForName:@"CameraType" 
                                 inManagedObjectContext:context];
    request.predicate = [NSPredicate predicateWithFormat:@"name == '%s'", DEFAULT_CAMERA_NAME];
    NSError *error = nil;
    NSMutableArray *mutableFetchResults = [[context executeFetchRequest:request error:&error] mutableCopy];
    if (mutableFetchResults == nil || mutableFetchResults.count == 0) {
        camera = (CameraType *)[NSEntityDescription insertNewObjectForEntityForName:@"CameraType" inManagedObjectContext:context];
        camera.name = DEFAULT_CAMERA_NAME;
        camera.flashOffset = nint(0);
        
        if (![context save:&error]) {
            // Handle the error.
        }
    }
    else {
        // TODO - verify singleton for result set
        camera = [mutableFetchResults objectAtIndex:0];
    }
    
    return camera;

}
@end
