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

#define MS_PER_SEC 1000
#define SEC_PER_MIN 60

// constants won't change. They're used here to 
// set pin numbers:
// prototype pins
//const int buttonPin = 2;     // the number of the pushbutton pin
//const int shutterPin = A2;
//const int focusPin = A3;
//const int flashPin = A4;
//const int flashSensePin = A5;
//const int micShortedPin = 4;
//const int batteryMonitorPin = A0;
//#define redLed 11
//#define greenLed 9
//#define blueLed 10

// breadboard  1 pins
#define buttonPin 2     // the number of the pushbutton pin
#define shutterPin A5
#define focusPin A4
#define flashPin A0
#define flashSensePin A1
#define micShortedPin 4
#define batteryMonitorPin A2
#define redLed 9
#define greenLed 10
#define blueLed 11

// TEMP FOR BREADBOARD
#define useIdlePin 3

#define BUTTON_TRANSMIT_PERIOD 1500 //ms
#define BUTTON_STOP_TIMELAPSE_PERIOD 1500
#define BUTTON_DEBOUNCE_PERIOD 25
#define CABLE_DEBOUNCE_PERIOD 100

#define DEFAULT_EXPOSURE 100 //ms
#define HDR_INTERVAL 1000 // TODO this should be configurable
#define SHUTTER_FEEDBACK_TIMEOUT 1000

#define SNAP_PHOTO (1)

#define STATIC_SHUTTER_LAG 30 //ms
#define BUFFER_RECOVER_TIME 200 //ms
#define EXPOSURE_WARNING_TIME_OFFSET ((uint32_t) 120000) //ms
#define MINIMUM_PHOTO_LENGTH 40 //ms

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
 STATE_TRANSMIT
};

void InitIdleState();
void SetConfig(int index);

#endif /* ETL_V1_H_ */