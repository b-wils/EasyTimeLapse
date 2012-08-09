/*
 * ETL_V1.cpp
 *
 * Created: 3/29/2012 11:34:34 AM
 *  Author: brandonw
 */ 

#include <avr/io.h>
#include <avr/eeprom.h>
#include "Arduino/Arduino.h"
#include "Arduino/HardwareSerial.h"
#include "Utils.h"
#include "Common.h"
#include "ETL_V1.h"
#include "crc.h"
#include "communications.h"
#include "camera.h"

#define UINT8_T_MAX 255

// Visible to other classes
uint8_t numConfigs;
SectionConfig myConfigs[MAX_CONFIGS];
uint8_t configPointer;

int lastButtonState = HIGH;
int buttonState = HIGH;

uint32_t lastDebounceTime;
uint32_t buttonPressTime;

uint32_t nextLedTime = 0;
int8_t ledCycleIndex = 0;
LedCycle currentLedCycle = LED_CYCLE_OFF;

uint16_t readPointer;

uint8_t currentState = 0;

byte buttonClicked;
byte buttonHeld;

extern uint32_t printTimer;
uint32_t incrementTimer;
uint32_t incrementCount;

uint8_t timelapseValid;

BoolDeviceSettings boolDeviceSettings;

extern uint32_t bulbModeShutterLag;
extern uint16_t bufferRecoverTime;

void dumpToEEProm() {
	EEPromHeader header;
	uint16_t eepromPointer = 0;
	memset(&header, 0, sizeof(EEPromHeader));
	
	header.numConfigs = numConfigs;
	header.ledStrength = ledStrength;
	header.bulbShutterOffset = bulbModeShutterLag;
	header.bufferRecoverTime = bufferRecoverTime;
	header.boolDeviceSettings = boolDeviceSettings;

	if (header.numConfigs > MAX_CONFIGS) {
		DebugPrint(F("Invalid eeprom header num "));
		DebugPrintln(header.numConfigs);
		return;
	}
	
	eeprom_write_block(&header, (void *) eepromPointer, sizeof(EEPromHeader));
	
	eepromPointer += sizeof(EEPromHeader);
	
	eeprom_write_block(&myConfigs[0], (void*) eepromPointer, sizeof(SectionConfig) * numConfigs);
}

void initFromEEProm() {
	EEPromHeader header;
	uint16_t eepromPointer = 0;
	
	eeprom_read_block(&header, (void *) eepromPointer, sizeof(EEPromHeader));
	eepromPointer += sizeof(EEPromHeader);
	
	if (header.numConfigs == 0) {
		// Manual mode
		DebugPrintln(F("Init to manual mode"));
		currentState = STATE_TIMELAPSE_MANUAL;
	} else if (header.numConfigs == UINT8_T_MAX) {
		// unconfigured set defaults
		DebugPrintln(F("initialize eeprom"));
		currentState = STATE_TIMELAPSE_MANUAL;
		
		ledStrength = DEFAULT_LED_STRENGTH;
		numConfigs = 0;
		bulbModeShutterLag = DEFAULT_BULB_SHUTTER_OFFSET;
		bufferRecoverTime = DEFAULT_BUFFER_RECOVER_TIME;
		boolDeviceSettings.enableIdle = DEFAULT_ENABLE_IDLE;
		boolDeviceSettings.enableHighResShotTimer = DEFAULT_ENABLE_HIGH_RES_PHOTO_TIMER;
		
		dumpToEEProm();
		return;
	} else if (header.numConfigs > MAX_CONFIGS) {
		DebugPrint(F("Init Invalid eeprom header num "));
		DebugPrintln(header.numConfigs);
		currentState = STATE_TIMELAPSE_MANUAL;
		
		ledStrength = DEFAULT_LED_STRENGTH;
		numConfigs = 0;
		bulbModeShutterLag = DEFAULT_BULB_SHUTTER_OFFSET;
		bufferRecoverTime = DEFAULT_BUFFER_RECOVER_TIME;
		boolDeviceSettings.enableIdle = DEFAULT_ENABLE_IDLE;
		boolDeviceSettings.enableHighResShotTimer = DEFAULT_ENABLE_HIGH_RES_PHOTO_TIMER;

		dumpToEEProm();
		return;
	} else {
		DebugPrintln("valid num configs");
	}
	
	numConfigs = header.numConfigs;	
	ledStrength = header.ledStrength;
	bufferRecoverTime = header.bufferRecoverTime;
	bulbModeShutterLag = header.bulbShutterOffset;
	boolDeviceSettings.enableIdle = header.boolDeviceSettings.enableIdle;
	boolDeviceSettings.enableHighResShotTimer = header.boolDeviceSettings.enableHighResShotTimer;
	
	DebugPrintln(F("bulb buffer idle"));
	DebugPrintln(bulbModeShutterLag);
	DebugPrintln(bufferRecoverTime);
	
	eeprom_read_block(&myConfigs[0], (void *) eepromPointer, sizeof(SectionConfig) * numConfigs);
}

void populateConfigs() {
    //myConfigs[0].type = CONFIG_SIN_P4
	myConfigs[0].type = 0;
	sbi(myConfigs[0].type, CONFIG_PRESS_TO_ADVANCE);
    myConfigs[0].repeatIndex = 0;
    myConfigs[0].numRepeats = 0;
    myConfigs[0].shots = 200;
    myConfigs[0].interval = 1000;
    myConfigs[0].intervalDelta = 0;
	myConfigs[0].exposureOffset = -2;
    myConfigs[0].exposureFstopChangePerMin = 0;
	myConfigs[0].fstopSinAmplitude = 0;
    myConfigs[0].fstopIncreasePerHDRShot = 0;
    myConfigs[0].numHDRShots = 0;
	myConfigs[0].fstopChangeOnPress = 0;
	
    myConfigs[1].type = 0;
	sbi(myConfigs[1].type, CONFIG_PRESS_TO_DERAMP);
    myConfigs[1].repeatIndex = 0;
    myConfigs[1].numRepeats = 20;
    myConfigs[1].shots = 200;
    myConfigs[1].interval = 5000;
    myConfigs[1].intervalDelta = 100;
    myConfigs[1].exposureOffset = -2;
    myConfigs[1].exposureFstopChangePerMin = 0;
	myConfigs[1].fstopSinAmplitude = 0;
    myConfigs[1].fstopIncreasePerHDRShot = 0;
    myConfigs[1].numHDRShots = 0;
	myConfigs[1].fstopChangeOnPress = 0;
	
    //myConfigs[2].type = 0;
	//sbi(myConfigs[2].type, CONFIG_PRESS_TO_ADVANCE);
    //myConfigs[2].repeatIndex = 0;
    //myConfigs[2].numRepeats = 0;
    //myConfigs[2].shots = 20;
    //myConfigs[2].interval = 4000;
    //myConfigs[2].intervalDelta = 0;
    //myConfigs[2].exposureOffset = -2;
    //myConfigs[2].exposureFstopChangePerMin = 0;
	//myConfigs[2].fstopSinAmplitude = 0;
    //myConfigs[2].fstopIncreasePerHDRShot = 0;
    //myConfigs[2].numHDRShots = 0;
	//myConfigs[2].fstopChangeOnPress = 0;
	////
    //myConfigs[3].type = 0;
	//sbi(myConfigs[3].type, CONFIG_PRESS_TO_DERAMP);
    //myConfigs[3].repeatIndex = 0; 
    //myConfigs[3].numRepeats = 10;
    //myConfigs[3].shots = 20;
    //myConfigs[3].interval = 4000;
    //myConfigs[3].intervalDelta = -100;
    //myConfigs[3].exposureOffset = -2;
    //myConfigs[3].exposureFstopChangePerMin = 0;
	//myConfigs[3].fstopSinAmplitude = 0;
    //myConfigs[3].fstopIncreasePerHDRShot = 0;
    //myConfigs[3].numHDRShots = 0;
	//myConfigs[3].fstopChangeOnPress = 0;
	
	numConfigs = 2;
}

void enableADC() {
	sbi(ADCSRA, ADEN);
}

void disableADC() {
	cbi(ADCSRA, ADEN);
}

void printBatteryLevel() {
	analogReference(INTERNAL);
	
	enableADC(); // TODO we may need to give some time to get this value to stabilize
	
	//delay(100);
	
	//pinMode(3, OUTPUT);
	//digitalWrite(3,HIGH);
	
	pinMode(enableBatteryMonitorPin, OUTPUT);
	digitalWrite(enableBatteryMonitorPin, HIGH);
	
	
	// need to throw out the first reading after enabling the ADC
	uint16_t adcReading = analogRead(batteryMonitorPin);
	adcReading = analogRead(batteryMonitorPin);
	int batLevel = (adcReading - ADC_EMPTY_VOLTAGE)/(ADC_FULL_VOLTAGE - ADC_EMPTY_VOLTAGE);
	
	//DebugPrint("Min BAT ADC: ");
	//DebugPrintln(ADC_EMPTY_VOLTAGE);
	//DebugPrint("Max BAT ADC: ");
	//DebugPrintln(ADC_FULL_VOLTAGE);
	//DebugPrint("Battery reading: ");
	DebugPrintln(adcReading);
	pinMode(enableBatteryMonitorPin, INPUT);
	digitalWrite(enableBatteryMonitorPin, LOW);
	
	disableADC();
}

uint16_t
getBatteryLevel() {
	analogReference(INTERNAL);
	
	enableADC();
	
	// When the VCC line is tied to a AVR pin. Not done in alpha
	pinMode(enableBatteryMonitorPin, OUTPUT);
	digitalWrite(enableBatteryMonitorPin, HIGH);
	
	// need to throw out the first reading after enabling the ADC
	uint16_t adcReading = analogRead(batteryMonitorPin);
	adcReading = analogRead(batteryMonitorPin);
	
	disableADC();
	
	pinMode(enableBatteryMonitorPin, INPUT);
	digitalWrite(enableBatteryMonitorPin, LOW);
	
	return adcReading;
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
	
	//for (int i = 0; i < cycle.NumLedPositions; i++) {
		//DebugPrint(F("R G B "));
		//DebugPrint(cycle.ColorCycle[0].red);
		//DebugPrint(cycle.ColorCycle[0].green);
		//DebugPrintln(cycle.ColorCycle[0].blue);
	//}
}

// Needed for external interrupt waking from power down
void ButtonChange(void) {}
void CableSenseChange(void) {}

void InitIdleState() {
    currentState = STATE_IDLE;
	
    SetLEDCycle(LED_CYCLE_OFF);
	
	disableADC();
}

void ProcessIdle();

void setup() {
	
	// TEMP for power testing
	//currentState = STATE_IDLE;
	//disableADC();
	//ProcessIdle();
	printTimer = millis();
	incrementTimer = millis();
	
	DebugInit();
	
	pinMode(buttonPin, INPUT);
	digitalWrite(buttonPin, HIGH);
	
    pinMode(shutterPin, OUTPUT);
    digitalWrite(shutterPin, LOW);
    pinMode(focusPin, OUTPUT);
    digitalWrite(focusPin, LOW);
    
    pinMode(flashFeedbackPin, INPUT);
    //digitalWrite(flashFeedbackPin, HIGH); // This will suck power if always on
    
	pinMode(useIdlePin, INPUT);
	digitalWrite(useIdlePin, HIGH);
	
	// not currently used
	//pinMode(FSK_INPUT_FILTER_ENABLE_PIN, OUTPUT);
	//digitalWrite(FSK_INPUT_FILTER_ENABLE_PIN, HIGH);
	
    //delay(20);
	
	nextLedTime = millis();
    
	populateConfigs();
	
	analogReference(INTERNAL);
	
	// Set LEDs to output
	pinMode(redLed, OUTPUT);
	pinMode(greenLed, OUTPUT);
	pinMode(blueLed, OUTPUT);
	
    InitIdleState();
	//InitManualTimelapseState();
	SetLED(OFF);
	
	SetLEDCycle(LED_CYCLE_START);
	
	printBatteryLevel();
	
	printTimer = millis();
	incrementTimer = millis();
	incrementCount = 0;
	
	timelapseValid = true;
	
	initFromEEProm();
}

extern uint32_t nextPhotoTime;
extern uint32_t shutterOffTime;

void ProcessIdle() {

    // By default power down
    set_sleep_mode(SLEEP_MODE_PWR_DOWN);

    switch (currentState) {
		case STATE_TIMELAPSE_WAITING_FLASH: // TODO: can we drop to low power and attach interrupt to flash pin?
		case STATE_TRANSMIT: //  TODO: can we drop to idle mode with a timer
		case STATE_TIMELAPSE_MANUAL_TRANSMIT:
		    // Dont Idle in these states
		    return;
			break;
        case STATE_TIMELAPSE_WAITING:
			uint32_t tempWakeTime;
		
			tempWakeTime = nextPhotoTime;
			// TODO set one of our T2 output compare flags to interrupt sooner.
			if (boolDeviceSettings.enableHighResShotTimer) {
				tempWakeTime -= (MILLIS_PER_OVERFLOW * 2);
			}
		
		    if (millis() > tempWakeTime) {
				return;
			} else {
				set_sleep_mode(SLEEP_MODE_PWR_SAVE);
			}
			break;
		case STATE_TIMELAPSE_EXPOSING:
			// Need precision on shutter off
			if (millis() > (shutterOffTime - (MILLIS_PER_OVERFLOW * 2))) {
				return;
			} else {
				set_sleep_mode(SLEEP_MODE_PWR_SAVE);
			}
			break;
        case STATE_TIMELAPSE_PAUSE:
		    // We will check LED state before actually going to idle here
		    set_sleep_mode(SLEEP_MODE_PWR_SAVE);
			break;
		case STATE_IDLE:
		case STATE_TIMELAPSE_MANUAL:
			break;
		case STATE_INVALID:
		default:
			//DebugPrintln("Process Idle: Unrecognized state");
			return;
	}

    if (currentLedCycle.NumLedPositions != 0) {
		
		if (AreColorsEqual(currentLedCycle.ColorCycle[ledCycleIndex],OFF)) {
			// Up to a 10 ms variance depending on next overflow and startup time
			if (millis() > nextLedTime) {
			//	DebugPrint("Led Soon");
				return;
			} else {
				//DebugPrint("Led off");
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

	Serial.flush();

    // If we've made it this far, we can idle!
    attachInterrupt(0,ButtonChange,CHANGE);
    sleep_enable();
	sleep_bod_disable();
    sleep_cpu();
    sleep_disable();
    detachInterrupt(0);
}

extern uint32_t idleTimer;

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
		
		//DebugPrint("button change");
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
					    if (millis() - buttonPressTime > BUTTON_STOP_TIMELAPSE_PERIOD) {
							DebugPrintln(F("Abandon Timelapse"));
							SetLEDCycle(LED_CYCLE_TIMELAPSE_ABANDON);
							InitTransmitState();
						} else {							
			                TimelapseResume();
						}	
					    
						break;
		            case STATE_IDLE:
                        if (millis() - buttonPressTime > BUTTON_TRANSMIT_PERIOD) {
			                InitTransmitState();
							SetLEDCycle(LED_CYCLE_START_PROGRAM);
                        } else {
							// Send to idle state after we finish the current exposure
							if (timelapseValid && numConfigs > 0) {
								InitTimelapseState(0);
							} else {
								SetLEDCycle(LED_CYCLE_TIMELAPSE_INVALID);
							}																
                        }                                                        
			            break;
                    case STATE_TRANSMIT:
						if (millis() - buttonPressTime > BUTTON_TRANSMIT_PERIOD) {
							idleTimer = millis();
                        } else {
							if (timelapseValid) {
								InitTimelapseState(0);
							} else {
								InitIdleState();
								SetLEDCycle(LED_CYCLE_TIMELAPSE_INVALID);
							}
						}							
                        break;
					case STATE_TIMELAPSE_MANUAL:
						EndExposure();
						//delay(200); // Idle if we need to keep a pin high during transmit
						InitTransmitState();
						break;
					case STATE_INVALID:
					default:
						DebugPrint(F("Unknown state "));
						DebugPrintln(currentState);
						break;
	            }
            } else {
                buttonPressTime = millis();
				switch (currentState) {
				case STATE_TIMELAPSE_MANUAL_TRANSMIT:
					LeaveTransmitState();
					// FALL THROUGH
				case STATE_TIMELAPSE_MANUAL:
					StartExposure();
					break;
				}					
            }
        }    
    }  

    // save the reading.  Next time through the loop,
    // it'll be the lastButtonState:
    lastButtonState = reading;
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
					return;
				}					
			}
			
			SetLED(currentLedCycle.ColorCycle[ledCycleIndex]);
			
			nextLedTime += currentLedCycle.TimePerLed;
		}
	}	
}

void loop() {
	
    ProcessButton();
    
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
		case STATE_TIMELAPSE_MANUAL_TRANSMIT:
		    ProcessTransmitState();
			break;
		case STATE_IDLE:
		case STATE_TIMELAPSE_MANUAL:
			break;
		case STATE_INVALID:
		default:
			//DebugPrint("loop: unrecognized state ");
			//DebugPrintln(currentState, HEX);
			break;
    }        
	
	ProcessLEDCycle();
	
	if (Serial.available()) {
		uint8_t incByte = Serial.read();
		uint8_t temp;
		switch (incByte) {
			case 'p':
				// dump our shots
				DebugPrint(F("num configs: "));
				DebugPrintln(numConfigs);
				for (int i = 0; i < numConfigs; i++) {
					DebugPrint("config #");
					DebugPrintln(i);
					PrintSectionConfig(myConfigs[i]);	
				}
				
				break;
			case 't':
				// dump the current millis() value
				DebugPrint(F("millis() = "));
				DebugPrintln(millis());
				break;
			case 'b':
				printBatteryLevel();
				break;
			case 'r':
				//
				temp = eeprom_read_byte(0);
				DebugPrint("temp eeprom: ");
				DebugPrintln(temp);
				break;
			case 'w':
				eeprom_write_byte(0, 5);
				break;
			case 'i':
				// initialize from our default settings
				populateConfigs();
			case 13:
			case 10:
				// new line characters
				break;
			default:
				DebugPrint(F("Unrecognized command "));
				DebugPrintln(incByte);
		}
	}
	
	if (boolDeviceSettings.enableIdle) {
		ProcessIdle();
	}
	
	//if (millis() > incrementTimer) {
		//incrementCount++;
		//incrementTimer = millis() + 5;
	//}
	//
	//if (millis() > printTimer) {
		//uint32_t printplus = ((uint32_t) 1000) * 10 * 60;
		//printTimer += printplus;
		//printBatteryLevel();
		////digitalWrite(greenLed, HIGH);
	//}
	
}