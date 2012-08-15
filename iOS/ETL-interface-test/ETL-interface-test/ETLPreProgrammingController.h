//
//  ETLPreProgrammingController.h
//  ETL-interface-test
//
//  Created by Carll Hoffman on 7/30/12.
//  Copyright (c) 2012 Microsoft. All rights reserved.
//

#import "ETLShotViewController.h"

// TODO - move these strings somewhere sensible with localization

#define READY_TO_PROGRAM_MSG @"Please hold button on device for two seconds and release to program"
#define MIC_REQUIRED_MSG @"Please connect the device"
#define LOW_VOLUME_MSG @"Please turn your headset volume all the way up"

@interface ETLPreProgrammingController : ETLShotViewController
{
    IBOutlet UILabel *statusLabel;
}
@end
