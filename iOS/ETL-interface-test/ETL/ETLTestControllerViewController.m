//
//  ETLTestControllerViewController.m
//  ETL
//
//  Created by Carll Hoffman on 9/6/12.
//  Copyright (c) 2012 Microsoft. All rights reserved.
//

#import "ETLTestControllerViewController.h"
#import <QuartzCore/QuartzCore.h>

@interface ETLTestControllerViewController ()

@end

@implementation ETLTestControllerViewController

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
    menuView.hidden = true;
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (IBAction)displayMenu:(id)sender
{
    menuView.hidden = false;
    menuView.layer.cornerRadius = 10;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

@end
