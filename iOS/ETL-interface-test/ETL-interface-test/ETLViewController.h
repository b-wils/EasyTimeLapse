//
//  ETLViewController.h
//  ETL-interface-test
//
//  Created by Carll Hoffman on 6/18/12.
//  Copyright (c) 2012 Microsoft. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NSArray+ArrayUtility.h"

#define CLASS(x) (NSClassFromString(@#x))

@class ETLViewController;
typedef void (^ETLViewInitBlock)(ETLViewController *);

@interface ETLViewController : UIViewController
{
    IBOutlet UIView * numpadToolbar;
}

@property(nonatomic, strong) id delegate;

- (IBAction)hideFirstResponder:(id)sender;

#pragma mark -
#pragma mark Screen Transitions
- (IBAction)goBack:(id)sender;
@end
