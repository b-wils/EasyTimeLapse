//
//  ETLHomeController.m
//  ETL-interface-test
//
//  Created by Carll Hoffman on 6/18/12.
//  Copyright (c) 2012 Microsoft. All rights reserved.
//

#import "ETLViewControllers.h"

@implementation ETLHomeController

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"Timelapse"])
	{
		ETLTimelapseController *timelapseController = [[self.navigationController viewControllers] objectAtIndex:0];
        timelapseController.delegate = self;
	}
}
@end
