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

@synthesize command, sections;

- (void)viewDidLoad
{
    [super viewDidLoad];
    deviceInterface = [[ETLDeviceInterface alloc] initWithReceiver:self];
    UIProgressView *original = programmingProgress;
    programmingProgress = (UIProgressView *)[[ADVPopoverProgressBar alloc] initWithFrame:programmingProgress.frame];
    [programmingProgress setProgress:0.6];
    [original removeFromSuperview];
    [self.view addSubview:programmingProgress];
    
    progressBarTimer = [NSTimer scheduledTimerWithTimeInterval:0.01 target:self selector:@selector(updateProgressBar:) userInfo:nil repeats:YES];
    [NSTimer scheduledTimerWithTimeInterval:0.75 target:self selector:@selector(startProgramming) userInfo:nil repeats:NO];
}

- (void)startProgramming
{
    [deviceInterface startProgramming];
    [deviceInterface sendCommand:command.command data:command.data];
    for (NSUInteger i = 0; i < command.data; i++) {
        [deviceInterface sendSection:sections + i];
    }
}

const NSUInteger streamBitsPerDataByte = 14;
- (void)updateProgressBar:(NSTimer *)timer
{
    NSUInteger bitCount = [deviceInterface.generator numRawBitsWritten];
    
    bytesTransferred.text = [NSString stringWithFormat:@"%i bytes sent", bitCount / streamBitsPerDataByte];
    if (bitCount < totalCommandBits) {        
        programmingProgress.progress = (bitCount / (totalCommandBits * 1.0)) * 0.9;
    }
    else {
        programmingProgress.progress += 0.001;
    }
    
    if (programmingProgress.progress >= 0.999) {
        [timer invalidate];
        programmingProgress.progress = 1.0;
        [deviceInterface stopProgramming];
        bytesTransferred.text = @"Done";
        cancelButton.hidden = true;
        
        [NSTimer scheduledTimerWithTimeInterval:2.0 target:self selector:@selector(didFinishProgramming:) userInfo:NULL repeats:NO];
    }
}

- (void)didFinishProgramming:(id)sender
{
    ETLDoneProgrammingController *controller = [self.storyboard instantiateViewControllerWithIdentifier:@"DoneProgramming"];
    [self.navigationController pushViewController:controller animated:YES];
}

- (void) setDeviceCommand:(CommandPacket)deviceCommand withSections:(SectionConfig *)commandSections
{
    command = deviceCommand;
    sections = commandSections;
    
    // TODO - review this calculation for general cases
    totalCommandBits = (sizeof(CommandPacket) + sizeof(ETlModemPacket) * command.data) * streamBitsPerDataByte;
}

- (void)goBack:(id)sender
{
    [deviceInterface stopProgramming];
    [progressBarTimer invalidate];
    progressBarTimer = nil;
    [super goBack:sender];
    //[self dismissModalViewControllerAnimated:NO];
}

- (void) receivedChar:(char)input
{
    NSLog(@"Received character: %c", input);
}

@end
