//
//  test3AppDelegate.m
//  test3
//
//  Created by Ben Hoffman on 2/8/12.
//  Copyright 2012 Microsoft. All rights reserved.
//

#import "test3AppDelegate.h"
#import "FSKSerialGenerator.h"
#import "crc.h"

void interruptionListenerCallback (
								   void	*inUserData,
								   UInt32	interruptionState
								   ) {
	// This callback, being outside the implementation block, needs a reference 
	//	to the AudioViewController object
	test3AppDelegate *delegate = (test3AppDelegate *) inUserData;
	
	if (interruptionState == kAudioSessionBeginInterruption) {
		
		NSLog (@"Interrupted. Stopping recording/playback.");
		
		[delegate.analyzer stop];
		[delegate.generator pause];
	} else if (interruptionState == kAudioSessionEndInterruption) {
		// if the interruption was removed, resume recording
		[delegate.analyzer record];
		[delegate.generator resume];
	}
}

@implementation test3AppDelegate

@synthesize window;
@synthesize tabBarController;
@synthesize generator;
@synthesize analyzer;

#pragma mark -
#pragma mark Application lifecycle



- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {    
    
    // Override point for customization after application launch.
    charsReceived = 0;
	
	self.window.rootViewController = self.tabBarController;
    [self.window makeKeyAndVisible];
    
		generator = [[FSKSerialGenerator alloc] init];
	
	// initialize the audio session object for this application,
	//		registering the callback that Audio Session Services will invoke 
	//		when there's an interruption
	AudioSessionInitialize (NULL,
							NULL,
							interruptionListenerCallback,
							self);
	
	// before instantiating the recording audio queue object, 
	//	set the audio session category
	UInt32 sessionCategory = kAudioSessionCategory_PlayAndRecord;
	AudioSessionSetProperty (kAudioSessionProperty_AudioCategory,
							 sizeof (sessionCategory),
							 &sessionCategory);
	
	recognizer = [[FSKRecognizer alloc] init];
	analyzer = [[AudioSignalAnalyzer alloc] init];
	[analyzer addRecognizer:recognizer];
	[recognizer addReceiver:self];
//	[recognizer addReceiver:typeController];
	generator = [[FSKSerialGenerator alloc] init];
	AudioSessionSetActive (true);
//	[analyzer record];
//	[generator play];
	
    
	UILabel *label = (UILabel*)[window viewWithTag:10];
	label.text = [NSString stringWithFormat:@"%d", sizeof(ETlModemPacket)];  
	
	//[generator play];
    
    //mySectionConfigs = [[NSMutableArray alloc] init];
    
    for (int i = 0; i<5;i++) {
        //SectionConfig *myConfig = malloc(sizeof(SectionConfig));
        //initEtlConfig(myConfig);
        //[mySectionConfigs addObject:myConfig];
        
        initEtlConfig(&myConfigs[i]);
    }
    
    configIndex = 0;
    
    return YES;
}

- (void) receivedChar:(char) input
{
	charsReceived++;
	UILabel *label = (UILabel*)[window viewWithTag:24];
	label.text = [NSString stringWithFormat:@"%d", input];
	
}

-(IBAction)buttonTouched {
	UILabel *label = (UILabel*)[window viewWithTag:10];
	label.text = @"Buttons!";
    
    UITextField *shots = (UITextField*)[window viewWithTag:31];
    UITextField *interval = (UITextField*)[window viewWithTag:32];
    
    ETlModemPacket myPacket;
    
    initEtlConfig(&myPacket.SectConf);
    
    myPacket.SectConf.shots = [shots.text intValue];
    myPacket.SectConf.interval = [interval.text intValue];
    
    myPacket.Crc = crc_init();
    
    myPacket.Crc = crc_update(myPacket.Crc, &(myPacket.SectConf), sizeof(SectionConfig));
    myPacket.Crc = crc_finalize(myPacket.Crc);
    
    label.text = [NSString stringWithFormat:@"%x", myPacket.Crc];
    
    for (int i=0; i<sizeof(ETlModemPacket);i++) {
            Byte transmitChar = ((Byte *) &myPacket)[i];
        [self.generator writeByte:transmitChar];
    }
    
	//Use audio sevices to create the sound
	//AudioServicesCreateSystemSoundID((CFURLRef)filePath, &soundID);
	//Use audio services to play the sound
	//AudioServicesPlaySystemSound(soundID);
	
	char transmitChar = 0xcc;
	
	//for (int i=0; i<255; i++) {
	//	[self.generator writeByte:transmitChar];	
	//}
	
	[generator play];
	//[[test3AppDelegate getInstance].generator writeByte:'c'];
}

- (IBAction) stopButtonTouched {
	[generator stop];
    [analyzer stop];
	UILabel *label = (UILabel*)[window viewWithTag:24];
	label.text = @"stopped";
}

- (IBAction) readButtonTouched {
	UILabel *label = (UILabel*)[window viewWithTag:24];
	label.text = @"reading!";
    [analyzer record];
}

- (IBAction) configSelectorTouched {
	UISegmentedControl *configSelector = (UISegmentedControl*)[window viewWithTag:41];
    UILabel *label = (UILabel*)[window viewWithTag:24];
    UITextField *shots = (UITextField*)[window viewWithTag:31];
    UITextField *interval = (UITextField*)[window viewWithTag:32];
    UITextField *expLength = (UITextField*)[window viewWithTag:33];
    UITextField *expDelta = (UITextField*)[window viewWithTag:34];
    
	label.text = [NSString stringWithFormat:@"config #%d", configSelector.selectedSegmentIndex];
    
    myConfigs[configIndex].shots = [shots.text intValue];
    myConfigs[configIndex].interval = [interval.text intValue];
    myConfigs[configIndex].exposureOffset = [expLength.text floatValue];
    myConfigs[configIndex].exposureFstopChangePerMin = [expDelta.text floatValue];
    
    configIndex = configSelector.selectedSegmentIndex;
    
    shots.text = [NSString stringWithFormat:@"%d", myConfigs[configIndex].shots];
    interval.text = [NSString stringWithFormat:@"%d", myConfigs[configIndex].interval];
    expLength.text = [NSString stringWithFormat:@"%.3f", myConfigs[configIndex].exposureOffset];
    expDelta.text = [NSString stringWithFormat:@"%.3f", myConfigs[configIndex].exposureFstopChangePerMin];
}



- (void)applicationWillResignActive:(UIApplication *)application {
    /*
     Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
     Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
     */
}


- (void)applicationDidEnterBackground:(UIApplication *)application {
    /*
     Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
     If your application supports background execution, called instead of applicationWillTerminate: when the user quits.
     */
}


- (void)applicationWillEnterForeground:(UIApplication *)application {
    /*
     Called as part of  transition from the background to the inactive state: here you can undo many of the changes made on entering the background.
     */
}


- (void)applicationDidBecomeActive:(UIApplication *)application {
    /*
     Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
     */
}


- (void)applicationWillTerminate:(UIApplication *)application {
    /*
     Called when the application is about to terminate.
     See also applicationDidEnterBackground:.
     */
}


#pragma mark -
#pragma mark Memory management

- (void)applicationDidReceiveMemoryWarning:(UIApplication *)application {
    /*
     Free up as much memory as possible by purging cached data objects that can be recreated (or reloaded from disk) later.
     */
}


- (void)dealloc {
	[tabBarController release];
    [window release];
    [super dealloc];
}


@end
