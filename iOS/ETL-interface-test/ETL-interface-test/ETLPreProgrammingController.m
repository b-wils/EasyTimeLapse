//
//  ETLPreProgrammingController.m
//  ETL-interface-test
//
//  Created by Carll Hoffman on 7/30/12.
//  Copyright (c) 2012 Microsoft. All rights reserved.
//

#import "ETLViewControllers.h"
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
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didRequestPacket:) name:BadCrc object:programView.programmer];
}

- (void)viewDidAppear:(BOOL)animated
{
    if (!programView.programmer.isHeadsetAttached) [self goBack:nil];
}

- (void)didRequestPacket:(NSNotification *)notification
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    programView.firstPacketSuccessful = [notification.name isEqualToString:PacketRequested];
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

- (void)goBack:(id)sender
{
    [programView.programmer halt];
    programView = nil;
    [super goBack:sender];
}

@end
