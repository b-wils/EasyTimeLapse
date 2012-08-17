/*
 * communications.h
 *
 * Created: 7/11/2012 1:55:36 PM
 *  Author: brandonw
 */ 


#ifndef COMMUNICATIONS_H_
#define COMMUNICATIONS_H_

#include "Utils.h"

#define MAX_IDLE_RETRY_COUNT 3
#define IDLE_RETRY_PERIOD 3000
#define CRC_ERRORS_TO_CLEAR_BUFFER 1
#define CRC_ERRORS_TO_ABANDON 9

#define LED_CYCLE_CRC_MISMATCH LedCycle(200, 1, 0, RED,OFF,OFF,OFF,OFF,OFF)
#define LED_CYCLE_CRC_MATCH LedCycle(200, 1, 0, GREEN,OFF,OFF,OFF,OFF,OFF)
#define LED_CYCLE_WRONG_PACKET LedCycle(200,2,0,RED,GREEN,OFF,OFF,OFF,OFF)
#define LED_CYCLE_START_PROGRAM LedCycle(333, 5, 0, YELLOW,OFF,YELLOW,OFF,YELLOW,OFF)
#define LED_CYCLE_END_PROGRAM LedCycle(333, 6, 0, YELLOW,GREEN,YELLOW,GREEN,YELLOW,GREEN)
#define LED_CYCLE_PROGRAM_FAILURE LedCycle(333, 6, 0, YELLOW,RED,YELLOW,RED,YELLOW,RED)
#define LED_CYCLE_PROGRAM_CLEAR_BUFFER LedCycle(333, 3, 0, RED,YELLOW,GREEN,RED,YELLOW,RED)

void InitTransmitState();
void LeaveTransmitState();
void ProcessTransmitState();


#endif /* COMMUNICATIONS_H_ */