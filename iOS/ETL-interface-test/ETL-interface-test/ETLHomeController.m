//
//  ETLHomeController.m
//  ETL-interface-test
//
//  Created by Carll Hoffman on 6/18/12.
//  Copyright (c) 2012 Microsoft. All rights reserved.
//

#import "ETLHomeController.h"
#import "ETLViewControllers.h"


@implementation ETLHomeController

- (IBAction)gotoTimelapse:(id)sender
{
    //[self transitionTo:[ETLTimelapseController alloc] fromNib:@"Timelapse"];
    [self transitionTo: [ETLTimelapseSlidersController alloc] 
          fromNib:@"ETLTimelapseSlidersController"];
}

- (IBAction)gotoManual:(id)sender
{
    [self transitionTo:[ETLManualController alloc] fromNib:@"Manual"];
}

- (IBAction)gotoBulb:(id)sender
{
    [self transitionTo:[ETLBulbController alloc] fromNib:@"Bulb"];
}

- (IBAction)gotoHDR:(id)sender
{
    [self transitionTo:[ETLHdrController alloc] fromNib:@"HDR"];
}

- (void)resumeView
{
    [self dismissModalViewControllerAnimated: YES];
}
@end
