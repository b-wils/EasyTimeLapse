//
//  ETLTestControllerViewController.h
//  ETL
//
//  Created by Carll Hoffman on 9/6/12.
//  Copyright (c) 2012 Microsoft. All rights reserved.
//

#import "ETLViewController.h"
#import "ETLThumb.h"

@interface ETLTestControllerViewController : ETLViewController
{
    IBOutlet UIButton *menuButton;
    IBOutlet UIView *menuView;
}

- (IBAction)displayMenu:(id)sender;

@end
