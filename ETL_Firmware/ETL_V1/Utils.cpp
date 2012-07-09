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
	Serial.println("ETL version 0.1");
	
	Serial.print("DeviceSettings size: ");
	Serial.println(sizeof(DeviceSettings));
		
	Serial.print("BasicTimelapse size: ");
	Serial.println(sizeof(BasicTimelapse));
		
	Serial.print("BulbRamp size: ");
	Serial.println(sizeof(BulbRamp));
		
	Serial.print("IntervalRamp size: ");
	Serial.println(sizeof(IntervalRamp));
	
	Serial.print("HDRShot size: ");
	Serial.println(sizeof(HDRShot));
}

void DebugPrint( const char* myString) {
	Serial.println(myString);
    delay(15);
}

void PrintSectionConfig(SectionConfig SecConf) {

    Serial.println("Section Config:");

    Serial.print("  type: ");
	Serial.println(SecConf.type);
	
	Serial.print("  repeatIndex: ");
	Serial.println(SecConf.repeatIndex);
	
	Serial.print("  numRepeats: ");
	Serial.println(SecConf.numRepeats);
	
	Serial.print("  shots: ");
	Serial.println(SecConf.shots);
	
	Serial.print("  interval: ");
	Serial.println(SecConf.interval);
	
	Serial.print("  intervalDelta: ");
	Serial.println(SecConf.intervalDelta);
	
	Serial.print("  exposureOffset: ");
	Serial.println(SecConf.exposureOffset);
	
	Serial.print("  exposureFstopChangePerMin: ");
	Serial.println(SecConf.exposureFstopChangePerMin);

	Serial.print("  fstopSinAmplitude: ");
	Serial.println(SecConf.fstopSinAmplitude);
	
	Serial.print("  fstopIncreasePerHDRShot: ");
	Serial.println(SecConf.fstopIncreasePerHDRShot);
	
	Serial.print("  numHDRShots: ");
	Serial.println(SecConf.numHDRShots);
	
	Serial.print("  fstopChangeOnPress: ");
	Serial.println(SecConf.fstopChangeOnPress);
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