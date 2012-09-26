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
//    UIProgressView *original = programmingProgress;
//    programmingProgress = (UIProgressView *)[[ADVPopoverProgressBar alloc] initWithFrame:programmingProgress.frame];
//    [programmingProgress setProgress:0];
//    [original removeFromSuperview];
//    [self.view addSubview:programmingProgress];
    
//    batteryLevelLabel.text = [NSString stringWithFormat:@"%u%%", batteryLevel];
//    programmingProgress.progress = (firstPacketSuccessful ? 1 : 0) / (packetProvider.packetCount + 2.0);
}

- (void)startProgramming
{
    programmer.packetProvider = packetProvider;
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didRequestPacket:) name:PacketRequested object:programmer];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didCompleteProgramming:) name:ProgrammingComplete object:programmer];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didReceiveDeviceData:) name:GotDeviceInfo object:programmer];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didDetachHeadphones:) name:HeadsetDetached object:programmer];
//    [programmer listen];
}

- (void)didDetachHeadphones:(NSNotification *)notification
{
    [self goBack:nil];
}

const NSUInteger streamBitsPerDataByte = 14;

- (void)didRequestPacket:(NSNotification *)notification
{
    NSDictionary *userInfo = notification.userInfo;
    UInt32 packetId; [(NSValue *)[userInfo objectForKey:@"sendingPacketId"] getValue:&packetId];
    
//    programmingProgress.progress = packetId / (packetProvider.packetCount + 2.0);
    UInt32 pct = packetId / (packetProvider.packetCount + 2.0) * 100;
    percentComplete.text = nsprintf(@"%2d", pct);
}

- (void)didCompleteProgramming:(NSNotification *)notification
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

const int BATTERY_MIN = 300;
const int BATTERY_MAX = 761;
const int BATTERY_RANGE = BATTERY_MAX - BATTERY_MIN;

- (void)didReceiveDeviceData:(NSNotification *)notification
{
    NSNumber *value = [notification.userInfo objectForKey:@"batteryLevel"];
    [value getValue:&batteryLevel];
    
    batteryLevel = MAX(0, batteryLevel - BATTERY_MIN);
    batteryLevel = batteryLevel * 100.0 / BATTERY_RANGE;
    
    batteryLevelLabel.text = [NSString stringWithFormat:@"%u%%", batteryLevel];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return NO;
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
