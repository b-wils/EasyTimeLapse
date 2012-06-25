//
//  test3AppDelegate.h
//  test3
//
//  Created by Ben Hoffman on 2/8/12.
//  Copyright 2012 Microsoft. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AudioToolbox/AudioToolbox.h>
#import "FSKSerialGenerator.h"
#import "MultiDelegate.h"
#import "FSKRecognizer.h"
#import "AudioSignalAnalyzer.h"
#import "CharReceiver.h"
#import "etl_typedefs.h"

@interface test3AppDelegate : NSObject <CharReceiver, UIApplicationDelegate, UITabBarControllerDelegate> {
    UIWindow *window;
	UITabBarController *tabBarController;
	CFURLRef        soundFileURLRef;
    SystemSoundID   soundFileObject;
	AudioSignalAnalyzer* analyzer;
	FSKSerialGenerator* generator;
	FSKRecognizer* recognizer;
	int charsReceived;
    NSMutableArray *mySectionConfigsArray;
    SectionConfig myConfigs[5];
    int configIndex;
    
}

@property (nonatomic, retain) IBOutlet UIWindow *window;
@property (nonatomic, retain) IBOutlet UITabBarController *tabBarController;

@property (readwrite)   CFURLRef        soundFileURLRef;
@property (readonly)    SystemSoundID   soundFileObject;
@property (nonatomic, retain) FSKSerialGenerator* generator;
@property (nonatomic, retain) AudioSignalAnalyzer* analyzer;

- (IBAction) playSystemSound: (id) sender;
- (IBAction) playAlertSound: (id) sender;
- (IBAction) vibrate: (id) sender;

-(IBAction)buttonTouched;
-(IBAction)stopButtonTouched;
-(IBAction)readButtonTouched;
-(IBAction)configSelectorTouched;
@end

