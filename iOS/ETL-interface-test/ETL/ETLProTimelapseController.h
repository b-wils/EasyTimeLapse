//
//  ETLProTimelapseController.h
//  ETL
//
//  Created by Carll Hoffman on 8/29/12.
//  Copyright (c) 2012 Microsoft. All rights reserved.
//

#import "ETLShotViewController.h"
#import "ETLUtil.h"

@interface ETLProTimelapseController : ETLShotViewController
{
    IBOutlet UIView *numpad;
    IBOutlet UIButton *intervalButton;
}

- (IBAction)didTapNumpadDone:(id)sender;
- (IBAction)didTapInterval:(id)sender;

@end
