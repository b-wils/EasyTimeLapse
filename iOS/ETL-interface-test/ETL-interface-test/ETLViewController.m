//
//  ETLViewController.m
//  ETL-interface-test
//
//  Created by Carll Hoffman on 6/18/12.
//  Copyright (c) 2012 Microsoft. All rights reserved.
//

#import "ETLViewController.h"
#import "UIView+FindAndResignFirstResponder.h"

@interface ETLViewController ()

@end

@implementation ETLViewController

@synthesize delegate;

-(id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self && !numpadToolbar)
    {
        [[NSBundle mainBundle] loadNibNamed:@"NumpadDismissBar" owner:self options:nil];
    }
    
    return self;
}

#pragma mark -
#pragma mark Screen Transitions
- (IBAction)goBack:(id)sender
{
    if(self.delegate) { [self.delegate resumeView]; }
}

// TODO - consider vairiants w/o fromNib:
- (void)transitionTo:(id)view fromNib:(NSString *)name
{
    [self transitionTo:view fromNib:name animated:YES];
}

- (void)transitionTo:(id)view fromNib:(NSString *)name animated:(bool)animated {
    [self transitionTo:view fromNib:name animated:animated withTransitionStyle:UIModalTransitionStyleFlipHorizontal];
}

- (void)transitionTo:(ETLViewController *)view fromNib:(NSString *)name animated:(bool)animated withCustomInit:(ETLViewInitBlock)initBlock
{
    view = [view initWithNibName:name bundle:nil];
    if(initBlock) initBlock(view);
    [self transitionTo:view animated:animated];
}

- (void)transitionTo:(ETLViewController *)view fromNib:(NSString *)name animated:(bool)animated withTransitionStyle:(UIModalTransitionStyle) style
{  
    __block UIModalTransitionStyle _style = style;
    ETLViewInitBlock initBlock = ^(ETLViewController * v) {
        v.modalTransitionStyle = _style;
    };
    
    [self transitionTo:view fromNib:name animated:animated withCustomInit:initBlock];
}

- (void)transitionTo:(ETLViewController *)view animated:(bool)animated
{
    view.delegate = self;
    [self presentViewController:view animated:animated completion:NULL];
}

#pragma mark -
- (void)resumeView
{
    [self dismissModalViewControllerAnimated: NO];
}

- (IBAction)hideFirstResponder:(id)sender
{
    UIView * w = [[UIApplication sharedApplication] keyWindow];
    [w findAndResignFirstResponder];
}

@end
