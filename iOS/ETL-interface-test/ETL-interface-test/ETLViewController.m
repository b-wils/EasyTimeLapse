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
- (void)transitionTo:(Class)type
{
    [self transitionTo:type fromNib:nil];
}

- (void)transitionTo:(Class)type fromNib:(NSString *)name
{
    [self transitionTo:type fromNib:name animated:YES];
}

- (void)transitionTo:(Class)type fromNib:(NSString *)name animated:(bool)animated {
    [self transitionTo:type fromNib:name animated:animated withTransitionStyle:UIModalTransitionStyleFlipHorizontal];
}

- (void)transitionTo:(Class)type fromNib:(NSString *)name animated:(bool)animated withCustomInit:(ETLViewInitBlock)initBlock
{
    if(!name) {
        name = [[NSString alloc] initWithCString: class_getName(type) 
                                        encoding:NSStringEncodingConversionAllowLossy]; 
        NSError * reError = nil;
        NSRegularExpression * re = [NSRegularExpression 
               regularExpressionWithPattern:@"ETL(.*)Controller" 
               options:NSRegularExpressionCaseInsensitive 
               error:&reError];
        NSArray * matches = [re matchesInString:name options:NSRegularExpressionCaseInsensitive range:NSMakeRange(0, [name length])];
        if ([matches count] > 0) 
        {
            NSTextCheckingResult *m = [matches objectAtIndex:0];
            name = [name substringWithRange:[m rangeAtIndex:1]];
        }
    }
    
    ETLViewController * view = [[type alloc] initWithNibName:name bundle:nil];
    if(initBlock) initBlock(view);
    [self transitionTo:view animated:animated];
}

- (void)transitionTo:(Class)type fromNib:(NSString *)name animated:(bool)animated withTransitionStyle:(UIModalTransitionStyle) style
{  
    __block UIModalTransitionStyle _style = style;
    ETLViewInitBlock initBlock = ^(ETLViewController * v) {
        v.modalTransitionStyle = _style;
    };
    
    [self transitionTo:type fromNib:name animated:animated withCustomInit:initBlock];
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
