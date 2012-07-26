/*
 * ETL_V1.cpp
 *
 * Created: 3/29/2012 11:34:34 AM
 *  Author: brandonw
 */ 

#include <avr/io.h>
#include "Arduino/Arduino.h"
#include "Arduino/HardwareSerial.h"
#include "Utils.h"
#include "Common.h"
#include "ETL_V1.h"
#include "crc.h"
#include "communications.h"
#include "camera.h"

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

void populateConfigs() {
    //myConfigs[0].type = CONFIG_SIN_P4
	myConfigs[0].type = 0;
    myConfigs[0].repeatIndex = 0;
    myConfigs[0].numRepeats = 0;
    myConfigs[0].shots = 2;
    myConfigs[0].interval = 5000;
    myConfigs[0].intervalDelta = 0;
    //myConfigs[0].exposureOffset = -2.841463415;
	myConfigs[0].exposureOffset = -2;
    myConfigs[0].exposureFstopChangePerMin = 0;
	//myConfigs[0].fstopSinAmplitude = 0.158536585;
	myConfigs[0].fstopSinAmplitude = 0;
    myConfigs[0].fstopIncreasePerHDRShot = 2;
    myConfigs[0].numHDRShots = 1;
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
	
	numConfigs = 1;
}

void enableADC() {
	sbi(ADCSRA, ADEN);
}

void disableADC() {
	cbi(ADCSRA, ADEN);
}

void printBatteryLevel() {
	enableADC(); // TODO we may need to give some time to get this value to stabilize
	
	pinMode(3, OUTPUT);
	digitalWrite(3,HIGH);
	
	pinMode(enableBatteryMonitorPin, OUTPUT);
	digitalWrite(enableBatteryMonitorPin, HIGH);
		
	uint8_t adcReading = analogRead(batteryMonitorPin);
	int batLevel = (adcReading - ADC_EMPTY_VOLTAGE)/(ADC_FULL_VOLTAGE - ADC_EMPTY_VOLTAGE);
	
	//DebugPrint("Min BAT ADC: ");
	//DebugPrintln(ADC_EMPTY_VOLTAGE);
	//DebugPrint("Max BAT ADC: ");
	//DebugPrintln(ADC_FULL_VOLTAGE);
	//DebugPrint("Current: ");
	//DebugPrintln(adcReading);
    //DebugPrint("Percent: ");
	pinMode(enableBatteryMonitorPin, INPUT);
	digitalWrite(enableBatteryMonitorPin, LOW);
	
	disableADC();
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
	disableADC();
    DebugPrintln("Enter Idle");
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
	
	printTimer = millis();
	incrementTimer = millis();
	incrementCount = 0;
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
		    if (millis() > (nextPhotoTime - (MILLIS_PER_OVERFLOW * 2))) {
				return;
			} else {
				set_sleep_mode(SLEEP_MODE_PWR_SAVE);
			}
			break;
		case STATE_TIMELAPSE_EXPOSING:
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
			if (millis() > (nextLedTime - (MILLIS_PER_OVERFLOW * 2))) {
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
					case STATE_TIMELAPSE_MANUAL:
						EndExposure();
						InitTransmitState();
						break;
					case STATE_INVALID:
					default:
						DebugPrint("Unknown state ");
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
		
		switch (incByte) {
			case 'p':
				// dump our shots
				DebugPrint("num configs: ");
				DebugPrintln(numConfigs);
				for (int i = 0; i < numConfigs; i++) {
					DebugPrint("config #");
					DebugPrintln(i);
					PrintSectionConfig(myConfigs[i]);	
				}
				
				break;
			case 't':
				// dump the current millis() value
				DebugPrint("millis() = ");
				DebugPrintln(millis());
				break;
			default:
				DebugPrint("Unrecognized command ");
				DebugPrintln(incByte);
		}
	}
	
	//if (digitalRead(useIdlePin) == LOW) {
		//ProcessIdle();
	//}
	
	//if (millis() > incrementTimer) {
		//incrementCount++;
		//incrementTimer = millis() + 5;
	//}
	//
	//if (millis() > printTimer) {
		//printTimer += 2000;
		//DebugPrintln(incrementCount);
		//incrementCount = 0;
	//}
	
}