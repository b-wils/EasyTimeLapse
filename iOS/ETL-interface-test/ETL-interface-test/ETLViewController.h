//
//  ETLViewController.h
//  ETL-interface-test
//
//  Created by Carll Hoffman on 6/18/12.
//  Copyright (c) 2012 Microsoft. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NSArray+ArrayUtility.h"
#import "ETLFirstResponder.h"

#define CLASS(x) (NSClassFromString(@#x))

// ISSUE TODO HACK
bool __macroFlag;
#define WITH if(__macroFlag) {
#define END __macroFlag = false;}

@class ETLViewController;
typedef void (^ETLViewInitBlock)(ETLViewController *);

@interface ETLViewController : UIViewController
{
    IBOutlet UIView * numpadToolbar;
    IBOutlet UIButton * backOrHomeButton;
}

@property(nonatomic, strong) id delegate;

- (NSManagedObjectContext *)objectContext;

- (void)emulateFirstResponder:(UIView <ETLFirstResponder>*)view;

- (IBAction)hideFirstResponder:(id)sender;
- (void)hideFakeFirstResponder;
- (IBAction)goBack:(id)sender;

- (void)observe:(id)sender forEvent:(NSString *)name andRun:(SEL)selector;

- (void)updateUICalculations:(NSNotification *)notification;
- (void)ensureInitialized;

- (void)replaceSwitches:(NSArray *)names;
@end
