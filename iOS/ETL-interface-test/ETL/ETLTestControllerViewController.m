//
//  ETLTestControllerViewController.m
//  ETL
//
//  Created by Carll Hoffman on 9/6/12.
//  Copyright (c) 2012 Microsoft. All rights reserved.
//

#import "ETLTestControllerViewController.h"
#import <QuartzCore/QuartzCore.h>
#import "ETLUnitKeypad.h"
#import "ETLUtil.h"

@interface ETLTestControllerViewController ()
{
    ETLUnitKeypad *keypad;
}
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
    keypad = [[ETLUnitKeypad alloc] initWithFrame:self.view.frame];
    
    self.view.transform = CGAffineTransformMakeRotation(3.141592/2);
    [self.view addSubview:keypad];
    
    ETLShortTimeValue *v = [[ETLShortTimeValue alloc] init];
    v.scaledValue = ndouble(4.222);
    v.unit = @"seconds";
    
    keypad.value = v;
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
