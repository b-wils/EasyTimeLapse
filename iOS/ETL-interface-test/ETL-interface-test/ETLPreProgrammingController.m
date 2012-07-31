//
//  ETLPreProgrammingController.m
//  ETL-interface-test
//
//  Created by Carll Hoffman on 7/30/12.
//  Copyright (c) 2012 Microsoft. All rights reserved.
//

#import "ETLPreProgrammingController.h"
#import "ETLProgramViewController.h"
#import "ETLProgrammer.h"

@interface ETLPreProgrammingController ()
{
    ETLProgramViewController *programView;
}
@end

@implementation ETLPreProgrammingController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    programView = [self.storyboard instantiateViewControllerWithIdentifier:@"ProgramView"];
    programView.packetProvider = self.packetProvider;
    [programView ensureInitialized];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didRequestPacket:) name:PacketRequested object:programView.programmer];
}

- (void)didRequestPacket:(NSNotification *)notification
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [[self navigationController] pushViewController:programView animated:YES];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

@end
