//
//  ETLBulbRampControllerViewController.h
//  ETL
//
//  Created by Carll Hoffman on 8/26/12.
//  Copyright (c) 2012 Microsoft. All rights reserved.
//

#import "ETLShotViewController.h"
#import "ETLRampView.h"

@interface ETLBulbRampController : ETLShotViewController
{
    IBOutlet ETLRampView *rampView;
}

- (IBAction)didChangeEaseIn:(id)sender;
- (IBAction)didChangeEaseOut:(id)sender;

@end
