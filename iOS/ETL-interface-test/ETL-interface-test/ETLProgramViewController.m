//
//  ETLProgramControllerViewController.m
//  ETL-interface-test
//
//  Created by Carll Hoffman on 6/20/12.
//  Copyright (c) 2012 Microsoft. All rights reserved.
//

#import "ETLProgramViewController.h"
#import "ETLViewControllers.h"
#import "ADVPopoverProgressBar.h"

@interface ETLProgramViewController ()

@end

@implementation ETLProgramViewController

@synthesize packetProvider;

- (void)viewDidLoad
{
    [super viewDidLoad];

    programmer = [[ETLProgrammer alloc] init];
    UIProgressView *original = programmingProgress;
    programmingProgress = (UIProgressView *)[[ADVPopoverProgressBar alloc] initWithFrame:programmingProgress.frame];
    [programmingProgress setProgress:0];
    [original removeFromSuperview];
    [self.view addSubview:programmingProgress];
    
    [self startProgramming];
}

- (void)startProgramming
{
    programmer.packetProvider = packetProvider;
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didRequestPacket:) name:PacketRequested object:programmer];
    [programmer listen];
}

const NSUInteger streamBitsPerDataByte = 14;

- (void)didRequestPacket:(NSNotification *)notification
{
    NSDictionary *userInfo = notification.userInfo;
    UInt32 packetId; [(NSValue *)[userInfo objectForKey:@"sendingPacketId"] getValue:&packetId];
    
    programmingProgress.progress = packetId / (packetProvider.packetCount + 1.0);
    if (programmingProgress.progress >= 0.999) {
        programmingProgress.progress = 1.0;
        [programmer halt];
        bytesTransferred.text = @"done";
        cancelButton.hidden = true;        
        [NSTimer scheduledTimerWithTimeInterval:2.0 target:self selector:@selector(didFinishProgramming:) userInfo:NULL repeats:NO];
    }
}

- (void)didFinishProgramming:(id)sender
{
    ETLDoneProgrammingController *controller = [self.storyboard instantiateViewControllerWithIdentifier:@"DoneProgramming"];
    [self.navigationController pushViewController:controller animated:YES];
}

- (void)goBack:(id)sender
{
    [programmer halt];
    [progressBarTimer invalidate];
    progressBarTimer = nil;
    [startTimer invalidate];
    startTimer = nil;
    [super goBack:sender];
}

@end
