/*
 * ETL_V1.cpp
 *
 * Created: 3/29/2012 11:34:34 AM
 *  Author: brandonw
 */ 

#include <avr/io.h>
#include "Arduino/Arduino.h"
#include "Arduino/HardwareSerial.h"
#include "SoftModem.h"
#include "Utils.h"
#include "Common.h"
#include "ETL_V1.h"
#include "crc.h"

SoftModem modem;
int lastButtonState = HIGH;
int buttonState = HIGH;

int cableSenseState = LOW;
int lastCableSenseState = LOW;
uint32_t lastCableDebounceTime;

uint32_t lastDebounceTime;
uint32_t buttonPressTime;

uint32_t nextLedTime = 0;
int8_t ledCycleIndex = 0;
LedCycle currentLedCycle = LED_CYCLE_OFF;


uint8_t currentState = 0;

int32_t shotsRemaining;
uint32_t currentInterval;
uint32_t nextPhotoTime;
uint32_t nextHDRBracketTime;
uint32_t shutterOffTime;
uint32_t expRefTime;
byte buttonClicked;
byte buttonHeld;

uint16_t readPointer;
uint8_t configIndex = 0;
uint8_t numConfigs;
SectionConfig myConfigs[MAX_CONFIGS];
int16_t repeatsRemaining;
uint8_t HDRShotNumber;

uint32_t exposureLength = 0;

uint32_t printTimer = 0;

//ETlModemPacket modemPacket;
size_t modemPacketIndex = 0;
uint8_t bytesRead = 0;

uint16_t validConfigs;

TransmitState tState;

double fstopSinPhase;
double fstopSinPeriodMin;

crc_t recvCrc;
SectionConfig recvConfig;
uint8_t recvCommand;
uint8_t recvNumShots;
uint8_t configPointer;

void populateConfigs() {
    myConfigs[0].type = CONFIG_SIN_P4;
    myConfigs[0].repeatIndex = 0;
    myConfigs[0].numRepeats = 0;
    myConfigs[0].shots = 50;
    myConfigs[0].interval = 1200;
    myConfigs[0].intervalDelta = 0;
    //myConfigs[0].exposureOffset = -2.841463415;
	myConfigs[0].exposureOffset = -4.5;
    myConfigs[0].exposureFstopChangePerMin = 0;
	myConfigs[0].fstopSinAmplitude = 0.158536585;
    myConfigs[0].fstopIncreasePerHDRShot = 0;
    myConfigs[0].numHDRShots = 0;
	myConfigs[0].fstopChangeOnPress = 0;
	
    myConfigs[1].type = 0;
    myConfigs[1].repeatIndex = 0;
    myConfigs[1].numRepeats = 0;
    myConfigs[1].shots = 400;
    myConfigs[1].interval = 12000;
    myConfigs[1].intervalDelta = 0;
    myConfigs[1].exposureOffset = -2.841463415;
    myConfigs[1].exposureFstopChangePerMin = 0.158536585;
	myConfigs[1].fstopSinAmplitude = 0;
    myConfigs[1].fstopIncreasePerHDRShot = 0;
    myConfigs[1].numHDRShots = 0;
	myConfigs[1].fstopChangeOnPress = -4;
	
    myConfigs[2].type = CONFIG_SIN_P1;
    myConfigs[2].repeatIndex = 0;
    myConfigs[2].numRepeats = 0;
    myConfigs[2].shots = 50;
    myConfigs[2].interval = 12000;
    myConfigs[2].intervalDelta = 0;
    myConfigs[2].exposureOffset = 2.841463415;
    myConfigs[2].exposureFstopChangePerMin = 0;
	myConfigs[2].fstopSinAmplitude = 0.158536585;
    myConfigs[2].fstopIncreasePerHDRShot = 0;
    myConfigs[2].numHDRShots = 0;
	myConfigs[2].fstopChangeOnPress = 0;
	//
    //myConfigs[3].type = 0;
    //myConfigs[3].repeatIndex = 0; 
    //myConfigs[3].numRepeats = 0;
    //myConfigs[3].shots = 100;
    //myConfigs[3].interval = 12000;
    //myConfigs[3].intervalDelta = 0;
    //myConfigs[3].exposureOffset = 2;
    //myConfigs[3].exposureFstopChangePerMin = 0;
	//myConfigs[3].fstopSinAmplitude = 0;
    //myConfigs[3].fstopIncreasePerHDRShot = 0;
    //myConfigs[3].numHDRShots = 0;
	//myConfigs[3].fstopChangeOnPress = 0;
	
	numConfigs = 2;
}

void printBatteryLevel() {
	int adcReading = analogRead(batteryMonitorPin);
	int batLevel = (adcReading - ADC_EMPTY_VOLTAGE)/(ADC_FULL_VOLTAGE - ADC_EMPTY_VOLTAGE);
	
	Serial.print("Min BAT ADC: ");
	Serial.println(ADC_EMPTY_VOLTAGE);
	Serial.print("Max BAT ADC: ");
	Serial.println(ADC_FULL_VOLTAGE);
	Serial.print("Current: ");
	Serial.println(adcReading);
    Serial.print("Percent: ");
	delay(10);
}

int main(void)
{
	init();
	setup();

    while(1)
    {
		loop();
		if (serialEventRun) serialEventRun();
	}		
}

void SetLEDCycle(LedCycle cycle) {
	SetLED(OFF); // OFF cycle won't get processed (since positions = 0) so set it here
	currentLedCycle = cycle;
	ledCycleIndex = -1; // so we can increment at start of our processing
	nextLedTime = millis();
}

// Needed for external interrupt waking from power down
void ButtonChange(void) {}
void CableSenseChange(void) {}

void InitIdleState() {
    currentState = STATE_IDLE;
//	SetLEDCycle(LED_CYCLE_IDLE);
    //LedCycle tempCycle = LED_CYCLE_OFF;
    SetLEDCycle(LED_CYCLE_OFF);
	printBatteryLevel();
    DebugPrint("Enter Idle");
}

void InitTimelapsePauseState() {
	currentState = STATE_TIMELAPSE_PAUSE;
	DebugPrint("Timelapse Paused");
	SetLEDCycle(LED_CYCLE_TIMELAPSE_PAUSE);
}

void SetConfig(int index) {
	Serial.print("set config index ");
	Serial.println(index);
    shotsRemaining = myConfigs[index].shots;
    currentInterval = myConfigs[index].interval;
	HDRShotNumber = 0;
	
	if (repeatsRemaining == -1 && myConfigs[index].numRepeats != 0) {
		repeatsRemaining = myConfigs[index].numRepeats;
	}
	
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
    SetLED(GREEN);
    currentState = STATE_TIMELAPSE_WAITING;
    DebugPrint("Enter Timelapse");

    pinMode(micShortedPin, INPUT);
	digitalWrite(micShortedPin, HIGH);
	
	byte flashSense = digitalRead(flashSensePin);
	if (flashSense == HIGH) {
		Serial.println("No PC sync cable");
	} else {
		Serial.println("PC sync cable attached");
	}
	
	byte micShorted = digitalRead(micShortedPin);
	
	if (micShorted == HIGH) {
	    DebugPrint("Mic not shorted");	
    } else {
        DebugPrint("Mic Shorted");	
	}		
	
	digitalWrite(micShortedPin, LOW);
	
	buttonClicked = false;
	buttonHeld = false;
	configIndex = 0;
	repeatsRemaining = -1;
	
	nextPhotoTime = millis();
	SetConfig(configIndex);
}

byte printval;

void InitTransmitState() {
    //SetLED(YELLOW);
    currentState = STATE_TRANSMIT;
    DebugPrint("Enter Transmit");
	
	// This is our unused audio channel. This must go to ground otherwise something
	// weird happens electrically. We could probably use the P/U resistor too.
	pinMode(flashPin, OUTPUT);
	digitalWrite(flashPin, HIGH);
	
    modemPacketIndex = 1;
	bytesRead = 0;
	modem.begin();
	printTimer = millis();
	validConfigs = 0;
	printval = 'A';
	tState = TSTATE_CONFIG;
	
	//
	// Send our begin packet
	//
	
	CommandPacket startPacket;
	startPacket.command = IOS_COMMAND_REQUESTPACKETID;
	startPacket.data = 0x1;

    startPacket.Crc = crc_init();
	startPacket.Crc = crc_update(startPacket.Crc, &startPacket.command, 2);
	startPacket.Crc = crc_finalize(startPacket.Crc);
	
	modem.writeBytes((uint8_t *) &startPacket, sizeof(startPacket));
}

void LeaveTransmitState() {
	modem.end();
	InitIdleState();
}

void setup() {
	
	DebugInit();
	
	pinMode(buttonPin, INPUT);
	digitalWrite(buttonPin, HIGH);
    
	pinMode(cableSensePin, INPUT);
	
    pinMode(shutterPin, OUTPUT);
    digitalWrite(shutterPin, LOW);
    pinMode(focusPin, OUTPUT);
    digitalWrite(focusPin, LOW);
    
    pinMode(flashPin, INPUT);
    digitalWrite(flashPin, HIGH);
    
	pinMode(FSK_INPUT_FILTER_ENABLE_PIN, OUTPUT);
	digitalWrite(FSK_INPUT_FILTER_ENABLE_PIN, HIGH);
	
    delay(20);
	
	nextLedTime = millis();
    
	populateConfigs();
	
	analogReference(INTERNAL);
	
    InitIdleState();
	
	SetLEDCycle(LED_CYCLE_START);
	
	printTimer = millis();
}

void ProcessIdle() {

    // By default power down
    set_sleep_mode(SLEEP_MODE_PWR_DOWN);

    switch (currentState) {
		case STATE_TIMELAPSE_WAITING_FLASH:
		case STATE_TIMELAPSE_EXPOSING:
		case STATE_TRANSMIT:
		    // Dont Idle in these states
		    return;
			break;
        case STATE_TIMELAPSE_WAITING:
		    if (millis() > (nextPhotoTime - (MILLIS_PER_OVERFLOW * 2))) {
				return;
			} else {
				set_sleep_mode(SLEEP_MODE_PWR_SAVE);
			}
			break;
        case STATE_TIMELAPSE_PAUSE:
		    // We will check LED state before actually going to idle here
		    set_sleep_mode(SLEEP_MODE_PWR_SAVE);
	}

    if (currentLedCycle.NumLedPositions != 0) {
		
		if (AreColorsEqual(currentLedCycle.ColorCycle[ledCycleIndex],OFF)) {
			if (millis() > (nextLedTime - (MILLIS_PER_OVERFLOW * 2))) {
			//	DebugPrint("Led Soon");
				return;
			} else {
			    set_sleep_mode(SLEEP_MODE_PWR_SAVE);
			}					
		} else {
			//DebugPrint("Led ON");
			return;
		}
	}

    if (lastButtonState == LOW || buttonState == LOW) {
		// Better way - Attach interrupt, disable interrupts, check state
		return;
	}

    if (lastCableSenseState != cableSenseState) {
		// Better way - Attach interrupt, disable interrupts, check state
		return;
	}

    // If we've made it this far, we can idle!
    attachInterrupt(0,ButtonChange,CHANGE);
    //attachInterrupt(1, CableSenseChange, CHANGE);
    sleep_enable();
    sleep_cpu();
    sleep_disable();
    //detachInterrupt(1);
    detachInterrupt(0);
}

void ProcessButton() {
    
    // read the state of the switch into a local variable:
    int reading = digitalRead(buttonPin);

    // check to see if you just pressed the button 
    // (i.e. the input went from LOW to HIGH),  and you've waited 
    // long enough since the last press to ignore any noise:  

    // If the switch changed, due to noise or pressing:
    if (reading != lastButtonState) {
        // reset the debouncing timer
        lastDebounceTime = millis();
    } 
  
    if ((millis() - lastDebounceTime) > BUTTON_DEBOUNCE_PERIOD) {
        // whatever the reading is at, it's been there for longer
        // than the debounce delay, so take it as the actual current state:
    
        if (buttonState != reading) {
            buttonState = reading;
    
            if (buttonState == HIGH) {
                switch (currentState) {
		            case STATE_TIMELAPSE_WAITING:
					case STATE_TIMELAPSE_WAITING_FLASH:
					case STATE_TIMELAPSE_EXPOSING:
					    if (millis() - buttonPressTime > BUTTON_STOP_TIMELAPSE_PERIOD) {
						    buttonHeld = true;
						} else {							
			                buttonClicked = true;
						}							
			            break;
				    case STATE_TIMELAPSE_PAUSE:
					    TimelapseResume();
						break;
		            case STATE_IDLE:
                        if (millis() - buttonPressTime > BUTTON_TRANSMIT_PERIOD) {
			                InitTransmitState();
                        } else {
							// Send to idle state after we finish the current exposure
                            InitTimelapseState();
                        }                                                        
			            break;
                    case STATE_TRANSMIT:
                        LeaveTransmitState();
                        break;
	            }
            } else {
                buttonPressTime = millis();
            }
        }    
    }  

    // save the reading.  Next time through the loop,
    // it'll be the lastButtonState:
    lastButtonState = reading;
}

void ProcessCableSense() {
    
    // read the state of the switch into a local variable:
    int reading = digitalRead(cableSensePin);

    // check to see if you just pressed the button 
    // (i.e. the input went from LOW to HIGH),  and you've waited 
    // long enough since the last press to ignore any noise:  

    // If the switch changed, due to noise or pressing:
    if (reading != lastCableSenseState) {
        // reset the debouncing timer
        lastCableDebounceTime = millis();
    } 
  
    if ((millis() - lastCableDebounceTime) > CABLE_DEBOUNCE_PERIOD) {
        if (cableSenseState != reading) {
		    cableSenseState = reading;	
			if (cableSenseState == HIGH) {
				DebugPrint("Cable Plugged!");
			} else {
				DebugPrint("Cable Unplugged");
			}
		}			
	}

    lastCableSenseState = reading;
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
	    double phase = -M_PI_2; // we start at negative amp
	    double period = (M_PI_2 / 1); // 1 minute phase
	
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
        SetLED(WHITE);
        currentState = STATE_TIMELAPSE_WAITING_FLASH;
    }
    
}

void ProcessTimeLapseWaitingFlash() {
    if (digitalRead(flashPin) == LOW) {
        shutterOffTime = millis() + exposureLength;
        currentState = STATE_TIMELAPSE_EXPOSING;
    } else {
		if (millis() >= nextPhotoTime) {
            digitalWrite(shutterPin, LOW);
            digitalWrite(focusPin, LOW);
			DebugPrint("Flash timeout");
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

void ProcessTransmitState() {
    
	CommandPacket startPacket;
	
	while(modem.available()) {
        byte myByte = modem.read();

		byte* dataPointer;
		//Serial.print("byte:");
		//Serial.println(myByte, HEX);
		
		if (bytesRead <= 1) {
			dataPointer = (byte *) &recvCrc;
			dataPointer += bytesRead;
			dataPointer[0] = myByte;
		    bytesRead++;
		} else {
			
			if (tState == TSTATE_CONFIG) {
				
				if (bytesRead == 2) {
					dataPointer = (byte *) &recvCommand;
				} else if (bytesRead == 3) {
					dataPointer = (byte*) &recvNumShots;
				} else {
					DebugPrint("TSTATE_CONFIG error");
				}
				
				dataPointer[0] = myByte;
				bytesRead++;
				
				if (bytesRead == 4) {
					bytesRead = 0;
					crc_t myCrc = crc_init();
		            myCrc = crc_update(myCrc, (byte*) &recvCommand, sizeof(uint8_t));
                    myCrc = crc_update(myCrc, (byte*) &recvNumShots, sizeof(uint8_t));
		            myCrc = crc_finalize(myCrc);
					
					Serial.print(" command: ");
					Serial.println(recvCommand, HEX);
					
					Serial.print(" data: ");
					Serial.println(recvNumShots, HEX);
					
					bool failCrc = false;
					
					if (random(2) == 0) {
						failCrc = true;
						Serial.println("force fail crc");
					}
					
			        if (myCrc != recvCrc || failCrc) {
				        DebugPrint("Crc mismatch!");
			            Serial.print(" recv_crc = ");
			            Serial.print(recvCrc, HEX);
                        Serial.print(" calc_Crc = ");
			            Serial.println(myCrc, HEX);
						Serial.println();
				        //SetLEDCycle(LED_CYCLE_CRC_ERROR);
						
						// Request the the pakcet again
						
						delay(1000);
						
                        startPacket.command = IOS_COMMAND_REQUESTPACKETID;
	                    startPacket.data = modemPacketIndex;

                        startPacket.Crc = crc_init();
	                    startPacket.Crc = crc_update(startPacket.Crc, &startPacket.command, 2);
	                    startPacket.Crc = crc_finalize(startPacket.Crc);
	
	                    modem.writeBytes((uint8_t *) &startPacket, sizeof(startPacket));
			        } else {
				        Serial.println("packet success");
						Serial.println();
						numConfigs = recvNumShots;
						configPointer = 0;
						validConfigs = 0;
						
						if (modemPacketIndex == recvNumShots) {
							modemPacketIndex++;
						}
						
						// need to make sure iphone is ready to receive again
						// this should be async
						// or ideally we will fix iphone so it can send receive simulteneously...
						delay(1000);
						
	                    startPacket.command = IOS_COMMAND_REQUESTPACKETID;
	                    startPacket.data = modemPacketIndex;

                        startPacket.Crc = crc_init();
	                    startPacket.Crc = crc_update(startPacket.Crc, &startPacket.command, 2);
	                    startPacket.Crc = crc_finalize(startPacket.Crc);
	
	                    modem.writeBytes((uint8_t *) &startPacket, sizeof(startPacket));
						
						//tState = TSTATE_SHOT_DATA;
					}						
				}
			} else if (tState == TSTATE_SHOT_DATA) {
				dataPointer = (byte *) &recvConfig;
			    dataPointer += bytesRead - 2;
				
		        dataPointer[0] = myByte;
		        bytesRead++;
				
		        if (bytesRead == sizeof(ETlModemPacket)) {
		            bytesRead = 0;
			        Serial.println("Packet Received!");
		            crc_t myCrc = crc_init();
		            myCrc = crc_update(myCrc, (byte*) &recvConfig, sizeof(SectionConfig));
		            myCrc = crc_finalize(myCrc);
			
			        PrintSectionConfig(recvConfig);
			
			        if (myCrc != recvCrc) {
				        DebugPrint("Crc mismatch!");
			            Serial.print(" recv_crc = ");
			            Serial.print(recvCrc, HEX);
                        Serial.print(" calc_Crc = ");
			            Serial.println(myCrc, HEX);
                        //PrintSectionConfig(modemPacket.SectConf);
			        } else {
				        Serial.println("Crc Match!");
						sbi(validConfigs, configPointer);
						memcpy(&myConfigs[configPointer], &recvConfig, sizeof(SectionConfig));
				        //PrintSectionConfig(modemPacket.SectConf);
			        }
			        //modem.printDebugInfo(false);
			        //modem.resetSignalCounts();
					configPointer++;
					if (configPointer >= numConfigs) {
					    // check to see if all configs are valid.
						uint16_t successMask = 0;
						for (int i = 0; i<numConfigs;i++) {
							successMask <<= 1;
							successMask += 1;
						}
						
						Serial.print("currentMask: ");
						Serial.println(validConfigs);
						Serial.print("successMask: ");
						Serial.println(successMask);
						if (successMask == validConfigs) {
							DebugPrint("Configs valid");
							SetLEDCycle(LED_CYCLE_CRC_SUCCESS);
						} else {
							DebugPrint("invalid config, retry");
							SetLEDCycle(LED_CYCLE_CRC_ERROR);
						}
						configPointer = 0;
					}						
		        }	
			} else {
				DebugPrint("Transmit State error");
			}

		}
		
		
    }
}

void ProcessLEDCycle() {
    if (currentLedCycle.NumLedPositions != 0) {
		if ( millis() > nextLedTime) {
			
            ledCycleIndex++;
			
			if (ledCycleIndex >= currentLedCycle.NumLedPositions) {
				if(currentLedCycle.RepeatCycle) {
				    ledCycleIndex = 0;
				} else {
					currentLedCycle = LED_CYCLE_OFF;
					SetLED(OFF);
				}					
			}
			
			SetLED(currentLedCycle.ColorCycle[ledCycleIndex]);
			
			nextLedTime += currentLedCycle.TimePerLed;
		}
	}	
}

void ProcessTransmitStateTest() {
	
	if (millis() > printTimer) {
	    //modem.write(printval);
		printval++;
		printTimer += 5000;
		
		modem.printDebugInfo(1);
	}
	
	while(modem.available()) {
        byte myByte = modem.read();
		
		Serial.print("byte:");
		Serial.println(myByte, HEX);
		
		//printTimer = millis() + 3000;
	}		
}

VariablePacket recvPacket;

void ProcessTransmitStateNew() {
	
	while(modem.available()) {
        ((char *) &recvPacket)[bytesRead] = modem.read();
        bytesRead++;
		
		if (bytesRead >= 16) {
			IPhonePacket sendPacket;
			
			memset(&sendPacket, 0, sizeof(IPhonePacket));
			
			bytesRead = 0;
		
            crc_t myCrc = crc_init();
		    myCrc = crc_update(myCrc, (byte*) &recvPacket, sizeof(recvPacket));
		    myCrc = crc_finalize(myCrc);
					
		    Serial.print(" command: ");
		    Serial.println(recvPacket.command, HEX);
					
		    Serial.print(" packetId: ");
		    Serial.println(recvPacket.packetId, HEX);
					
		    bool failCrc = false;
					
		    if (random(2) == 0) {
			    failCrc = true;
			    Serial.println("force fail crc");
		    }
					
		    if (myCrc != recvPacket.crc || failCrc) {
			    DebugPrint("Crc mismatch!");
			    Serial.print(" recv_crc = ");
			    Serial.print(recvCrc, HEX);
                Serial.print(" calc_Crc = ");
			    Serial.println(myCrc, HEX);
			    Serial.println();
			    //SetLEDCycle(LED_CYCLE_CRC_ERROR);
			    
				// TODO for now we always request a packet, need specifc retry code here
		    } else {
			    Serial.println("packet success");
			    Serial.println();
						
			    if (modemPacketIndex == recvPacket.packetId) {
				    modemPacketIndex++;
			    } else {
				    // TODO reqeust next packet
				}					
		    }
		
		
			// need to make sure iphone is ready to receive again
			// this should be async
			// or ideally we will fix iphone so it can send receive simulteneously...
		    delay(1000);
			
	        sendPacket.command = IOS_COMMAND_REQUESTPACKETID;
	        sendPacket.data = modemPacketIndex;

            sendPacket.crc = crc_init();
	        sendPacket.crc = crc_update(sendPacket.crc, &sendPacket.command, 2);
	        sendPacket.crc = crc_finalize(sendPacket.crc);
	
	        modem.writeBytes((uint8_t *) &sendPacket, sizeof(sendPacket));
        }							
	}
		
}

void loop() {
	
    ProcessButton();
 
    //ProcessCableSense();
    
    switch (currentState) {
        case STATE_TIMELAPSE_WAITING:
            ProcessTimelapseWaiting();
            break;
        case STATE_TIMELAPSE_WAITING_FLASH:
            ProcessTimeLapseWaitingFlash();
            break;
        case STATE_TIMELAPSE_EXPOSING:
            ProcessTimeLapseExposing();
            break;
        case STATE_TRANSMIT:
		    ProcessTransmitState();
			//ProcessTransmitStateTwoWay();
			break;
    }        
	
	ProcessLEDCycle();
}