
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
        
//        NSLog(@"varible packet size %ld", sizeof(VariablePacket
//                                                 ));
//        NSLog(@"settings size %ld", sizeof(DeviceSettings));
//        NSLog(@"basic size %ld", sizeof(BasicTimelapse));
//        NSLog(@"bulb ramp size %ld", sizeof(BulbRamp));
//        NSLog(@"interval ramp size %ld", sizeof(IntervalRamp));
//        NSLog(@"hdr size %ld", sizeof(HDRShot));
        
        sendExtraByte = 1;
        
        [self populatePackets];
    }
}

-(void) initBulbRampPacket: (VariablePacket *)packet packetId:(uint8_t)packetId fstopChange:(float)fstopChange fstopSinAmp:(float)fstopSinAmp fstopChangePress:(int8_t)fstopChangePress
{
    packet->command = ETL_COMMAND_BULBRAMP;
    packet->packetId = packetId;
    
    packet->bulbRamp.exposureFstopChangePerMin = fstopChange;
    packet->bulbRamp.fstopChangeOnPress = fstopChangePress;
    packet->bulbRamp.fstopSinAmplitude = fstopSinAmp;
    
    packet->crc = crc_init();
    packet->crc =  crc_update(packet->crc, ((uint8_t *) packet) + sizeof(crc_t), sizeof(VariablePacket) - sizeof(crc_t));
    packet->crc = crc_finalize(packet->crc);
}

-(void) initTimelapsePacket: (VariablePacket *)packet packetId:(uint8_t)packetId shots:(uint32_t)shots interval:(uint32_t)interval expLength:(float)expLength
{
    packet->command = ETL_COMMAND_BASICTIMELAPSE;
    packet->packetId = packetId;
    
    packet->basicTimelapse.shots = shots;
    packet->basicTimelapse.interval = interval;
    packet->basicTimelapse.exposureLengthPower = expLength;
    
    packet->crc = crc_init();
    packet->crc =  crc_update(packet->crc, ((uint8_t *) packet) + sizeof(crc_t), sizeof(VariablePacket) - sizeof(crc_t));
    packet->crc = crc_finalize(packet->crc);  
}

-(void) initSignoffPacket: (VariablePacket *)packet packetId:(uint8_t)packetId
{
    packet->command = ETL_COMMAND_SIGNOFF;
    packet->packetId = packetId;
    
    packet->crc = crc_init();
    packet->crc =  crc_update(packet->crc, ((uint8_t *) packet) + sizeof(crc_t), sizeof(VariablePacket) - sizeof(crc_t));
    packet->crc = crc_finalize(packet->crc);  
}

- (void)populatePackets
{
    
    memset(sentPackets, 0, sizeof(VariablePacket) * MAX_PACKETS);

    [self initBulbRampPacket:&sentPackets[1] packetId:1 fstopChange:-0.15 fstopSinAmp:0 fstopChangePress:0];
    [self initTimelapsePacket:&sentPackets[2] packetId:2 shots:10 interval:2000 expLength:-1];
    [self initBulbRampPacket:&sentPackets[3] packetId:3 fstopChange:-0.1 fstopSinAmp:0 fstopChangePress:0];
    [self initTimelapsePacket:&sentPackets[4] packetId:4 shots:5 interval:2000 expLength:-1];
    [self initSignoffPacket:&sentPackets[5] packetId:5];
    
    return;
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
        myCrc = crc_update(myCrc, ((uint8_t *) &receivePacket) + sizeof(crc_t), sizeof(receivePacket) - sizeof(crc_t));
        myCrc = crc_finalize(myCrc);
        
        //NSLog(@"random %ld", random());
        
        // randomly fail our crc check to check for robustness
        if (random() % 2 == 0) {
            //NSLog(@"fail crc");
            //failCrc = TRUE;
        }
        
        if (myCrc != receivePacket.crc || failCrc) {
            NSLog(@"crc mismatch recv: %x, calc: %x; resend packet %d", receivePacket.crc, myCrc, packetIndex);
            // Resend the last packet. If this is the first time through, last packet is initialized to a ping packet
  
            [deviceInterface stopReader];
            
            usleep(500000);
            
            programmingProgress.progress = 0;
            progressBarTimer = [NSTimer scheduledTimerWithTimeInterval:0.01 target:self selector:@selector(updateProgressBar:) userInfo:nil repeats:YES];
            
            [deviceInterface startPlayer];
            [deviceInterface writeBuffer:(uint8_t *) &sentPackets[packetIndex] ofSize:sizeof(sentPackets[packetIndex])];
            totalCommandBits = 32;
        } else {
            NSLog(@"crc match; cmd: %x, data %x", receivePacket.command, receivePacket.packetId);
            // Initialize and send the next packet
            
            //NSLog(@"sleep wake");
            
            switch (receivePacket.command) {
                case IOS_COMMAND_REQUESTPACKETID:
                    // we will send next packet anyway
                    break;
                case IOS_COMMAND_DEVICEINFO:
                    NSLog(@"Device info:");
                    NSLog(@"  Major Version: %d", receivePacket.deviceInfo.majorVersion);
                    NSLog(@"  Minor Version: %d", receivePacket.deviceInfo.minorVersion);
                    NSLog(@"  BatteryLevel: %d", receivePacket.deviceInfo.batteryLevel);
                    break;
                case IOS_COMMAND_INVALID:
                default:
                    NSLog(@"Unrecognized command %x", receivePacket.command);
                    break;
                    
            }
            
            packetIndex = receivePacket.packetId;
                         
            NSLog(@"packet %d request", packetIndex);
            [deviceInterface stopReader];
            
            usleep(500000);
            
//            if (packetIndex % 2 == 0) {
//            
//            sentPackets[packetIndex].command = ETL_COMMAND_BASICTIMELAPSE;
//            sentPackets[packetIndex].packetId = packetIndex;
//        
//            sentPackets[packetIndex].basicTimelapse.shots = packetIndex;
//            sentPackets[packetIndex].basicTimelapse.interval = 2000;
//            sentPackets[packetIndex].basicTimelapse.exposureLengthPower = -2;
//            } else {
//                sentPackets[packetIndex].command = ETL_COMMAND_BULBRAMP;
//                sentPackets[packetIndex].packetId = packetIndex;
//                
//                sentPackets[packetIndex].bulbRamp.exposureFstopChangePerMin = 0.15;
//            }
//            
//            
//            sentPackets[packetIndex].crc = crc_init();
//            sentPackets[packetIndex].crc =  crc_update(sentPackets[packetIndex].crc, ((uint8_t *) &sentPackets[packetIndex]) + sizeof(crc_t), sizeof(VariablePacket) - sizeof(crc_t));
//            sentPackets[packetIndex].crc = crc_finalize(sentPackets[packetIndex].crc);
            
            NSLog(@"packet %d request crc %x", packetIndex, sentPackets[packetIndex].crc);
            
            programmingProgress.progress = 0;
            progressBarTimer = [NSTimer scheduledTimerWithTimeInterval:0.01 target:self selector:@selector(updateProgressBar:) userInfo:nil repeats:YES];
            
            [deviceInterface startPlayer];
            
            if (sendExtraByte > 0) {
                sendExtraByte--;
                [deviceInterface writeBuffer:(uint8_t *) &sendExtraByte ofSize:sizeof(sendExtraByte)];
                NSLog(@"Send extra bytes");
            }
            
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
