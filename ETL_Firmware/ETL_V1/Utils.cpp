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

uint8_t ledStrength = DEFAULT_LED_STRENGTH;

void DebugInit() {	
	Serial.begin(9600);
	DebugPrintln(F("ETL version 0.1"));
	DebugPrint("milpf: usPovf:");
	DebugPrintln(MILLIS_PER_OVERFLOW);
	DebugPrintln(MICROSECONDS_PER_TIMER2_OVERFLOW);
	
	//Serial.print("testprint");
	//Serial.print(PSTR("testprint"));
	//DebugPrint(PSTR("testprint"));
	
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
    DebugPrint(F("  type: "));
	DebugPrintln(SecConf.type, HEX);
	//
	DebugPrint(F("  shots: "));
	DebugPrintln(SecConf.shots);
	//
	DebugPrint(F("  interval: "));
	DebugPrintln(SecConf.interval);
	
	if (SecConf.numRepeats != 0) {
		DebugPrint(F("  numRepeats: "));
		DebugPrintln(SecConf.numRepeats);

		DebugPrint(F("  repeatIndex: "));
		DebugPrintln(SecConf.repeatIndex);
	}	

	if (SecConf.intervalDelta != 0) {
		DebugPrint(F("  intervalDelta: "));
		DebugPrintln(SecConf.intervalDelta);
	}
	
	if (SecConf.exposureOffset != 0 ) {
		DebugPrint(F("  exposureOffset: "));
		DebugPrintln(SecConf.exposureOffset);
	}
	
	if (SecConf.exposureFstopChangePerMin != 0 ) {
		DebugPrint(F("  exposureFstopChangePerMin: "));
		DebugPrintln(SecConf.exposureFstopChangePerMin);
	}
	
	if (SecConf.fstopSinAmplitude != 0 ) {
		DebugPrint(F("  fstopSinAmplitude: "));
		DebugPrintln(SecConf.fstopSinAmplitude);
	}
	
	if (SecConf.fstopIncreasePerHDRShot != 0 ) {
		DebugPrint(F("  fstopIncreasePerHDRShot: "));
		DebugPrintln(SecConf.fstopIncreasePerHDRShot);
	}
	
	if (SecConf.numHDRShots != 0 ) {
		DebugPrint(F("  numHDRShots: "));
		DebugPrintln(SecConf.numHDRShots);
	}
	
	if (SecConf.fstopChangeOnPress != 0 ) {
		DebugPrint(F("  fstopChangeOnPress: "));
		DebugPrintln(SecConf.fstopChangeOnPress);
	}		
}

void SetLED(RGBColors colors) {
	
	//if (colors.red != 0) {
		//digitalWrite(redLed, HIGH);
	//} else {
		//digitalWrite(redLed, LOW);
	//}
	
	if (colors.green != 0) {
		digitalWrite(blueLed, HIGH);
	} else {
		digitalWrite(blueLed, LOW);
	}
	
	if (colors.blue != 0) {
		digitalWrite(greenLed, HIGH);
	} else {
		digitalWrite(greenLed, LOW);
	}
//
	if (colors.red != 0) {
		analogWrite(redLed, 50);
	} else {
		analogWrite(redLed, 0);
	}
	//
	//if (colors.green != 0) {
		//analogWrite(blueLed, ledStrength);
	//} else {
		//analogWrite(blueLed, 0);
	//}
	//
	//if (colors.blue != 0) {
		//analogWrite(greenLed, ledStrength);
	//} else {
		//analogWrite(greenLed, 0);
	//}


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