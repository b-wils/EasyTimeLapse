//
//  ETLBulbSettingsControllerViewController.h
//  ETL-interface-test
//
//  Created by Carll Hoffman on 6/28/12.
//  Copyright (c) 2012 Microsoft. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ETLBulbSettingsController : UIViewController

@property (weak, nonatomic) IBOutlet UILabel *latencyLabel;
@property (weak, nonatomic) IBOutlet UITextField *latencyField;
- (IBAction)latencyValueChanged:(id)sender;
@end
