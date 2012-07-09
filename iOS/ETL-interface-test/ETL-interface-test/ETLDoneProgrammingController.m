//
//  ETLDoneProgramming.m
//  ETL-interface-test
//
//  Created by Carll Hoffman on 7/9/12.
//  Copyright (c) 2012 Microsoft. All rights reserved.
//

#import "ETLDoneProgrammingController.h"

@interface ETLDoneProgrammingController ()

@end

@implementation ETLDoneProgrammingController

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
    // Do any additional setup after loading the view from its nib.
}

- (void)goBack:(id)sender
{
    [self.navigationController popToRootViewControllerAnimated: YES];
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
