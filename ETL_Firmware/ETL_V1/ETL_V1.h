/*
 * etl.h
 *
 * Created: 4/5/2012 12:18:11 PM
 *  Author: brandonw
 */ 


#ifndef ETL_V1_H_
#define ETL_V1_H_

#include "Common.h"
#include "Arduino/Arduino.h"
#include "Utils.h"

#if 1
#undef PROGMEM 
#define PROGMEM __attribute__(( section(".progmem.data") )) 

#undef PSTR 
#define PSTR(s) (__extension__({static prog_char __c[] PROGMEM = (s); &__c[0];})) 
#endif 

#define MS_PER_SEC 1000
#define SEC_PER_MIN 60

// constants won't change. They're used here to 
// set pin numbers:
// prototype pins
const int buttonPin = 2;     // the number of the pushbutton pin
const int enableBatteryMonitorPin = A1;
const int shutterPin = A2;
const int focusPin = A3;
const int flashFeedbackPin = A4;
const int flashSensePin = A5;
const int batteryMonitorPin = A0;
#define redLed 11
#define greenLed 9
#define blueLed 10
#define fskVCCFitlerPin 8 // NOT USED

// breadboard  1 pins
//#define buttonPin 2     // the number of the pushbutton pin
//#define shutterPin A5
//#define focusPin A2
//#define flashFeedbackPin A0
//#define flashSensePin A1
//#define batteryMonitorPin A3
//#define redLed 9
//#define greenLed 10
//#define blueLed 11
//#define fskVCCFitlerPin 8


// TEMP FOR BREADBOARD
#define useIdlePin 3

#define BUTTON_TRANSMIT_PERIOD 1500 //ms
#define BUTTON_STOP_TIMELAPSE_PERIOD 1500
#define BUTTON_DEBOUNCE_PERIOD 25
#define CABLE_DEBOUNCE_PERIOD 100

// Voltage Divider
#define VOTLAGE_DIV_FACTOR 11 // (R1 + R2)/R2
#define FULL_VOLTAGE 9
#define EMPTY_VOLTAGE 7.5
#define ADC_MAX 1023
#define ADC_REF_VOLTAGE 1.1
#define ADC_FULL_VOLTAGE (ADC_MAX * FULL_VOLTAGE / VOTLAGE_DIV_FACTOR / ADC_REF_VOLTAGE)
#define ADC_EMPTY_VOLTAGE (ADC_MAX * EMPTY_VOLTAGE / VOTLAGE_DIV_FACTOR / ADC_REF_VOLTAGE)

enum {
 STATE_INVALID = 0,
 STATE_IDLE,
 STATE_TIMELAPSE_WAITING,
 STATE_TIMELAPSE_WAITING_FLASH,
 STATE_TIMELAPSE_EXPOSING,
 STATE_TIMELAPSE_PAUSE,
 STATE_TRANSMIT,
 STATE_TIMELAPSE_MANUAL,
 STATE_TIMELAPSE_MANUAL_TRANSMIT // Hybird state... should we move manual to it's own variable?
};

struct EEPromHeader {
	uint32_t bulbShutterOffset;
	uint16_t bufferRecoverTime;
	uint8_t numConfigs;
	uint8_t ledStrength;
	uint8_t deviceSettingsBits;
};

void InitIdleState(); //__attribute__ ((section (".idleinit")));
void SetConfig(int index);
void dumpToEEProm();
uint16_t getBatteryLevel();
#endif /* ETL_V1_H_ */