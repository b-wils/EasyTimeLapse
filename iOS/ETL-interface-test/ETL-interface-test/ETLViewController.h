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

@protocol ResumeView <NSObject>
- (void) resumeView;
@end

@class ETLViewController;
typedef void (^ETLViewInitBlock)(ETLViewController *);

@interface ETLViewController : UIViewController <ResumeView>
{
    IBOutlet UIView * numpadToolbar;
}

@property(nonatomic, strong) id <ResumeView> delegate;

- (IBAction)hideFirstResponder:(id)sender;

#pragma mark -
#pragma mark Screen Transitions
- (IBAction)goBack:(id)sender;
- (void)transitionTo:(Class)type;
- (void)transitionTo:(Class)type fromNib:(NSString *)name;
- (void)transitionTo:(Class)type fromNib:(NSString *)name animated:(bool)animated;
- (void)transitionTo:(Class)type fromNib:(NSString *)name animated:(bool)animated 
                                                       withTransitionStyle:(UIModalTransitionStyle)style;
- (void)transitionTo:(Class)type fromNib:(NSString *)name animated:(bool)animated 
                                                       withCustomInit:(ETLViewInitBlock)customInit;
@end
