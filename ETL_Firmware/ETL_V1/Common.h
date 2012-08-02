    /*
 * Common.h
 *
 * Contains definitions used by both web app and firmware
 *
 * Created: 4/5/2012 11:59:07 AM
 *  Author: brandonw
 */ 

#include "crc.h"

#ifndef COMMON_H_
#define COMMON_H_

#ifndef byte
typedef uint8_t byte;
#endif

#ifndef cbi
#define cbi(sfr, bit) (_SFR_BYTE(sfr) &= ~_BV(bit))
#endif
#ifndef sbi
#define sbi(sfr, bit) (_SFR_BYTE(sfr) |= _BV(bit))
#endif

// bit feilds
enum {
 CONFIG_PAUSE = 0,
 CONFIG_PRESS_TO_ADVANCE = 1,
 CONFIG_PRESS_TO_DERAMP = 2,
 CONFIG_PRESS_TO_PAUSE = 3,
 CONFIG_SIN_BYTE1 = 6,
 CONFIG_SIN_BYTE2 = 7,
};

#define CONFIG_SIN_MASK (_BV(CONFIG_SIN_BYTE2) | _BV(CONFIG_SIN_BYTE1))
#define CONFIG_SIN_P1   (0)
#define CONFIG_SIN_P2   (_BV(CONFIG_SIN_BYTE1))
#define CONFIG_SIN_P3   (_BV(CONFIG_SIN_BYTE2))
#define CONFIG_SIN_P4   (_BV(CONFIG_SIN_BYTE2) | _BV(CONFIG_SIN_BYTE1))

#define MAX_CONFIGS 10

enum deviceCommands {
	ETL_COMMAND_INVALID = 0,
	ETL_COMMAND_SETTINGS,
	ETL_COMMAND_BASICTIMELAPSE,
	ETL_COMMAND_BULBRAMP,
	ETL_COMMAND_INTERVALRAMP,
	ETL_COMMAND_HDRSHOT,
	ETL_COMMAND_GETDEVICEINFO,
	ETL_COMMAND_MANUALMODE,
	ETL_COMMAND_SIGNOFF
};

#define PACKED __attribute__((__packed__))

typedef struct {
	uint32_t staticShutterLag;
	uint8_t  configSections;
} PACKED DeviceSettings;

typedef struct {
	uint32_t shots;
	uint32_t interval;
	float    exposureLengthPower;
} PACKED BasicTimelapse;

typedef struct {
	float     exposureFstopChangePerMin;
    float     fstopSinAmplitude;
	int8_t    fstopChangeOnPress;
	uint8_t    sinPhase;
} PACKED BulbRamp;

typedef struct {
	uint32_t   intervalDelta;
    uint16_t   numRepeats;
    int8_t     repeatIndex;
	uint8_t	   changeConfigInfo;
} PACKED IntervalRamp;

typedef struct {
	float      fstopIncreasePerHDRShot;
    uint8_t    numHDRShots; // This is in addition to the initial exposure, eg value of 4 would result in 5 shots per bracket
} PACKED HDRShot;

typedef struct {
	crc_t crc;
	uint8_t command;
	uint8_t packetId;
	union {
		DeviceSettings deviceSettings;
		BasicTimelapse basicTimelapse;
		BulbRamp       bulbRamp;
		IntervalRamp   intervalRamp;
		HDRShot        hdrShot;
	};
} PACKED VariablePacket;

// TODO remove
typedef struct {
 uint8_t    type;
 int8_t     repeatIndex;
 uint16_t   numRepeats;
 uint32_t   shots;
 int32_t   interval;
 int32_t   intervalDelta;
 float      exposureOffset;
 float      exposureFstopChangePerMin;
 float     fstopSinAmplitude;
 float      fstopIncreasePerHDRShot;
 uint8_t    numHDRShots; // This is in addition to the initial exposure, eg value of 4 would result in 5 shots per bracket
 int8_t    fstopChangeOnPress;
} PACKED SectionConfig;

enum iosCommands {
	IOS_COMMAND_INVALID = 0,
	IOS_COMMAND_REQUESTPACKETID,
	IOS_COMMAND_DEVICEINFO
};

typedef struct {
	uint8_t majorVersion;
	uint8_t minorVersion;
	uint8_t batteryLevel;
} PACKED DeviceInfo;

typedef struct {
    crc_t crc;
	uint8_t command;
	uint8_t packetId; // TODO this is actually next packet we want, should we move this into the union?
	union {
		DeviceInfo deviceInfo;
	};
} PACKED IPhonePacket;

// this is a test

#endif /* COMMON_H_ */