/*
 * Utils.h
 *
 * Created: 4/4/2012 2:43:51 PM
 *  Author: brandonw
 */ 


#ifndef UTILS_H_
#define UTILS_H_

#include "Arduino/HardwareSerial.h"
#include "ETL_V1.h"
#include <avr/sleep.h>
#include <avr/interrupt.h>

#ifndef cbi
#define cbi(sfr, bit) (_SFR_BYTE(sfr) &= ~_BV(bit))
#endif
#ifndef sbi
#define sbi(sfr, bit) (_SFR_BYTE(sfr) |= _BV(bit))
#endif

struct RGBColors {	
	byte red;
	byte green;
	byte blue;
};

const RGBColors OFF		= {0,0,0};
const RGBColors RED		= {255,0,0};
const RGBColors GREEN	= {0,100,0};
const RGBColors BLUE	= {0,0,150};
const RGBColors YELLOW	= {255,40,0};
const RGBColors PURPLE	= {255,0,100};
const RGBColors CYAN	= {0,100,150};
const RGBColors WHITE	= {255,60,90};
	
const int colorLoop_elements = 8;
//const RGBColors colorLoop[] = {GREEN,YELLOW,RED,PURPLE,BLUE,CYAN,WHITE, OFF};

struct LedCycle {
	uint32_t TimePerLed;
	uint8_t  NumLedPositions;
	uint8_t  RepeatCycle;
	RGBColors ColorCycle[6];

    LedCycle(uint32_t myTime, uint8_t myPos, uint8_t myRepeat, RGBColors Color0, RGBColors Color1, RGBColors Color2,
	            RGBColors Color3, RGBColors Color4, RGBColors Color5) {
		TimePerLed = myTime;
		NumLedPositions = myPos;
		RepeatCycle = myRepeat;
		ColorCycle[0] = Color0;
		ColorCycle[1] = Color1;
		ColorCycle[2] = Color2;
		ColorCycle[3] = Color3;
		ColorCycle[4] = Color4;
		ColorCycle[5] = Color5;
	};
};

struct TestStruct {
	uint32_t val;
	TestStruct(uint32_t myVal) {
		
	};
};

#define LED_CYCLE_OFF LedCycle(0,0,0,OFF,OFF,OFF,OFF,OFF,OFF)
#define LED_CYCLE_START LedCycle(200,6,0,GREEN,OFF,GREEN,OFF,GREEN,OFF)
#define LED_CYCLE_TIMELAPSE_PAUSE LedCycle(200,2,1,GREEN,OFF,OFF,OFF,OFF,OFF)
#define LED_CYCLE_TIMELAPSE_COMPLETE LedCycle(333,6,0,YELLOW,OFF,YELLOW,OFF,GREEN,OFF)
#define LED_CYCLE_TIMELAPSE_ABANDON LedCycle(333,6,0,RED,OFF,RED,OFF,GREEN,OFF)
#define LED_CYCLE_IDLE LedCycle(333, 8, 1, PURPLE, OFF,OFF,OFF,OFF,OFF)
#define LED_CYCLE_CRC_ERROR LedCycle(333, 2, 1, RED,YELLOW,OFF,OFF,OFF,OFF)
#define LED_CYCLE_CRC_SUCCESS LedCycle(333, 2, 1, GREEN,YELLOW,OFF,OFF,OFF,OFF)

void DebugInit() {	
	Serial.begin(19200);
	Serial.println("ETL version 0.1");
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

#endif /* UTILS_H_ */