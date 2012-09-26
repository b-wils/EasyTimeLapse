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
 
    if (!programView.programmer.isHeadsetAttached) {
        [self didDetachHeadphones:nil];
    }
    else {
        [self didAttachHeadphones:nil];
    }
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didRequestPacket:) name:PacketRequested object:programView.programmer];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didRequestPacket:) name:BadCrc object:programView.programmer];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didAttachHeadphones:) name:HeadsetAttached object:programView.programmer];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didDetachHeadphones:) name:HeadsetDetached object:programView.programmer];
}

- (void)didRequestPacket:(NSNotification *)notification
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    programView.firstPacketSuccessful = [notification.name isEqualToString:PacketRequested];
    [[self navigationController] pushViewController:programView animated:YES];
}

- (void)didDetachHeadphones:(NSNotification *)notification
{
    statusLabel.text = MIC_REQUIRED_MSG;
    [programView.programmer pause];
}

- (void)didAttachHeadphones:(NSNotification *)notification
{
    statusLabel.text = READY_TO_PROGRAM_MSG;
    [programView.programmer listen];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return NO;
}

- (void)goBack:(id)sender
{
    [programView.programmer halt];
    programView = nil;
    [super goBack:sender];
}

@end
