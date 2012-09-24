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
#include "communications.h"
#include <avr/sleep.h>
#include <avr/interrupt.h>

enum COLOR_BITS {
	COLOR_RED,
	COLOR_GREEN,
	COLOR_BLUE
};

//struct RGBColors {	
	//byte red;
	//byte green;
	//byte blue;
//};

struct RGBColors {	
	unsigned red:1;
	unsigned blue:1;
	unsigned green:1;
};
//const RGBColors2 WHITE2 = {1,1,1};
	
RGBColors createColor(uint8_t Red, uint8_t Green, uint8_t Blue);

#define DEFAULT_LED_STRENGTH 5
extern uint8_t ledStrength;

#define RED_MAX 1
#define BLUE_MAX 1
#define GREEN_MAX 1

const RGBColors OFF		= {0,0,0};
const RGBColors RED		= {RED_MAX,0,0};
const RGBColors GREEN	= {0,BLUE_MAX,0};
const RGBColors BLUE	= {0,0,GREEN_MAX};
const RGBColors YELLOW	= {RED_MAX,BLUE_MAX,0};
const RGBColors PURPLE	= {RED_MAX,0,GREEN_MAX};
const RGBColors CYAN	= {0,BLUE_MAX,GREEN_MAX};
const RGBColors WHITE	= {RED_MAX,BLUE_MAX,GREEN_MAX};

//
//#define OFF     createColor(0,0,0)
//#define RED	    createColor(RED_MAX,0,0)
//#define GREEN	createColor(0,BLUE_MAX,0)
//#define BLUE	createColor(0,0,GREEN_MAX)
//#define YELLOW	createColor(RED_MAX,BLUE_MAX,0)
//#define PURPLE	createColor(RED_MAX,0,GREEN_MAX)
//#define CYAN	createColor(0,BLUE_MAX,GREEN_MAX)
//#define WHITE	createColor(RED_MAX,BLUE_MAX,GREEN_MAX)
//
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

#define LED_CYCLE_OFF LedCycle(0,0,0,OFF,OFF,OFF,OFF,OFF,OFF)
#define LED_CYCLE_START LedCycle(300,6,0,RED,OFF,YELLOW,OFF,GREEN,OFF)
#define LED_CYCLE_IDLE LedCycle(333, 8, 1, PURPLE, OFF,OFF,OFF,OFF,OFF)
#define LED_CYCLE_COLOR_COMBOS LedCycle(500, 4, 1, PURPLE,YELLOW,CYAN,WHITE,OFF,OFF)
#define LED_CYCLE_BAD_CLICK LedCycle(200, 1, 0, YELLOW,OFF,OFF,OFF,OFF,OFF)
#define LED_CYCLE_GOOD_CLICK LedCycle(400, 3, 0, GREEN,OFF,GREEN,OFF,OFF,OFF)

void DebugInit();

#define DEBUGPRINT

// Debug print statements

static inline
void DebugPrintln() {
#ifdef DEBUGPRINT
	Serial.println();
#endif
}

static inline
void DebugPrintln(const char* myString) {
#ifdef DEBUGPRINT
	Serial.println(myString);
#endif
}

static inline
void DebugPrint(const char* myString) {
#ifdef DEBUGPRINT
	Serial.print(myString);
#endif
}

static inline
void DebugPrintln(const __FlashStringHelper *myString) {
#ifdef DEBUGPRINT
	Serial.println(myString);
#endif
}

static inline
void DebugPrint(const __FlashStringHelper * myString) {
#ifdef DEBUGPRINT
	Serial.print(myString);
#endif
}

static inline
void DebugPrint(int myString) {
#ifdef DEBUGPRINT
	Serial.print(myString);
#endif
}

static inline
void DebugPrintln(int myString) {
#ifdef DEBUGPRINT
	Serial.println(myString);
#endif
}

static inline
void DebugPrintln(uint16_t myString) {
#ifdef DEBUGPRINT
	Serial.println(myString);
#endif
}

static inline
void DebugPrintln(uint32_t myString) {
#ifdef DEBUGPRINT
	Serial.println(myString);
#endif
}

static inline
void DebugPrintln(int32_t myString) {
#ifdef DEBUGPRINT
	Serial.println(myString);
#endif
}

static inline
void DebugPrintln(double myString) {
#ifdef DEBUGPRINT
	Serial.println(myString);
#endif
}

static inline
void DebugPrintln(int myString, int format) {
#ifdef DEBUGPRINT
	Serial.println(myString, format);
#endif
}

static inline
void DebugPrint(int myString, int format) {
#ifdef DEBUGPRINT
	Serial.print(myString, format);
#endif
}

void PrintSectionConfig(SectionConfig SecConf);

void SetLED(RGBColors colors);

byte AreColorsEqual(RGBColors color1, RGBColors color2);

void SetLEDCycle(LedCycle cycle);

#endif /* UTILS_H_ */