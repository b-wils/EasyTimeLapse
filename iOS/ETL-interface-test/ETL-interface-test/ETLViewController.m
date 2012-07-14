//
//  ETLViewController.m
//  ETL-interface-test
//
//  Created by Carll Hoffman on 6/18/12.
//  Copyright (c) 2012 Microsoft. All rights reserved.
//

#import "ETLViewController.h"
#import "UIView+FindAndResignFirstResponder.h"
#import <objc/runtime.h>
#import <Foundation/Foundation.h>

@interface ETLViewController ()

@end

@implementation ETLViewController

@synthesize delegate;

- (void)viewDidLoad
{
    [super viewDidLoad];
    if (!numpadToolbar)
    {
        [[NSBundle mainBundle] loadNibNamed:@"NumpadDismissBar" owner:self options:nil];
    }

}

#pragma mark -
#pragma mark Screen Transitions
- (IBAction)goBack:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark -

- (void)observe:(id)sender forEvent:(NSString *)name andRun:(SEL)selector
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:selector name:name object:sender];
}

- (IBAction)hideFirstResponder:(id)sender
{
    UIView * w = [[UIApplication sharedApplication] keyWindow];
    [w findAndResignFirstResponder];
}

@end
