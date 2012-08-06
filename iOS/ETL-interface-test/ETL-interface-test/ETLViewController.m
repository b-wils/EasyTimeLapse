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
{
    id fakeFirstResponder;
}

@end

@implementation ETLViewController

@synthesize delegate;

- (void)ensureInitialized
{
    
}

- (void)viewDidLoad
{
    [super viewDidLoad];
//    if (!numpadToolbar)
//    {
//        [[NSBundle mainBundle] loadNibNamed:@"NumpadDismissBar" owner:self options:nil];
//    }
    
    if (backOrHomeButton)
    {
        if ([[[self navigationController] viewControllers] count] > 2) 
        {
            [backOrHomeButton setImage:[UIImage imageNamed:@"back.png"] forState:UIControlStateNormal];
            [backOrHomeButton setImage:nil forState:UIControlStateHighlighted];
        }
    }
}

#pragma mark -
#pragma mark Screen Transitions
- (IBAction)goBack:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark -

- (void)emulateFirstResponder:(UIView *)view {
    [self hideFirstResponder:nil];
    fakeFirstResponder = view;
}

- (void)observe:(id)sender forEvent:(NSString *)name andRun:(SEL)selector
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:selector name:name object:sender];
}

- (IBAction)hideFirstResponder:(id)sender
{
//    [fakeFirstResponder show:NO animated:YES];
    bool no = NO, yes = YES;
    [fakeFirstResponder performSelector:@selector(show:animated:) 
                             withObject:[NSValue valueWithBytes:&no objCType:@encode(bool)] 
                             withObject:[NSValue valueWithBytes:&yes objCType:@encode(bool)]];
    fakeFirstResponder = nil;
    
    UIView * w = [[UIApplication sharedApplication] keyWindow];
    [w findAndResignFirstResponder];
}

- (void)updateUICalculations:(NSNotification *)notification
{
}

@end
