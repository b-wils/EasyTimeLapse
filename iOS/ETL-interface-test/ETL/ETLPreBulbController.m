//
//  ETLPreBulbController.m
//  ETL-interface-test
//
//  Created by Carll Hoffman on 8/15/12.
//  Copyright (c) 2012 Microsoft. All rights reserved.
//

#import "ETLPreBulbController.h"
#import "ETLBulbController.h"

@interface ETLPreBulbController ()

@end

@implementation ETLPreBulbController

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
	// Do any additional setup after loading the view.
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    ETLBulbController *controller = segue.destinationViewController;
    if ([segue.identifier isEqualToString:@"Sunset"]) {
        controller.sunsetMode = true;
    }
    else {
        controller.sunsetMode = false;
    }
    
    [super prepareForSegue:segue sender:sender];
}

@end
