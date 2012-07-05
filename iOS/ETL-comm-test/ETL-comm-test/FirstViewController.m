//
//  FirstViewController.m
//  ETL-comm-test
//
//  Created by Inspired Eye on 6/28/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "FirstViewController.h"

@interface FirstViewController ()

@end



@implementation FirstViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    if (self) {
        NSLog(@"create etldevint");
        deviceInterface = [[ETLDeviceInterface alloc] initWithReceiver:self];
        [deviceInterface startReader];
        packetIndex = 0;
        
        memset(sentPackets, 0, sizeof(CommandPacket) * MAX_PACKETS);
    }
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
    } else {
        return YES;
    }
}

- (void) receivedChar:(char) input
{
    //NSLog(@"received char: %d", input);
    
    //progressBarTimer = [NSTimer scheduledTimerWithTimeInterval:0.01 target:self selector:@selector(updateProgressBar:) userInfo:nil repeats:YES];
    
    ((char *) &receivePacket)[receivedBits] = input;
    receivedBits++;
    
    
    if (receivedBits >= sizeof(receivePacket)) {
        
        bool failCrc = FALSE;
        
        
        receivedBits = 0;
        
        // Process received packet
        
        crc_t myCrc = crc_init();
        myCrc = crc_update(myCrc, (uint8_t *) &receivePacket.Command, 2);
        myCrc = crc_finalize(myCrc);
        
        //NSLog(@"random %ld", random());
        
        // randomly fail our crc check to check for robustness
        if (random() % 2 == 0) {
            NSLog(@"fail crc");
            failCrc = TRUE;
        }
        
        if (myCrc != receivePacket.Crc || failCrc) {
            NSLog(@"crc mismatch recv: %x, calc: %x; resend packet %d", receivePacket.Crc, myCrc, packetIndex);
            // Resend the last packet. If this is the first time through, last packet is initialized to a ping packet
  
            [deviceInterface stopReader];
            
            usleep(500000);
            
            programmingProgress.progress = 0;
            progressBarTimer = [NSTimer scheduledTimerWithTimeInterval:0.01 target:self selector:@selector(updateProgressBar:) userInfo:nil repeats:YES];
            
            [deviceInterface startPlayer];
            [deviceInterface writeBuffer:(uint8_t *) &sentPackets[packetIndex] ofSize:sizeof(sentPackets[packetIndex])];
            totalCommandBits = 32;
        } else {
            NSLog(@"crc match; cmd: %x, data %x", receivePacket.Command, receivePacket.Data);
            // Initialize and send the next packet
            
            //NSLog(@"sleep wake");
            
            packetIndex = receivePacket.Data;
            
            if (packetIndex > 5) {
                packetIndex = 1;
                return;
            }
             
            NSLog(@"packet %d request", packetIndex);
            
            [deviceInterface stopReader];
            
            usleep(500000);
            
            sentPackets[packetIndex].Command = 0x77;
            sentPackets[packetIndex].Data = packetIndex;
        
            sentPackets[packetIndex].Crc = crc_init();
            sentPackets[packetIndex].Crc =  crc_update(sentPackets[packetIndex].Crc, ((uint8_t *) &sentPackets[packetIndex].Command), 2);
            sentPackets[packetIndex].Crc = crc_finalize(sentPackets[packetIndex].Crc);
            
            programmingProgress.progress = 0;
            progressBarTimer = [NSTimer scheduledTimerWithTimeInterval:0.01 target:self selector:@selector(updateProgressBar:) userInfo:nil repeats:YES];
            
            [deviceInterface startPlayer];
            [deviceInterface writeBuffer:(uint8_t *) &sentPackets[packetIndex] ofSize:sizeof(sentPackets[packetIndex])];
            totalCommandBits = 32;
        }
        
        
    }
    
}

-(IBAction)programButtonPush {
    programmingProgress.progress = 0;
    progressBarTimer = [NSTimer scheduledTimerWithTimeInterval:0.01 target:self selector:@selector(updateProgressBar:) userInfo:nil repeats:YES];
    
    Byte data = 0xcc;
    [deviceInterface startPlayer];
    [deviceInterface writeBuffer:&data ofSize:sizeof(Byte)];
    totalCommandBits = 8;
    NSLog(@"program");
}

-(IBAction)listenButtonPush {
    [deviceInterface startReader];
    NSLog(@"Listen");
}

-(IBAction)stopButtonPush {
    NSLog(@"Stop");
    
    [deviceInterface stopProgramming];
}

const NSUInteger streamBitsPerDataByte = 14;
- (void)updateProgressBar:(NSTimer *)timer
{
    NSUInteger bitCount = [deviceInterface.generator numRawBitsWritten];
    
    //bytesTransferred.text = [NSString stringWithFormat:@"%i bytes sent", bitCount / streamBitsPerDataByte];
    if (bitCount < totalCommandBits) {        
        programmingProgress.progress = (bitCount / (totalCommandBits * 1.0)) * 0.9;
    }
    else {
        programmingProgress.progress += 0.007;
    }
    
    if (programmingProgress.progress >= 1) {
        [timer invalidate];
        [deviceInterface stopProgramming];
        [deviceInterface startReader];
        //bytesTransferred.text = @"Done";
        //cancelButton.hidden = true;
    }
}

@end