/*
 * communications.cpp
 *
 * Created: 7/11/2012 1:55:23 PM
 *  Author: brandonw
 */ 

#include "ETL_V1.h"
#include "communications.h"
#include "Arduino/Arduino.h"
#include "SoftModem.h"
#include "Utils.h"
#include "camera.h"

SoftModem modem;
VariablePacket recvPacket;

extern uint8_t currentState;
extern uint32_t nextLedTime;

uint32_t printTimer = 0;
byte printval;

uint8_t crcErrors;
uint8_t idleRetryCount;
uint8_t bytesRead = 0;
size_t modemPacketIndex = 0;

// For testing retry
uint8_t sendExtraByte;

bool firstPacketReceived;

extern SectionConfig myConfigs[MAX_CONFIGS];
extern uint8_t numConfigs;
extern uint8_t configPointer;
extern uint8_t timelapseValid;
extern uint32_t bulbModeShutterLag;

uint32_t idleTimer;

void InitTransmitState() { 
	sendExtraByte = 1;
	firstPacketReceived = false;
	switch (currentState) {
		case STATE_IDLE:
		case STATE_TIMELAPSE_WAITING:
			currentState = STATE_TRANSMIT;
			break;
		case STATE_TIMELAPSE_MANUAL:
			currentState = STATE_TIMELAPSE_MANUAL_TRANSMIT;
			break;
	}
		
    DebugPrintln(F("Enter Transmit"));
	
	// This is our unused audio channel. This must go to ground otherwise something
	// weird happens electrically. We could probably use the P/U resistor too.
	pinMode(focusPin, OUTPUT);
	digitalWrite(focusPin, HIGH);
	
	pinMode(fskVCCFitlerPin, OUTPUT);
	digitalWrite(fskVCCFitlerPin, HIGH);
	
    modemPacketIndex = 1;
	bytesRead = 0;
	modem.begin();
	printTimer = millis();
	printval = 'A';
	
	configPointer = 0;
	
	crcErrors = 0;
	idleRetryCount = 0;
	
	//
	// Send our begin packet
	//
	
	IPhonePacket startPacket;
    memset(&startPacket, 0, sizeof(IPhonePacket));
	startPacket.command = IOS_COMMAND_DEVICEINFO;
	startPacket.packetId = 0x1;

	startPacket.deviceInfo.batteryLevel = 0;
	startPacket.deviceInfo.majorVersion = 1;
	startPacket.deviceInfo.minorVersion = 1;

    startPacket.crc = crc_init();
	startPacket.crc = crc_update(startPacket.crc, &startPacket.command, sizeof(startPacket) - sizeof(crc_t));
	startPacket.crc = crc_finalize(startPacket.crc);
	
	modem.writeBytes((uint8_t *) &startPacket, sizeof(startPacket));
	
	idleTimer = millis();
}

void LeaveTransmitState() {
	modem.end();
	switch (currentState) {
	case STATE_TRANSMIT:
		InitIdleState();	
		break;
	case STATE_TIMELAPSE_MANUAL_TRANSMIT:
		InitManualTimelapseState();
		break;
	default:
		DebugPrintln(F("Bad attempt to leave transmit state"));
	}
}

void InitRequestPacket(IPhonePacket *packet, uint8_t requestId) {
	memset(packet, 0, sizeof(IPhonePacket));
	
	packet->command = IOS_COMMAND_REQUESTPACKETID;
	packet->packetId = requestId;

    packet->crc = crc_init();
	packet->crc = crc_update(packet->crc, ((uint8_t *) packet) + sizeof(crc_t), sizeof(IPhonePacket) - sizeof(crc_t));
	packet->crc = crc_finalize(packet->crc);
}

void ProcessTransmitState() {
	
	//modem.flushBuffer(1)
	
	while(modem.available()) {

        ((char *) &recvPacket)[bytesRead] = modem.read();
        bytesRead++;
		
		//DebugPrintln(((char *) &recvPacket)[bytesRead]);
		
		if (bytesRead >= 16) {
			IPhonePacket sendPacket;
			
			memset(&sendPacket, 0, sizeof(IPhonePacket));
			
			bytesRead = 0;
			idleRetryCount = 0;
		
            crc_t myCrc = crc_init();
		    myCrc = crc_update(myCrc, (byte*) &recvPacket + sizeof(crc_t), sizeof(recvPacket) - sizeof(crc_t));
		    myCrc = crc_finalize(myCrc);
					
		    DebugPrintln(F(" command packetId: "));
		    DebugPrintln(recvPacket.command, HEX);
		    DebugPrintln(recvPacket.packetId, HEX);
					
		    bool failCrc = false;
					
		    //if (random(2) == 0) {
			    //failCrc = true;
			    //DebugPrintln("force fail crc");
		    //}
					
		    if (myCrc != recvPacket.crc || failCrc) {
			    DebugPrintln(F("Crc mismatch!"));
				SetLEDCycle(LED_CYCLE_CRC_MISMATCH);
				
			    DebugPrint(F(" recv_crc = "));
			    DebugPrint(recvPacket.crc, HEX);
                DebugPrint(F(" calc_Crc = "));
			    DebugPrintln(myCrc, HEX);
			    
				//DebugPrint("Shots: ");
				//DebugPrintln(recvPacket.basicTimelapse.shots);
				//DebugPrint("exposure: ");
				//DebugPrintln(recvPacket.basicTimelapse.exposureLengthPower);
				//DebugPrint("interval: ");
				//DebugPrintln(recvPacket.basicTimelapse.interval);
			    //DebugPrintln();
				
				// TODO for now we always request a packet, need specifc retry code here
				
				crcErrors++;
				
				if (crcErrors >= CRC_ERRORS_TO_ABANDON) {
					LeaveTransmitState();
					DebugPrintln(F("CRC errors exceeded"));
					SetLEDCycle(LED_CYCLE_PROGRAM_FAILURE);
					return;
				}
				
				if ((crcErrors % CRC_ERRORS_TO_CLEAR_BUFFER) == 0) {
					DebugPrintln(F("CRC errors - clear buffer"));
					// wait 500 ms then clear out the buffer
					delay(500);
					
					while (modem.available()) {
						modem.read();
					}
					
					SetLEDCycle(LED_CYCLE_PROGRAM_CLEAR_BUFFER);
				}
				
				InitRequestPacket(&sendPacket, modemPacketIndex);
				
		    } else {
				crcErrors = 0;
				
			    DebugPrint(F("packet success; crc = "));
				DebugPrintln(myCrc, HEX);
			    DebugPrintln();				
					
			    if (modemPacketIndex == recvPacket.packetId) {
					SetLEDCycle(LED_CYCLE_CRC_MATCH);
					modemPacketIndex++; 
					InitRequestPacket(&sendPacket, modemPacketIndex);
					
					if (firstPacketReceived == false) {
						firstPacketReceived = true;
						
						memset(&myConfigs[0], 0, sizeof(SectionConfig) * MAX_CONFIGS);
						numConfigs = 0;
						timelapseValid = false;
						currentState = STATE_TRANSMIT; // If we were in manual mode
					}
					
				    switch (recvPacket.command) {
	            
	                case ETL_COMMAND_SETTINGS:
						bulbModeShutterLag = recvPacket.deviceSettings.staticShutterLag;
				        break;
	                case ETL_COMMAND_BASICTIMELAPSE:						
				        myConfigs[configPointer].shots = recvPacket.basicTimelapse.shots;
					    myConfigs[configPointer].exposureOffset = recvPacket.basicTimelapse.exposureLengthPower;
					    myConfigs[configPointer].interval = recvPacket.basicTimelapse.interval;
				        // Increment to the next config. basic MUST come last
					    // TODO dump to EEPROM here
					    configPointer++;
					    numConfigs = configPointer;
				        break;
	                case ETL_COMMAND_BULBRAMP:
				        myConfigs[configPointer].exposureFstopChangePerMin = recvPacket.bulbRamp.exposureFstopChangePerMin;
					    myConfigs[configPointer].fstopChangeOnPress = recvPacket.bulbRamp.fstopChangeOnPress;
					    myConfigs[configPointer].fstopSinAmplitude = recvPacket.bulbRamp.fstopSinAmplitude;
						myConfigs[configPointer].type |= recvPacket.bulbRamp.sinPhase;
				        break;
	                case ETL_COMMAND_INTERVALRAMP:
				        myConfigs[configPointer].intervalDelta = recvPacket.intervalRamp.intervalDelta;
					    myConfigs[configPointer].numRepeats = recvPacket.intervalRamp.numRepeats;
					    myConfigs[configPointer].repeatIndex = recvPacket.intervalRamp.repeatIndex;
						myConfigs[configPointer].type |= recvPacket.intervalRamp.changeConfigInfo;
				        break;
	                case ETL_COMMAND_HDRSHOT:
				        myConfigs[configPointer].fstopIncreasePerHDRShot = recvPacket.hdrShot.fstopIncreasePerHDRShot;
					    myConfigs[configPointer].numHDRShots = recvPacket.hdrShot.numHDRShots;
				        break;
					case ETL_COMMAND_GETDEVICEINFO:
						// TODO populate and send device info
						DebugPrintln("device info");
						break;
					case ETL_COMMAND_MANUALMODE:
						// Can probably signoff here
						currentState = STATE_TIMELAPSE_MANUAL_TRANSMIT;
						break;
					case ETL_COMMAND_SIGNOFF:
						DebugPrintln(F("programming complete!"));
						timelapseValid = true;
						LeaveTransmitState();
						dumpToEEProm();
						SetLEDCycle(LED_CYCLE_END_PROGRAM);
						
						return;
						break;
				    case ETL_COMMAND_INVALID:
				    default:
				        DebugPrint(F("unrecognized command: "));
					    DebugPrintln(recvPacket.command, HEX);
				    }	
			    } else {
					DebugPrintln(F("Dont need this packet"));
				    InitRequestPacket(&sendPacket, modemPacketIndex);
					SetLEDCycle(LED_CYCLE_WRONG_PACKET);
				}					
		    }
		
		
			// need to make sure iphone is ready to receive again
			// this should be async. Interferes with ability to do manual shots
			// or ideally we will fix iphone so it can send receive simulteneously...
		    delay(100);
	        modem.writeBytes((uint8_t *) &sendPacket, sizeof(sendPacket));
			
			nextLedTime = millis(); // TEMP so we still flash after these sync processing
        }
		idleTimer = millis();
	}
	
	if (millis() > idleTimer + IDLE_RETRY_PERIOD) {
		
		idleRetryCount++;
		idleTimer = millis();
		
		if (idleRetryCount > MAX_IDLE_RETRY_COUNT) {
			DebugPrintln(F("Idle timeout"));
			LeaveTransmitState();
			return;
		}

		DebugPrintln("Retry packet");
		IPhonePacket sendPacket;
			
		InitRequestPacket(&sendPacket, modemPacketIndex);
		modem.writeBytes((uint8_t *) &sendPacket, sizeof(sendPacket));
	}
}

void ProcessTransmitStateTest() {
	
	//if (millis() > printTimer) {
	    ////modem.write(printval);
		////printval++;
		////printTimer += 5000;
		//
		//modem.printDebugInfo(1);
	//}
	
	while(modem.available()) {
        //byte myByte = modem.read();
		
		//DebugPrint("byte:");
		//DebugPrintln(myByte, HEX);
		
		//printTimer = millis() + 3000;
	}		
}