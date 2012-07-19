/*
 * communications.h
 *
 * Created: 7/11/2012 1:55:36 PM
 *  Author: brandonw
 */ 


#ifndef COMMUNICATIONS_H_
#define COMMUNICATIONS_H_

#define IDLE_TIMEOUT_PERIOD 5000

void InitTransmitState();
void LeaveTransmitState();
void ProcessTransmitState();


#endif /* COMMUNICATIONS_H_ */