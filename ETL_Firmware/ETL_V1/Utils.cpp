/*
 * Utils.cpp
 *
 * Created: 7/8/2012 10:47:53 AM
 *  Author: brandonw
 */ 

/*
 * Utils.h
 *
 * Created: 4/4/2012 2:43:51 PM
 *  Author: brandonw
 */ 

#include "Utils.h"
#include "Arduino/Arduino.h"
const int colorLoop_elements = 8;
//const RGBColors colorLoop[] = {GREEN,YELLOW,RED,PURPLE,BLUE,CYAN,WHITE, OFF};

void DebugInit() {	
	Serial.begin(19200);
	DebugPrintln("ETL version 0.1");
	
	//__FlashStringHelper test = F("hi");	
	
//	Serial.println(F("ETL version 0.1"));
	//DebugPrint("DeviceSettings size: ");
	//DebugPrintln(sizeof(DeviceSettings));
		//
	//DebugPrint("BasicTimelapse size: ");
	//DebugPrintln(sizeof(BasicTimelapse));
		//
	//DebugPrint("BulbRamp size: ");
	//DebugPrintln(sizeof(BulbRamp));
		//
	//DebugPrint("IntervalRamp size: ");
	//DebugPrintln(sizeof(IntervalRamp));
	//
	//DebugPrint("HDRShot size: ");
	//DebugPrintln(sizeof(HDRShot));
}

//static inline
//void DebugPrint( const char* myString) {
	//DebugPrintln(myString);
//}

void PrintSectionConfig(SectionConfig SecConf) {

    // TODO string print takes 16 bytes out of memory. This adds up VERY quickly.
	// This either needs to be optimized or split out

    //DebugPrintln("Section Config:");
//
    //DebugPrint("  type: ");
	//DebugPrintln(SecConf.type);
	//
	//DebugPrint("  repeatIndex: ");
	//DebugPrintln(SecConf.repeatIndex);
	//
	//DebugPrint("  numRepeats: ");
	//DebugPrintln(SecConf.numRepeats);
	//
	DebugPrint("  shots: ");
	DebugPrintln(SecConf.shots);
	
	DebugPrint("  interval: ");
	DebugPrintln(SecConf.interval);
	
	//DebugPrint("  intervalDelta: ");
	//DebugPrintln(SecConf.intervalDelta);
	
	DebugPrint("  exposureOffset: ");
	DebugPrintln(SecConf.exposureOffset);
	//
	//DebugPrint("  exposureFstopChangePerMin: ");
	//DebugPrintln(SecConf.exposureFstopChangePerMin);
//
	//DebugPrint("  fstopSinAmplitude: ");
	//DebugPrintln(SecConf.fstopSinAmplitude);
	
	DebugPrint("  fstopIncreasePerHDRShot: ");
	DebugPrintln(SecConf.fstopIncreasePerHDRShot);
	//
	DebugPrint("  numHDRShots: ");
	DebugPrintln(SecConf.numHDRShots);
	////
	//DebugPrint("  fstopChangeOnPress: ");
	//DebugPrintln(SecConf.fstopChangeOnPress);
}

void SetLED(RGBColors colors) {
	analogWrite(redLed, colors.red);
	analogWrite(blueLed, colors.blue);
	analogWrite(greenLed, colors.green);
}

byte AreColorsEqual(RGBColors color1, RGBColors color2) {
	if (color1.blue != color2.blue) {
		return 0;
	}
	
	if (color1.red != color2.red) {
		return 0;
	}
	
	if (color1.green != color2.green) {
		return 0;
	}
	
	return 1;
}

RGBColors createColor(uint8_t Red, uint8_t Green, uint8_t Blue) {
	RGBColors color;
	
	color.red = Red;
	color.blue = Blue;
	color.green = Green;
	
	return color;
}		