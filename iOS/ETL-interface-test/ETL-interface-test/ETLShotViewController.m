//
//  ETLShotViewController.m
//  ETL-interface-test
//
//  Created by Carll Hoffman on 6/20/12.
//  Copyright (c) 2012 Microsoft. All rights reserved.
//

#import "ETLShotViewController.h"
#import "ETLProgramViewController.h"

@interface ETLShotViewController ()

@end

@implementation ETLShotViewController

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

- (IBAction)goProgramDevice:(id)sender
{
    __block ETLShotViewController * dataSource = self;
    ETLViewInitBlock initBlock = ^(ETLViewController * view) {
        [(ETLProgramViewController *)view setDeviceCommand:dataSource->command 
                                          withSections:dataSource->sections];
    };
    
    [self transitionTo:CLASS(ETLProgramViewController) fromNib:@"ProgramETL" animated:NO withCustomInit:initBlock];
}

@end
