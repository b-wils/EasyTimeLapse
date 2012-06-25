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

struct CommandPacket {
	crc_t Crc;
	byte command;
	byte data;
};

struct SectionConfig {
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
};

struct ETlModemPacket {
	crc_t Crc;
	SectionConfig SectConf;
};

// this is a test

#endif /* COMMON_H_ */