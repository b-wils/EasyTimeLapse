//
//  ETLViewController.h
//  ETL-interface-test
//
//  Created by Carll Hoffman on 6/18/12.
//  Copyright (c) 2012 Microsoft. All rights reserved.
//

#import <UIKit/UIKit.h>

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
- (void)transitionTo:(id)view fromNib:(NSString *)name;
- (void)transitionTo:(id)view fromNib:(NSString *)name animated:(bool)animated;
- (void)transitionTo:(id)view fromNib:(NSString *)name animated:(bool)animated 
                                                       withTransitionStyle:(UIModalTransitionStyle)style;
- (void)transitionTo:(id)view fromNib:(NSString *)name animated:(bool)animated 
                                                       withCustomInit:(ETLViewInitBlock)customInit;
@end
