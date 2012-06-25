//
//  etl_typedefs.h
//  etl_iphone_v1
//
//  Created by Inspired Eye on 5/23/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#ifndef etl_iphone_v1_etl_typedefs_h
#define etl_iphone_v1_etl_typedefs_h

#include "crc.h"

enum {
    CONFIG_PAUSE = 0,
    CONFIG_LOOP_BEGIN,
    CONFIG_LOOP_END,
    CONFIG_PRESS_TO_ADVANCE
};

#define MAX_CONFIGS 10

typedef struct CommandPacket {
	crc_t Crc;
	uint8_t Command;
	uint8_t Data;
} __attribute__((__packed__)) CommandPacket;

typedef struct SectionConfig {
    uint8_t    type;
    int8_t     repeatIndex;
    uint16_t   numRepeats;
    uint32_t   shots;
    uint32_t   interval;
    uint32_t   intervalDelta;
    float      exposureOffset;
    float      exposureFstopChangePerMin;
    float      fstopIncreasePerHDRShot;
    uint8_t    numHDRShots; // This is in addition to the initial exposure, eg value of 4 would result in 5 shots per bracket
	int8_t	   fstopChangeOnPress;
} __attribute__((__packed__)) SectionConfig;

typedef struct ETlModemPacket {
    crc_t Crc;
    SectionConfig SectConf;
}  __attribute__((__packed__)) ETlModemPacket;


void initEtlConfig(SectionConfig* config);

#endif
