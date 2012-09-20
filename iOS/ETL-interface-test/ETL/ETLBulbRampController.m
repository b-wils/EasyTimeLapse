//
//  ETLBulbRampControllerViewController.m
//  ETL
//
//  Created by Carll Hoffman on 8/26/12.
//  Copyright (c) 2012 Microsoft. All rights reserved.
//

#import "ETLBulbRampController.h"

@interface ETLBulbRampController ()

@end

@implementation ETLBulbRampController

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
    [[UIApplication sharedApplication] setStatusBarHidden:YES];
    [UIViewController attemptRotationToDeviceOrientation];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
    [rampView setNeedsDisplay];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return YES;
}

- (IBAction)didChangeEaseIn:(id)sender
{
    UISlider *slider = (UISlider *)sender;
    rampView.easeIn = slider.value;
}

- (IBAction)didChangeEaseOut:(id)sender
{
    UISlider *slider = (UISlider *)sender;
    rampView.easeOut = slider.value;
}

@end
