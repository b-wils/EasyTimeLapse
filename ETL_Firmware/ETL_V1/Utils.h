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
	
    //RGBColors(uint8_t Red, uint8_t Green, uint8_t Blue) {
		//red = Red;
		//blue = Blue;
		//green = Green;
	//};
};

#define RED_MAX 150
#define BLUE_MAX 150
#define GREEN_MAX 150

const RGBColors OFF		= {0,0,0};
const RGBColors RED		= {RED_MAX,0,0};
const RGBColors GREEN	= {0,BLUE_MAX,0};
const RGBColors BLUE	= {0,0,GREEN_MAX};
const RGBColors YELLOW	= {RED_MAX,BLUE_MAX,0};
const RGBColors PURPLE	= {RED_MAX,0,GREEN_MAX};
const RGBColors CYAN	= {0,BLUE_MAX,GREEN_MAX};
const RGBColors WHITE	= {RED_MAX,BLUE_MAX,GREEN_MAX};

//
//#define OFF     RGBColors(0,0,0)
//#define RED	    RGBColors(RED_MAX,0,0)
//#define GREEN	RGBColors(0,BLUE_MAX,0)
//#define BLUE	RGBColors(0,0,GREEN_MAX)
//#define YELLOW	RGBColors(RED_MAX,BLUE_MAX,0)
//#define PURPLE	RGBColors(RED_MAX,0,GREEN_MAX)
//#define CYAN	RGBColors(0,BLUE_MAX,GREEN_MAX)
//#define WHITE	RGBColors(RED_MAX,BLUE_MAX,GREEN_MAX)
//
//const RGBColors colorLoop[] = {GREEN,YELLOW,RED,PURPLE,BLUE,CYAN,WHITE, OFF};

void testFunc(RGBColors testcolor);

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
		//ColorCycle[0] = Color0;
		//ColorCycle[1] = Color1;
		//ColorCycle[2] = Color2;
		//ColorCycle[3] = Color3;
		//ColorCycle[4] = Color4;
		//ColorCycle[5] = Color5;
	};
};

//struct tempStruct {
	//RGBColors color;
	//tempStruct(RGBColors *myColor) {
		//color = myColor;
	//}
//};

struct test2struct {
	uint8_t hi;
};

void test2func(test2struct hihi);

#define LED_CYCLE_OFF LedCycle(0,0,0,OFF,OFF,OFF,OFF,OFF,OFF)
#define LED_CYCLE_START LedCycle(200,6,0,RED,OFF,GREEN,OFF,BLUE,OFF)
#define LED_CYCLE_TIMELAPSE_PAUSE LedCycle(200,2,1,GREEN,OFF,OFF,OFF,OFF,OFF)
#define LED_CYCLE_TIMELAPSE_COMPLETE LedCycle(333,6,0,YELLOW,OFF,YELLOW,OFF,GREEN,OFF)
#define LED_CYCLE_TIMELAPSE_ABANDON LedCycle(333,6,0,RED,OFF,RED,OFF,GREEN,OFF)
#define LED_CYCLE_IDLE LedCycle(333, 8, 1, PURPLE, OFF,OFF,OFF,OFF,OFF)
#define LED_CYCLE_CRC_ERROR LedCycle(333, 6, 1, RED,OFF,OFF,YELLOW,OFF,OFF)
#define LED_CYCLE_CRC_SUCCESS LedCycle(333, 2, 1, GREEN,YELLOW,OFF,OFF,OFF,OFF)

void DebugInit();

void DebugPrint( const char* myString);

void PrintSectionConfig(SectionConfig SecConf);

void SetLED(RGBColors colors);

byte AreColorsEqual(RGBColors color1, RGBColors color2);

#endif /* UTILS_H_ */