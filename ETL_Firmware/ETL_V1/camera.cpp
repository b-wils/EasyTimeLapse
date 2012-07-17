/*
 * camera.cpp
 *
 * Created: 7/11/2012 1:56:03 PM
 *  Author: brandonw
 */ 

#include "camera.h"
#include "Utils.h"

double fstopSinPhase;
double fstopSinPeriodMin;

int32_t shotsRemaining;
uint32_t currentInterval;
uint32_t nextHDRBracketTime;
uint32_t shutterOffTime;
uint32_t expRefTime;

uint8_t configIndex = 0;
int16_t repeatsRemaining;
uint32_t exposureLength = 0;
uint8_t useFlashFeeback = 0;
uint8_t HDRShotNumber;

uint32_t nextPhotoTime;

extern uint8_t currentState;

extern byte buttonClicked;
extern byte buttonHeld;
extern SectionConfig myConfigs[MAX_CONFIGS];
extern uint8_t numConfigs;

void SetConfig(int index) {

	Serial.print("set config index ");
	Serial.println(index);
    shotsRemaining = myConfigs[index].shots;
    currentInterval = myConfigs[index].interval;
	HDRShotNumber = 0;
	//
		//Serial.print("use flash: ");
		//Serial.println(useFlashFeeback, HEX);
	
	if (repeatsRemaining == -1 && myConfigs[index].numRepeats != 0) {
		repeatsRemaining = myConfigs[index].numRepeats;
	}
	
	
	Serial.print("config type: ");
	Serial.println(myConfigs[index].type);
	if (myConfigs[index].type & _BV(CONFIG_PAUSE)) {
	    InitTimelapsePauseState();
	}
	
	if (myConfigs[index].fstopSinAmplitude != 0) {
		uint8_t sinSetting = myConfigs[index].type;// & CONFIG_SIN_MASK;
		fstopSinPeriodMin = myConfigs[index].interval * myConfigs[index].shots / 60 / 1000;
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
	DebugPrint("Timelapse Paused");
	SetLEDCycle(LED_CYCLE_TIMELAPSE_PAUSE);
}

void TimelapseResume() {
	DebugPrint("Resume Timelapse");
	if (millis() > nextPhotoTime) {
		nextPhotoTime = millis();
		// TODO we should to a time adjustment to our exposure reference time
	}
	SetLEDCycle(LED_CYCLE_OFF);
	currentState = STATE_TIMELAPSE_WAITING;
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
    DebugPrint("Enter Timelapse");
	
	useFlashFeeback = 0;
	
	byte flashSense = digitalRead(flashSensePin);
	if (flashSense == HIGH) {
		Serial.println("No PC sync cable");
	} else {
		Serial.println("PC sync cable attached");
	}
	
	digitalWrite(flashFeedbackPin, LOW);
	
	//byte micShorted = digitalRead(micShortedPin);
	
	//if (micShorted == HIGH) {
	    //DebugPrint("Mic not shorted");	
    //} else {
        //DebugPrint("Mic Shorted");	
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
		DebugPrint("Repeat!");
		SetConfig(configIndex);
	} else {
	    configIndex++;
        if (configIndex < numConfigs) {
		    SetConfig(configIndex);
	    } else {
			SetLEDCycle(LED_CYCLE_TIMELAPSE_COMPLETE);
            InitIdleState();
	    }
	}
}

uint32_t CalcExpTime(uint32_t startTime, uint32_t endTime, float fstopSinAmplitude,
                     float fstopchange, float fstopoffset)
{
	uint32_t exposureLength = 0;
	float timeDiff = endTime - startTime;
	float timeDiffMin = timeDiff / 1000 / 60;
	
	double fstopExpFactor = 0;
	
	if (fstopSinAmplitude != 0) {
	
	    fstopExpFactor += fstopSinAmplitude * sin(M_PI_2 * timeDiffMin / fstopSinPeriodMin + fstopSinPhase);
	}

    if (fstopchange != 0) {
		fstopExpFactor += fstopchange * timeDiffMin;
	}

    fstopExpFactor += fstopoffset;
	
	exposureLength = pow(2, fstopExpFactor) * 1000;
	exposureLength -= STATIC_SHUTTER_LAG;
	
    //Serial.print("CalcExpTime timeDiffMin: ");
	//Serial.println(timeDiffMin);
//
    //Serial.print("CalcExpTime fstop: ");
	//Serial.println(fstopExpFactor);
	//
	//Serial.print("CalcExpTime exposureLength: ");
	//Serial.println(exposureLength);
	
	return exposureLength;
}

void ProcessTimelapseWaiting() {
	
	if (buttonHeld == true) {
		DebugPrint("Abandon Timelapse");
        SetLEDCycle(LED_CYCLE_TIMELAPSE_ABANDON);
		InitIdleState();
	}
	
    if (shotsRemaining <= 0) {
		TimelapseSettingComplete();
    }
	
	if (buttonClicked == true) {
		// TODO we should only advance if specified in the config
		buttonClicked = false;
		DebugPrint("Button Click");
        //TimelapseSettingComplete();
		
		if (myConfigs[configIndex].fstopChangeOnPress != 0) {
			uint32_t tempExposure;
			
		    tempExposure = CalcExpTime(expRefTime, millis(), myConfigs[configIndex].fstopSinAmplitude,
		            myConfigs[configIndex].exposureFstopChangePerMin,
					myConfigs[configIndex].exposureOffset + myConfigs[configIndex].fstopChangeOnPress);
			
			// Check exposure bounds before setting
			if (tempExposure < 20) {
				DebugPrint("Exposure too low");
			} else if (tempExposure > (myConfigs[configIndex].interval - BUFFER_RECOVER_TIME)) {
				DebugPrint("Exposure too high");
			} else {
				// TODO track exposure offset in a local variable, not from config
				myConfigs[configIndex].exposureOffset += myConfigs[configIndex].fstopChangeOnPress;
				int32_t newOffset = myConfigs[configIndex].exposureOffset;
				Serial.print("tempExposure: ");
				Serial.println(tempExposure);
                Serial.print("newOffset: ");
				Serial.println(newOffset);
			}
			
		}
	}
	
    if (millis() >= nextPhotoTime) {
		
        exposureLength = CalcExpTime(expRefTime, millis(), myConfigs[configIndex].fstopSinAmplitude,
		    myConfigs[configIndex].exposureFstopChangePerMin, myConfigs[configIndex].exposureOffset);
		
		if (exposureLength > (myConfigs[configIndex].interval - BUFFER_RECOVER_TIME)) {
			DebugPrint("Exposure length/interval collision");
		}
		
		if (exposureLength < MINIMUM_PHOTO_LENGTH) {
			DebugPrint("Exposure length less than minimum");
		}
		
		// Detect if there is a collision soon
        // TODO figure out the UI interactions and adjust window vs warning time
		// TODO check for HDR as well
		if (myConfigs[configIndex].exposureFstopChangePerMin != 0) {
		
		    uint32_t tempExposure = CalcExpTime(expRefTime, millis() + EXPOSURE_WARNING_TIME_OFFSET, myConfigs[configIndex].fstopSinAmplitude,
		            myConfigs[configIndex].exposureFstopChangePerMin, myConfigs[configIndex].exposureOffset);
			
			//Serial.print("temp tempFstopExpFactor: ");
			//Serial.println((int)tempFstopExpFactor);
			//Serial.print("temp tempExposure: ");
			//Serial.println(tempExposure);
			
			if (tempExposure < 50) {
				DebugPrint("Warning: impending low exposure collision");
			} else if (tempExposure > (myConfigs[configIndex].interval - BUFFER_RECOVER_TIME) ){
				DebugPrint("Warning: impending high exposure collision");
			}
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
				DebugPrint("Bracket Complete");
			} else {
				HDRShotNumber++;
				// TODO should we set the next photo time after the shot is complete?
				// Consistency in HDR shot time vs how quick we can shoot
				nextPhotoTime += exposureLength + HDR_INTERVAL;
			}
		} else {
			nextPhotoTime += currentInterval;
			currentInterval += myConfigs[configIndex].intervalDelta;
			shotsRemaining--;
		}
					
		Serial.print("Exp length ");
		Serial.println(exposureLength);
        digitalWrite(focusPin, HIGH);
        digitalWrite(shutterPin, HIGH);
        SetLEDCycle(LED_CYCLE_TAKE_PICTURE);
		
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
			DebugPrint("Flash timeout");
			digitalWrite(flashFeedbackPin, LOW);
			InitIdleState(); // TODO, get an error here
		}
	}
}

void ProcessTimeLapseExposing() {
    if (millis() >= shutterOffTime) {
        SetLED(OFF);
        digitalWrite(shutterPin, LOW);
        digitalWrite(focusPin, LOW);
        currentState = STATE_TIMELAPSE_WAITING;
    }
}