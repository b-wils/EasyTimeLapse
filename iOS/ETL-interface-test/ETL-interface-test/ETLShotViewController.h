//
//  ETLShotViewController.h
//  ETL-interface-test
//
//  Created by Carll Hoffman on 6/20/12.
//  Copyright (c) 2012 Microsoft. All rights reserved.
//

#import "ETLViewController.h"
#import "ETLProgrammer.h"

@interface ETLShotViewController : ETLViewController

@property (nonatomic, assign) id <PacketProvider> packetProvider;

- (IBAction)gotoSettings;

@end
