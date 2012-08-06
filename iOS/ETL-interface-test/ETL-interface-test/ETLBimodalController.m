//
//  ETLBimodalController.m
//  ETL-interface-test
//
//  Created by Carll Hoffman on 8/1/12.
//  Copyright (c) 2012 Microsoft. All rights reserved.
//

#import "ETLBimodalController.h"
#import "ETLTimelapse.h"

@interface ETLBimodalController ()
{
    ETLTimelapse *modeA, *modeB;
}
@end

@implementation ETLBimodalController

- (void)ensureInitialized
{
    if(!modeA) {
        modeA = [[ETLTimelapse alloc] init];
    }
    
    if(!modeB) {
        modeB = [[ETLTimelapse alloc] init];
    }
}

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

- (void)updateUICalculations:(NSNotification *)notification
{
    
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

@end
