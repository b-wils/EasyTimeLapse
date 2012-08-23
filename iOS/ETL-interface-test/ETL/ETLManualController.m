//
//  ETLManualController.m
//  ETL-interface-test
//
//  Created by Carll Hoffman on 6/18/12.
//  Copyright (c) 2012 Microsoft. All rights reserved.
//

#import "ETLManualController.h"
#import "ETLProgramViewController.h"
#import "ETLManual.h"

@interface ETLManualController ()
    
@end

@implementation ETLManualController

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"Program"]) {
        ETLProgramViewController *controller = [segue destinationViewController];
        controller.packetProvider = [[ETLManual alloc] init];;
    }
}

@end
