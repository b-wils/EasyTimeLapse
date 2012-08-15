//
//  Settings.m
//  ETL-interface-test
//
//  Created by Carll Hoffman on 8/8/12.
//  Copyright (c) 2012 Microsoft. All rights reserved.
//

#import "Settings.h"
#import "CameraType.h"
#import "ETLUtil.h"

@implementation Settings

@dynamic useFlashFeedback;
@dynamic isHelpEnabled;
@dynamic videoFramerate;
@dynamic flashOffset;
@dynamic cameraType;
@dynamic bufferTime;

+ (Settings *)ensureDefaultForContext:(NSManagedObjectContext *)context
{
    Settings *result = nil;
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    request.entity = [NSEntityDescription entityForName:@"Settings" 
                                 inManagedObjectContext:context];
    NSError *error = nil;
    NSMutableArray *mutableFetchResults = [[context executeFetchRequest:request error:&error] mutableCopy];
    if (mutableFetchResults == nil || mutableFetchResults.count == 0) {
        result = (Settings *)[NSEntityDescription insertNewObjectForEntityForName:@"Settings" 
                                                             inManagedObjectContext:context];
        result.useFlashFeedback = nbool(false);
        result.isHelpEnabled = nbool(true);
        result.videoFramerate = nfloat(24);
        result.bufferTime = nint(500);
        
        CameraType *camera = [CameraType ensureDefaultForContext:context];
        result.cameraType = camera;
        result.flashOffset = camera.flashOffset;
        
        NSError *error = nil;
        if (![context save:&error]) {
            // Handle the error.
        }

    }
    else {
        // TODO - verify singleton for result set
        result = [mutableFetchResults objectAtIndex:0];
    }

    return result;
}

@end
