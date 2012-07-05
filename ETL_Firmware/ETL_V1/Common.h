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

enum {
 CONFIG_PAUSE = 0,
 CONFIG_LOOP_BEGIN,
 CONFIG_LOOP_END,
 CONFIG_PRESS_TO_ADVANCE
};

#define CONFIG_SIN_MASK (_BV(7) | _BV(6))
#define CONFIG_SIN_P1   (0)
#define CONFIG_SIN_P2   (_BV(6))
#define CONFIG_SIN_P3   (_BV(7))
#define CONFIG_SIN_P4   (_BV(7) | _BV(6))

#define MAX_CONFIGS 5

enum commands {
	COMMAND_INVALID,
	COMMAND_BEGIN
};

typedef struct {
	crc_t Crc;
	byte command;
	byte data;
} __attribute__((__packed__)) CommandPacket;

typedef struct {
	uint32_t StaticShutterLag;
	uint8_t  ConfigSections;
} __attribute__((__packed__)) DeviceSettings;

typedef struct {
	uint32_t shots;
	uint32_t interval;
	float    exposureLengthPower;
} __attribute__((__packed__)) BasicTimelapse;

typedef struct {
	float     exposureFstopChangePerMin;
    float     fstopSinAmplitude;
	int8_t    fstopChangeOnPress;
} __attribute__((__packed__)) BulbRamp;

typedef struct {
	uint32_t   intervalDelta;
    int8_t     repeatIndex;
    uint16_t   numRepeats;
} __attribute__((__packed__)) IntervalRamp;

typedef struct {
	float      fstopIncreasePerHDRShot;
    uint8_t    numHDRShots; // This is in addition to the initial exposure, eg value of 4 would result in 5 shots per bracket
} __attribute__((__packed__)) HDRShot;

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
} __attribute__((__packed__)) VariablePacket;

typedef struct {
 uint8_t    type;
 int8_t     repeatIndex;
 uint16_t   numRepeats;
 uint32_t   shots;
 uint32_t   interval;
 uint32_t   intervalDelta;
 float      exposureOffset;
 float      exposureFstopChangePerMin;
 float     fstopSinAmplitude;
 float      fstopIncreasePerHDRShot;
 uint8_t    numHDRShots; // This is in addition to the initial exposure, eg value of 4 would result in 5 shots per bracket
 int8_t    fstopChangeOnPress;
} __attribute__((__packed__)) SectionConfig;

typedef struct  {
	crc_t Crc;
	SectionConfig SectConf;
} __attribute__((__packed__)) ETlModemPacket;



// this is a test

#endif /* COMMON_H_ */