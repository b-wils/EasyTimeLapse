/*
 * camera.cpp
 *
 * Created: 7/11/2012 1:56:03 PM
 *  Author: brandonw
 */ 

#include "camera.h"
#include "Utils.h"

double fstopSinPhase;
double sinPeriodMin;

int32_t shotsRemaining;
uint32_t currentInterval;
uint32_t nextHDRBracketTime;
uint32_t shutterOffTime;
uint32_t expRefTime;

uint8_t configIndex = 0;
int16_t repeatsRemaining;
int32_t exposureLength = 0;
uint8_t useFlashFeeback = 1;
uint8_t HDRShotNumber;

uint32_t nextPhotoTime;

float exposurePressChange = 0;

extern uint8_t currentState;

extern byte buttonClicked;
extern byte buttonHeld;
extern SectionConfig myConfigs[MAX_CONFIGS];
extern uint8_t numConfigs;

void StartExposure() {
    digitalWrite(shutterPin, HIGH);
    digitalWrite(focusPin, HIGH);
}

void EndExposure() {
    digitalWrite(shutterPin, LOW);
    digitalWrite(focusPin, LOW);
}

void SetConfig(int index) {

	DebugPrint("set config index ");
	DebugPrintln(index);
    shotsRemaining = myConfigs[index].shots;
    currentInterval = myConfigs[index].interval;
	HDRShotNumber = 0;
	exposurePressChange = 0; // TODO there may be cases where we want to preserve this across configs
	//
		//DebugPrint("use flash: ");
		//DebugPrintln(useFlashFeeback, HEX);
	
	if (repeatsRemaining == -1 && myConfigs[index].numRepeats != 0) {
		repeatsRemaining = myConfigs[index].numRepeats;
	}
	
	
	DebugPrint("config type: ");
	DebugPrintln(myConfigs[index].type);
	if (myConfigs[index].type & _BV(CONFIG_PAUSE)) {
	    InitTimelapsePauseState();
	}
	
	if (myConfigs[index].fstopSinAmplitude != 0) {
		uint8_t sinSetting = myConfigs[index].type;// & CONFIG_SIN_MASK;
		sinPeriodMin = myConfigs[index].interval * myConfigs[index].shots / 60 / 1000;
		switch (sinSetting) {
	    case CONFIG_SIN_P1:
		    fstopSinPhase = 0;
			break;
	    case CONFIG_SIN_P2:
		    fstopSinPhase = M_PI_2;
			break;
	    case CONFIG_SIN_P3:
		    fstopSinPhase = M_PI;
			break;
	    case CONFIG_SIN_P4:
		    fstopSinPhase = -M_PI_2;
			break;
		}
	}
	
	expRefTime = nextPhotoTime;
}

void InitTimelapsePauseState() {
	currentState = STATE_TIMELAPSE_PAUSE;
	DebugPrintln("Timelapse Paused");
	SetLEDCycle(LED_CYCLE_TIMELAPSE_PAUSE);
}

void TimelapseResume() {
	DebugPrintln("Resume Timelapse");
	if (millis() > nextPhotoTime) {
		nextPhotoTime = millis();
		// TODO we should to a time adjustment to our exposure reference time
	}
	SetLEDCycle(LED_CYCLE_OFF);
	currentState = STATE_TIMELAPSE_WAITING;
}

void InitManualTimelapseState() {
	DebugPrintln("Init manual timelapse");
	
	// Technically these are output pins, but we can the 20k pullup resistors are enough
	// to open our transistor and trigger the shutter. By using the pullups, we can go to low
	// power mode
    pinMode(shutterPin, INPUT);
    digitalWrite(shutterPin, LOW);
    pinMode(focusPin, INPUT);
    digitalWrite(focusPin, LOW);
	
	currentState = STATE_TIMELAPSE_MANUAL;
}

void InitTimelapseState() {
	pinMode(flashSensePin, INPUT);
	digitalWrite(flashSensePin, LOW);
	
	// flash sense is connected to flash feedback when there is no switch plugged in
	digitalWrite(flashFeedbackPin, HIGH);

	// Technically these are output pins, but we can the 20k pullup resistors are enough
	// to open our transistor and trigger the shutter. By using the pullups, we can go to low
	// power mode
    pinMode(shutterPin, INPUT);
    digitalWrite(shutterPin, LOW);
    pinMode(focusPin, INPUT);
    digitalWrite(focusPin, LOW);
	
    //SetLED(GREEN);
    currentState = STATE_TIMELAPSE_WAITING;
    DebugPrintln("Enter Timelapse");
	
	byte flashSense = digitalRead(flashSensePin);
	if (flashSense == HIGH) {
		DebugPrintln("No PC sync cable");
		useFlashFeeback = 0;
	} else {
		DebugPrintln("PC sync cable attached");
		useFlashFeeback = 1;
	}
	
	digitalWrite(flashFeedbackPin, LOW);
	
	//byte micShorted = digitalRead(micShortedPin);
	
	//if (micShorted == HIGH) {
	    //DebugPrintln("Mic not shorted");	
    //} else {
        //DebugPrintln("Mic Shorted");	
	//}		
	
	//digitalWrite(micShortedPin, LOW);
	
	buttonClicked = false;
	buttonHeld = false;
	configIndex = 0;
	repeatsRemaining = -1;
	
	nextPhotoTime = millis();
	SetConfig(configIndex);
}


void TimelapseSettingComplete() {
	
	if (myConfigs[configIndex].numRepeats != 0 && repeatsRemaining > 0) {
		repeatsRemaining--;
	    configIndex = myConfigs[configIndex].repeatIndex;
		DebugPrintln("Repeat!");
		SetConfig(configIndex);
	} else {
	    configIndex++;
        if (configIndex < numConfigs) {
		    SetConfig(configIndex);
	    } else {
			Serial.println("timelapse complete");
			InitIdleState();
			SetLEDCycle(LED_CYCLE_TIMELAPSE_COMPLETE);
	    }
	}
}

int32_t CalcExpTime(uint32_t startTime, uint32_t endTime, float fstopSinAmplitude,
                     float fstopchange, float fstopoffset)
{
	int32_t exposureLength = 0;
	float timeDiff = endTime - startTime;
	float timeDiffMin = timeDiff / 1000 / 60;
	
	double fstopExpFactor = 0;
	
	if (fstopSinAmplitude != 0) {
	
	    fstopExpFactor += fstopSinAmplitude * sin(M_PI_2 * timeDiffMin / sinPeriodMin + fstopSinPhase);
	}

    if (fstopchange != 0) {
		fstopExpFactor += fstopchange * timeDiffMin;
	}

    fstopExpFactor += fstopoffset;
	fstopExpFactor += exposurePressChange;
	
	exposureLength = pow(2, fstopExpFactor) * 1000;
	exposureLength -= STATIC_SHUTTER_LAG;
	
    //DebugPrint("CalcExpTime timeDiffMin: ");
	//DebugPrintln(timeDiffMin);
//
    //DebugPrint("CalcExpTime fstop: ");
	//DebugPrintln(fstopExpFactor);
	//
	//DebugPrint("CalcExpTime exposureLength: ");
	//DebugPrintln(exposureLength);
	
	return exposureLength;
}

void ProcessTimelapseWaiting() {
	
	if (buttonHeld == true) {
		DebugPrintln(F("Abandon Timelapse"));
        SetLEDCycle(LED_CYCLE_TIMELAPSE_ABANDON);
		InitTransmitState();
		buttonHeld = false;
		return;
	}
	
	if (buttonClicked == true) {
		// TODO we should only advance if specified in the config
		buttonClicked = false;
		DebugPrintln(F("Button Click"));
        //TimelapseSettingComplete();
		
		if (myConfigs[configIndex].fstopChangeOnPress != 0) {
			int32_t tempExposure;
			
		    tempExposure = CalcExpTime(expRefTime, millis(), myConfigs[configIndex].fstopSinAmplitude,
		            myConfigs[configIndex].exposureFstopChangePerMin,
					myConfigs[configIndex].exposureOffset + myConfigs[configIndex].fstopChangeOnPress);
			
			// Check exposure bounds before setting
			if (tempExposure < MINIMUM_PHOTO_LENGTH) {
				DebugPrintln(F("Exposure too low"));
				SetLEDCycle(LED_CYCLE_STOP_CHANGE_FAILURE);
			} else if (tempExposure > (myConfigs[configIndex].interval - BUFFER_RECOVER_TIME)) {
				DebugPrintln(F("Exposure too high"));
				SetLEDCycle(LED_CYCLE_STOP_CHANGE_FAILURE);
			} else {
				// Safe to change our exposure
				exposurePressChange += myConfigs[configIndex].fstopChangeOnPress;
				int32_t newOffset = myConfigs[configIndex].exposureOffset + exposurePressChange;
				DebugPrint(F("tempExposure: "));
				DebugPrintln(tempExposure);
                DebugPrint(F("newOffset: "));
				DebugPrintln(newOffset);
				InitTimelapsePauseState();
			}
		} else {
			SetLEDCycle(LED_CYCLE_BAD_CLICK);
		}
	}
	
    if (millis() >= nextPhotoTime) {
		
		SetLEDCycle(LED_CYCLE_TAKE_PICTURE);
		
        exposureLength = CalcExpTime(expRefTime, millis(), myConfigs[configIndex].fstopSinAmplitude,
		    myConfigs[configIndex].exposureFstopChangePerMin, myConfigs[configIndex].exposureOffset
			+ (HDRShotNumber * myConfigs[configIndex].fstopIncreasePerHDRShot));
		
		// Detect if there is a collision soon
        // TODO figure out the UI interactions and adjust window vs warning time
		// TODO check for HDR as well
		if (myConfigs[configIndex].exposureFstopChangePerMin != 0) {
		
		    int32_t tempExposure = CalcExpTime(expRefTime, millis() + EXPOSURE_WARNING_TIME_OFFSET, myConfigs[configIndex].fstopSinAmplitude,
		            myConfigs[configIndex].exposureFstopChangePerMin, myConfigs[configIndex].exposureOffset);
			
			//DebugPrint("temp tempFstopExpFactor: ");
			//DebugPrintln((int)tempFstopExpFactor);
			//DebugPrint("temp tempExposure: ");
			//DebugPrintln(tempExposure);
			
			if (tempExposure < 50) {
				DebugPrintln("Warning: impending low exposure collision");
				SetLEDCycle(LED_CYCLE_TIMELAPSE_CHANGE_READY);
			} else if (tempExposure > (((int32_t) myConfigs[configIndex].interval) - BUFFER_RECOVER_TIME) ){
				DebugPrint("Warning: impending high exposure collision: ");
				DebugPrintln(tempExposure);
				DebugPrintln((((int32_t) myConfigs[configIndex].interval) - BUFFER_RECOVER_TIME));
				SetLEDCycle(LED_CYCLE_TIMELAPSE_CHANGE_READY);
			}
		}
		
		DebugPrint(F("Exp length "));
		DebugPrintln(exposureLength);
		
		if (exposureLength > (myConfigs[configIndex].interval - BUFFER_RECOVER_TIME)) {
			DebugPrintln(F("Exposure length/interval collision"));
			SetLEDCycle(LED_CYCLE_TIMELAPSE_EXP_COLLISION);
			exposureLength = myConfigs[configIndex].interval - BUFFER_RECOVER_TIME;
		}
		
		if (exposureLength < MINIMUM_PHOTO_LENGTH) {
			DebugPrintln(F("Exposure length less than minimum"));
			SetLEDCycle(LED_CYCLE_TIMELAPSE_EXP_COLLISION);
			exposureLength = MINIMUM_PHOTO_LENGTH;
		}
		
		if (myConfigs[configIndex].numHDRShots > 0) {
			if (HDRShotNumber == 0) {
			    nextHDRBracketTime += currentInterval;
			    currentInterval += myConfigs[configIndex].intervalDelta;
			}
			
			// Bracket is complete
			if (HDRShotNumber == myConfigs[configIndex].numHDRShots) {
				nextPhotoTime = nextHDRBracketTime;
				shotsRemaining--;
				HDRShotNumber = 0;
				DebugPrintln(F("Bracket Complete"));
			} else {
				HDRShotNumber++;
				// TODO should we set the next photo time after the shot is complete?
				// Consistency in HDR shot time vs how quick we can shoot
				//nextPhotoTime += exposureLength + HDR_INTERVAL;
			}
			// For flash timeout, this will actually be updated after exposure is complete
			nextPhotoTime = millis() + HDR_INTERVAL + exposureLength; 
		} else {
			nextPhotoTime += currentInterval;
			currentInterval += myConfigs[configIndex].intervalDelta;
			shotsRemaining--;
		}
					
		StartExposure();
		
		// Set our pullup resistor for flash feedback
		digitalWrite(flashFeedbackPin, HIGH);
		
		if (useFlashFeeback) {
            currentState = STATE_TIMELAPSE_WAITING_FLASH;
		} else {
			currentState = STATE_TIMELAPSE_EXPOSING;
			shutterOffTime = millis() + exposureLength;
		}						
    }
}

void ProcessTimeLapseWaitingFlash() {
    if (digitalRead(flashFeedbackPin) == LOW) {
        shutterOffTime = millis() + exposureLength;
        currentState = STATE_TIMELAPSE_EXPOSING;
		digitalWrite(flashFeedbackPin, LOW);
    } else {
		if (millis() >= nextPhotoTime) {
            digitalWrite(shutterPin, LOW);
            digitalWrite(focusPin, LOW);
			digitalWrite(flashFeedbackPin, LOW);
			DebugPrintln(F("Flash timeout"));
			InitIdleState(); // TODO, get an error here
		}
	}
}

void ProcessTimeLapseExposing() {
    if (millis() >= shutterOffTime) {
		EndExposure();
		//Serial.println("shot complete");
        currentState = STATE_TIMELAPSE_WAITING;
		if (HDRShotNumber != 0) {
			nextPhotoTime = millis() + HDR_INTERVAL;
		}
		if (shotsRemaining <= 0) {
			TimelapseSettingComplete();
		}	
    }
}