//
//  ETLProgramControllerViewController.m
//  ETL-interface-test
//
//  Created by Carll Hoffman on 6/20/12.
//  Copyright (c) 2012 Microsoft. All rights reserved.
//

#import "ETLViewControllers.h"
#import "ADVPopoverProgressBar.h"

@interface ETLProgramViewController ()

@end

@implementation ETLProgramViewController

@synthesize packetProvider, programmer, firstPacketSuccessful;

- (void)ensureInitialized 
{
    if (!programmer) {
        programmer = [[ETLProgrammer alloc] init];
        programmer.settings = [Settings ensureDefaultForContext:self.objectContext];
        [self startProgramming];
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    [self ensureInitialized];
    UIProgressView *original = programmingProgress;
    programmingProgress = (UIProgressView *)[[ADVPopoverProgressBar alloc] initWithFrame:programmingProgress.frame];
    [programmingProgress setProgress:0];
    [original removeFromSuperview];
    [self.view addSubview:programmingProgress];
    
    programmingProgress.progress = (firstPacketSuccessful ? 1 : 0) / (packetProvider.packetCount + 2.0);
}

- (void)startProgramming
{
    programmer.packetProvider = packetProvider;
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didRequestPacket:) name:PacketRequested object:programmer];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didCompleteProgramming:) name:ProgrammingComplete object:programmer];
    [programmer listen];
}

const NSUInteger streamBitsPerDataByte = 14;

- (void)didRequestPacket:(NSNotification *)notification
{
    NSDictionary *userInfo = notification.userInfo;
    UInt32 packetId; [(NSValue *)[userInfo objectForKey:@"sendingPacketId"] getValue:&packetId];
    
    programmingProgress.progress = packetId / (packetProvider.packetCount + 2.0);
}

- (void)didCompleteProgramming:(NSNotification *)notificatoin
{
    programmingProgress.progress = 1.0;
    bytesTransferred.text = @"done";
    cancelButton.hidden = true;        
    [NSTimer scheduledTimerWithTimeInterval:2.0 target:self selector:@selector(didFinishProgramming:) userInfo:NULL repeats:NO];
}

- (void)didFinishProgramming:(id)sender
{
    [programmer halt];
    programmer = nil;
    
    ETLDoneProgrammingController *controller = [self.storyboard instantiateViewControllerWithIdentifier:@"DoneProgramming"];
    [self.navigationController pushViewController:controller animated:YES];
}

- (void)goBack:(id)sender
{
    [programmer halt];
    NSArray *viewControllers = [self.navigationController viewControllers];
    UIViewController *controller = [viewControllers objectAtIndex:([viewControllers count] - 3)];
    [self.navigationController popToViewController:controller animated:YES];
//    [super goBack:sender];
}

@end
