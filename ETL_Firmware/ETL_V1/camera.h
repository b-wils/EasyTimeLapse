/*
 * camera.h
 *
 * Created: 7/11/2012 1:55:52 PM
 *  Author: brandonw
 */ 


#ifndef CAMERA_H_
#define CAMERA_H_

#include "Utils.h"

#define DEFAULT_EXPOSURE 100 //ms
#define HDR_INTERVAL 500 // TODO this should be configurable
#define SHUTTER_FEEDBACK_TIMEOUT 1000

#define BUFFER_RECOVER_TIME 200 //ms
#define EXPOSURE_WARNING_TIME_OFFSET (((uint32_t) 5)*60*1000) //ms
#define MINIMUM_PHOTO_LENGTH 20 //ms

#define LED_CYCLE_TIMELAPSE_PAUSE LedCycle(400,2,1,GREEN,YELLOW,OFF,OFF,OFF,OFF)
#define LED_CYCLE_TIMELAPSE_COMPLETE LedCycle(333,5,0,GREEN,OFF,GREEN,OFF,GREEN,OFF)
#define LED_CYCLE_TIMELAPSE_ABANDON LedCycle(333,5,0,RED,OFF,RED,OFF,RED,OFF)
#define LED_CYCLE_TAKE_PICTURE LedCycle(50, 1, 0, GREEN,OFF,OFF,OFF,OFF,OFF)
#define LED_CYCLE_TIMELAPSE_INVALID LedCycle(333,5,0,RED,YELLOW,RED,YELLOW,RED,OFF)
#define LED_CYCLE_TIMELAPSE_CHANGE_READY LedCycle(250, 1, 0, YELLOW,OFF,OFF,OFF,OFF,OFF)
#define LED_CYCLE_TIMELAPSE_EXP_COLLISION LedCycle(250, 1, 0, RED,OFF,OFF,OFF,OFF,OFF)
#define LED_CYCLE_STOP_CHANGE_SUCCESS LedCycle(250,5,0,GREEN,OFF,GREEN,OFF,GREEN,OFF)
#define LED_CYCLE_STOP_CHANGE_FAILURE LedCycle(500,1,0,RED,OFF,RED,OFF,RED,OFF)

void StartExposure();
void EndExposure();
void TimelapseResume();
void InitTimelapseState();
void InitManualTimelapseState();
void InitTimelapsePauseState();
void ProcessTimelapseWaiting();
void ProcessTimeLapseWaitingFlash();
void ProcessTimeLapseExposing();

#endif /* CAMERA_H_ */