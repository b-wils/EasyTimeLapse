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
#import "RCSwitchOnOff.h"

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

- (void)replaceSwitches:(NSArray *)names
{
    [names eachWith:^void (id obj) {
        UISwitch *s = (UISwitch *)[self valueForKey:obj];
        CGRect frame = s.frame;
        frame.size.width = 64;
        frame.size.height = 28;
        RCSwitchOnOff *res = [[RCSwitchOnOff alloc] initWithFrame:frame];
        [res setOn:[s isOn]];
        
        NSArray* actions = [s actionsForTarget:self forControlEvent:UIControlEventValueChanged];
        for (NSString *a in actions) {
            [res addTarget:self action:NSSelectorFromString(a) forControlEvents:UIControlEventValueChanged];
        }
        
        [[self view] addSubview:res];
        [s removeFromSuperview];
        [self setValue:res forKey:obj];
    }];
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
    [self hideFakeFirstResponder];
    
    UIView * w = [[UIApplication sharedApplication] keyWindow];
    [w findAndResignFirstResponder];
}

- (void)hideFakeFirstResponder
{
    [fakeFirstResponder show:NO animated:YES];
    fakeFirstResponder = nil;
}

- (void)updateUICalculations:(NSNotification *)notification
{
}

@end
