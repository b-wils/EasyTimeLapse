//
//  ETLShotStatusController.m
//  ETL
//
//  Created by Carll Hoffman on 10/1/12.
//  Copyright (c) 2012 Microsoft. All rights reserved.
//

#import "ETLShotStatusController.h"
#import <QuartzCore/QuartzCore.h>

@interface ETLShotStatusController ()
{
    CALayer *pieLayer;
}

@end

@implementation ETLShotStatusController

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
    
    pieLayer = [CALayer layer];
    pieLayer.bounds = pieView.bounds;
    pieLayer.position = CGPointMake(55, 55);
    pieLayer.backgroundColor = UIColor.greenColor.CGColor;
    pieLayer.cornerRadius = 55;
    
    pieView.backgroundColor = UIColor.clearColor;
    [pieView.layer insertSublayer:pieLayer atIndex:0];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return NO;
}

@end
