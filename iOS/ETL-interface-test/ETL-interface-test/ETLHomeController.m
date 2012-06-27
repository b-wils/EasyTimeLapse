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
    [self transitionTo: CLASS(ETLTimelapseController)];
    //[self transitionTo:CLASS(ETLTimelapseSlidersController)];
}

- (IBAction)gotoManual:(id)sender
{
    [self transitionTo:CLASS(ETLManualController)];
}

- (IBAction)gotoBulb:(id)sender
{
    [self transitionTo:CLASS(ETLBulbController)];
}

- (IBAction)gotoHDR:(id)sender
{
    [self transitionTo:CLASS(ETLHdrController)];
}

- (void)resumeView
{
    [self dismissModalViewControllerAnimated: YES];
}
@end
