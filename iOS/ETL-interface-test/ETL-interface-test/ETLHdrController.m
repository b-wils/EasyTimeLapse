//
//  ETLHdrController.m
//  ETL-interface-test
//
//  Created by Carll Hoffman on 6/18/12.
//  Copyright (c) 2012 Microsoft. All rights reserved.
//

#import "ETLHdrController.h"

@interface ETLHdrController ()

@end

@implementation ETLHdrController

- (void)viewDidLoad
{
    [super viewDidLoad];
    bracketCountField.inputAccessoryView = numpadToolbar;
    initialExposureField.inputAccessoryView = numpadToolbar;
    finalExposureField.inputAccessoryView = numpadToolbar;
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
