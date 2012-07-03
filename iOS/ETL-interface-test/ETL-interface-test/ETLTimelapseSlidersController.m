//
//  ETLTimelapseSlidersController.m
//  ETL-interface-test
//
//  Created by Carll Hoffman on 6/27/12.
//  Copyright (c) 2012 Microsoft. All rights reserved.
//

#import "ETLTimelapseSlidersController.h"

@interface ETLTimelapseSlidersController ()

@end

@implementation ETLTimelapseSlidersController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

@end
