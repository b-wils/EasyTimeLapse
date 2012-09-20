//
//  ETLProTimelapseController.m
//  ETL
//
//  Created by Carll Hoffman on 8/29/12.
//  Copyright (c) 2012 Microsoft. All rights reserved.
//

#import "ETLProTimelapseController.h"

@interface ETLProTimelapseController ()

@end

@implementation ETLProTimelapseController

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

- (IBAction)didTapNumpadDone:(id)sender
{
    numpad.hidden = YES;
}

- (IBAction)didTapInterval:(id)sender
{
    numpad.hidden = NO;
}

@end
